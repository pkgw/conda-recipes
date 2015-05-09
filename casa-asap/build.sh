#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e

cmake_args="
-DALMA_LIB_PATH=$PREFIX/lib/libalma.so
-DBLAS_LIBRARIES=$PREFIX/lib/libatlas.a
-DLAPACK_LIBRARIES=$PREFIX/lib/libatlas.a
-DCASACORE_INCLUDE_DIR=$PREFIX/include/casacore
-DCASACORE_PATHS=$PREFIX
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_COLOR_MAKEFILE=OFF
-DCMAKE_EXE_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
-DCMAKE_INSTALL_PREFIX=$PREFIX
-DCMAKE_MODULE_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
-DCMAKE_STATIC_LINKER_FLAGS=-L$PREFIX/lib
-DPGPLOT_INCLUDE_DIRS=$PREFIX/include/pgplot
-DPGPLOT_LIBRARIES=$PREFIX/lib/libpgplot.so;$PREFIX/lib/libcpgplot.a
"

cd asap
mkdir build
cd build
cmake $cmake_args ..
make -j3 VERBOSE=1
make install

cd $PREFIX
mkdir -p $SP_DIR
mv python/*/asap $SP_DIR
