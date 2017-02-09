#! /bin/bash
# Copyright 2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' -o -z "$NJOBS" ] && NJOBS=1
set -e
set -o pipefail # we have that key "|tee" command ...
test $(echo "$PREFIX" |wc -c) -gt 200 # check that we're getting long paths

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    platform=macintel
else
    platform=linux64
fi

mkdir -p $PREFIX/bin $PREFIX/lib
ln -s $(pwd) $PREFIX/lib/iraf
iraf=$PREFIX/lib/iraf
cd $iraf

# Here we go ...
export EXTRA_LDFLAGS="-L$PREFIX/lib $(curl-config --libs) -Wl,-rpath,$PREFIX/lib"
bash build.sh $platform $PREFIX/lib/iraf $PREFIX 2>&1 |tee -i LOG

# Remove the symlink and actually install
rm $iraf
mkdir -p $iraf/bin.$platform $iraf/bin.noarch $iraf/unix/hlib

# Hardcoded bits assume the existence of an "extern" directory. They also do a
# globbed ls of it, so we have to stick something there.

mkdir $iraf/extern
touch $iraf/extern/placeholder

# Copy only the files needed at runtime; this list of extensions based on
# the contents of "local/lib/strip.local":
find lib local noao pkg unix/hlib vendor/x11iraf vo \
     -name '*.cl' -o \
     -name '*.dat' -o \
     -name '*.def' -o \
     -name '*.e' -o \
     -name '*.gui' -o \
     -name '*.hd' -o \
     -name '*.hlp' -o \
     -name '*.key' -o \
     -name '*.men' -o \
     -name '*.mip' -o \
     -name '*.par' -o \
     -name '*.pkg' \
     |tar c --files-from - |tar x -C $iraf

cp -a bin.$platform/* $iraf/bin.$platform/
for s in cl ecl mkiraf mkmlist ; do
    dest=$iraf/bin.noarch/$s.csh
    # Auto-set the environment
    cat <<EOF >$dest
#! /bin/csh -f
# Hardcoded settings for the Conda packages:
setenv iraf "$iraf/"
setenv host "\${iraf}unix/"
setenv hlib "\${host}hlib/"
setenv IRAFARCH "$platform"
setenv MACH "$platform"
setenv arch ".\$IRAFARCH"
setenv tmp "/tmp/"
# End of hardcoded settings.

EOF
    cat unix/hlib/$s.csh >>$dest
    chmod +x $dest
done

# Random support data files
mkdir -p $iraf/dev
for f in graphcap termcap ; do
    cp dev/$f $iraf/dev/$f
done
touch $iraf/dev/hosts # no hardcoded list of some random site's hosts!
touch $iraf/unix/hlib/utime

# X11 binaries.
for p in obmsh resize vximtool xgterm ximtool ; do
    cp vendor/x11iraf/bin/$p $PREFIX/bin/
done

# Globally-visible binaries.
cd $PREFIX/bin
ln -s ../lib/iraf/bin.noarch/cl.csh cl
ln -s ../lib/iraf/bin.noarch/mkiraf.csh mkiraf
