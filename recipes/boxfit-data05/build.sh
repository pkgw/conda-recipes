#! /bin/bash
# Copyright 2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e

mkdir -p $PREFIX/share/boxfit
cd $PREFIX/share/boxfit

while read basename ; do
    curl -fsSL http://cosmo.nyu.edu/afterglowlibrary/boxfitdatav2/$basename >$basename
done <<EOF
boxboostISM_04.h5
boxboostISM_05.h5
boxboostISM_06.h5
boxboostISM_07.h5
boxboostISM_08.h5
boxboostISM_09.h5
boxboostISM_10.h5
boxboostISM_11.h5
boxboostISM_12.h5
boxboostISM_13.h5
boxboostISM_14.h5
boxboostISM_15.h5
boxboostISM_16.h5
boxboostISM_17.h5
boxboostISM_18.h5
boxboostISM_19.h5
boxboostISM_20.h5
boxboostISM_21.h5
boxboostISM_22.h5
EOF
