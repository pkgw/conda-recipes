# Reliably building Anaconda packages

This repository collects my recipes for building packages for the Anaconda
Python distribution. Many of them involve compiled code, and a big challenge
is building such packages in a way that’s as platform-independent as possible.
This file documents my system for doing so.


## Initial setup

To do everything you need accounts on both [PyPI] and [anaconda.org].

[PyPI]: https://pypi.python.org/pypi
[anaconda.org]: https://anaconda.org/dashboard

The Conda framework doesn’t specify the binary ABI that Linux-targeting
packages should follow. Basic Python packages can be built on just about any
distribution, but the safest approach seems to be to build everything on
CentOS 5 if at all possible. (Some C++ packages require newer compiler
features, although the Red Hat ``devtools`` package looks like it will allow
access to an updated compiler on an otherwise-stock CentOS 5 stack.) In practice
I use [docker] to get a consistent build environment.

[docker]: https://www.docker.com/

So the first step is to set up a pristine container for development. Below I’m
exporting the directory ``/b/conda-build`` on my host machine to ``/work`` within
the container, for sharing build recipes and built packages.

```
sudo systemctl start docker
sudo docker create -i -t --name c5py3 -v /b/conda-build:/work centos:5 /bin/bash
sudo docker start c5py3
sudo docker exec -t -i c5py3 /bin/bash
# the above drops you into a shell inside the container
echo 'exclude=*.i386 *.i586 *.i686' >>/etc/yum.conf # Centos 5 yum silliness
yum update -y
```

Install a bunch of base development packages (using some shell trickiness so I
can linewrap and alphabetize the list of packages):

```
yum install $(echo "
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
java
libICE-devel
libSM-devel
libXi-devel
libX11-devel
libXau-devel
libXdmcp-devel
libXtst-devel
libXext-devel
libXrender-devel
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
wget
which
xz
")
```

Now we install [Miniconda]. The stock Anaconda install needs you to enter your
email to recover the download link, and it’s really big and just contains a
bunch of stuff that we don’t need. Absolutely no reason not to download
packages on the fly. This example uses the Python 3 stack.

[Miniconda]: http://conda.pydata.org/miniconda.html

```
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh -b -p /conda
cat >~/.bashrc <<'EOF'
# .bashrc
alias l='ls -lart --color=auto'
export PATH="/conda/bin:$PATH"
EOF
source ~/.bashrc
rm miniconda.sh
conda update --all
conda install python=3.5
conda update --all
```

Our environment has its own set of standard packages that need to be installed for
development:

```
conda install $(echo "
anaconda-client
conda-build
jinja2
pip
setuptools
")
```

Then set up my personal [anaconda.org] channel as a source of additional packages, and
make it so the (unused) named environments directory is out of the way:

```
conda config --add envs_dirs /conda/envs
conda config --add channels http://conda.anaconda.org/pkgw/channel/main
mkdir /conda/conda-bld
(cd /conda/conda-bld && ln -s /work/linux-64)
```

Once all that work has been done, packages should be able to be built simply
by running

```
conda build $PACKAGE_NAME
```

in `/work/recipes` inside the Docker container.


## Packaging and releasing personal projects

The basic recipe for packaging a personal Python module using my system. When
you control the code, I think it makes more sense to store the [conda] recipe
files in the package’s source tree, rather than in this grab-bag repository.

1. Break down and use `setup.py` as a build tool.
2. Develop [conda] build files, potentially using the ones in this repository
   as a template.
3. When there’s new code you want to release, update the version in `setup.py`.
4. Build, register, upload to PyPI:

   ```python setup.py sdist bdist register upload```

   You have to do it all in one go so that cached authentication information
   can be used.
5. Update `meta.yaml` in the [conda] recipe. The MD5 of the package on PyPI
   is not the same as the file you upload; get it with something like:

   ```
   curl -s https://pypi.python.org/pypi/pwkit/ |grep md5= |grep -v linux |sed -e 's/.*md5=//'
   ```

   where you replace `pwkit` with the appropriate package name.

6. Build for [conda]: `conda build {path-to-recipe-dir}`.
7. Verify that package looks good. No extraneous files included, any binary
   files have been properly made relocatable, etc.
8. Upload to [anaconda.org]: execute line at end of the `conda build` output.

[conda]: http://conda.pydata.org/docs/


## Miscellany

### Updating Anaconda

Have to be careful with this since their update practices are amateurish and
[conda]’s dependency management is lame. (I.e., it lets you remove a package
upon which other installed packages depend.) But in an ideal world

```
conda update --all
```

### Correcting SELinux permissions

If you’re running the docker container on an SELinux-enabled system, files
created outside of the container may not be given permissions to be read from
inside it. You can give the permissions by running:

```
sudo chcon -Rt svirt_sandbox_file_t /b/conda-build
```

on the container host.

### Regenerating the local channel

On the container host, run `conda index` in `/b/conda-build/linux-64/`.

### Viewing this document locally

Run `grip --wide how-it-all-works.md`. Installing `grip` from PyPI was a
hassle for unclear reasons, so this repository now includes a recipe for it!
