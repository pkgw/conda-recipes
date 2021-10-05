# Copyright 2015-2021 Peter Williams
# Licensed under the MIT License.
#
# See ./build.sh for a simple build recipe.
#
# I had to keep this at CentOS 6 for a long time for broad glibc compatibility.
# That's now EOL so we have to use CentOS 7 -- I hope that's OK!

FROM centos:7
MAINTAINER Peter Williams <peter@newton.cx>
ARG EXTUSERID
ARG EXTGRPID

VOLUME /work
COPY setup.sh setup-unpriv.sh entrypoint.sh /
RUN ["/bin/bash", "/setup.sh"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["help"]
