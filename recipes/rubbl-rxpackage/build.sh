#! /bin/bash
# Copyright 2019 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -ex

cargo install --path . --root $PREFIX
rm -f $PREFIX/.crates.toml
