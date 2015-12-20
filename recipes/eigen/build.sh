#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' ] && NJOBS=1
set -e

cmake_args="
-DCMAKE_INSTALL_PREFIX=$PREFIX
"

if [ -n "$OSX_ARCH" ] ; then
    cmake_args="$cmake_args -DCMAKE_OSX_DEPLOYMENT_TARGET="
fi

mkdir build
cd build
cmake $cmake_args ..
make install
