#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e

cmake_args="
-DBLAS_LIBRARIES=$PREFIX/lib/libatlas.a
-DLAPACK_LIBRARIES=$PREFIX/lib/liblapack.a;$PREFIX/lib/libf77blas.a;$PREFIX/lib/libatlas.a
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_COLOR_MAKEFILE=OFF
-DCMAKE_EXE_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
-DCMAKE_INSTALL_PREFIX=$PREFIX
-DCMAKE_MODULE_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
"
jflag=-j4

mkdir build
cd build
cmake $cmake_args ..
make $jflag VERBOSE=1
make install

cd $PREFIX
