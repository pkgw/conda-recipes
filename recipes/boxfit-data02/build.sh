#! /bin/bash
# Copyright 2017 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e

mkdir -p $PREFIX/share/boxfit
cd $PREFIX/share/boxfit

while read basename ; do
    curl -fsSL http://cosmo.nyu.edu/afterglowlibrary/boxfitdatav2/$basename >$basename
done <<EOF
boxboostmedwind_09.h5
boxboostmedwind_10.h5
boxboostmedwind_11.h5
boxboostmedwind_12.h5
boxboostmedwind_13.h5
boxboostmedwind_14.h5
boxboostmedwind_15.h5
boxboostmedwind_16.h5
boxboostmedwind_17.h5
boxboostmedwind_18.h5
boxboostmedwind_19.h5
boxboostmedwind_20.h5
boxboostmedwind_21.h5
boxboostmedwind_22.h5
EOF
