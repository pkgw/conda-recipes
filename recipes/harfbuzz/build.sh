#! /bin/bash

set -e
./configure --prefix=$PREFIX --disable-gtk-doc || { cat config.log ; exit 1 ; }
make -j$(nproc --ignore=4)
make install

cd $PREFIX
rm -rf share/gtk-doc

# workaround for libffi .la file path issues
sed -i -e 's|lib/\.\./lib64|lib|g' lib/*.la
