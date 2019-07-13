#! /bin/bash
# Copyright 2014-2019 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -ex

meson_config_args=(
    -D gtk_doc=false
    -D demos=false
    -D examples=false
    -D installed_tests=false
    -D wayland_backend=true
)

if [ -n "$OSX_ARCH" ] ; then
    # Clashing libuuid causes compilation problems unless we do this. libuuid
    # is pulled in by xorg-libSM.
    rm -rf $PREFIX/include/uuid
fi

meson builddir --prefix=$PREFIX --libdir=$PREFIX/lib
meson configure "${meson_config_args[@]}" builddir
ninja -v -C builddir
ninja -C builddir install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
rm -rf $(echo "
share/applications
share/gtk-doc
share/man
bin/gtk3-demo*
bin/gtk3-icon-browser
bin/gtk3-widget-factory
")
