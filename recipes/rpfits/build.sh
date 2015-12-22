#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' ] && NJOBS=1
set -e

FFLAGS="-g -O -fno-automatic -Wall -fPIC"
CFLAGS="-g -O -Wall -fPIC"

if [ -n "$OSX_ARCH" ] ; then
    # I want to create a library that doesn't drag around issues w.r.t. linking
    # with libgfortran. AFAICT that means I need to make a dynamic library, which
    # the Makefile totally doesn't support. Fortunately, this codebase is so simple
    # that a manual build is easy!

    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/
    FC=gfortran-4.2

    mkdir -p $PREFIX/bin $PREFIX/lib $PREFIX/include

    $FC -static-libgfortran -dynamiclib -o $PREFIX/lib/librpfits.dylib \
	-install_name '@rpath/librpfits.dylib' -arch $OSX_ARCH \
	-compatibility_version 1.0.0 -current_version 1.0.0 \
	-headerpad_max_install_names \
	$FFLAGS -isysroot $sdk \
	-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET \
	code/*.f code/utdate.c code/darwin/*.f

    for bin in rpfex rpfhdr ; do
	gcc -dynamic -o $PREFIX/bin/$bin \
	    code/$bin.c $PREFIX/lib/librpfits.dylib
    done

    cp -a code/RPFITS.h code/rpfits.inc $PREFIX/include
else
    cd linux64
    make install \
	 PREFIX=$PREFIX \
	 CC=gcc \
	 FC=gfortran \
	 CFLAGS="$CFLAGS" \
	 FFLAGS="$FFLAGS" \
	 LDFLAGS="$LDFLAGS"
fi
