#! /bin/bash
# Copyright 2014-2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

# I want to create a library that doesn't drag around issues w.r.t. linking
# with libgfortran. AFAICT that means I need to make a dynamic library, which
# the Makefile totally doesn't support. Fortunately, this codebase is so
# simple that a manual build is easy!

FFLAGS="-g -O -fno-automatic -Wall -fPIC"
CFLAGS="-g -O -Wall -fPIC"

mkdir -p $PREFIX/bin $PREFIX/lib $PREFIX/include

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/
    FC=gfortran-4.2
    SOEXT=dylib
    SOFLAGS=(
	-dynamiclib
	-static-libgfortran
	-install_name '@rpath/librpfits.dylib'
	-arch $OSX_ARCH
	-compatibility_version 1.0.0
	-current_version 1.0.0
	-headerpad_max_install_names
	-isysroot $sdk
	-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET
    )
    EXEFLAGS=(
	-dynamic
    )
else
    # Get newer compilers that use libgfortran.so.3:
    export PATH=/opt/rh/devtoolset-2/root/usr/bin:$PATH

    FC=gfortran
    SOEXT=so.0
    SOFLAGS=(
	-shared
	-fPIC
	-Wl,-soname,librpfits.so.0
    )
    EXEFLAGS=()
fi

$FC "${SOFLAGS[@]}" $FFLAGS \
    -o $PREFIX/lib/librpfits.$SOEXT \
    code/*.f code/utdate.c code/darwin/*.f

for bin in rpfex rpfhdr ; do
    gcc "${EXEFLAGS[@]}" \
	-o $PREFIX/bin/$bin \
	code/$bin.c $PREFIX/lib/librpfits.$SOEXT
done

cp -a code/RPFITS.h code/rpfits.inc $PREFIX/include

if [ -z "$OSX_ARCH" ] ; then
    (cd $PREFIX/lib && ln -s librpfits.$SOEXT librpfits.so)
fi
