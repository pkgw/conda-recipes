#! /bin/bash

set -e
./configure.py --bootstrap

mkdir $PREFIX/bin
cp -p ninja $PREFIX/bin/ninja
