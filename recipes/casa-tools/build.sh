#! /bin/bash
# Copyright 2015-2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

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
    -DPGPLOT_INCLUDE_DIRS=$PREFIX/include/pgplot
    -DQT_DBUSXML2CPP_EXECUTABLE=$PREFIX/qt4/bin/qdbusxml2cpp
    -DQT_LIBRARY_DIR=$PREFIX/qt4/lib
    -DQT_MKSPECS_DIR=$PREFIX/qt4/mkspecs
    -DQT_RCC_EXECUTABLE=$PREFIX/qt4/bin/rcc
    -DQWT_INCLUDE_DIRS=$PREFIX/include/qwt5
)

#cmake_args+=(--debug-trycompile --debug-output)

if [ $(uname) = Darwin ] ; then
    # Fun fact: if you add a "-L$PREFIX/lib" argument here, the -L and the -Wl
    # arguments *disappear* from the link.txt files generated from CMake. If
    # you *don't* put in a -L argument, one appears. CMake, you so crazy!
    linkflags="-Wl,-rpath,$PREFIX/lib $LDFLAGS"

    cmake_args+=(
	-Darch=darwin64
	-Darchflag=x86_64
	-DCMAKE_CXX_FLAGS="-arch $OSX_ARCH -stdlib=libc++ -std=c++11"
	-DCMAKE_Fortran_COMPILER=gfortran
	-DPGPLOT_LIBRARIES="$PREFIX/lib/libpgplot.dylib;$PREFIX/lib/libcpgplot.a"
	# Make sure to get Conda versions of libraries:
	-DLIBXML2_ROOT_DIR=$PREFIX
	-DLIBXSLT_ROOT_DIR=$PREFIX
	-DREADLINE_ROOT_DIR=$PREFIX
    )
else
    toolroot=/opt/rh/devtoolset-2/root
    linkflags=-Wl,-rpath-link,$PREFIX/lib

    cmake_args+=(
	-DBLAS_LIBRARIES="$PREFIX/lib/libopenblas.so"
	-DCMAKE_C_COMPILER=$toolroot/usr/bin/gcc
	-DCMAKE_CXX_COMPILER=$toolroot/usr/bin/g++
	-DCMAKE_CXX_FLAGS="-std=c++11"
	-DCMAKE_Fortran_COMPILER=$toolroot/usr/bin/gfortran
	-DLAPACK_LIBRARIES="$PREFIX/lib/libopenblas.so"
	-DPGPLOT_LIBRARIES="$PREFIX/lib/libpgplot.so;$PREFIX/lib/libcpgplot.a"
    )
fi

cmake_args+=(
    -DCMAKE_EXE_LINKER_FLAGS="$linkflags"
    -DCMAKE_MODULE_LINKER_FLAGS="$linkflags"
    -DCMAKE_SHARED_LINKER_FLAGS="$linkflags"
)

cd code
mkdir build
cd build
cmake "${cmake_args[@]}" ..
make -j$NJOBS VERBOSE=1

# Post-install tidying

pushd $PREFIX
rm -f casainit.* lib/casa/casainit.* makedefs
rm -f bin/t* bin/qwtplottertest # tests

# if we keep the compat symlinks, conda thinks we installed these files:
rm -f lib/libxerces-c$SHLIB_EXT include/xercesc

# casabrowser as installed is a broken + pointless wrapper script around
# qcasabrowser. Shockingly, all other binaries appear to be usable as
# installed.
rm -f bin/casabrowser
ln -s qcasabrowser bin/casabrowser

if [ $(uname) = Darwin ] ; then
    rm -rf apps
fi

popd
