#! /bin/bash

set -e
./waf configure --prefix=$PREFIX
./waf build
./waf install
