#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.7 # C++ libc++ needs this
    sdk=/
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export CXXFLAGS="$CXXFLAGS -isysroot $sdk -stdlib=libc++"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"

    platform=macosx
else
    platform=linux
fi

export XERCESCROOT=$(pwd)
cd src/xercesc
bash ./runConfigure -p$platform -cgcc -xg++ -minmem -nsocket -tnative -rpthread -b64 -P$PREFIX
make # note: build is not parallel-compatible
make install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
