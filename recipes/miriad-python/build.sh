#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/ # might be useful later?
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"
else
    # get newer gfortran that can do static libgfortran
    export PATH="/opt/rh/devtoolset-2/root/usr/bin:/opt/rh/devtoolset-2/root/bin:$PATH"
fi

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -Wl,-rpath-link,$PREFIX/lib"

./configure --prefix=$PREFIX --with-miriad=$PREFIX || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install
