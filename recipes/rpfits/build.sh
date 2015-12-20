#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' ] && NJOBS=1
set -e

if [ -n "$OSX_ARCH" ] ; then
    FC=gfortran-4.2
else
    FC=gfortran
fi

cd linux64
make install PREFIX=$PREFIX FC=$FC FFLAGS="-g -O -fno-automatic -Wall -fPIC" CFLAGS="-g -O -Wall -fPIC"
