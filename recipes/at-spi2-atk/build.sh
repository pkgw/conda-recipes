#! /bin/bash
# Copyright 2014-2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
    export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
fi

meson builddir --prefix=$PREFIX --libdir=$PREFIX/lib
meson configure -D enable_docs=false builddir
ninja -v -C builddir
ninja -C builddir install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
rm -rf share/gtk-doc
