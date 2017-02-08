#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

# don't get locally installed pkg-config entries:
export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"

# needed to detect X11:
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

if [ -n "$OSX_ARCH" ] ; then
    # rpath setting is often needed to run compiled autoconf test programs:
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk -Wl,-rpath,$PREFIX/lib"
else
    # also for X11:
    export LDFLAGS="$LDFLAGS -Wl,-rpath-link,$PREFIX/lib"
fi

./configure --prefix=$PREFIX --disable-gtk-doc || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
rm -rf etc/xdg share/gtk-doc
