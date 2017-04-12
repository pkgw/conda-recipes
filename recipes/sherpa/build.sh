#! /bin/bash

set -e

cat >setup.cfg <<EOF
[aliases]
build_ext = sherpa_config xspec_config build_ext
develop = sherpa_config xspec_config develop
test = develop test
bdist_wheel = sherpa_config bdist_wheel

[sherpa_config]
install_dir=$PREFIX
extra-fortran-link-flags=-shared
fftw=local
fftw-include_dirs=$PREFIX/include
fftw-lib-dirs=$PREFIX/lib
fftw-libraries=fftw3
wcs=local
wcs-include-dirs=$PREFIX/include/wcstools
wcs-lib-dirs=$PREFIX/lib
wcs-libraries=wcstools

[xspec_config]
with-xspec=True
xspec_lib_dirs=$PREFIX/lib
cfitsio_lib_dirs=$PREFIX/lib
ccfits_lib_dirs=$PREFIX/lib
ccfits_libraries=CCfits_2.5
wcslib_lib_dirs=$PREFIX/lib
wcslib_libraries=wcs_xspec
gfortran_lib_dirs=$PREFIX/lib
EOF

python setup.py install --prefix=$PREFIX

cd $PREFIX
find . -name '*.la' -delete
rm -f bin/sherpa_smoke bin/sherpa_test

pushd include
rm -f cxcregion.h dmstack.h grplib.h region_priv.h regpar.h stack.h
popd

pushd lib
for stem in grp region stk ; do
    rm -f lib$stem$SHLIB_EXT* lib$stem.a
done
popd

pushd $SP_DIR
rm -f group.a stk.a
popd

rm -rf share/doc
