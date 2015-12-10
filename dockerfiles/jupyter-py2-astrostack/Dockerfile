# Copyright 2015 Peter Williams
# Licensed under the MIT License.
#
# Build with something like "sudo docker build --rm -t jupyter-py2-astrostack:$(date +%Y%m%d) ."

FROM centos:7
MAINTAINER Peter Williams <peter@newton.cx>

ENV PATH=/conda/bin:/usr/sbin:/usr/bin:/sbin:/bin
COPY setup.sh /
RUN ["/bin/bash", "/setup.sh"]

# cf https://github.com/jupyter/notebook/pull/485
ADD https://github.com/krallin/tini/releases/download/v0.8.4/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

EXPOSE 80
CMD ["jupyter", "notebook", "--port=80", "--ip=0.0.0.0", "--no-browser"]
