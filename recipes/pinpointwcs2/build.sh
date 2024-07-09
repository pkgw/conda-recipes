#! /bin/bash
# Copyright Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -xeuo pipefail

cmake_args=(
    -DCFITSIO_INCLUDE_DIR=$PREFIX/include
    -DCFITSIO_LIBRARY=$PREFIX/lib/libcfitsio.dylib
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_COLOR_MAKEFILE=OFF
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DEIGEN3_INCLUDE_DIR=$PREFIX/include/eigen3
    -DLIBWCS_INCLUDE_DIR=$PREFIX/include/wcstools
    -DLIBWCS_LIBRARY=$PREFIX/lib/libwcstools.dylib
    -DXPA_INCLUDE_DIR=$PREFIX/include
    -DXPA_LIBRARY=$PREFIX/lib/libxpa.a
)

if [[ $(uname) == Darwin ]] ; then
    linkflags="-Wl,-rpath,$PREFIX/lib $LDFLAGS"

    # cmake_args+=(
    #     -DCMAKE_CXX_FLAGS="-arch $OSX_ARCH -stdlib=libc++ -std=c++11 -D_LIBCPP_DISABLE_AVAILABILITY"
    #     -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET
    #     -DCMAKE_OSX_SYSROOT=/
    # )
else
    linkflags="-Wl,-rpath-link,$PREFIX/lib $LDFLAGS"
fi

cmake_args+=(
    -DCMAKE_EXE_LINKER_FLAGS="$linkflags"
    -DCMAKE_MODULE_LINKER_FLAGS="$linkflags"
    -DCMAKE_SHARED_LINKER_FLAGS="$linkflags"
)

# temp hack for my dumb tarball
rm -rf CMakeFiles cmake_install.cmake CMakeCache.txt .git

mkdir build
cd build

cmake "${cmake_args[@]}" ..
make -j$NJOBS VERBOSE=1

mkdir -p $PREFIX/bin
cp -p PinpointWCS $PREFIX/bin
