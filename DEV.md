<!--- To render this locally, use `grip --wide` on this file. -->

# Linux: Using the Docker images

I build my Linux [Conda] packages using [Docker], to ensure a reproducible
build environment that produces packages with maximal binary compatibility.

[Conda]: http://conda.pydata.org/docs/
[Docker]: https://www.docker.com/


## Local configuration

Built packages will land in the `linux-64` subdirectory of the directory
containing this file. To set up your local Anaconda installation to look there
for packages, run

```
conda config --add channels file://$(pwd)
```

in this directory.


## Building the Docker image

The Conda builds occur inside a “Docker container”. The Docker container is an
instance of a “Docker image”, which must itself be built! The process of
building the Docker image involves collecting all of the development packages
and Conda infrastructure required to run the `conda build` command.

I’ve uploaded the builder image to the [Docker Hub] as
`pkgw/conda-py2-builder`, so you ought to be able to **skip this step** —
assuming my development environment contains everything needed to build
whatever package you want to build.

[Docker Hub]: https://hub.docker.com/

However, I expect to need to rebuild the image periodically to track updates
to Conda and, less frequently, the base CentOS image. If you’re is working
from the directory containing this file, the recommended command to build a
new version of the image is:

```
docker build -t conda-py2-builder:latest dockerfiles/conda-py2-builder
```

The meat of the action is the
[setup.sh](dockerfiles/conda-py2-builder/setup.sh) script contained in that
subdirectory.

If you have an account on the [Docker Hub], you can also publish your image
there. Their framework is very unclear to me, and it looks like it may be
evolving very quickly, but you do something like this:

```
docker tag conda-py2-builder:latest docker.io/pkgw/conda-py2-builder:$(date +%Y%m%d)
docker tag -f conda-py2-builder:latest docker.io/pkgw/conda-py2-builder:latest
docker push docker.io/pkgw/conda-py2-builder:$(date +%Y%m%d)
docker push docker.io/pkgw/conda-py2-builder:latest
```

It would then appear [here](https://hub.docker.com/r/pkgw/conda-py2-builder/).
Note that magic `latest` tag does not update automatically.


## Setting up SELinux

If you’re using the Docker stuff on an SELinux-enabled machine, you need to
run a magic command to allow the docker containers to access the files on the
external machine. In the directory containing this file, run:

```
sudo chcon -Rt svirt_sandbox_file_t .
```
(Note the trailing period!)


## One-off package builds

The simplest way to build a package is with the `docker run` command. This
will create a temporary container and run the build process inside of it. If
the build succeeds, a new Conda package should have landed inside the
`linux-64` subdirectory after the command exits. Assuming that you’re working
out of the directory containing this file, this can be done with:

```
docker run -v $(pwd):/work --rm conda-py2-builder build <package>
```

Of course `<package>` should be replaced with the name of a recipe inside the
`recipes` subdirectory. The `-v` argument is needed to expose the local
directory inside the container so that it can access the build recipes and
package destination directory. The `--rm` flag causes the image to be removed
after it’s done.

What’s happening under the hood here is that the
[entrypoint.sh](dockerfiles/conda-py2-builder/entrypoint.sh) script inside the
Docker image is being invoked with arguments `build` and `<package>`. This
script then essentially does a `conda update` followed by a `conda build`.


## Persistent builder containers

It is also possible to create a persistent Docker container that builds
packages. This is valuable if it takes a long time to set up the package
build; for instance, if the source code download is large.

Once again we assume that you’re working from the directory containing this
file. First, create a container:

```
docker create -itv $(pwd):/work --name py2builder conda-py2-builder bash
```

I find the semantics of `docker create` a bit weird; basically we are saying
that Docker should go and set everything up as if we were going to run `docker
run -itv $(pwd):work conda-py2-builder bash`, except:

1. The command is not actually run, and
2. A persistent duplicate image is created, rather than a one-off.

To do anything in the container, we then need to start it up:

```
docker start py2builder
```

This launches the container, which in this case has `bash` for PID 1. The
`bash` process runs inside a pseudo-TTY and sits around waiting for input, by
default. You could use `docker attach` to attach to this special `bash`
process, but as far as I can tell there’s no way to detach once you’ve done
this, so exiting the shell will cause the container to shut down. Instead, to
get an interactive shell you should use `docker exec`:

```
docker exec -it py2builder /bin/bash
```

The container will keep on running along merrily after you exit this shell.
However, if you all you’re doing is trying to build packages, there’s no need
for an interactive shell. You can just run commands like:

```
docker exec py2builder /entrypoint.sh build ninja
```

This will run the entrypoint script as in the one-off case, but now the
changes to the filesystem will be saved. If, for instance, various packages
are downloaded, they won’t need to be re-downloaded the next time you run the
script.

If you want to explicitly shut down a container, unsurprisingly the command is:

```
docker stop py2builder
```


# OS X: Using Vagrant

I build my OS X packages using [Vagrant], which is nice because it takes steps
towards reproducibility (though not as far as Docker) and also allows you to
run builds in an automatable “headless” fashion.

[Vagrant]: https://www.vagrantup.com/

[Vagrant] works by setting up a headless virtual machine (VM) and automating
the “provisioning” steps that fill out its software quite. This is much more
heavyweight to do than Docker, so it’s not preferable in the Linux case. But
Docker requires the Linux kernel so it just can’t run on OS X natively.

Unfortunately, OS X is proprietary so, unlike my Docker images, I can’t share
them. But the base image I use is very straightforward: it is a basically
pristine install of [OS X Yosemite] (10.10), with the [Xcode command line
tools] installed. The user account and remote access are configured as
described in the [Vagrant “base box” page] so that Vagrant can automatically
SSH into the virtual machine to run commands on it. This VM is packaged into a
Vagrant “box” named `pkgw-yosemite-dev`. Instructions for doing so are out of
the scope of this document, but if you can create a Vagrant “box” with that
name that has Xcode installed and the appropriate “base box” configuration,
then you’re good to go.

[OS X Yosemite]: https://en.wikipedia.org/wiki/History_of_OS_X#Version_10.10:_.22Yosemite.22
[Xcode command line tools]: https://developer.apple.com/library/ios/technotes/tn2339/_index.html
[Vagrant “base box” page]: https://docs.vagrantup.com/v2/boxes/base.html

Assuming that you have such a box, building packages in this machine is
straightforward. If you run

```
vagrant up
```

in the directory containing this file, Vagrant will instantiate a VM and start
it running; on the first startup, it will “provision” the machine by
installing [Homebrew] and Miniconda and the essential tools for compiling
software. The current directory is shared into the machine as the path
`/vagrant/` so that the VM can access the recipes. Building a package for a
given recipe is then a matter of running a command of the form:

```
vagrant ssh -c "conda build /vagrant/recipes/pwkit"
```

When the command completes, the new OS X package should be sitting in the
`osx-64` subdirectory.

[Homebrew]: http://brew.sh/

To shut down your builder, use `vagrant suspend`, and `vagrant resume` to
bring it back up. Running `vagrant destroy` completely erases the VM, but not
the box; if you `vagrant up` again later, it will recreate and reprovision the
VM image, hopefully leading to identical builds.


# Miscellaneous Notes

## Packaging and releasing personal projects

Here’s the basic recipe for packaging a personal Python module. When you
control the code, I think it makes more sense to store the [conda] recipe
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

6. Build for [conda]: `conda build {path-to-recipe-dir}`. **TODO/FIXME**: this
   assumes that you have a pure Python package where it’s OK to not use the
   Docker environment! If we want to use the Docker environment consistently,
   it is in fact better to keep *all* Conda recipes in the repo and not with
   their packages.
7. Verify that package looks good. No extraneous files included, any binary
   files have been properly made relocatable, etc.
8. Upload to [anaconda.org]: execute line at end of the `conda build` output.

[conda]: http://conda.pydata.org/docs/
[anaconda.org]: https://anaconda.org/dashboard

### Regenerating the local channel

On the container host, run `conda index` in the `linux-64` subdirectory.


### C++11 and checking binary compatibility

CASA now uses C++11 constructs and as such requires G++ version >~ 4.7 to
build. However, building on a relatively recent OS injects dependencies on new
symbol versions in libstdc++ and a fancy new ELF ABI version ("Linux" rather
than "SYSV"/"none"), so you can't build on too new of a machine.

Inspired by [StackExchange], I've found that I can generate a portable binary
if I build on CentOS 5 using the Red Hat `devtools` package, or more
specifically [a CentOS build of devtools 2]. Some of the build files are
modified to point to the devtools version of `g++` to build the C++ code
appropriately. However, we need to point them to the stock version of
`gfortran` (when there’s FORTRAN code too) to maintain binary compatibility
with the rest of the Conda distribution.

[StackExchange]: http://superuser.com/a/542091/447180
[a CentOS build of devtools 2]: http://people.centos.org/tru/devtools-2/readme

To check the versions of various built binaries, use commands like:

```
readelf -h libsakura*.so # to check the ABI version
readelf -V libsakura*.so # to check the symbol versions
```
