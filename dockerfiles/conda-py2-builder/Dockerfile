# Copyright 2015 Peter Williams
# Licensed under the MIT License.
#
# Build with something like "sudo docker build -t conda-py2:$(date +%Y%m%d) ."

FROM centos:5
MAINTAINER Peter Williams <peter@newton.cx>

VOLUME /work
COPY setup.sh /
RUN ["/bin/bash", "/setup.sh"]

COPY entrypoint.sh /
RUN ["chmod", "+x", "entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["help"]
