#! /bin/bash
# Copyright 2014-2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e

configure_args=(
    --prefix=$PREFIX
    --x-includes=$PREFIX/include
    --x-libraries=$PREFIX/lib
    --disable-gtk-doc
)

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.9

    # rpath setting is often needed to run compiled autoconf test programs:
    export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"

    configure_args+=(
	--enable-quartz-backend
	--disable-cups
    )

    # Clashing libuuid causes compilation problems unless we do this. libuuid
    # is pulled in by xorg-libSM.
    rm -rf $PREFIX/include/uuid
else
    # I get a double-free crash in gtk/gtkcairoblur.c if I compile with the
    # stock compilers, and it goes away if I use the updated ones!
    export PATH=/opt/rh/devtoolset-2/root/usr/bin:$PATH
fi

rm -f $PREFIX/lib/*.la # deps include busted libtool files
./configure "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install

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
