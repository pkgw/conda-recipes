#! /bin/bash
# Copyright 2015-2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

# Java must be installed to build this package! Lame but not too hard to deal
# with.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e

cmake_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_COLOR_MAKEFILE=OFF
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DCMAKE_STATIC_LINKER_FLAGS=-L$PREFIX/lib
    -DCXX11=ON
    -DPGPLOT_INCLUDE_DIRS=$PREFIX/include/pgplot
    -DQWT_INCLUDE_DIRS=$PREFIX/include/qwt5
)

#cmake_args+=(--debug-trycompile --debug-output --trace)

if [ -n "$OSX_ARCH" ] ; then
    # Need to require 10.7 because of the C++11 features.
    export MACOSX_DEPLOYMENT_TARGET=10.7

    # Ugh. install_name fixup currently needed; have to copy since
    # install_name_tool patches in place and the files are hardlinked out of
    # the pkgs tree!
    for lib in xml2 xslt readline ; do
	lpath=$PREFIX/lib/lib${lib}.dylib
	mv $lpath $lpath.tmp
	cp $lpath.tmp $lpath
	rm -f $lpath.tmp
	iname=$(otool -D $lpath |sed -e '2!d')
	install_name_tool -id @rpath/$iname $lpath
    done

    # This is needed to get our EXTRA_CXX_FLAGS to take effect. I like how
    # every CASA package handles C++ flags differently.
    unset CXXFLAGS CFLAGS

    cmake_args+=(
	-Darch=darwin64
	-Darchflag=x86_64
	-DCMAKE_Fortran_COMPILER=/usr/local/bin/gfortran-4.2
	-DCMAKE_OSX_DEPLOYMENT_TARGET=$MACOSX_DEPLOYMENT_TARGET
	-DCMAKE_OSX_SYSROOT=/
	-DEXTRA_CXX_FLAGS="-arch $OSX_ARCH -stdlib=libc++ -std=c++11"
	-DPGPLOT_LIBRARIES="$PREFIX/lib/libpgplot.dylib;$PREFIX/lib/libcpgplot.a"
    )
else
    toolroot=/opt/rh/devtoolset-2/root

    cmake_args+=(
	-DBLAS_LIBRARIES="$PREFIX/lib/libopenblas.so"
	-DCMAKE_C_COMPILER=$toolroot/usr/bin/gcc
	-DCMAKE_CXX_COMPILER=$toolroot/usr/bin/g++
	-DCMAKE_EXE_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
	-DCMAKE_Fortran_COMPILER=$toolroot/usr/bin/gfortran
	-DCMAKE_MODULE_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
	-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-rpath-link,$PREFIX/lib
	-DLAPACK_LIBRARIES="$PREFIX/lib/libopenblas.so"
	-DPGPLOT_LIBRARIES="$PREFIX/lib/libpgplot.so;$PREFIX/lib/libcpgplot.a"
    )
fi

cd gcwrap
mkdir build
cd build
cmake "${cmake_args[@]}" ..
make -j$NJOBS VERBOSE=1

# Blow away a lot of files ... We need to keep TablePlotTkAgg.py since CASA's
# bizarre plotting code automatically imports it (from C++!) even without the
# casapy frontend. Fortunately things still seem to work even though much of
# the plotting stuff doesn't get hooked up and our matplotlib version is
# different (I think).

cd $PREFIX
rm -rf xml
rm bin/{buildmytasks,casa,casapy,xmlgenpy} lib/saxon*.jar

# consistent include directories:
mv include/casa/* include/casacode/
rmdir include/casa

mkdir -p $SP_DIR
casapydir=$(echo python/2.*)
for stem in __casac__ casac.py casadef.py TablePlotTkAgg.py ; do
    mv $casapydir/$stem $SP_DIR/
done
rm -rf python # note! not lib/python ...
