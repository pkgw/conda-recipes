#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/ # might be useful later?
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"
else
    # get newer gfortran that can do static libgfortran
    export PATH="/opt/rh/devtoolset-7/root/usr/bin:/opt/rh/devtoolset-3/root/bin:$PATH"
fi

./configure --prefix=$PREFIX --with-deplibs=$PREFIX --with-telescope=big1 --bindir=$PREFIX/lib/miriad --x-includes=$PREFIX/include --x-libraries=$PREFIX/lib || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install
