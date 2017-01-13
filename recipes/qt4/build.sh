#!/ bin/bash
# Copyright 2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

configure_args=(
    -prefix $PREFIX
    -libdir $PREFIX/lib/qt4
    -bindir $PREFIX/lib/qt4/bin
    -headerdir $PREFIX/include/qt4
    -datadir $PREFIX/share/qt4
    -plugindir $PREFIX/lib/qt4/plugins
    -importdir $PREFIX/lib/qt4/imports
    -translationdir $PREFIX/share/qt4/translations
    -sysconfdir $PREFIX/etc/qt4
    -L $PREFIX/lib
    -I $PREFIX/include
    -R $PREFIX/lib
    -release
    -fast
    -no-qt3support
    -no-script
    -nomake examples
    -nomake demos
    -nomake docs
    -opensource
    -openssl
    -webkit
    -system-zlib
    -system-libpng
    -system-libtiff
    -system-libjpeg
    -dbus
    -verbose
)

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/ # AFAIK we won't want to change this, but just in case
    unset CFLAGS CXXFLAGS LDFLAGS

    configure_args+=(
	-no-framework
	-no-phonon # can't be built on Sierra due to QuickTime issues
	-platform macx-g++
	-arch $OSX_ARCH
	-sdk $sdk
    )
fi

chmod +x configure
./configure "${configure_args[@]}"
make -j$NJOBS
make install

cd $PREFIX
# NOTE: do not delete *.a since we need libQtUiTools.a
find . -name '*.la' -delete

cat <<EOF >lib/qt4/bin/qt.conf
[Paths]
Prefix = $PREFIX
Binaries = $PREFIX/lib/qt4/bin
Libraries = $PREFIX/lib/qt4
Headers = $PREFIX/include/qt4
EOF

rm -rf tests
mkdir -p lib/pkgconfig
mv lib/qt4/pkgconfig/* lib/pkgconfig/
