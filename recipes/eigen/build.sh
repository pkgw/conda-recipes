#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e

cmake_args="
-DCMAKE_INSTALL_PREFIX=$PREFIX
"

mkdir build
cd build
cmake $cmake_args ..
make install
