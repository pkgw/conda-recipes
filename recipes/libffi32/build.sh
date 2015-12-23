#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' ] && NJOBS=1
set -e

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"
fi

./configure --prefix=$PREFIX || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install

# Now we patch up the library name; whee

cd $PREFIX
rm -rf share
rm -f lib/*.la lib/*.a
sed -i '' -e 's|-lffi|-lffi32|' lib/pkgconfig/libffi.pc

if [ -n "$OSX_ARCH" ] ; then
    vers=6
    cd lib
    mv libffi.$vers.dylib libffi32.$vers.dylib
    rm -f libffi.dylib
    ln -s libffi32.$vers.dylib libffi32.dylib
    install_name_tool -id "$(pwd)/libffi32.$vers.dylib" libffi32.$vers.dylib
else
    echo need to implement SO renaming on non-OSX platform
    exit 1
fi
