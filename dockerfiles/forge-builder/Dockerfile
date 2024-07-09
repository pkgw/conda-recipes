# Copyright Peter Williams
# Licensed under the MIT License.
#
# See ./build.sh for a simple build recipe.

FROM rockylinux:8
ARG EXTUSERID
ARG EXTGRPID

VOLUME /work
COPY setup.sh setup-unpriv.sh entrypoint.sh /
RUN ["/bin/bash", "/setup.sh"]
ENTRYPOINT ["/entrypoint.sh"]
CMD ["help"]
