#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

# This is the second part of our OS X workaround -- see
# https://github.com/ContinuumIO/anaconda-issues/issues/600 .

set -e
cd $PREFIX/include/X11
shopt -s nullglob
for override in *.mxs ; do
    cp $override $(basename $override .mxs)
done
