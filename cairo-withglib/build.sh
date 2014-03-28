#!/bin/bash

set -e
export CPPFLAGS=-I$PREFIX/include LDFLAGS=-L$PREFIX/lib

./configure                 \
    --prefix=$PREFIX        \
    --disable-static        \
    --enable-ft             \
    --enable-ps             \
    --enable-pdf            \
    --enable-svg            \
    --disable-gtk-doc
make
make install

rm -rf $PREFIX/share
