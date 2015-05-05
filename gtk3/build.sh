#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
./configure --prefix=$PREFIX --disable-gtk-doc || { cat config.log ; exit 1 ; }
make
make install

cd $PREFIX
rm -rf share/gtk-doc
