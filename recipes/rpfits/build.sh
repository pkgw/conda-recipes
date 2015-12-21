#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' ] && NJOBS=1
set -e

FFLAGS="-g -O -fno-automatic -Wall -fPIC"
CFLAGS="-g -O -Wall -fPIC"

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/SDKs/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk
    CFLAGS="$CFLAGS -arch $OSX_ARCH -isysroot $sdk"
    FFLAGS="$FFLAGS -arch $OSX_ARCH -isysroot $sdk"
    LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"

    FC=gfortran-4.2
    subdir=darwin
else
    FC=gfortran
    subdir=linux64
fi

cd $subdir
make install \
     PREFIX=$PREFIX \
     CC=gcc \
     FC=$FC \
     CFLAGS="$CFLAGS" \
     FFLAGS="$FFLAGS" \
     LDFLAGS="$LDFLAGS"
