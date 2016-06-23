#! /bin/bash
# Copyright 2015-2016 Peter Williams <peter@newton.cx>
# Licensed under the MIT License.

# Just Do It script: rebuild a package or packages on Linux. We use a
# persistent builder container for efficiency.

set -e

img_name=conda-py2-builder:latest
cont_name=py2-builder
recipe_topdir=$(cd $(dirname $0) && pwd)

# Make sure container is up and running

set +e
is_running=$(docker inspect --format="{{ .State.Running }}" $cont_name 2>/dev/null)
ec=$?
set -e

if [ $ec -eq 1 ] ; then
    # Most likely, the container doesn't exist at all.
    echo "Starting container ..."
    docker run -d -it -v "$recipe_topdir":/work --name $cont_name $img_name bash
    is_running=true
fi

if [ "$is_running" != "true" ] ; then
    # Container is stopped.
    docker start $cont_name
fi

# Ready to go.

while [ $# -gt 0 ] ; do
    pkg="$1"
    shift

    log="$recipe_topdir/recipes/$pkg/linux-64.log"
    echo "Building with logs to $log ..."
    set +e
    stdbuf -oL -eL docker exec $cont_name /entrypoint.sh build "$pkg" >"$log" 2>&1
    ec=$?
    set -e
    echo "========================================"
    tail -n8 "$log"
    echo "========================================"
    [ "$ec" -ne 0 ] && exit $ec
done
