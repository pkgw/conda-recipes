#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e

# Note that unlike some of the other packages, here we use the devtools gcc as
# well as g++ since CentOS 5's gcc chokes on a "-march=native" switch used by
# the build system.

cmake_args="
-DCMAKE_BUILD_TYPE=Release
-DCMAKE_COLOR_MAKEFILE=OFF
-DCMAKE_C_COMPILER=/opt/rh/devtoolset-2/root/usr/bin/gcc
-DCMAKE_CXX_COMPILER=/opt/rh/devtoolset-2/root/usr/bin/g++
-DCMAKE_INSTALL_PREFIX=$PREFIX
-DCMAKE_MODULE_PATH=../cmake-modules
"

mkdir condabuild
cd condabuild
cmake $cmake_args ..
make VERBOSE=1 # note: not parallel-compatible
make install
