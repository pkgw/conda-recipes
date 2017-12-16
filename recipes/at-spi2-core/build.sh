#! /bin/bash
# Copyright 2014-2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e

# needed to detect X11:
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
    export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"
else
    # also for X11:
    export LDFLAGS="$LDFLAGS -Wl,-rpath-link,$PREFIX/lib"
fi

./configure --prefix=$PREFIX --disable-gtk-doc || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
rm -rf etc/xdg lib/systemd share/gtk-doc share/locale
