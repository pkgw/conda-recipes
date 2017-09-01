#! /bin/bash
# Copyright 2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e

mkdir -p $PREFIX/share/boxfit
cd $PREFIX/share/boxfit

while read basename ; do
    curl -fsSL http://cosmo.nyu.edu/afterglowlibrary/boxfitdatav2/$basename >$basename
done <<EOF
boxboostwind_07.h5
boxboostwind_08.h5
boxboostwind_09.h5
boxboostwind_10.h5
boxboostwind_11.h5
boxboostwind_12.h5
boxboostwind_13.h5
boxboostwind_14.h5
boxboostwind_15.h5
boxboostwind_16.h5
boxboostwind_17.h5
boxboostwind_18.h5
boxboostwind_19.h5
boxboostwind_20.h5
boxboostwind_21.h5
boxboostwind_22.h5
boxboostISM_00.h5
boxboostISM_01.h5
boxboostISM_02.h5
boxboostISM_03.h5
EOF
