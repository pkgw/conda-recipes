#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e

cmake_args="
-DCMAKE_BUILD_TYPE=RelWithDebInfo
-DCMAKE_COLOR_MAKEFILE=OFF
-DCMAKE_INSTALL_PREFIX=$PREFIX
-DCMAKE_MODULE_PATH=../cmake-modules
"

mkdir condabuild
cd condabuild
cmake $cmake_args ..
make VERBOSE=1 # note: not parallel-compatible
make install
