#!/ bin/bash
# Copyright 2015 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

# As mentioned in meta.yaml, this package aims to provide the QtDBus subsystem
# of Qt, which is not included in the "qt" package on Mac OS X.
#
# The most-sensible approach that I can think of is to emulate my dbus-client
# or cairo-gobject packages: simply rebuild the package, but delete the
# already-provided files after installation. However, we need to provide some
# executables, and if we delete all of the non-DBus files after install,
# Conda's binary fixup routines end up crashing when they try to process the
# executables.
#
# The workaround is to have us depend on "qt" during build, since Conda will
# think that redundant installed libraries belong to the preexisting package,
# so it won't include them in the new package. However, this workaround adds
# its own wrinkle: various steps of the build process get confused by the
# preexisting Qt headers in $PREFIX, resulting in a crash. Therefore, before
# we begin the build proper, we trash those headers.
#
# Finally, there are a couple of headers in the main "qt" package that encode
# the configuration result that DBUS isn't available:
# {Qt,QtCore}/q{features,config}.h. I've chosen to modify the definitions in a
# post-link script. I could also sed the qdbus headers to remove the gate, but
# that seems potentially confusing for anything else that checks out
# QT_NO_DBUS.

[ "$NJOBS" = '<UNDEFINED>' ] && NJOBS=1
set -e

if [ `uname` != Darwin ]; then
    echo This package is only needed for Darwin
    exit 1
fi

# Step 1: remove stuff from existing "qt" package that confuses the build. I
# only know that the include files do, but it can't hurt to trash the other
# stuff. Of course we have to make sure not to trash files corresponding to
# our *actual* build dependencies. We also leave lib/libQt*, since we need
# to build the "tools" and some of them require QtGui, and it saves us a TON
# of time to not have to build that ourselves.

work=$(pwd)
cd $PREFIX
rm -rf imports include/Qt* include/phonon \
   lib/libphonon.* lib/pkgconfig/Qt* mkspecs plugins

# Step 2: build a version that includes QtDBus and as few other bits as we can
# manage.

cd "$work"
export MACOSX_DEPLOYMENT_TARGET=10.6
sdk=/ # AFAIK we won't want to change this, but just in case
unset CFLAGS CXXFLAGS LDFLAGS

chmod +x configure
./configure \
    -release -fast -prefix $PREFIX -platform macx-g++ \
    -no-qt3support -nomake examples -nomake demos -nomake docs \
    -opensource -verbose -openssl -no-framework -system-libpng \
    -L $PREFIX/lib -I $PREFIX/include \
    \
    -no-xmlpatterns -no-multimedia -no-audio-backend -no-phonon \
    -no-svg -no-webkit -no-javascript-jit -no-script -no-gui \
    -no-scripttools -no-declarative -no-declarative-debug \
    -no-opengl -nomake translations -dbus -arch $OSX_ARCH -sdk $sdk

make -j$NJOBS
make install

# Step 3: blow away everything that isn't DBus. I actually think that we could
# mostly skip this part, since all of the non-DBus Qt files will get
# interpreted as belonging to the installed Qt package, but I already wrote
# this part so let's just delete stuff.

cd $PREFIX
rm -rf mkspecs phrasebooks plugins q3porting.xml

cd $PREFIX/bin
for f in * ; do
    case "$f" in
	*dbus*) ;;
	*) rm -rf "$f" ;;
    esac
done

cd $PREFIX/include
for f in * ; do
    case "$f" in
	*DBus*) ;;
	Qt) ;;
	*) rm -rf "$f" ;;
    esac
done

cd $PREFIX/include/Qt
for f in * ; do
    case "$f" in
	*DBus*) ;;
	*dbus*) ;;
	*) rm -f "$f" ;;
    esac
done

cd $PREFIX/lib/pkgconfig
for f in * ; do
    case "$f" in
	*DBus*) ;;
	*) rm -f "$f" ;;
    esac
done
