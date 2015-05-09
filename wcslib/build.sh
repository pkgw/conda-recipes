#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

configure_args="
--prefix=$PREFIX
--enable-fortran
--with-cfitsiolib=$PREFIX/lib
--with-cfitsioinc=$PREFIX/include
--with-pgplotlib=$PREFIX/lib
--with-pgplotinc=$PREFIX/include/pgplot
"

set -e
./configure $configure_args || { cat config.log ; exit 1 ; }
make # note: Makefile is not parallel-safe
make install

cd $PREFIX
rm -rf share/doc
