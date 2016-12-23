#! /bin/bash
# Copyright 2015-2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

export PATH="$PREFIX/lib/qt4/bin:$PATH"

(cd $PREFIX/include && ln -s xercesc28 xercesc) || exit 1
(cd $PREFIX/lib && ln -s libxerces-c.so.28.0 libxerces-c.so) || exit 1 # XXX: dylib on OSX

cmake_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_COLOR_MAKEFILE=OFF
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DPGPLOT_INCLUDE_DIRS=$PREFIX/include/pgplot
    -DQT_DBUSXML2CPP_EXECUTABLE=$PREFIX/lib/qt4/bin/qdbusxml2cpp
    -DQT_LIBRARY_DIR=$PREFIX/lib/qt4
    -DQT_MKSPECS_DIR=$PREFIX/share/qt4/mkspecs
    -DQT_RCC_EXECUTABLE=$PREFIX/lib/qt4/bin/rcc
    -DQWT_INCLUDE_DIRS=$PREFIX/include/qwt5
)

#cmake_args+=(--debug-trycompile --debug-output)

if [ -n "$OSX_ARCH" ] ; then
    # Need to require 10.7 because of the C++11 features.
    export MACOSX_DEPLOYMENT_TARGET=10.7

    cmake_args+=(
	-Darch=darwin64
	-Darchflag=x86_64
	-DCMAKE_CXX_FLAGS="-arch $OSX_ARCH -stdlib=libc++ -std=c++11"
	-DCMAKE_Fortran_COMPILER=/usr/local/bin/gfortran-4.2
	-DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET
	-DCMAKE_OSX_SYSROOT=/
	-DPGPLOT_LIBRARIES="$PREFIX/lib/libpgplot.dylib;$PREFIX/lib/libcpgplot.a"
	# Make sure to get Conda versions of libraries:
	-DLIBXML2_ROOT_DIR=$PREFIX
	-DLIBXSLT_ROOT_DIR=$PREFIX
	-DREADLINE_ROOT_DIR=$PREFIX
    )
else
    toolroot=/opt/rh/devtoolset-2/root

    cmake_args+=(
	-DBLAS_LIBRARIES="$PREFIX/lib/libopenblas.so"
	-DCMAKE_C_COMPILER=$toolroot/usr/bin/gcc
	-DCMAKE_CXX_COMPILER=$toolroot/usr/bin/g++
	-DCMAKE_EXE_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
	-DCMAKE_Fortran_COMPILER=$toolroot/usr/bin/gfortran
	-DCMAKE_MODULE_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
	-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
	-DLAPACK_LIBRARIES="$PREFIX/lib/libopenblas.so"
	-DPGPLOT_LIBRARIES="$PREFIX/lib/libpgplot.so;$PREFIX/lib/libcpgplot.a"
    )
fi

cd code
mkdir build
cd build
cmake "${cmake_args[@]}" ..
make -j$NJOBS VERBOSE=1

cd $PREFIX
rm -f casainit.* lib/casa/casainit.* makedefs
rm -f bin/t* bin/qwtplottertest # tests

# casabrowser as installed is a broken + pointless wrapper script around
# qcasabrowser. Shockingly, all other binaries appear to be usable as
# installed.
rm -f bin/casabrowser
ln -s qcasabrowser bin/casabrowser

if [ -n "$OSX_ARCH" ] ; then
    rm -rf apps
fi
