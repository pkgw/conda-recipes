#! /bin/bash
# Copyright 2014-2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e

# For now, we have to manually update the gdk-pixbuf loader list:
eval $(grep -v : $PREFIX/lib/pkgconfig/gdk-pixbuf-2.0.pc)
$PREFIX/bin/gdk-pixbuf-query-loaders >$gdk_pixbuf_cache_file

configure_args=(--prefix=$PREFIX)

./configure "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install

cd $PREFIX
cd share/icons
ln -sf Adwaita default
