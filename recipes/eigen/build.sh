#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e

cmake_args=(
    -DCMAKE_INSTALL_PREFIX=$PREFIX
)

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.7 # C++ libc++ needs this
    sdk=/
    cmake_args+=(
	-DCMAKE_CXX_FLAGS="-arch $OSX_ARCH -stdlib=libc++"
	-DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET
	-DCMAKE_OSX_SYSROOT=$sdk
    )
fi

mkdir build
cd build
cmake "${cmake_args[@]}" ..
make install
