#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

if [ -z "$OSX_ARCH" ] ; then
    echo only build me for os x
    exit 1
fi

# don't get locally installed pkg-config entries:
export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"

# For reasons that completely escape me, if we run "waf configure" with
# LDFLAGS etc. set, the compile flags returned by Python on OS X include
# various -isysroot flags pointing to SDKs that we don't have. If they're
# unset, some code kicks in that strips out these bad flags (cf.
# _osx_support.py in the Python tree). So let's unset them.
export MACOSX_DEPLOYMENT_TARGET=10.6
sdk=/
unset CFLAGS CXXFLAGS LDFLAGS

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
