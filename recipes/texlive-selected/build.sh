#! /bin/bash
# Copyright 2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' ] && NJOBS=1
set -e -x

dist=$PREFIX/share/texlive/
mkdir -p $dist
cp -a . $dist

# One annoying script not distributed in any useful source tarball.
cp $RECIPE_DIR/mktexlsr.pl $dist/texmf-dist/scripts/texlive/
chmod +x $dist/texmf-dist/scripts/texlive/mktexlsr.pl

cd $dist
mktexlsr
fmtutil-sys --all
mktexlsr
