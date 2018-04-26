#! /bin/bash
# Copyright 2015-2018 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

set -e

# If git-lfs is properly integrated the 'git checkout' command invoked by the
# 'distro' script will somehow magically slurp just the desired files. But
# that doesn't work in my build environment so I've slapped together something
# that seems to work.

set -x
mkdir -p $PREFIX/lib/casa
cd $PREFIX/lib/casa
git clone --no-checkout https://open-bitbucket.nrao.edu/scm/casa/casa-data.git data
cd data
git lfs install
git show HEAD:distro |bash
find . -type f |egrep -v '^./.git' |xargs -n1 git lfs fetch -I
find . -type f |egrep -v '^./.git' |xargs git lfs checkout
rm -rf .git
