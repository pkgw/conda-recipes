#!/bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"
fi

export CPPFLAGS=-I$PREFIX/include LDFLAGS=-L$PREFIX/lib

./configure                 \
    --prefix=$PREFIX        \
    --disable-static        \
    --enable-ft             \
    --enable-ps             \
    --enable-pdf            \
    --enable-svg            \
    --enable-xcb            \
    --enable-xlib-xcb       \
    --disable-xcb-shm       \
    --disable-gtk-doc
make -j$NJOBS
make install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
rm -rf share

if [ -z "$OSX_ARCH" ] ; then
    # If we're not providing the full Cairo stack, delete all of the redundant
    # stuff. Alternatively, I could add "cairo" as a build dep and ask the
    # Conda file-finder to effectively do this work for me.

    rm -rf bin lib/cairo

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
fi
