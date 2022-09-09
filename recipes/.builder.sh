#! /bin/bash
# Copyright 2015-2020 Peter Williams <peter@newton.cx>
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

set -ex

case "$1" in
    --python=*)
        build_args+=("$1")
        shift
        ;;
esac

if [ -z "$1" ] ; then
    echo 1>&2 "error: must specify the recipe directory to build"
    exit 1
fi

recipedir="$1"
if [ ! -d "$recipedir" ] ; then
    echo 1>&2 "error: \"$recipedir\" is not a directory"
    exit 1
fi

rm -rf /conda/conda-bld/condabuilder.*
work=$(mktemp -d condabuilder.XXXXXX)

if [ -f $recipedir/.excludes ] ; then
    arg="-X $recipedir/.excludes"
fi

tar c -C $recipedir -X $(pwd)/.global_excludes $arg . |tar x -C "$work"
export PYTHONUNBUFFERED=1
conda update -y --all

# We used to symlink /conda package output directories into /vagrant but
# currently (2022 Sep) this causes a conda-build crash, so we need to explicitly
# sync.
if [ "$(uname)" = Darwin ] ; then
    for a in broken noarch osx-64 ; do
        rsync -avP /vagrant/artifacts/$a /conda/conda-bld
        pushd /conda/conda-bld
        conda index
        popd
    done
fi

conda build -m /conda/conda_build_config.yaml "${build_args[@]}" "$work"

if [ "$(uname)" = Darwin ] ; then
    for a in broken noarch osx-64 ; do
        rsync -avP /conda/conda-bld/$a /vagrant/artifacts
    done
fi

rm -rf "$work"
