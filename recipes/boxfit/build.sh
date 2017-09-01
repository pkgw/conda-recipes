#! /bin/bash
# Copyright 2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

cd src
make all

mkdir -p $PREFIX/bin $PREFIX/share/boxfit

cd ..
cp -p bin/boxfit bin/dump_box $PREFIX/bin/
for f in settings/*.txt ; do
    sed -e "s|@datadir@|$PREFIX/share/boxfit|" $f >$PREFIX/share/boxfit/$(basename $f)
done
cp data/*.txt $PREFIX/share/boxfit/
