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

# Can now install git because we got epel-release
yum install -y $(echo "
git
")

# Devtools
wget http://people.centos.org/tru/devtools-2/devtools-2.repo -O /etc/yum.repos.d/devtools-2.repo
yum install -y $(echo "
devtoolset-2-binutils
devtoolset-2-elfutils
devtoolset-2-gcc
devtoolset-2-gcc-c++
devtoolset-2-gcc-gfortran
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
