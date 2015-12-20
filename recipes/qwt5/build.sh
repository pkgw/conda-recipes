#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' ] && NJOBS=1
set -e

if [ -n "$OSX_ARCH" ] ; then
    spec=macx-g++
else
    spec=linux-g++
fi

cat <<EOF >>qwtconfig.pri
target.path = $PREFIX/lib
headers.path = $PREFIX/include/qwt\$\$VER_MAJ
doc.path = $PREFIX/doc
EOF
qmake -spec $spec qwt.pro
make -j$NJOBS
make install

cd $PREFIX
rm -rf doc
