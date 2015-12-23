#!/bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' ] && NJOBS=1
set -e

if [ -z "$OSX_ARCH" ] ; then
    echo only build me on os x
    exit 1
fi

export MACOSX_DEPLOYMENT_TARGET=10.6
sdk=/
export CFLAGS="$CFLAGS -isysroot $sdk"
export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"

./configure                 \
    --prefix=$PREFIX        \
    --disable-static
make -j$NJOBS
make install
