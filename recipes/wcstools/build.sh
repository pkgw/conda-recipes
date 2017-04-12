#! /bin/bash

set -e
IFS=$' \t\n' # workaround for conda 4.2.13+toolchain bug
[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

# The makefiles are too lamebrained to worry about

pushd libwcs
rm -f *0.c *1.c ang2str.c caphot.c fortcat.c fortwcs.c log.c nut2006.c polfit.c \
   shrink.c str2*.c tabsort.c
popd
gcc -shared -fPIC -DPIC $CFLAGS $LDFLAGS -o libwcstools$SHLIB_EXT libwcs/*.c

mkdir -p $PREFIX/lib $PREFIX/include/wcstools
cp libwcstools$SHLIB_EXT $PREFIX/lib/
cp libwcs/*.h $PREFIX/include/wcstools/
