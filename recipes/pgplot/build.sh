#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

if [ -n "$OSX_ARCH" ] ; then
    subtype=actually_osx
    shlib=dylib
    export MACOSX_DEPLOYMENT_TARGET=10.6
    export CONDA_SYSROOT=/
else
    subtype=gfortran_gcc
    shlib=so

    # Get newer compilers that use libgfortran.so.3:
    export PATH=/opt/rh/devtoolset-2/root/usr/bin:$PATH
fi

./makemake . linux $subtype
for f in png.h pngconf.h pnglibconf.h zlib.h zconf.h ; do
    ln -s $PREFIX/include/$f $f
done
make all libcpgplot.a

mkdir -p $PREFIX/bin $PREFIX/lib $PREFIX/include/pgplot $PREFIX/share/pgplot
cp -a pgxwin_server $PREFIX/bin/
cp -a libcpgplot.a libpgplot.a libpgplot.$shlib $PREFIX/lib/
cp -a grfont.dat rgb.txt $PREFIX/share/pgplot/
cp -a cpgplot.h grpckg1.inc pgplot.inc $PREFIX/include/pgplot/

# NOTE: do not delete .a files! They're what we provide!
