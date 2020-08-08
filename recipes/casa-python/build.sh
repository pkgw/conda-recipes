#! /bin/bash
# Copyright 2015-2020 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

# Java must be installed to build this package! Lame but not too hard to deal
# with.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -ex

export PATH="$PREFIX/qt4/bin:$PATH"

# Pre-build setup

pushd $PREFIX
ln -s xercesc28 include/xercesc

if [ $(uname) = Darwin ] ; then
    src=libxerces-c.28.0.dylib
else
    src=libxerces-c.so.28.0
fi

ln -s $src lib/libxerces-c$SHLIB_EXT
popd

# Ready to configure and make

pyvers=$(python -c 'from sys import version_info as v; print(f"{v.major}.{v.minor}")')

cmake_args=(
    -DCASA_PACKAGES=$PREFIX
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_COLOR_MAKEFILE=OFF
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_STATIC_LINKER_FLAGS=-L$PREFIX/lib
    -DPGPLOT_INCLUDE_DIRS=$PREFIX/include/pgplot
    -DPGPLOT_LIBRARIES="$PREFIX/lib/libpgplot$SHLIB_EXT;$PREFIX/lib/libcpgplot.a"
    -DPYTHON_LIBNAME="$pyvers"
    -DQT_DBUSXML2CPP_EXECUTABLE=$PREFIX/qt4/bin/qdbusxml2cpp
    -DQT_LIBRARY_DIR=$PREFIX/qt4/lib
    -DQT_MKSPECS_DIR=$PREFIX/qt4/mkspecs
    -DQT_RCC_EXECUTABLE=$PREFIX/qt4/bin/rcc
    -DQWT_INCLUDE_DIRS=$PREFIX/include/qwt5
    -DUseCrashReporter=OFF
)

#cmake_args+=(--debug-trycompile --debug-output --trace)

if [ $(uname) = Darwin ] ; then
    # The gcwrap CMakeLists.txt manipulates CMAKE_SHARED_LINKER_FLAGS and
    # friends such that we shouldn't set them directly. Fortunately the script
    # will honor $LDFLAGS.
    export LDFLAGS="-Wl,-rpath,$PREFIX/lib -L$PREFIX/lib $LDFLAGS"

    cmake_args+=(
        -Darch=darwin64
        -Darchflag=x86_64
        -DCMAKE_Fortran_COMPILER=$FC
    )
else
    # C++17 bans dynamic exceptions, which this codebase uses, so we need to
    # drop down to C++14
    export CXXFLAGS="$(echo $CXXFLAGS |sed -e 's/std=c..17/std=c++14/g')"
    export LDFLAGS="-Wl,-rpath-link,$PREFIX/lib $LDFLAGS"
fi

cmake_args+=(
    -DEXTRA_CXX_FLAGS="$CPPFLAGS $CXXFLAGS"
)

# The CXXFLAGS unset is needed to get EXTRA_CXX_FLAGS to take effect. I like
# how every CASA package handles C++ flags differently.
unset CXXFLAGS CFLAGS LINKFLAGS

cd gcwrap
mkdir build
cd build
# helps debugging:
env |sed -e 's/^/export /' -e "s/\([^=]*\)=/\1='/" -e "s/$/'/" |tr '\0' '\n' >ENVIRON.sh
cmake "${cmake_args[@]}" ..
make -j$NJOBS VERBOSE=1

# Post-install tidying.

pushd $PREFIX
rm bin/{buildmytasks,casa,xmlgenpy} lib/saxon*.jar

# if we keep the compat symlinks, conda thinks we installed these files:
rm -f lib/libxerces-c$SHLIB_EXT include/xercesc

# consistent include directories:
mv include/casa/* include/casacode/
rmdir include/casa

# CASA's task code is essentially impossible to use outside of the casapy
# environment, but it's nice to distribute the Python files for reference. So
# we install them into $PREFIX/share, where they're available but hopefully
# less confusing to the user.
#
# A task "foo" results in files named "foo.py", "task_foo.py", "foo_cli.py",
# and "foo_pg.py". Of these, only "task_foo.py" is of any interest.

pushd share/casa-python/tasks

for f in task_*.py ; do
    b=$(echo $f |sed -e 's/task_//' -e 's/\.py//')
    rm -f $b.py
done

rm -f *_pg.py
rm -f *_cli.py
chmod -x *.py

# CASA's bizarre plotting code automatically imports TablePlotTkAgg (from
# C++!) even without the casapy frontend.

mv TablePlotTkAgg.* TablePlotQt4Agg.* ../../../lib/python*/site-packages/

popd
popd
