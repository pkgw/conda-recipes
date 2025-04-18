#! /bin/bash
# Copyright Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -xeuo pipefail

cargo install --path . --root $PREFIX
rm -f $PREFIX/.crates*
