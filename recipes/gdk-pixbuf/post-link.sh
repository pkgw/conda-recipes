#! /bin/bash
# Copyright 2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

# Make sure that loaders.cache is fully up-to-date. I don't want to assume
# that pkg-config is available, so we hack a bit to avoid running it when we
# get the cache location. Or we could just glob or hardcode the binary version
# ...

set -e
eval $(grep -v : $PREFIX/lib/pkgconfig/gdk-pixbuf-2.0.pc)
if [ -z "$gdk_pixbuf_cache_file" ] ; then
    bindir="$(echo $PREFIX/lib/gdk-pixbuf-2.0/*)"
    if [ ! -d $bindir ] ; then
	echo >&2 "error: no such gdk-pixbuf binary directory $PREFIX/lib/gdk-pixbuf-2.0/*"
	exit 1
    fi
    gdk_pixbuf_cache_file=$bindir/loaders.cache
fi
$PREFIX/bin/gdk-pixbuf-query-loaders >$gdk_pixbuf_cache_file
