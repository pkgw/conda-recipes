#! /bin/bash
# Copyright 2015-2020 Peter Williams <peter@newton.cx>
# Licensed under the MIT License.

# Just Do It script: rebuild a package or packages on OS X.

set -e

recipe_topdir=$(cd $(dirname $0) && pwd)
builder_args=("--python='3.8.* *_cpython'")

# Make sure container is up and running

echo "- Don't forget ./start-vagrant.sh"
vagrant up >/dev/null

# Ready to go.

while [ $# -gt 0 ] ; do
    pkg="$1"
    shift
    if [ ! -d "$recipe_topdir/recipes/$pkg" ] ; then
	echo >&2 "error: no such package $pkg"
	exit 1
    fi

    log="$recipe_topdir/recipes/$pkg/osx-64-py3.log"
    echo "Building with logs to $log ..."
    set +e
    stdbuf -oL -eL vagrant ssh -c "cd /vagrant/recipes/ && ./.builder.sh ${builder_args[@]} /vagrant/recipes/$pkg" >"$log" 2>&1
    ec=$?
    set -e
    echo "========================================"
    tail -n8 "$log"
    echo "========================================"
    [ "$ec" -ne 0 ] && exit $ec
done

exit 0
