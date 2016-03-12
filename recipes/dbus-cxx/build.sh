#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.7 # C++ libc++ needs this
    sdk=/
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export CXXFLAGS="$CXXFLAGS -isysroot $sdk -stdlib=libc++"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"
fi

./configure --prefix=$PREFIX --disable-ecore --disable-tests --disable-examples || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install
