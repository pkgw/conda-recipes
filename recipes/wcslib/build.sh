#! /bin/bash
# Copyright 2015-2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

configure_args=(
    --prefix=$PREFIX
    --enable-fortran
    --with-cfitsiolib=$PREFIX/lib
    --with-cfitsioinc=$PREFIX/include
    --with-pgplotlib=$PREFIX/lib
    --with-pgplotinc=$PREFIX/include/pgplot
)

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/
    export F77=gfortran-4.2
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export FFLAGS="$FFLAGS -isysroot $sdk"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"
else
    # Get newer compilers that use libgfortran.so.3:
    export PATH=/opt/rh/devtoolset-2/root/usr/bin:$PATH
fi

./configure "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make # note: Makefile is not parallel-safe
mkdir -p $PREFIX/share/man/man1
make install

cd $PREFIX
rm -rf share/doc
