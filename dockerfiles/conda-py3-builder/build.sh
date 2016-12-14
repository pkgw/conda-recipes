#! /bin/bash
# Copyright 2015-2016 Peter Williams
# Licensed under the MIT License.

set -e

base=conda-py3-builder
tag=$(date +%Y%m%d)

docker build -t $base:$tag .
docker tag $base:$tag $base:latest
