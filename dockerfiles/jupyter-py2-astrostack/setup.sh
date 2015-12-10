#! /bin/bash
# Copyright 2015 Peter Williams <peter@newton.cx>
# Licensed under the MIT License.
#
# Set up an image with a preinstalled astronomical Python (2.x) stack. It
# notably includes CASA, which makes it a very hefty image.

set -e -x

# Base packages (keep alphabetized!)
yum install -y $(echo "
bzip2
curl
emacs-nox
file
strace
tar
wget
which
xz
")

# Python 2.x Miniconda
wget https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p /conda
rm miniconda.sh

# Config customization
conda config --add envs_dirs /conda/envs
conda config --add channels http://conda.anaconda.org/pkgw/channel/main

conda update -y --all

conda install -y $(echo "
astropy
astroquery
casa-data
casa-python
cython
h5py
jupyter
matplotlib
modern-xorg-stack
notebook
numexpr
numpy
pandas
pwkit
pymc
pytables
scikit-learn
scipy
sqlite
sympy
xray
")
