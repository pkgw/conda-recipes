# Copyright 2015-2016 Peter Williams
# Licensed under the MIT License.
#
# See ./build.sh for a simple build recipe.

FROM centos:6
MAINTAINER Peter Williams <peter@newton.cx>

VOLUME /work
COPY setup.sh entrypoint.sh /
RUN ["/bin/bash", "/setup.sh"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["help"]
