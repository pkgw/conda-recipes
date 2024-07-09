#! /bin/bash
# Copyright Peter Williams <peter@newton.cx>
# Licensed under the MIT License.
#
# Set up an image that's ready to build Conda packages repeatably.

set -ex

# Base packages (keep alphabetized!)
yum install -y $(echo "
bison
bzip2
curl
emacs-nox
file
flex
git
glibc-devel
libstdc++-devel
make
man
man-pages
mesa-libEGL-devel
ncompress
patch
perl-XML-Parser
pkgconfig
strace
subversion
sudo
tar
tcsh
wget
which
xz
zip
")

# Set up a user whose UID/GID match the person building the container. A
# fancier setup would be to do this on container bootup, since different users
# could want to use the same image.

groupadd -g $EXTGRPID -o conda
useradd --shell /bin/bash -u $EXTUSERID -g conda -G wheel -o -c "" -m conda
mkdir /conda
chown conda:conda /conda

# Farm out to the unprivileged script
su -l conda -c "bash -x /setup-unpriv.sh"

# Docker infrastructure cleanup
chmod +x /entrypoint.sh
rm /setup.sh /setup-unpriv.sh # self-destruct!
