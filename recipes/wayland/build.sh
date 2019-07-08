#! /bin/bash
# Copyright 2019 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -ex

configure_args=(
    --prefix=$PREFIX
    --disable-documentation
    --disable-dtd-validation
)

# Wayland test framework specifically complains about this:
export CPPFLAGS="$(echo "$CPPFLAGS" |sed -e 's/-DNDEBUG//')"

# tests/fixed-benchmark uses clock_gettime:
export LDFLAGS="$LDFLAGS -lrt"

./configure "${configure_args[@]}" || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
