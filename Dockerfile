
FROM ubuntu:latest

ARG IMG_DPDK_REPO="https://github.com/ShrewdThingsLtd/dpdk.git"
ARG IMG_DPDK_VERSION="v17.11-rc4"

ENV DPDK_REPO="${IMG_DPDK_REPO}"
ENV DPDK_VERSION=$IMG_DPDK_VERSION
ENV SRC_DIR=/usr/src
ENV DPDK_DIR=$SRC_DIR/dpdk

COPY app/ ${SRC_DIR}/
ENV BASH_ENV=${SRC_DIR}/docker-entrypoint.sh
SHELL ["/bin/bash", "-c"]

RUN exec_apt_update
RUN exec_apt_install "$(dpdk_prerequisites)"
#RUN exec_apt_clean

RUN \
	dpdk_clone; \
	dpdk_userspace_config
RUN exec_install_node

COPY runtime/ ${SRC_DIR}/runtime/
ENV BASH_ENV=${SRC_DIR}/app-entrypoint.sh

WORKDIR $DPDK_DIR
ONBUILD COPY app/ ${SRC_DIR}/

ONBUILD RUN \
	dpdk_configure; \
	dpdk_build
#ONBUILD RUN make clean
