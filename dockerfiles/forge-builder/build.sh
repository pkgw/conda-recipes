#! /bin/bash
# Copyright 2015-2018 Peter Williams
# Licensed under the MIT License.

set -e
exec docker build --network=host --build-arg=EXTUSERID=$(id -u) --build-arg=EXTGRPID=$(id -g) -t forge-builder .
