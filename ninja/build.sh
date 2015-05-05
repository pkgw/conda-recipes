#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
./configure.py --bootstrap

mkdir $PREFIX/bin
cp -p ninja $PREFIX/bin/ninja
