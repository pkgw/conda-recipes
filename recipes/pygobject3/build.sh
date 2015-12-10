#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
# conda provides libffi, but it has a busted .la file:
rm -f $PREFIX/lib/libffi.la
# ... and no pkgconfig info:
export FFI_CFLAGS="-I$PREFIX/include" FFI_LIBS="-L$PREFIX/lib -lffi"
# Make sure we pick up local cairo, etc:
export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"

./configure --prefix=$PREFIX || { cat config.log ; exit 1 ; }
make -j$(nproc --ignore=4)
make install

cd $PREFIX
rm -rf share/gtk-doc
