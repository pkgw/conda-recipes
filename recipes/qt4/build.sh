#!/ bin/bash
# Copyright 2016-2020 Peter Williams and collaborators.
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

# (Ported from conda-forge qt[5] recipe
#
# Frustratingly, Qt's configure checks do not honor the standard build
# environment variables ($CC, $*FLAGS, etc) in a very consistent way. In
# particular, they are largely ignored during configuration. AFAICT, the best
# way to get them to apply during both configuration and the primary build is
# to modify the "mkspec" files used in the build. (You can pass #defines to
# the configuration script, but you can't pass linker flags like
# `-Wl,-rpath`.)
#
# Aside: our toolchain environments unfortunately mix preprocessor and
# non-preprocessor flags in both $CFLAGS and $CPPFLAGS.

if [[ $(uname) == Linux ]] ; then
    compiler_mkspec=mkspecs/common/g++-base.conf
    flag_mkspec=mkspecs/linux-g++/qmake.conf
    extra_flags=

    export CFLAGS="$CFLAGS -fpermissive"
    export CXXFLAGS="$CXXFLAGS -fpermissive -Wno-expansion-to-defined -Wno-unused-local-typedefs"
    export LDFLAGS="$LDFLAGS -Wl,-rpath-link,$(pwd)/lib -L$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib"
elif [[ $(uname) == Darwin ]] ; then
    compiler_mkspec=mkspecs/common/clang.conf
    flag_mkspec=mkspecs/unsupported/macx-clang-libc++/qmake.conf
    extra_flags="-Wno-c++11-narrowing"  # turns out this old code needs this (for both C and C++ compilers)

    export MACOSX_DEPLOYMENT_TARGET=10.6
    unset CFLAGS CXXFLAGS LDFLAGS

    configure_args+=(
	-no-framework
	-no-phonon # can't be built on Sierra due to QuickTime issues
	-platform unsupported/macx-clang-libc++
	-arch $OSX_ARCH
    )
fi

export LD="$CXX" # Qt expects $LD to accept "-Wl,foo", etc.

# If we don't $(basename) here, when $CC contains an absolute path it will
# point into the *build* environment directory, which won't get replaced when
# making the package -- breaking the mkspec for downstream consumers.
sed -i -e "s|^QMAKE_CC.*=.*|QMAKE_CC = $(basename $CC)|" $compiler_mkspec
sed -i -e "s|^QMAKE_CXX.*=.*|QMAKE_CXX = $(basename $CXX)|" $compiler_mkspec

# The mkspecs only append to QMAKE_*FLAGS, so if we set them at the very top
# of the main mkspec file, the settings will be honored.

cp $flag_mkspec $flag_mkspec.orig
cat <<EOF >$flag_mkspec
QMAKE_CFLAGS = $CFLAGS $CPPFLAGS $extra_flags
QMAKE_CXXFLAGS = $CXXFLAGS $CPPFLAGS $extra_flags
QMAKE_LFLAGS = $LDFLAGS
EOF
cat $flag_mkspec.orig >>$flag_mkspec

# The above were also copied from conda-forge's qt5 recipe

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
