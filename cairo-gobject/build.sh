#!/bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
export CPPFLAGS=-I$PREFIX/include LDFLAGS=-L$PREFIX/lib

./configure                 \
    --prefix=$PREFIX        \
    --disable-static        \
    --enable-ft             \
    --enable-ps             \
    --enable-pdf            \
    --enable-svg            \
    --disable-xcb           \
    --disable-xlib-xcb      \
    --disable-xcb-shm       \
    --disable-gtk-doc
make -j$(nproc --ignore=4)
make install

cd $PREFIX
rm -rf bin lib/cairo share

(cd include/cairo
 for f in * ; do
     case $f in
	 cairo-gobject.h) ;;
	 *) rm -f $f ;;
     esac
 done
)

cd lib
for f in libcairo* ; do
    case $f in
	libcairo-gobject*) ;;
	*) rm -f $f ;;
    esac
done

# workaround for libffi .la file path issues
sed -i -e 's|lib/\.\./lib64|lib|g' *.la

cd pkgconfig
for f in cairo*.pc ; do
    case $f in
	cairo-gobject.pc) ;;
	*) rm -f $f ;;
    esac
done
