#! /bin/bash
# Copyright Peter Williams <peter@newton.cx>
# Licensed under the MIT License.
#
# This script is run by the main `setup.sh` as the "conda" user.

set -e

wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -O ~/miniforge.sh
bash ~/miniforge.sh -b -f -p /conda
rm -f ~/miniforge.sh

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

conda config --set report_errors false

conda update --all -y

conda install -y $(echo "
conda-build
conda-forge-pinning
jinja2
pip
setuptools
")

mkdir /conda/conda-bld
(cd /conda/conda-bld && ln -s /work/linux-64 linux-64 && ln -s /work/noarch noarch)

conda clean -pity
