#! /bin/bash
# Copyright 2016-2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    platdir=macosx
else
    platdir=unix
fi

# libxml2 include in CFLAGS is a hack for tksao submodule
export CFLAGS="-I$PREFIX/include -I$PREFIX/include/libxml2"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export EXTRA_CONFIGURE_ARGS="\
--x-includes=$PREFIX/include \
--x-libraries=$PREFIX/lib \
--with-xml2-config=$PREFIX/bin/xml2-config \
--with-xslt-config=$PREFIX/bin/xslt-config
"
PATH="$(pwd):$PATH" $platdir/configure
make # parallel builds do not work
mkdir -p $PREFIX/bin
cp -a bin/ds9 $PREFIX/bin/
