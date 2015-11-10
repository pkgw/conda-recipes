#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
export XERCESCROOT=$(pwd)
cd src/xercesc
bash ./runConfigure -plinux -cgcc -xg++ -minmem -nsocket -tnative -rpthread -b64 -P$PREFIX
make # note: build is not parallel-compatible
make install
