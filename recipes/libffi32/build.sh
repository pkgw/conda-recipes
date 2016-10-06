#! /bin/bash
# Copyright 2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

configure_args=(
    --prefix=$PREFIX
)

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"
    sedinplace=(-i '')
else
    sedinplace=(--in-place=)
fi

./configure "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install

cd $PREFIX
rm -rf share
rm -f lib/*.la lib/*.a
sed "${sedinplace[@]}" -e 's|-lffi|-lffi32|' lib/pkgconfig/libffi.pc

# I think this should no longer be needed?
###if [ -n "$OSX_ARCH" ] ; then
###    vers=6
###    cd lib
###    mv libffi.$vers.dylib libffi32.$vers.dylib
###    rm -f libffi.dylib
###    ln -s libffi32.$vers.dylib libffi32.dylib
###    install_name_tool -id "$(pwd)/libffi32.$vers.dylib" libffi32.$vers.dylib
###fi
