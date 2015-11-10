#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e

# Downstream elements of the C++ code require C++11 to compile, and for binary
# compatibility we need to compile casacore with C++11 as well. We can do this
# even on a CentOS 5 machine thanks to the Red Hat "devtoolset" package.
# However, we still need to compile with stock gfortran, to maintain binary
# compatibility with the Conda FORTRAN stack. Fun times.

cmake_args="
-DBLAS_atlas_LIBRARY=$PREFIX/lib/libcblas.a;$PREFIX/lib/libatlas.a
-DBUILD_PYTHON=ON
-DBUILD_TESTING=OFF
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_C_COMPILER=/usr/bin/gcc
-DCMAKE_COLOR_MAKEFILE=OFF
-DCMAKE_CXX_COMPILER=/opt/rh/devtoolset-2/root/usr/bin/g++
-DCMAKE_Fortran_COMPILER=/usr/bin/gfortran
-DCMAKE_INSTALL_PREFIX=$PREFIX
-DDATA_DIR=$PREFIX/lib/casa/data
-DUSE_FFTW3=ON
-DUSE_HDF5=ON
-DUSE_THREADS=ON
-DCXX11=ON
-DCONDA_CASA_ROOT=$PREFIX/lib/casa
"
jflag=-j4

cd casacore
mkdir build
cd build
cmake $cmake_args ..
make $jflag VERBOSE=1
make install

cd $PREFIX
rm -f casa_sover.txt bin/casacore_floatcheck bin/countcode
