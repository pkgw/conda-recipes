#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e

# don't get locally installed pkg-config entries:
export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"

if [ -n "$OSX_ARCH" ] ; then
    # Cf. the discussion in meta.yaml -- we require 10.7.
    export MACOSX_DEPLOYMENT_TARGET=10.7
    sdk=/
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"

    # Pick up the Conda version of gettext/libintl:
    export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
    export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
fi

./configure --prefix=$PREFIX || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install

cd $PREFIX
rm -rf share/bash-completion share/gdb share/gtk-doc share/systemtap
