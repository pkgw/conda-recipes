#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' ] && NJOBS=1
set -e

if [ -n "$OSX_ARCH" ] ; then
    # Cf. the discussion in meta.yaml -- we require 10.7.
    export MACOSX_DEPLOYMENT_TARGET=10.7
    sdk=/
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"

    # Pick up the Conda version of gettext/libintl:
    export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
    export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

    # OS X: we assume there's a pkg-config from Brew; libffi is provided by
    # the system.
    export LIBFFI_CFLAGS="-I/usr/include/ffi" LIBFFI_LIBS="-lffi"
else
    # Linux: conda provides libffi with a busted .la file:
    rm -f $PREFIX/lib/libffi.la
    export LIBFFI_CFLAGS="-I$PREFIX/include" LIBFFI_LIBS="-L$PREFIX/lib -lffi"
fi

./configure --prefix=$PREFIX || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install

cd $PREFIX
rm -rf share/bash-completion share/gdb share/gtk-doc share/systemtap
