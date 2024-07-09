#! /bin/bash
# Copyright Peter Williams
# Licensed under the MIT License.

set -e

# XXXX: errors building the image related to resource limits, unless I change
# the user/group ID away from those of my user account? Mysterious but I worked
# around by just replace $(id -u) with 1111, etc.

exec docker build \
  --ulimit nofile=8192:8192 \
  --network=host \
  --build-arg=EXTUSERID=$(id -u) --build-arg=EXTGRPID=$(id -g) \
  -t forge-builder \
  $(dirname $0)
