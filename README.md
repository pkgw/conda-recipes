<!--- To render this locally, use `grip --wide` on this file. -->

conda-recipes
=============

This repository contains the tools I use to build various packages in the
[Conda] package manager used by the [Anaconda] Python distribution. Most of
them build up to providing support for the [Gtk+ 3] graphical toolkit and the
[CASA] radio interferometry package. Builds are provided on 64-bit Linux and
OS X. **My packages are layered on top of those provided by the [conda-forge]
project, so you must add `conda-forge` as a channel in your Conda
configuration!**

[Conda]: http://conda.pydata.org/
[Anaconda]: http://docs.continuum.io/anaconda/index
[Gtk+ 3]: http://www.gtk.org/
[CASA]: http://casa.nrao.edu/
[conda-forge]: http://conda-forge.github.io/

I upload built packages to [my personal anaconda.org channel]. You can
configure your [Anaconda] installation to fetch packages from it with:

```
conda config --add channels pkgw-forge
```

To directly install the package `pwkit` (for example) without altering your
configuration, use:

```
conda install -c pkgw-forge pwkit
```

As part of this work I’ve also developed a [prebuilt Docker image] that can be
used to repeatably build binary `linux-64` packages. For OS X, I use [Vagrant]
to make `osx-64` packages repeatably. My [notes for developers](DEV.md) may be
valuable if you’re interesting in making Conda packages containing compiled
code for Linux and/or Mac OS X machines.

[my personal anaconda.org channel]: https://anaconda.org/pkgw-forge/
[prebuilt Docker image]: https://hub.docker.com/r/pkgw/forge-py2-builder/
[Vagrant]: https://www.vagrantup.com/


How it All Works
===============================

Many of my Conda packages involve compiled code, and a big challenge is
building such packages in a way that’s as platform-independent as possible.
The OS X developer tools make this fairly manageable. But Linux is harder,
especially since Conda doesn't explicitly specify the ABIs that they target.
However, things built on CentOS 5 are generally highly portable — but no one
wants to run CentOS 5 as their primary OS since it’s ancient!

So there are two main components to how I build my [Conda] packages. First, I
have set up a [Docker] environment that allows me to build packages repeatably
inside a stable, containerized Centos 5 environment. Then, I’ve written the
[Conda recipes](recipes) that actually define the packages that I build. I’ve
written up notes on how the system works if you might be interested in doing
similar things.

OK, there are three components — I use [Vagrant] to generate and drive a
repeatable, headless build environment for the OS X package builds.

[Docker]: https://www.docker.com/

* [Notes for developers](DEV.md)
* [The order in which everything needs to be built](ordered.md)


License
=======

The Conda recipes are licensed under a 3-clause BSD license, for compatibility
with the main [conda-recipes] repository. See the file
[LICENSE.txt](LICENSE.txt) for the details. Other files are licensed under the
MIT License.

[conda-recipes]: https://github.com/conda/conda-recipes


Copyright Notice For This File
==============================

Copyright 2014–2015 Peter Williams

This file is free documentation; the copyright holder gives unlimited
permission to copy, distribute, and modify it.
