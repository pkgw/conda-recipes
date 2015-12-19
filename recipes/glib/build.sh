#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' ] && NJOBS=1
set -e

if [ -n "$OSX_ARCH" ] ; then
    # Need pkg-config, gettext.
    export CPPFLAGS="-I/usr/local/opt/gettext/include" LDFLAGS="-L/usr/local/opt/gettext/lib"
    export PATH="/usr/local/opt/gettext/bin:$PATH"
    # OS X: libffi is provided by system
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
