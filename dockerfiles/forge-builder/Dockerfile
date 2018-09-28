# Copyright 2015-2018 Peter Williams
# Licensed under the MIT License.
#
# See ./build.sh for a simple build recipe.
#
# Keep this at CentOS 6, since using its glibc gives use the widest possible
# range of binary compatibility across Linux distros. Several clusters I use
# are still using CentOS 6.

FROM centos:6
MAINTAINER Peter Williams <peter@newton.cx>
ARG EXTUSERID
ARG EXTGRPID

VOLUME /work
COPY setup.sh setup-unpriv.sh entrypoint.sh /
RUN ["/bin/bash", "/setup.sh"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["help"]
