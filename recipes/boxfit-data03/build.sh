#! /bin/bash
# Copyright 2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e

mkdir -p $PREFIX/share/boxfit
cd $PREFIX/share/boxfit

while read basename ; do
    curl -fsSL http://cosmo.nyu.edu/afterglowlibrary/boxfitdatav2/$basename >$basename
done <<EOF
boxboostmedwind_23.h5
boxboostmedwind_24.h5
boxboostmedwind_25.h5
boxboostmedwind_26.h5
boxboostmedwind_27.h5
boxboostmedwind_28.h5
boxboostmedwind_29.h5
boxboostmedwind_30.h5
boxboostmedwind_31.h5
boxboostmedwind_32.h5
boxboostmedwind_33.h5
boxboostwind_00.h5
boxboostwind_01.h5
boxboostwind_02.h5
boxboostwind_03.h5
boxboostwind_04.h5
boxboostwind_05.h5
boxboostwind_06.h5
EOF
