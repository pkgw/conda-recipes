#! /usr/bin/env bash
# Copyright 2015-2016 Peter Williams.
# Licensed under the MIT License.
#
# Set up a Mac OS X machine to build Conda+Conda-forge packages reliably. Note
# that this "bootstrap" script is run as root. The base VM image already has
# the Xcode command line tools installed such that just running "gcc" works,
# and Homebrew as well.

set -e -x
cd /Users/vagrant
vrun="sudo -iu vagrant"

# Homebrew additions. Java is annoying, but needed for casa-python.

$vrun brew install $(echo "
Caskroom/cask/java
homebrew/dupes/apple-gcc42
pkg-config
wget
xz
")

# Miniconda. Maybe we could use the same prefix as Homebrew, but seems risky.
# And this way we have the same layout as the Linux Docker images.

mkdir -p /conda
chown vagrant /conda

curl -s https://repo.continuum.io/miniconda/Miniconda2-latest-MacOSX-x86_64.sh >miniconda.sh
$vrun bash miniconda.sh -f -b -p /conda
cat >/Users/vagrant/.bash_profile <<'EOF'
# .bash_profile
export PATH="/conda/bin:$PATH"
source ~/.bashrc
EOF
cat >/Users/vagrant/.bashrc <<'EOF'
# .bashrc
alias l='ls -lrtAGh'
PS1='\h \A \W \$ '
EOF
chown vagrant /Users/vagrant/.bash*
rm miniconda.sh

# Conda-Forge!
$vrun conda config --add channels conda-forge
$vrun conda update --all -y

# Conda dev packages
$vrun conda install -y $(echo "
conda-build
jinja2
pip
setuptools
")

# Some final touchups for our particular build system.

$vrun conda config --add envs_dirs /conda/envs
$vrun mkdir /conda/conda-bld
(cd /conda/conda-bld && ln -s /vagrant/osx-64 osx-64)
