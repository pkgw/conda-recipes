#!/ bin/bash
# Copyright 2016-2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

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
    CFLAGS="$CFLAGS -fpermissive"
    CXXFLAGS="$CXXFLAGS -fpermissive"
fi

if [ $(uname) = Darwin ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/ # AFAIK we won't want to change this, but just in case
    unset CFLAGS CXXFLAGS LDFLAGS

    configure_args+=(
	-no-framework
	-no-phonon # can't be built on Sierra due to QuickTime issues
	-platform unsupported/macx-clang-libc++
	-arch $OSX_ARCH
	-sdk $sdk
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

# on OSX, qmake loads the 'default' mkspec by default which is a copy of
# 'unsupported/macx-clang-libc++'. The qmake.conf file there references
# relative paths like '../../common/<stuff>', which are broken when the
# source file is not in the 'unsupported' subdirectory. So we have to
# futz the installed files.

sed -e 's|\.\./\.\./common/|../common/|g' mkspecs/default/qmake.conf >tmp
mv -f tmp mkspecs/default/qmake.conf
