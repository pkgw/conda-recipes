# Copyright 2015-2016 Peter Williams
# Licensed under the MIT License.
#
# Build with something like "docker build -t conda-py2-builder:$(date +%Y%m%d) ."

FROM centos:5
MAINTAINER Peter Williams <peter@newton.cx>

VOLUME /work
COPY setup.sh entrypoint.sh /
RUN ["/bin/bash", "/setup.sh"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["help"]
