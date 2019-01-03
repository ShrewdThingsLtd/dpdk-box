#!/bin/bash

dpdk_remote_install() {

	local remote_dir="/"
	local container_src_dir=${SRC_DIR}
##################
local remote_cmd="\
export SRC_DIR=${TGT_SRC_DIR}/dpdk-${DPDK_VERSION};\
export DPDK_DIR=${TGT_SRC_DIR}/dpdk-${DPDK_VERSION}/dpdk;\
export DPDK_REPO=${DPDK_REPO};\
export DPDK_VERSION=${DPDK_VERSION};\
export DPDK_TARGET=${DPDK_TARGET};\
mkdir -p ${TGT_SRC_DIR}/dpdk-${DPDK_VERSION};\
docker cp $DOCKER_INST:${container_src_dir}/env/ ${TGT_SRC_DIR}/dpdk-${DPDK_VERSION}/;\
docker cp $DOCKER_INST:${container_src_dir}/utils/ ${TGT_SRC_DIR}/dpdk-${DPDK_VERSION}/;\
docker cp $DOCKER_INST:${container_src_dir}/docker-entrypoint.sh ${TGT_SRC_DIR}/dpdk-${DPDK_VERSION}/docker-entrypoint.sh;\
. ${TGT_SRC_DIR}/dpdk-${DPDK_VERSION}/docker-entrypoint.sh;\
dpdk_clone;\
cd ${TGT_SRC_DIR}/dpdk-${DPDK_VERSION}/dpdk;\
yum -y install numactl-devel;\
dpdk_kni_build_disable;\
dpdk_build"
##################
	exec_tgt "${remote_dir}" "${remote_cmd}"
}

dpdk_igb_uio_install_module() {

	local remote_dir="${TGT_SRC_DIR}/dpdk-${DPDK_VERSION}"
##################
local remote_cmd="\
sleep 1;\
rmmod igb_uio;\
sleep 1;\
modprobe uio;\
sleep 1;\
insmod ${TGT_SRC_DIR}/dpdk-${DPDK_VERSION}/dpdk/${DPDK_TARGET}/kmod/igb_uio.ko"
##################
	exec_tgt "${remote_dir}" "${remote_cmd}"
}

dpdk_igb_uio_bind_interface() {

	local pci_addr=$1
	
	dpdk_igb_uio_install_module
	local remote_dir="${TGT_SRC_DIR}/dpdk-${DPDK_VERSION}"
##################
local remote_cmd="\
${TGT_SRC_DIR}/dpdk-${DPDK_VERSION}/dpdk/usertools/dpdk-devbind.py -b igb_uio ${pci_addr}"
##################
	exec_tgt "${remote_dir}" "${remote_cmd}"
}
