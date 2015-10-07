# Reproducible Python stacks with (Ana)Conda

Some notes on reproducible Python stacks with the [Anaconda] Python
distribution. These notes don’t totally belong in this repository anymore, but
this is where they started.

[Anaconda]: http://docs.continuum.io/anaconda/index

These notes are also somewhat outdated since they’re based on setting up
separate Python “environments” within one Anaconda install. The support for
environments is kind of flaky, and I’m more and more just using [Miniconda] to
quickly deploy full stacks that work much more reliably.

[Miniconda]: http://conda.pydata.org/miniconda.html


### Setting up a new environment

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


### Making the environment reproducible

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
sub-dependencies. Hmmm.

[IPython]: http://ipython.org/


### Updating Anaconda

Have to be careful with this since their update practices are amateurish and
[conda]’s dependency management is lame. (I.e., it lets you remove a package
upon which other installed packages depend.) But in an ideal world

```
conda update -p {path-to-env-dir} --all
```

### TODO:

- Investigate `conda develop`
