#! /bin/bash

set -e

if [ $(uname) = Linux ] ; then
    export PATH=/opt/rh/devtoolset-2/root/usr/bin:$PATH
fi

configure_args=(
    --disable-docs
    --enable-clang
    --prefix="$PREFIX"
)
./configure "${configure_args[@]}"
make -j$CPU_COUNT
make install

cd $PREFIX
rm -rf lib/rustlib/install.log lib/rustlib/uninstall.sh share/doc/rust share/man
