#! /bin/bash
# Copyright 2015-2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e

# We do fancy things with Bash arrays because we need to pass command-line
# options that contain internal spaces, and with pure string expansions
# there's no way to avoid them getting split up.

cmake_args=(
    -DBUILD_PYTHON=ON
    -DBUILD_TESTING=OFF
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_COLOR_MAKEFILE=OFF
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DDATA_DIR=$PREFIX/lib/casa/data
    -DUSE_FFTW3=ON
    -DUSE_HDF5=ON
    -DUSE_THREADS=ON
    -DCXX11=ON
    -DCONDA_CASA_ROOT=$PREFIX/lib/casa
)

if [ -n "$OSX_ARCH" ] ; then
    # Need to require 10.7 because of the C++11 features.
    export MACOSX_DEPLOYMENT_TARGET=10.7
    cmake_args+=(
	-DCMAKE_CXX_FLAGS="-arch $OSX_ARCH -stdlib=libc++ -std=c++11"
	-DCMAKE_Fortran_COMPILER=/usr/local/bin/gfortran-4.2
	-DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET
	-DCMAKE_OSX_SYSROOT=/
	-DREADLINE_INCLUDE_DIR=$PREFIX/include
	-DREADLINE_LIBRARY=$PREFIX/lib/libreadline.dylib
    )
else
    # Downstream elements of the C++ code require C++11 to compile, and for
    # binary compatibility we need to compile casacore with C++11 as well. We
    # can do this even on a CentOS 5 machine thanks to the Red Hat
    # "devtoolset" package. However, we still need to compile with stock
    # gfortran, to maintain binary compatibility with the Conda FORTRAN stack.
    # Fun times.

    cmake_args+=(
	-DBLAS_atlas_LIBRARY="$PREFIX/lib/libcblas.a;$PREFIX/lib/libatlas.a"
	-DCMAKE_C_COMPILER=/usr/bin/gcc
	-DCMAKE_CXX_COMPILER=/opt/rh/devtoolset-2/root/usr/bin/g++
	-DCMAKE_Fortran_COMPILER=/usr/bin/gfortran
    )
fi

cd casacore
mkdir build
cd build
cmake "${cmake_args[@]}" ..
make -j$NJOBS VERBOSE=1
make install

cd $PREFIX
rm -f casa_sover.txt bin/casacore_floatcheck bin/countcode
