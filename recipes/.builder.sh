#! /bin/bash
# Copyright 2015-2016 Peter Williams <peter@newton.cx>
# Licensed under the MIT License.
#
# This script is run inside the standardized Docker container to build a Conda
# package. We keep it separate from the container so that we don't need to
# make a whole new container just to adjust the builder script. We are run
# from the 'recipes' directory, and the argument is a fully-qualified path to
# the directory with the recipe we're supposed to build.
#
# The only interesting thing we do is copy files to a temporary directory
# since "conda build" slurps everything in the recipe directory into the built
# package, including tilde backup files, etc.

set -e

if [ -z "$1" ] ; then
    echo 1>&2 "error: must specify the recipe directory to build"
    exit 1
fi

recipedir="$1"
work=$(mktemp -d)

if [ -f $recipedir/.excludes ] ; then
    arg="-X $recipedir/.excludes"
fi

tar c -C $recipedir -X $(pwd)/.global_excludes $arg . |tar x -C "$work"
conda update --all
conda build "$work"
rm -rf "$work"
