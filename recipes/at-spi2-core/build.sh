#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
# conda provides libffi, but it has a busted .la file:
rm -f $PREFIX/lib/libffi.la
# need this for dbus:
export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"
# need this to detect X11:
export CPPFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib"

./configure --prefix=$PREFIX --disable-gtk-doc || { cat config.log ; exit 1 ; }
make -j$(nproc --ignore=4)
make install

cd $PREFIX
rm -rf etc/xdg share/gtk-doc

