#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths
./waf --help >/dev/null # trigger unpacking of waflib directory
rdir=$(cd $RECIPE_DIR && pwd)
(cd .waf* && patch -p1 -i $rdir/60_python-config-without-interpreter.patch)
(cd .waf* && patch -p1 -i $rdir/70_dont-link-libpython.patch)
(cd .waf* && patch -p1 -i $rdir/80_fix-pickle.patch)
(cd .waf* && patch -p1 -i $rdir/81_pickling-again.patch)
./waf configure --prefix=$PREFIX
./waf build
./waf install

cd $PREFIX
# touchups?
