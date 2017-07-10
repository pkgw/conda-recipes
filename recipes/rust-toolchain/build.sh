#! /bin/bash

set -e

if [ $(uname) = Linux ] ; then
    triple="x86_64-unknown-linux-gnu" # not currently used here but nice to have around
    export PATH=/opt/rh/devtoolset-2/root/usr/bin:$PATH
elif [ $(uname) = Darwin ] ; then
    triple="x86_64-apple-darwin"
    export RUSTFLAGS="-C link-args=-Wl,-headerpad_max_install_names"
    export CFLAGS="$CFLAGS -Wl,-headerpad_max_install_names"

    # Gross: the libgit2-sys build system has some weaknesses where it tries
    # to link to libiconv but doesn't try to figure out where it lives. This
    # is the best solution I can come up with.

    mkdir -p build/$triple/stage2-tools/release/deps
    cp $PREFIX/lib/libiconv.dylib build/$triple/stage2-tools/release/deps/
fi

# The configuration file has an "extended" option which makes it seem as if it
# should install `cargo` too, which would be nice since then we could skip
# having a separate-but-closely-aligned `cargo` package. But it doesn't
# actually install `cargo`, so I must be misinterpreting what it does.

cat <<EOF >config.toml
[llvm]
ninja = true

[build]
docs = false
python = "$PYTHON"

[install]
prefix = "$PREFIX"
EOF

./x.py build -vv
./x.py dist --install

cd $PREFIX
rm -rf lib/rustlib/components lib/rustlib/etc lib/rustlib/install.log lib/rustlib/uninstall.sh
rm -rf share/man/man1
