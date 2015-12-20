#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' ] && NJOBS=1
set -e

if [ -n "$OSX_ARCH" ] ; then
    platform=macosx
else
    platform=linux
fi

export XERCESCROOT=$(pwd)
cd src/xercesc
bash ./runConfigure -p$platform -cgcc -xg++ -minmem -nsocket -tnative -rpthread -b64 -P$PREFIX
make # note: build is not parallel-compatible
make install
