#! /bin/bash

set -e
set -o pipefail

# What a pain. Cargo can now only be built with Cargo. @dhuseby on GitHub has
# made a thing that can bootstrap it but it doesn't seem to work anymore. So,
# let's download the entire Rust toolchain! This is actually not that painful.

if [ $(uname) = Linux ] ; then
    triple="x86_64-unknown-linux-gnu"
elif [ $(uname) = Darwin ] ; then
    triple="x86_64-apple-darwin"
else
    echo "unsupported build host but easy to fix"
    exit 1
fi

version="1.18.0"
url="https://static.rust-lang.org/dist/rust-${version}-${triple}.tar.gz"
curl -ssL "$url" |tar xz
pushd rust-${version}-${triple}
./install.sh --prefix=$(pwd)/../temprust --without=rust-docs
popd

export PATH="$(pwd)/temprust/bin:$PATH"

# Gross: the libgit2-sys build system has some weaknesses where it tries to
# link to libiconv but doesn't try to figure out where it lives. This is the
# best solution I can come up with.

if [ $(uname) = Darwin ] ; then
    cp $PREFIX/lib/libiconv.dylib temprust/lib/rustlib/$triple/lib/
fi

# Now that that's taken care of, the rest is straightforward.

cargo build --release
#CFG_DISABLE_CROSS_TESTS=1 cargo test # some of these fail on Linux
cargo install --root $PREFIX

# Not sure what this is ...
rm -f $PREFIX/.crates.toml
