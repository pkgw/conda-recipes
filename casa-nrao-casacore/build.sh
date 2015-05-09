#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e

# the CMAKE_CXX_FLAGS assignment is to avoid a default -pedantic flag that
# CASA applies which causes problems with the Numpy header files.

cmake_args="
-DBLAS_atlas_LIBRARY=$PREFIX/lib/libcblas.a;$PREFIX/lib/libatlas.a
-DBUILD_PYTHON=ON
-DBUILD_TESTING=OFF
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_COLOR_MAKEFILE=OFF
-DCMAKE_CXX_FLAGS=-Wall
-DCMAKE_INSTALL_PREFIX=$PREFIX
-DDATA_DIR=$PREFIX/share/casa-data
-DUSE_FFTW3=ON
-DUSE_HDF5=ON
-DUSE_THREADS=ON
"

cd casacore
mkdir build
cd build
cmake $cmake_args ..
make -j3 VERBOSE=1
make install

cd $PREFIX
rm -f casa_sover.txt bin/casacore_floatcheck bin/countcode
