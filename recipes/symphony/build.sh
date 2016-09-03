#! /bin/bash
# Copyright 2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e

cmake_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_C_FLAGS="-I$PREFIX/include"
    -DCMAKE_COLOR_MAKEFILE=OFF
    -DGSL_INCLUDES=$PREFIX/include
)

if [ -n "$OSX_ARCH" ] ; then
    # TODO.
    export MACOSX_DEPLOYMENT_TARGET=10.6
    cmake_args+=(
	-DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET
	-DCMAKE_OSX_SYSROOT=/
    )
else
    cmake_args+=(
	-DCBLAS_cblas_INCLUDE="$PREFIX/include"
	-DCBLAS_cblas_LIBRARY="$PREFIX/lib/libopenblas.so"
    )
fi

cd src
cmake  "${cmake_args[@]}" .
make

# "Installation". XXX: shlibs should have real version information, etc!

mkdir -p $PREFIX/lib $PREFIX/include/symphony $SP_DIR

for l in libsymphony.so integrator/libintegrator.so kappa/libkappa.so maxwell_juettner/libmaxwell_juettner.so power_law/libpower_law.so ; do
    cp -a $l $PREFIX/lib/
done

cp -a symphonyPy.so $SP_DIR/

find . -name '*.h' |xargs tar c |(cd $PREFIX/include/symphony && tar x)
