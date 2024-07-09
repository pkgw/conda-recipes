#! /usr/bin/env bash
# Copyright Peter Williams
# Licensed under the MIT License
#
# Set up a Mac OS X machine to build Conda+Conda-forge packages reliably. Note
# that this "bootstrap" script is run as root. The base VM image already has
# the Xcode command line tools installed such that just running "gcc" works,
# and Homebrew as well.

set -ex
cd /Users/vagrant

# MacOS boots with a read-only root filesystem. We can use the following magic
# configuration file to create root-level symlinks that allow our setup to
# seem to have the same layout as the Linux one, although it will only take
# effect on the next boot. The two columns of the file must be separated by
# tab characters.

tab=$'\t'

cat <<EOF >/etc/synthetic.conf
conda${tab}private/var/conda
vagrant${tab}private/var/vagrant
EOF

# I used to install some stuff with Homebrew here, but I believe it's no longer
# needed, and my "base box" no longer preinstalls Homebrew.

# Miniforge

conda=/private/var/conda

rm -rf $conda
mkdir -p $conda
chown -R vagrant $conda

# Current conda ends up having permissions problems when run via `sudo`, so we
# have to use `su`, which means that we have to write out an inner script
# since `su`'s command quoting is so impossible.

script=$(mktemp /tmp/vagrantbs.XXXXXX)
cat <<'EOF' >"$script"
#! /usr/bin/env bash

set -ex
conda=/private/var/conda

curl -fsSL https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-x86_64.sh >miniforge.sh
bash miniforge.sh -f -b -p $conda

cat >~/.bash_profile <<'EOF2'
# .bash_profile
source ~/.bashrc
EOF2

cat >~/.bashrc <<'EOF2'
# .bashrc
alias l='ls -lrtAGh'
PS1='\h \A \W \$ '
source /private/var/conda/etc/profile.d/conda.sh
conda activate
EOF2

rm miniforge.sh
source ~/.bashrc

conda update --all -y

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
