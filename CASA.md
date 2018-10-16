# Installing CASA through conda-forge and pkgw-forge

Welcome! This file attempts to document how you can install the tools from
[CASA](https://casa.nrao.edu/) in an
[Anaconda Python](https://www.anaconda.com/what-is-anaconda/) environment on
Linux or macOS. This lets you invoke CASA functionality from Python scripts
that run in your fully-loaded Anaconda environment — including ones built on
Python 3!

There are a few important things to know before getting started, so **please
read the following carefully**.


## Important: What We’re Installing

If you follow the instructions below you will obtain the following in your
Anaconda environment:

1. The [casacore](https://casacore.github.io/casacore/) library.
2. The compiled CASA “tools” for calibration, imaging, and so on.
3. Standard CASA helper programs like `casaplotms`, `casaviewer`, and
   `wvrgcal`.
4. The CASA supporting data files.
5. The low-level `casac` Python module that provides access to the compiled
   CASA tools in the Python language.
6. My [pwkit](https://pwkit.readthedocs.io/) package, which provides
  [a relatively high-level, Pythonic interface](https://pwkit.readthedocs.io/en/latest/environments/casa/)
  to many of the standard CASA tasks through the module
  `pwkit.environments.casa`. This module is suitable for use in interactive
  consoles like [Jupyter](http://jupyter.org/) or
  [IPython](https://ipython.org/), or in scripts.
7. A command-line tool `casatask`, which provides command-line access to many
   of the standard CASA tasks.

You will **not** obtain the following:

1. The standard interactive CASA user interface.
2. Some of the “tasks” provided in the standard interface.

Technical limitations make it infeasible to provide the standard interface and
certain of the tasks that are tightly coupled to its implementation.

In other words, the system provided here is aimed at Python-based *scripting*
of CASA analysis. If you want the classic CASA interactive interface, you
should install CASA through the standard means. (It’s possible to have both
kinds of CASA installed at once, so that you can both run scripts and do
interactive analyses.)


## First-Time Installation

To install CASA, we need to set up your Anaconda environment to use packages
provided by the [conda-forge](https://conda-forge.org/) project. This project
provides a framework for adding extra packages to the Anaconda base, and CASA
needs many of these extra packages to run. To set it up we add the conda-forge
“channel” to your conda configuration.

An important feature of conda-forge, though, is that it must *replace* the
vast majority of the official packages provided by Anaconda, Inc. Therefore,
when setting everything up for the first time, there must be an upgrade step
during which a bunch of your environment will be churned around:

```
conda config --add channels conda-forge
conda update --all
```

When running the second command, you will probably be asked if you want to
update a large number of packages. If you’re willing to read over this list
and double-check it, by all means, do so. But there is close coordination
between Anaconda, Inc. and conda-forge, and generally it is safe to do this
wholesale replacement.

The main CASA packages are too large to be built on conda-forge’s public
infrastructure, so I ([PKGW](https://newton.cx/~peter/)) must provide them in
a separate channel called `pkgw-forge`. To activate this channel, run the
following command:

```
conda config --add channels pkgw-forge
```

Now that this setup has been performed, installation is straightforward:

```
conda install casa-data casa-python pwkit
```

The `pkgw-forge` channel also provides packages of
[aoflagger](https://sourceforge.net/p/aoflagger/wiki/Home/) and
[wsclean](https://sourceforge.net/p/wsclean/wiki/Home/) if you are interested
in those pieces of software.

To quickly check if your installation is working, you can run the following
command:

```
python -c "import casac"
```

It should exit without printing any error messages. If you get an error
message, [report a problem](#reporting-problems).

Finally, after the installation has succeeded, you can free up a nontrivial
amount of disk space by running the following command:

```
conda clean -tipsy
```


## Staying Up-To-Date

If you have installed your packages as directed above, you can ensure that your
installation is up-to-date by running this command:

```
conda update --all
```


## Reporting Problems

Anaconda and CASA are both complex software systems with many dependencies, so
it is not uncommon for things to go wrong. If a problem occurs, you should
investigate the issue and ask for help:

1. Go to this project’s
   [GitHub issues listing](https://github.com/pkgw/conda-recipes/issues) and
   look if there are any issues whose descriptions match the problem that
   you’re having. If there are, read the discussion for guidance as to how to
   proceed.
2. If no existing issue seems to match your problem, press the “New issue”
   button to start filing a new one.
3. Choose the “Report a CASA problem” button.
4. Fill in a brief-but-descriptive title for your issue.
5. Provide information in the main issue body following the prompts in the
   edit box.
6. Check over that you’ve filled in all of the appropriate information, and
   then hit the “Submit new issue” button.
