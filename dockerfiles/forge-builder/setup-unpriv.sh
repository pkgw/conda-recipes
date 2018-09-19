#! /bin/bash
# Copyright 2018 Peter Williams <peter@newton.cx>
# Licensed under the MIT License.
#
# This script is run by the main `setup.sh` as the "conda" user.

set -e

wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
bash ~/miniconda.sh -b -f -p /conda
rm -f ~/miniconda.sh

source /conda/bin/activate

cat <<'EOF' >~/.bash_profile
# .bash_profile
source /conda/bin/activate
EOF

cat <<'EOF' >~/.bashrc
# .bashrc
alias l='ls -lart --color=auto'
PS1='\h \A \W \$ '
EOF

conda config --add channels conda-forge
conda update --all -y

conda install -y $(echo "
conda-build
conda-forge-pinning
jinja2
pip
setuptools
")

conda config --add envs_dirs /conda/envs

mkdir /conda/conda-bld
(cd /conda/conda-bld && ln -s /work/linux-64 linux-64 && ln -s /work/noarch noarch)

conda clean -tipsy
