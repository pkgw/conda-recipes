#! /bin/bash
# Copyright 2015-2018 Peter Williams <peter@newton.cx>
# Licensed under the MIT License.
#
# Set up an image that's ready to build Conda packages repeatably.

set -e -x

# Base packages (keep alphabetized!)
yum install -y $(echo "
bison
bzip2
centos-release-scl
curl
emacs-nox
epel-release
file
flex
gcc
gcc-c++
gcc-gfortran
gettext-devel
java
libstdc++-devel
make
man
man-pages
ncompress
ncurses-devel
patch
perl-XML-Parser
pkgconfig
strace
subversion
tar
tcsh
wget
which
xz
zip
")

# Can now install git and devtools because we added extra repositories
yum install -y $(echo "
devtoolset-7-binutils
devtoolset-7-elfutils
devtoolset-7-gcc
devtoolset-7-gcc-c++
devtoolset-7-gcc-gfortran
git
")

# Set up a user whose UID/GID match the person building the container. A
# fancier setup would be to do this on container bootup, since different users
# could want to use the same image.

groupadd -g $EXTGRPID -o conda
useradd --shell /bin/bash -u $EXTUSERID -g conda -o -c "" -m conda
mkdir /conda
chown conda:conda /conda

# Farm out to the unprivileged script
su -l conda -c "bash -x /setup-unpriv.sh"

# Docker infrastructure cleanup
chmod +x /entrypoint.sh
rm /setup.sh /setup-unpriv.sh # self-destruct!
