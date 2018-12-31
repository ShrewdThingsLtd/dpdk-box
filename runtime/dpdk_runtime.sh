#!/bin/bash

dpdk_build() {

	cd "${DPDK_DIR}"
	export DPDK_BUILD="${DPDK_DIR}/${DPDK_TARGET}"
	make install T="${DPDK_TARGET}" DESTDIR=install -j20
	cd -
}

dpdk_remote_install() {

	echo "dpdk_remote_install: TGT_SRC_DIR=$TGT_SRC_DIR TGT_IP=$TGT_IP TGT_USER=$TGT_USER"
	remote_install_dir="${TGT_SRC_DIR}"
##################
remote_install_cmd="\
export SRC_DIR=${TGT_SRC_DIR};\
export DPDK_DIR=${TGT_SRC_DIR}/dpdk;\
export DPDK_REPO=${DPDK_REPO};\
export DPDK_VERSION=${DPDK_VERSION};\
export DPDK_TARGET=${DPDK_TARGET};\
export UTILS_DIR=${TGT_SRC_DIR}/docker-dpdk/utils;\
source ${TGT_SRC_DIR}/docker-dpdk/app/utils/exec_utils.sh;\
source ${TGT_SRC_DIR}/docker-dpdk/app/utils/git_utils.sh;\
source ${TGT_SRC_DIR}/docker-dpdk/app/utils/dpdk_utils.sh;\
source ${TGT_SRC_DIR}/docker-dpdk/app/runtime/dpdk_runtime.sh;\
yum -y install numactl-devel;\
dpdk_clone;\
dpdk_kni_disable;\
dpdk_build"
##################
echo "${remote_install_cmd}"
	exec_tgt "${remote_install_dir}" "${remote_install_cmd}"
}

dpdk_igb_uio_install() {

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
echo "${remote_cmd}"
	exec_tgt "${remote_dir}" "${remote_cmd}"
}

dpdk_igb_uio_bind() {

	local pci_addr=$1
	
	dpdk_igb_uio_install
	local remote_dir="${TGT_SRC_DIR}"
##################
local remote_cmd="\
${TGT_SRC_DIR}/dpdk/usertools/dpdk-devbind.py -b igb_uio ${pci_addr}"
##################
echo "${remote_cmd}"
	exec_tgt "${remote_dir}" "${remote_cmd}"
}
