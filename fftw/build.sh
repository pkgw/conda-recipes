#!/usr/bin/env bash
# Stolen from github:conda/conda-recipes, which in turn credits "jeanconn" on Binstar.
# "inspired by build script for Arch Linux fftw pacakge:
# https://projects.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/fftw"

set -e
CONFIGURE="./configure --prefix=$PREFIX --enable-shared --enable-threads --disable-fortran"

# Single precision (fftw libraries have "f" suffix)
$CONFIGURE --enable-float --enable-sse
make -j$(nproc --ignore=4)
make install

# Long double precision (fftw libraries have "l" suffix)
$CONFIGURE --enable-long-double
make -j$(nproc --ignore=4)
make install

# Double precision (fftw libraries have no precision suffix)
$CONFIGURE --enable-sse2
make -j$(nproc --ignore=4)
make install

# I ignore the tests.
