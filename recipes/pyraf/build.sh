#! /bin/bash
# Copyright 2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

if [ -n "$OSX_ARCH" ] ; then
    arch=macintel
else
    arch=linux64
fi

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
python setup.py install --prefix=$PREFIX

# Patch up the wrapper script to not need any environment variable futzing

cd $PREFIX
mkdir -p $SP_DIR/pyraf
mv bin/pyraf $SP_DIR/pyraf/orig_pyraf
cat >bin/pyraf <<EOF
#! /bin/bash
export iraf=$PREFIX/lib/iraf
export IRAFARCH=$arch
exec $SP_DIR/pyraf-*.egg-info/scripts/pyraf "\$@"
EOF
chmod +x bin/pyraf
