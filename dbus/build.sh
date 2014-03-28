#! /bin/bash

set -e
./configure --prefix=$PREFIX --disable-tests || { cat config.log ; exit 1 ; }
make
make install

cd $PREFIX
rm -rf bin etc libexec share
