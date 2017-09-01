#! /bin/bash
# Copyright 2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e

mkdir -p $PREFIX/share/boxfit
cd $PREFIX/share/boxfit

while read basename ; do
    curl -fsSL http://cosmo.nyu.edu/afterglowlibrary/boxfitdatav2/$basename >$basename
done <<EOF
boxboostmedwind_00.h5
boxboostmedwind_01.h5
boxboostmedwind_02.h5
boxboostmedwind_03.h5
boxboostmedwind_04.h5
boxboostmedwind_05.h5
boxboostmedwind_06.h5
boxboostmedwind_07.h5
boxboostmedwind_08.h5
EOF
