#! /bin/bash
# Copyright 2017-2019 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -ex

meson_config_args=(
    -D docs=false
    -D egl=yes
    -D x11=true
    -D tests=false
)

# Make it so that pkg-config can find the CDT (E)GL(X) packages:
export PKG_CONFIG_PATH="$BUILD_PREFIX/$HOST/sysroot/usr/lib64/pkgconfig"

# Hackity hack: manually copy the GL headers that we require, so that
# downstream deps don't all have to include a magic CDT package as a dependency

mkdir -p $PREFIX/include/KHR $PREFIX/include/EGL
cp $BUILD_PREFIX/$HOST/sysroot/usr/include/KHR/khrplatform.h $PREFIX/include/KHR/
cp $BUILD_PREFIX/$HOST/sysroot/usr/include/EGL/eglplatform.h $PREFIX/include/EGL/

meson builddir --prefix=$PREFIX --libdir=$PREFIX/lib
meson configure "${meson_config_args[@]}" builddir
ninja -v -C builddir
ninja -C builddir install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
