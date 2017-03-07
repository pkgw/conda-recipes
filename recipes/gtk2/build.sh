#!/bin/bash -x -e

post_install() {
  # remove libtool la files, assuming all la files are from libtool
  find "$PREFIX" -name \*.la -exec /bin/rm {} \;
  # strip binaries
  find "$PREFIX" -type f -perm -0100 ! -name \*.debug -links 1 -exec sh -c \
       'if file {} | grep -q " ELF "; then
          strip --strip-unneeded -R .comment "{}"
          echo "-> {}"
        fi' \;
  echo '-- end of post_install() --'
}


./configure --prefix=$PREFIX \
            --enable-shared --disable-static \
            --disable-visibility --disable-introspection \
            --disable-glibtest --disable-cups --disable-papi \
            --with-included-immodules
make -j$CPU_COUNT
make -j$CPU_COUNT RUN_QUERY_IMMODULES_TEST=false install
rm -rf $PREFIX/share/gtk-doc
post_install
