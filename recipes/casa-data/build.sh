#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths
mkdir -p $PREFIX/lib/casa
svn export . $PREFIX/lib/casa/data
