#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

export PATH="$PREFIX/lib/qt4/bin:$PATH"

cat <<EOF >>qwtconfig.pri
target.path = $PREFIX/lib
headers.path = $PREFIX/include/qwt\$\$VER_MAJ
doc.path = $PREFIX/doc
EOF

if [ -n "$OSX_ARCH" ] ; then
    spec=macx-g++

    export MACOSX_DEPLOYMENT_TARGET=10.7
    sdk=/
    cat <<EOF >tmp1
QMAKE_MACOSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET
QMAKE_MAC_SDK = $sdk
QMAKE_CXXFLAGS += -stdlib=libc++
EOF
    mv qwtconfig.pri tmp2
    cat tmp1 tmp2 >qwtconfig.pri
else
    spec=linux-g++
fi

qmake -spec $PREFIX/share/qt4/mkspecs/$spec qwt.pro
make -j$NJOBS
make install

cd $PREFIX
rm -rf doc
