#!/bin/bash

dpdk_remote_install() {

	local remote_dir="${TGT_SRC_DIR}"
##################
local remote_cmd="\
export SRC_DIR=${TGT_SRC_DIR};\
export DPDK_DIR=${TGT_SRC_DIR}/dpdk;\
export DPDK_REPO=${DPDK_REPO};\
export DPDK_VERSION=${DPDK_VERSION};\
export DPDK_TARGET=${DPDK_TARGET};\
source ${TGT_SRC_DIR}/dpdk-box/app/utils/exec_utils.sh;\
source ${TGT_SRC_DIR}/dpdk-box/app/utils/git_utils.sh;\
source ${TGT_SRC_DIR}/dpdk-box/app/utils/dpdk_utils.sh;\
source ${TGT_SRC_DIR}/dpdk-box/runtime/utils/dpdk_runtime.sh;\
yum -y install numactl-devel;\
dpdk_clone;\
dpdk_kni_build_disable;\
dpdk_build"
##################
	exec_tgt "${remote_dir}" "${remote_cmd}"
}

dpdk_igb_uio_install_module() {

	local remote_dir="${TGT_SRC_DIR}"
##################
local remote_cmd="\
sleep 1;\
rmmod igb_uio;\
sleep 1;\
modprobe uio;\
sleep 1;\
insmod ${TGT_SRC_DIR}/dpdk/${DPDK_TARGET}/kmod/igb_uio.ko"
##################
	exec_tgt "${remote_dir}" "${remote_cmd}"
}

dpdk_igb_uio_bind_interface() {

	local pci_addr=$1
	
	dpdk_igb_uio_install_module
	local remote_dir="${TGT_SRC_DIR}"
##################
local remote_cmd="\
${TGT_SRC_DIR}/dpdk/usertools/dpdk-devbind.py -b igb_uio ${pci_addr}"
##################
	exec_tgt "${remote_dir}" "${remote_cmd}"
}
