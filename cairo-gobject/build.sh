#!/bin/bash

set -e
export CPPFLAGS=-I$PREFIX/include LDFLAGS=-L$PREFIX/lib

./configure                 \
    --prefix=$PREFIX        \
    --disable-static        \
    --enable-ft             \
    --enable-ps             \
    --enable-pdf            \
    --enable-svg            \
    --disable-gtk-doc
make
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

cd pkgconfig
for f in cairo*.pc ; do
    case $f in
	cairo-gobject.pc) ;;
	*) rm -f $f ;;
    esac
done
