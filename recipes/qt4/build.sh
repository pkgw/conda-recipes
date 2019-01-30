#!/ bin/bash
# Copyright 2016-2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -ex

configure_args=(
    -prefix $PREFIX/qt4
    -libdir $PREFIX/qt4/lib
    -bindir $PREFIX/qt4/bin
    -headerdir $PREFIX/qt4/include
    -datadir $PREFIX/qt4
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

if [ $(uname) = Linux ] ; then
    export CFLAGS="$CFLAGS -fpermissive"
    export CXXFLAGS="$CXXFLAGS -fpermissive"
    export LDFLAGS="$LDFLAGS -Wl,-rpath-link,$(pwd)/lib -L$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib"
    export LD="$CXX" # Qt expects $LD to accept "-Wl,foo", etc.
fi

if [ $(uname) = Darwin ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    unset CFLAGS CXXFLAGS LDFLAGS

    configure_args+=(
	-no-framework
	-no-phonon # can't be built on Sierra due to QuickTime issues
	-platform unsupported/macx-clang-libc++
	-arch $OSX_ARCH
    )
fi

mkdir -p $PREFIX/qt4/lib
mkdir -p src/3rdparty/webkit/Source/lib # needed on OSX
chmod +x configure
./configure "${configure_args[@]}"
make -j$NJOBS
make install

mkdir -p $PREFIX/lib/pkgconfig
mv $PREFIX/qt4/lib/pkgconfig/* $PREFIX/lib/pkgconfig/

cd $PREFIX/qt4
# NOTE: do not delete *.a since we need libQtUiTools.a
find . -name '*.la' -delete

cat <<EOF >bin/qt.conf
[Paths]
Prefix = $PREFIX/qt4
Binaries = $PREFIX/qt4/bin
Libraries = $PREFIX/qt4/lib
Headers = $PREFIX/qt4/include
EOF

rm -rf tests translations q3porting.xml phrasebooks
rm -rf bin/*.app
