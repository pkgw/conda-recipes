#!/usr/bin/env bash
# Stolen from github:conda/conda-recipes, which in turn credits "jeanconn" on Binstar.
# "inspired by build script for Arch Linux fftw pacakge:
# https://projects.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/fftw"

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e

configure="./configure --prefix=$PREFIX --enable-shared --enable-threads --disable-fortran"

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"
fi

# Single precision (fftw libraries have "f" suffix)
$configure --enable-float --enable-sse
make -j$NJOBS
make install

# Long double precision (fftw libraries have "l" suffix)
$configure --enable-long-double
make -j$NJOBS
make install

# Double precision (fftw libraries have no precision suffix)
$configure --enable-sse2
make -j$NJOBS
make install

# I ignore the tests.
