#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
export CPPFLAGS=-I$PREFIX/include LDFLAGS=-L$PREFIX/lib
./configure --prefix=$PREFIX || { cat config.log ; exit 1 ; }
make
make install
