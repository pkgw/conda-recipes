#! /bin/bash
# Copyright 2016 Peter Williams and collaborators.
# This file is licensed under a 3-clause BSD license; see LICENSE.txt.

[ "$NJOBS" = '<UNDEFINED>' ] && NJOBS=1
set -e

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    platform=macintel
    # surely more to do ...
else
    platform=linux64
fi

mkdir -p $PREFIX/bin $PREFIX/lib
ln -s $(pwd) $PREFIX/lib/iraf
iraf=$PREFIX/lib/iraf
cd $iraf

# build system is too crappy to disable features that should be optional, so
# just ignore errors and hope that most stuff worked out.
(bash build.sh $platform |tee -i LOG 2>&1) || true

# Remove the symlink and actually install
rm $iraf
mkdir -p $iraf/bin.$platform $iraf/bin.noarch $iraf/extern $iraf/unix/hlib

# Copy only the files needed at runtime; this list of extensions based on
# the contents of "local/lib/strip.local":
find lib local noao pkg unix/hlib vo \
     -name '*.cl' -o -name '*.dat' -o -name '*.def' -o -name '*.hd' -o \
     -name '*.hlp' -o -name '*.key' -o -name '*.men' -o -name '*.mip' -o \
     -name '*.par' -o -name '*.pkg' \
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

cd $PREFIX/bin
ln -s ../lib/iraf/bin.noarch/cl.csh cl
ln -s ../lib/iraf/bin.noarch/mkiraf.csh mkiraf
