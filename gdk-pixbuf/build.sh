#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
export CPPFLAGS=-I$PREFIX/include LDFLAGS=-L$PREFIX/lib
./configure --prefix=$PREFIX || { cat config.log ; exit 1 ; }
make -j$(nproc --ignore=4)
make install

cd $PREFIX
# workaround for libffi .la file path issues
sed -i -e 's|lib/\.\./lib64|lib|g' lib/*.la lib/gdk-pixbuf-2.0/*/loaders/*.la
