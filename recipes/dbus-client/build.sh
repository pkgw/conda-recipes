#! /bin/bash
# Copyright 2014-2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

# We disable systemd since otherwise the installation tries to write to
# /usr/lib/... even though we've specified --prefix.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"
fi

./configure --prefix=$PREFIX --disable-tests --disable-systemd || { cat config.log ; exit 1 ; }
make -j$NJOBS
make install

cd $PREFIX
find . '(' -name '*.la' -o -name '*.a' ')' -delete
rm -rf etc libexec share
rm $(echo "
bin/dbus-cleanup-sockets
bin/dbus-launch
bin/dbus-monitor
bin/dbus-run-session
bin/dbus-send
bin/dbus-test-tool
")
mkdir -p var/lib/dbus
echo placeholder >var/lib/dbus/machine-id # filled in by post-link.sh
