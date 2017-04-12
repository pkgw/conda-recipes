#! /bin/bash
#
# HEASoft has a lame build system that means that we have to do crappy stuff
# to get it to build. The build system is not parallel-friendly.

set -e

if [ $(uname) = Linux ] ; then
    export PATH=/opt/rh/devtoolset-2/root/usr/bin:$PATH
fi

export CFLAGS="-I$PREFIX/include $CFLAGS"
export CXXFLAGS="-std=c++11 -I$PREFIX/include $CXXFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"

configure_args=(
    --prefix=$PREFIX
    --enable-openmp
    --enable-collapse
    --x-includes=$PREFIX/include
    --x-libraries=$PREFIX/lib
    --with-components=Xspec
)

cd BUILD_DIR
./configure "${configure_args[@]}"
make
make install

# Whee, what a gnarly install.
#
# ## Skipped libraries:
#
# XSPlot - because it needs pgplot
# XSMinuit - because it needs minuit
# XSUser - because it needs Tcl
#
# ## Shipped libraries:
#
# wcs_xspec needs: nothing unusual
# CCfits needs: cfitsio
# XSUtil needs: nothing unusual
# XS potentially needs: m, gfortran, readline
# XSModel needs: XSUtil, CCfits
# XSFit needs: XSModel, XSUtil
# XSFunctions needs: XSModel XSUtil wcs_xspec CCfits cfitsio gfortran m(via libXS)
# xsmix needs: XSFunctions XSModel XSUtil CCfits

cd $PREFIX
mkdir -p include share/xspec

rm -rf spectral/help
rm -rf spectral/scripts
mv spectral/manager share/xspec/

platdir=$(dirname $(echo */headas-init.sh))
pushd $platdir

rm -rf bin BUILD_DIR fguipfiles help
rm -rf include/tcl* include/Tcl* include/Tk*
mv include ../include/xspec

pushd lib
mv libCCfits_*$SHLIB_EXT ../../lib/
mv libwcs-*$SHLIB_EXT ../../lib/libwcs_xspec$SHLIB_EXT
patchelf --set-soname libwcs_xspec$SHLIB_EXT ../../lib/libwcs_xspec$SHLIB_EXT
rm -f libXSPlot* libXSMinuit* libXSUser*
mv libXS*$SHLIB_EXT libxs*$SHLIB_EXT libXS.a ../../lib/
popd

mv refdata ../share/xspec/
popd

rm -rf $platdir
