#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
# conda provides libffi, but it has a busted .la file:
rm -f $PREFIX/lib/libffi.la
# don't get locally installed pkg-config entries:
export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"
# conda libffi doesn't come with pkgconfig info:
export FFI_CFLAGS="-I$PREFIX/include" FFI_LIBS="-L$PREFIX/lib"
./configure --prefix=$PREFIX || { cat config.log ; exit 1 ; }
make -j$(nproc --ignore=4)
make install
