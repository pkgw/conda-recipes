#! /bin/bash

set -xeuo pipefail

which python
which pip

# Some bdsf build scripts assume that the Fortran compiler is gfortran
(cd $BUILD_PREFIX/bin && ln -s $FC gfortran)

export LDFLAGS="$LDFLAGS -shared"

python -m pip install . --no-deps -vv
#python setup.py install

