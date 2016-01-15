#! /bin/bash
# Copyright 2015-2016 Peter Williams <peter@newton.cx>
# Licensed under the MIT License.
#
# Set up an image that's ready to build Conda packages repeatably.

ANACONDA_ORG_USER=pkgw

set -e -x

# Centos 5 yum silliness
echo 'exclude=*.i386 *.i586 *.i686' >>/etc/yum.conf
yum update -y

# Base packages (keep alphabetized!)
yum install -y $(echo "
bison
bzip2
curl
emacs-nox
file
flex
gcc
gcc-c++
gcc-gfortran
gettext-devel
libstdc++-devel
make
man
man-pages
ncurses-devel
patch
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

# Devtools
wget http://people.centos.org/tru/devtools-2/devtools-2.repo -O /etc/yum.repos.d/devtools-2.repo
yum install -y $(echo "
devtoolset-2-binutils
devtoolset-2-elfutils
devtoolset-2-gcc
devtoolset-2-gcc-c++
devtoolset-2-gcc-gfortran
")

# We use RPMForge to get git
wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm
rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
rpm -K rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm
rpm -i rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm
yum update -y # get miscellaneous overrides
yum install -y $(echo "
git
")
rm -f rpmforge-release-0.5.3-1.el5.rf.x86_64.rpm

# Miniconda
# XXX: a Python 3 version would be different!
wget https://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p /conda
cat >~/.bashrc <<'EOF'
# .bashrc
alias l='ls -lart --color=auto'
PS1='\h \A \W \$ '
export PATH="/conda/bin:$PATH"
EOF
source ~/.bashrc
rm miniconda.sh
conda update --all

# Conda dev packages
conda install -y $(echo "
anaconda-client
conda-build
jinja2
pip
setuptools
")

# Other personalized Conda setup
conda config --add envs_dirs /conda/envs
conda config --add channels http://conda.anaconda.org/$ANACONDA_ORG_USER/channel/main
mkdir /conda/conda-bld
(cd /conda/conda-bld && ln -s /work/linux-64 linux-64)
