<!--- To render this locally, use `grip --wide` on this file. -->

conda-recipes
=============

This repository contains the tools I use to build various packages in the
[Conda] package manager used by the [Anaconda] Python distribution. Most of
them build up to providing support for the [Gtk+ 3] graphical toolkit and the
[CASA] radio interferometry package. Builds are only tested on 64-bit Linux.

[Conda]: http://conda.pydata.org/
[Anaconda]: http://docs.continuum.io/anaconda/index
[Gtk+ 3]: http://www.gtk.org/
[CASA]: http://casa.nrao.edu/

I upload built packages to [my personal anaconda.org channel]. You can
configure your [Anaconda] installation to fetch packages from it with:

```
conda config --add channels http://conda.anaconda.org/pkgw/channel/main
```

To directly install the package `pwkit` (for example) without altering your
configuration, use:

```
conda install -c pkgw pwkit
```

As part of this work I’ve also developed a [prebuilt Docker image] that can be
used to repeatably build binary `linux-64` packages.

[my personal anaconda.org channel]: https://anaconda.org/pkgw/
[prebuilt Docker image]: https://hub.docker.com/r/pkgw/conda-py2-builder/


How it All Works
===============================

Many of my Conda packages involve compiled code, and a big challenge is
building such packages in a way that’s as platform-independent as possible.
The Conda framework doesn’t specify the binary ABI that Linux-targeting
packages should follow, but things built on CentOS 5 are generally highly
portable. However, no one wants to run CentOS 5 as their primary OS since it’s
ancient!

So there are two main components to how I build my [Conda] packages. First, I
have set up a [Docker] environment that allows me to build packages repeatably
inside a stable, containerized Centos 5 environment. Then, I’ve written the
[Conda recipes](recipes) that actually define the packages that I build. I’ve
written up notes on how the system works if you might be interested in doing
similar things.

[Docker]: https://www.docker.com/

* [Notes for developers](dev.md)
* [The order in which everything needs to be built](ordered.txt)


License
=======

The Conda recipes are licensed under a 3-clause BSD license, for compatibility
with the main [conda-recipes] repository. See the file
[LICENSE.txt](LICENSE.txt) for the details. Other files are licensed under the
MIT License.

[conda-recipes]: https://github.com/conda/conda-recipes


Copyright Notice
================

Copyright 2014–2015 Peter Williams

This file is free documentation; the copyright holder gives unlimited
permission to copy, distribute, and modify it.
