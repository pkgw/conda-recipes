#! /bin/bash
# Copyright 2014-2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

# don't get locally installed pkg-config entries:
export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"

if [ -n "$OSX_ARCH" ] ; then
    sdk=/
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk -Wl,-rpath,$PREFIX/lib -L$PREFIX/lib"
fi

# The configure script uses the python-config script to get link info,
# but it heuristics fail when we're on Python 3 because of how it tries
# to find the script's name. This fixes the problem.
if [ $PY3K -eq 1 ] ; then
    export PYTHON=python3
fi

./configure --prefix=$PREFIX --enable-compile-warnings=minimum || { cat config.log ; exit 1 ; }
make -j$NJOBS V=1
make install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
rm -rf share/gtk-doc
