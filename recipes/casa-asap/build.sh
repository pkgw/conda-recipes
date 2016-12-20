#! /bin/bash
# Copyright 2015-2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

cmake_args=(
    -DCASACORE_INCLUDE_DIR=$PREFIX/include/casacore
    -DCASACORE_PATHS=$PREFIX
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_COLOR_MAKEFILE=OFF
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_STATIC_LINKER_FLAGS=-L$PREFIX/lib
    -DCXX11=ON
    -DPGPLOT_INCLUDE_DIRS=$PREFIX/include/pgplot
    # Make sure to get Conda versions of libraries:
    -DLIBXML2_ROOT_DIR=$PREFIX
)

if [ -n "$OSX_ARCH" ] ; then
    # Need to require 10.7 because of the C++11 features.
    export MACOSX_DEPLOYMENT_TARGET=10.7

    cmake_args+=(
	-Darch=darwin64
	-Darchflag=x86_64
	-DALMA_LIB_PATH=$PREFIX/lib/libalma.dylib
	-DCMAKE_Fortran_COMPILER=/usr/local/bin/gfortran-4.2
	-DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET
	-DCMAKE_OSX_SYSROOT=/
	-DCXX_FLAGS_TAIL_END="-stdlib=libc++"
	-DFORTRAN_LIBRARIES="-lm" # pacify the Fortran checks
	-DPGPLOT_LIBRARIES="$PREFIX/lib/libpgplot.dylib;$PREFIX/lib/libcpgplot.a"
	-DPYTHON_INCLUDE_DIRS="$PREFIX/include/python2.7;$PREFIX/lib/python2.7/site-packages/numpy/core/include"
    )
else
    toolroot=/opt/rh/devtoolset-2/root

    cmake_args+=(
	-DALMA_LIB_PATH=$PREFIX/lib/libalma.so
	-DBLAS_LIBRARIES=$PREFIX/lib/libopenblas.so
	-DCMAKE_C_COMPILER=$toolroot/usr/bin/gcc
	-DCMAKE_CXX_COMPILER=$toolroot/usr/bin/g++
	-DCMAKE_EXE_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
	-DCMAKE_Fortran_COMPILER=$toolroot/usr/bin/gfortran
	-DCMAKE_MODULE_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
	-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
	-DLAPACK_LIBRARIES=$PREFIX/lib/libopenblas.so
	-DPGPLOT_LIBRARIES="$PREFIX/lib/libpgplot.so;$PREFIX/lib/libcpgplot.a"
    )
fi

cd asap
mkdir build
cd build
cmake "${cmake_args[@]}" ..
make -j$NJOBS VERBOSE=1
make install

cd $PREFIX
mkdir -p $SP_DIR
mv python/*/asap $SP_DIR
rm -rf share # asap/ipythonrc-asap

if [ -n "$OSX_ARCH" ] ; then
    # Conda's binary patchup step fails because we've moved the dylib, so
    # let's prevent that. Note that even though we're on OS X, the file
    # extension is indeed ".so".
    install_name_tool -id $SP_DIR/asap/_asap.so $SP_DIR/asap/_asap.so
fi
