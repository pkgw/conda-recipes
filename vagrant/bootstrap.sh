#! /usr/bin/env bash
# Copyright 2015-2019 Peter Williams.
# Licensed under the MIT License.
#
# Set up a Mac OS X machine to build Conda+Conda-forge packages reliably. Note
# that this "bootstrap" script is run as root. The base VM image already has
# the Xcode command line tools installed such that just running "gcc" works,
# and Homebrew as well.

set -ex
cd /Users/vagrant

# Homebrew additions. Java is annoying, but needed for casa-python.
### sudo -iu vagrant brew install $(echo "
### Caskroom/cask/java
### pkg-config
### wget
### xz
### ")

# Miniconda. Maybe we could use the same prefix as Homebrew, but seems risky.
# And this way we have the same layout as the Linux Docker images.
#
# Some setup for our build system. We don't want to map conda-bld to /vagrant
# because doing the builds over NFS would be too slow.

rm -rf /conda # XXXXXXXXXXXXXXXXXXXXXX

mkdir -p /conda/conda-bld
for d in broken linux-64 noarch osx-64 src_cache ; do
    (cd /conda/conda-bld && ln -s /vagrant/artifacts/$d)
done
chown -R vagrant /conda

# Current conda ends up having permissions problems when run via `sudo`, so we
# have to use `su`, which means that we have to write out an inner script
# since `su`'s command quoting is so impossible.

script=$(mktemp /tmp/vagrantbs.XXXXXX)
cat <<'EOF' >"$script"
#! /usr/bin/env bash

set -ex

curl -s https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh >miniconda.sh
bash miniconda.sh -f -b -p /conda

cat >~/.bash_profile <<'EOF2'
# .bash_profile
source ~/.bashrc
EOF2

cat >~/.bashrc <<'EOF2'
# .bashrc
alias l='ls -lrtAGh'
PS1='\h \A \W \$ '
source /conda/etc/profile.d/conda.sh
conda activate
EOF2

rm miniconda.sh
source ~/.bashrc

# Conda-Forge!
conda config --add channels conda-forge
conda update --all -y

conda config --add envs_dirs /conda/envs

# Conda dev packages
conda install -y $(echo "
conda-build
conda-forge-pinning
jinja2
pip
setuptools
")
EOF

chown vagrant "$script"
sudo su vagrant -c "bash $script"
rm -f "$script"
