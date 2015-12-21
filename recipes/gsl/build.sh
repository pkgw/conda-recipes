#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' ] && NJOBS=1
set -e

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/SDKs/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk
    CFLAGS="$CFLAGS -isysroot $sdk"
    FFLAGS="$FFLAGS -isysroot $sdk"
    LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"
fi

./configure --prefix=$PREFIX || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install
