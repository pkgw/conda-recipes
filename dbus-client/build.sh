#! /bin/bash
#
# We disable systemd since otherwise the installation tries to write to
# /usr/lib/... even though we've specified --prefix.

set -e
./configure --prefix=$PREFIX --disable-tests --disable-systemd || { cat config.log ; exit 1 ; }
make
make install

cd $PREFIX
rm -rf bin etc libexec share
