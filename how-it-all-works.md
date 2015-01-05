# Reproducible Python Stacks with Conda and Binstar

This system has so freakin’ many issues, but it’s still the best I’ve been
able to cook up.


## Initial setup

To do everything you need accounts on both [PyPI] and [Binstar].

[PyPI]: https://pypi.python.org/pypi
[Binstar]: https://binstar.org/dashboard

Install [Miniconda]. The stock Anaconda install needs you to enter your email
to recover the download link, and it’s really big and just contains a bunch of
stuff that we don’t need. Absolutely no reason not to download packages on the
fly.

[Miniconda]: http://conda.pydata.org/miniconda.html

Stuff to install in the main Anaconda environment:

```
binstar
conda-build
pip
setuptools
```

Then set up my personal [Binstar] channel as a source of additional packages, and
make it so the (unused) named environments directory is out of the way:

```
conda config --add channels http://conda.binstar.org/pkgw/channel/main
conda config --add envs_dirs {path-to-anaconda}/envs
```


## Setting up a new environment

Create a new blank environment in some sensible working directory.

```
conda create -p {path-to-env-dir} -y python=2.7
```

Fortunately, wrappers are mostly set up properly such that “using the
environment” is just a matter of putting its `bin` directory in `$PATH`.
However, the `conda` tool does *not* do this because these people are freaking
amateurs, so various of the [conda] commands need to have the environment
location re-specified, usually with that `-p` argument. So, to set up new
packages:

```
conda install -p {path-to-env-dir} numpy scipy ipython pwkit
```

Other packages of potential interest:

- astropy
- omegaplot
- pandas


## Making the environment reproducible

You can export the current setup for an environment with:

```
conda list -p {path-to-env-dir} -e |tee environment.txt
```

You can then recreate it programmatically with:

```
conda create -p {path-to-new-env-dir} -y --file environment.txt
```

I need to think about what to do with the fact that, e.g., I’ll want to have
[IPython] available for testing and such, but it’s something that would be
nice to keep out of the environment dep list since it pulls in so many
sup-dependencies. Hmmm.

[IPython]: http://ipython.org/


## Building and publishing packages

1. Break down and use `setup.py` as a build tool.
2. When there’s new code you want to release, update the version in `setup.py`.
3. Build, register, upload: `python setup.py sdist bdist register upload`. You
   have to do it all in one go so that cached authentication information can
   be used.
4. Update `meta.yaml` in [conda] recipe. Take the MD5 sum from what [PyPI]
   reports, since it’s not the same as the MD5 of the tarball you upload.
5. Build for [conda]: `conda build {path-to-recipe-dir}`.
6. Upload to [Binstar]: execute line at end of the `conda build` output.

[conda]: http://conda.pydata.org/docs/


## Miscellany

### Updating Anaconda

Have to be careful with this since their update practices are amateurish and
[conda]’s dependency management is lame. (I.e., it lets you remove a package
upon which other installed packages depend.) But in an ideal world

```
conda update -p {path-to-env-dir} --all
```

### TODO:

- Investigate `conda develop`

### Regenerating the local channel

Run `conda index` in `$ANACONDA/conda-bld/linux-64/`.

### Viewing this document locally

Run `grip --wide how-it-all-works.md`. The [grip](https://github.com/joeyespo/grip)
package is on [PyPI] and seems to do the job. Installing `grip` locally with the
Anaconda Python stack was a total pain in the ass for unclear reasons. I ended
up getting it to work with

```
pip install -i https://pypi.binstar.org/pypi/simple grip
```

which seems to be the recommended method for any [PyPI] package that doesn’t
have its own Conda incarnation.
