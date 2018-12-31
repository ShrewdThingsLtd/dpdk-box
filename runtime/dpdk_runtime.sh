#!/bin/bash

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
echo "${remote_cmd}"
	exec_tgt "${remote_dir}" "${remote_cmd}"
}

dpdk_igb_uio_bind_interface() {

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
