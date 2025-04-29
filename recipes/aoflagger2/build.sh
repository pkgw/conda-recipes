#! /bin/bash
# Copyright 2015-2022 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -xeuo pipefail

cmake_args=(
    -GNinja
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DPORTABLE=ON
)

#cmake_args+=(--debug-trycompile --debug-output)

if [[ $(uname) = "Darwin" ]] ; then
    cmake_args+=(
        -Darch=darwin64
        -Darchflag=x86_64
        -DCMAKE_CXX_FLAGS="-arch $OSX_ARCH -stdlib=libc++ -D_LIBCPP_DISABLE_AVAILABILITY"
        -DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET
        -DCMAKE_OSX_SYSROOT=/
        -DCMAKE_SHARED_LINKER_FLAGS="-Wl,-undefined,dynamic_lookup"
        -DPYTHON_EXECUTABLE="$BUILD_PREFIX/bin/python3"
        -DPYTHON_INCLUDE_DIR="$(echo $BUILD_PREFIX/include/python3.*)"
        -DPYTHON_LIBRARY="$BUILD_PREFIX/lib"
    )
else
    cmake_args+=(
        -DCMAKE_EXE_LINKER_FLAGS="-L$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib"
        -DCMAKE_MODULE_LINKER_FLAGS="-L$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib"
        -DCMAKE_SHARED_LINKER_FLAGS="-L$PREFIX/lib -Wl,-rpath-link,$PREFIX/lib"
    )
fi

mkdir build
cd build
cmake "${cmake_args[@]}" ..
ninja -j$CPU_COUNT
ninja install

# Remove GUI stuff that we don't provide:
cd $PREFIX
rm -rf share/applications share/icons
