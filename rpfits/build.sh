#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
cd linux64
make install PREFIX=$PREFIX FC=gfortran FFLAGS="-g -O -fno-automatic -Wall -fPIC" CFLAGS="-g -O -Wall -fPIC"
