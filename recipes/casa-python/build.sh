#! /bin/bash
# Copyright 2015-2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

# Java must be installed to build this package! Lame but not too hard to deal
# with.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

# ??? on my builder, this is currently set to python3.5 even though everything
# else is configured for Python 2.7? And this didn't used to happen. Sigh.
export SP_DIR=$($PYTHON -c 'import site; print site.getsitepackages()[0]')

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

cmake_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_COLOR_MAKEFILE=OFF
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_STATIC_LINKER_FLAGS=-L$PREFIX/lib
    -DCXX11=ON
    -DPGPLOT_INCLUDE_DIRS=$PREFIX/include/pgplot
    -DQT_DBUSXML2CPP_EXECUTABLE=$PREFIX/qt4/bin/qdbusxml2cpp
    -DQT_LIBRARY_DIR=$PREFIX/qt4/lib
    -DQT_MKSPECS_DIR=$PREFIX/qt4/mkspecs
    -DQT_RCC_EXECUTABLE=$PREFIX/qt4/bin/rcc
    -DQWT_INCLUDE_DIRS=$PREFIX/include/qwt5
)

#cmake_args+=(--debug-trycompile --debug-output --trace)

if [ $(uname) = Darwin ] ; then
    # Fun fact: if you add a "-L$PREFIX/lib" argument here, the -L and the -Wl
    # arguments *disappear* from the link.txt files generated from CMake. If
    # you *don't* put in a -L argument, one appears. CMake, you so crazy!
    linkflags="-Wl,-rpath,$PREFIX/lib $LDFLAGS"

    cmake_args+=(
	-Darch=darwin64
	-Darchflag=x86_64
	-DCMAKE_Fortran_COMPILER=gfortran
	-DEXTRA_CXX_FLAGS="$CXXFLAGS -stdlib=libc++ -std=c++11"
	-DPGPLOT_LIBRARIES="$PREFIX/lib/libpgplot.dylib;$PREFIX/lib/libcpgplot.a"
    )
else
    toolroot=/opt/rh/devtoolset-2/root
    linkflags=-Wl,-rpath-link,$PREFIX/lib

    cmake_args+=(
	-DBLAS_LIBRARIES="$PREFIX/lib/libopenblas.so"
	-DCMAKE_C_COMPILER=$toolroot/usr/bin/gcc
	-DCMAKE_CXX_COMPILER=$toolroot/usr/bin/g++
	-DCMAKE_Fortran_COMPILER=$toolroot/usr/bin/gfortran
	-DEXTRA_CXX_FLAGS="$CXXFLAGS"
	-DLAPACK_LIBRARIES="$PREFIX/lib/libopenblas.so"
	-DPGPLOT_LIBRARIES="$PREFIX/lib/libpgplot.so;$PREFIX/lib/libcpgplot.a"
    )
fi

cmake_args+=(
    -DCMAKE_EXE_LINKER_FLAGS="$linkflags"
    -DCMAKE_MODULE_LINKER_FLAGS="$linkflags"
    -DCMAKE_SHARED_LINKER_FLAGS="$linkflags"
)

# The CXXFLAGS unset is needed to get EXTRA_CXX_FLAGS to take effect. I like
# how every CASA package handles C++ flags differently.
unset CXXFLAGS CFLAGS LDFLAGS LINKFLAGS

cd gcwrap
mkdir build
cd build
cmake "${cmake_args[@]}" ..
make -j$NJOBS VERBOSE=1

# Blow away a lot of files ... We need to keep TablePlotTkAgg.py since CASA's
# bizarre plotting code automatically imports it (from C++!) even without the
# casapy frontend. Fortunately things still seem to work even though much of
# the plotting stuff doesn't get hooked up and our matplotlib version is
# different (I think).

pushd $PREFIX
rm -rf xml
rm bin/{buildmytasks,casa,casapy,xmlgenpy} lib/saxon*.jar

# if we keep the compat symlinks, conda thinks we installed these files:
rm -f lib/libxerces-c$SHLIB_EXT include/xercesc

# consistent include directories:
mv include/casa/* include/casacode/
rmdir include/casa

mkdir -p $SP_DIR
casapydir=$(echo python/2.*)
for stem in __casac__ casac.py casadef.py TablePlotTkAgg.py ; do
    mv $casapydir/$stem $SP_DIR/
done
rm -rf python # note! not lib/python ...

popd
