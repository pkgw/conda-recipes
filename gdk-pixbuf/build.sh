#! /bin/bash

set -e
export CPPFLAGS=-I$PREFIX/include LDFLAGS=-L$PREFIX/lib
./configure --prefix=$PREFIX || { cat config.log ; exit 1 ; }
make
make install
