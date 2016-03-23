#! /bin/bash
# Copyright 2014-2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e

# don't get locally installed pkg-config entries:
export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"

configure_args=(--prefix=$PREFIX --disable-gtk-doc --with-gobject)

if [ -n "$OSX_ARCH" ] ; then
    # rpath setting is often needed to run compiled autoconf test programs:
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk -Wl,-rpath,$PREFIX/lib"

    configure_args+=(--with-coretext)

    # Ugh. install_name fixup currently needed; have to copy since
    # install_name_tool patches in place and the files are hardlinked out of
    # the pkgs tree!
    for lib in freetype; do
	lpath=$PREFIX/lib/lib${lib}.dylib
	mv $lpath $lpath.tmp
	cp $lpath.tmp $lpath
	rm -f $lpath.tmp
	iname=$(otool -D $lpath |sed -e '2!d')
	install_name_tool -id @rpath/$iname $lpath
    done
else
    # harfbuzz's configure script gets C++ compiler flags from Conda's ICU
    # package, which adds a '--std=c++0x' that is not understood by the stock
    # CentOS 5 g++. So we need to use the fancy modern compilers:
    export PATH=/opt/rh/devtoolset-2/root/usr/bin:$PATH
fi

./configure "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
rm -rf share/gtk-doc
