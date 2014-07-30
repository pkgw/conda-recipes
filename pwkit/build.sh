#! /bin/bash
#
# See http://docs.continuum.io/conda/build.html for a list of environment
# variables that are set during the build process.

exec $PYTHON setup.py install
