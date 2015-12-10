#! /bin/bash

set -e
# conda provides libffi, but it has a busted .la file:
rm -f $PREFIX/lib/libffi.la

./configure --prefix=$PREFIX --disable-gtk-doc || { cat config.log ; exit 1 ; }
make -j$(nproc --ignore=4)
make install

cd $PREFIX
rm -rf share/gtk-doc
