#! /bin/bash
# Copyright 2015-2016 Peter Williams <peter@newton.cx>
# Licensed under the MIT License.
#
# This is the "entrypoint" script for the Conda build image. When a user runs
# "docker run forge-py2-builder build casa-tools", we are invoked with $1=build
# and $2=casa-tools.

set -e
export PATH=/conda/bin:$PATH

if [ -z "$1" -o "$1" = help ] ; then
    echo "You must supply a subcommand to run in the image. Commands are:

bash        -- Run a bash shell
build <pkg> -- Build the package described in /work/recipes/<pkg>
update      -- Run 'conda update --all'

E.g., use 'docker run -it buildercontainer bash' to launch an interactive
shell within a long-running container.
"
    exit 1
fi

command="$1"
shift

if [ "$command" = update ] ; then
    exec conda update --all
fi

if [ "$command" = bash ] ; then
    exec bash "$@"
fi

if [ "$command" = build ] ; then
    cd /work/recipes
    exec ./.builder.sh /work/recipes/$1
fi

echo "Unrecognized command \"$command\"."
exit 1
