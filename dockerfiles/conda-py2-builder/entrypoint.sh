#! /bin/bash
# Copyright 2015 Peter Williams <peter@newton.cx>
# Licensed under the MIT License.
#
# This is the "entrypoint" script for the Conda build image. When a user runs
# "docker run pkgw/conda-py2 build casa-tools", we are invoked with $1=build
# and $2=casa-tools.

set -e
export PATH=/conda/bin:$PATH

if [ -z "$1" -o "$1" = help ] ; then
    echo "You must supply a subcommand to run in the image. Commands are:

bash        -- Run a bash shell
build <pkg> -- Build the package described in /work/recipes/<pkg>
update      -- Run 'conda update --all'

E.g., use 'sudo docker run -it pkgw/conda-py2 bash' to launch an interactive
shell within the container.
"
    exit 1
fi

if [ "$1" = update ] ; then
    exec conda update --all
fi

if [ "$1" = bash ] ; then
    exec bash
fi

if [ "$1" = build ] ; then
    if [ -z "$2" ] ; then
	echo 1>&2 "error: must specify the name of the package to build"
	exit 1
    fi

    # We copy files to a temporary directory since "conda build" slurps
    # everything in the recipe directory into the built package, including
    # tilde backup files, etc.
    cd /work/recipes/$2
    work=$(mktemp -d)
    shopt -s nullglob
    cp meta.yaml build.sh *.bat *.patch "$work"

    # Looks like we're all set; let's do this.
    conda update --all
    exec conda build "$work"
fi

echo "Unrecognized command \"$1\"."
exit 1
