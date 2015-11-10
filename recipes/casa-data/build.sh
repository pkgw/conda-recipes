#! /bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e
mkdir -p $PREFIX/lib/casa
svn export . $PREFIX/lib/casa/data
