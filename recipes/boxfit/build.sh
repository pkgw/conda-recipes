#! /bin/bash
# Copyright 2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

mkdir -p $PREFIX/bin $PREFIX/share/boxfit

# We compile and install two versions since the program's capability to deal
# with Doppler boosting is, annoyingly, a compile-time flag.

cd src
mkdir -p bin
make all HOME=.
cp -p ../bin/boxfit $PREFIX/bin/boxfit-boost
cp -p ../bin/dump_box $PREFIX/bin/
rm -f ../bin/* *.o
sed -i -e 's|#define BOOST_.*|#define BOOST_ DISABLED_|' environment.h
make all HOME=.
cp -p ../bin/boxfit $PREFIX/bin/boxfit-noboost

cd ..
for f in settings/*.txt ; do
    sed -e "s|@datadir@|$PREFIX/share/boxfit|" $f >$PREFIX/share/boxfit/$(basename $f)
done
cp data/*.txt $PREFIX/share/boxfit/
