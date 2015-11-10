#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
# conda libffi doesn't come with pkgconfig info:
export LIBFFI_CFLAGS="-I$PREFIX/include" LIBFFI_LIBS="-L$PREFIX/lib -lffi"
./configure --prefix=$PREFIX || { cat config.log ; exit 1 ; }
make -j$(nproc --ignore=4)
make install

cd $PREFIX
rm -rf share/bash-completion share/gdb share/gtk-doc share/systemtap

# workaround for libffi .la file path issues
sed -i -e 's|lib/\.\./lib64|lib|g' lib/*.la
