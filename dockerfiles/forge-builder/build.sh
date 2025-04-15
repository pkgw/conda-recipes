#! /bin/bash
# Copyright Peter Williams
# Licensed under the MIT License.

set -e

exec docker build \
  --ulimit nofile=8192:8192 \
  --network=host \
  --build-arg=EXTUSERID=$(id -u) --build-arg=EXTGRPID=$(id -g) \
  -t forge-builder \
  $(dirname $0)
