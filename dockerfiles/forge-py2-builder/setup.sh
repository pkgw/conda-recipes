#! /bin/bash
# Copyright 2015-2016 Peter Williams <peter@newton.cx>
# Licensed under the MIT License.
#
# Set up an image that's ready to build Conda packages repeatably.

set -e -x

# Centos 5 yum silliness (XXX: we're now on CentOS 6 but this shouldn't hurt)
echo 'exclude=*.i386 *.i586 *.i686' >>/etc/yum.conf
yum update -y

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

# Python 2 Miniconda
wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p /conda
cat >~/.bashrc <<'EOF'
# .bashrc
alias l='ls -lart --color=auto'
PS1='\h \A \W \$ '
export PATH="/conda/bin:$PATH"
EOF
source ~/.bashrc
rm miniconda.sh

# Enable Conda Forge
conda config --add channels conda-forge
conda update --all -y

# Conda dev packages
conda install -y $(echo "
conda-build
jinja2
pip
setuptools
")

# Miscellaneous Conda config
conda config --add envs_dirs /conda/envs
mkdir /conda/conda-bld
(cd /conda/conda-bld && ln -s /work/linux-64 linux-64)

# Docker infrastructure cleanup
chmod +x /entrypoint.sh
rm /setup.sh # self-destruct!
