#! /bin/bash

set -e
IFS=$' \t\n' # workaround for conda 4.2.13+toolchain bug

configure_args=(
    --prefix=$PREFIX
    --with-compile
    --with-include=$PREFIX/include
    --with-ascii
    --with-ots=$PREFIX
    --with-fits
)

export LDFLAGS="$LDFLAGS -Wl,-rpath,$PREFIX/lib"

./configure "${configure_args[@]}"
make install # note: build breaks if we just do "make" first

# NOTE: this will break on a conda-forge type setup where we run multiple
# builds in the same work environment.
#
# shlib situation:
#
# pytransform requires: libtransform, libwcstools
# region requires: libascdm, libcfitsio, libregion, libwcstools
# cxcdm requires: libascdm, libcfitsio, libregion, libwcstools
#
# libascdm requires: libcfitsio, libregion, libwcstools
# libregion requires: nothing
# libtransform requires: libwcstools

cd $PREFIX
rm bin/*
rm -rf binexe config include lib/pkgconfig share/doc test
rm -f COPYING COPYING.LIB INSTALL_BINARY INSTALL_SOURCE LICENSE \
   LICENSE.SAO *.html README README.obsvis VERSION VERSION.prop_tk

pushd lib
rm -f *.a *.la
rm -f libASCHelp.* libcxcparam.* liberr.* libgrp.*
popd

pushd lib/python*/site-packages
rm -rf ahelp* group.* ipython_cxc.py paramio
popd
