#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
# conda provides libffi, but it has a busted .la file:
rm -f $PREFIX/lib/libffi.la
# need this to link everything:
export CPPFLAGS=-I$PREFIX/include LDFLAGS=-L$PREFIX/lib

./configure --prefix=$PREFIX --with-x11 || { cat config.log ; exit 1 ; }
make -j$(nproc --ignore=4)
make install
