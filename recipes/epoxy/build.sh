#! /bin/bash
# Copyright 2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e

configure_args=(
    --prefix=$PREFIX
    --x-includes=$PREFIX/include
    --x-libraries=$PREFIX/lib
    --disable-egl
)

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
    export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
else
    # also for X11:
    export LDFLAGS="$LDFLAGS -Wl,-rpath-link,$PREFIX/lib"
fi

./configure "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
