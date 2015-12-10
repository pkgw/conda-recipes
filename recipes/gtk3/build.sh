#! /bin/bash
# Copyright 2014-2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
# conda provides libffi, but it has a busted .la file:
rm -f $PREFIX/lib/libffi.la

export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"
export LDFLAGS="-L$PREFIX/lib"
./configure --prefix=$PREFIX --disable-gtk-doc || { cat config.log ; exit 1 ; }
make -j$(nproc --ignore=4)
make install

cd $PREFIX
rm -rf $(echo "
share/applications
share/gtk-doc
share/man
bin/gtk3-demo*
bin/gtk3-icon-browser
bin/gtk3-widget-factory
")
