#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
cat <<EOF >>qwtconfig.pri
target.path = $PREFIX/lib
headers.path = $PREFIX/include/qwt\$\$VER_MAJ
doc.path = $PREFIX/doc
EOF
qmake -spec linux-g++ qwt.pro
make -j$(nproc --ignore=4)
make install

cd $PREFIX
rm -rf doc
