#! /bin/bash

set -e
./configure --prefix=$PREFIX --disable-gtk-doc || { cat config.log ; exit 1 ; }
make
make install

cd $PREFIX
rm -rf share/gtk-doc

