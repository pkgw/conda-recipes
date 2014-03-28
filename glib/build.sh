#! /bin/bash

set -e
./configure --prefix=$PREFIX || { cat config.log ; exit 1 ; }
make
make install

cd $PREFIX
rm -rf share/bash-completion share/gdb share/gtk-doc share/systemtap
