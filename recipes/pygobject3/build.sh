#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
# I want to avoid local-OS packages, but cairo requires things like "xrender"
# and "x11" and I so do not want to go down that rathole.
###export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"
# conda libffi doesn't come with pkgconfig info:
export FFI_CFLAGS="-I$PREFIX/include" FFI_LIBS="-L$PREFIX/lib -lffi"
./configure --prefix=$PREFIX --disable-gtk-doc || { cat config.log ; exit 1 ; }
make -j$(nproc --ignore=4)
make install

cd $PREFIX
rm -rf share/gtk-doc

# workaround for libffi .la file path issues
sed -i -e 's|lib/\.\./lib64|lib|g' lib/python*/site-packages/gi/*.la
