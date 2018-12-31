#!/bin/bash

set -x

dpdk_prerequisites() {

	echo 'gcc make git curl build-essential libnuma1 libnuma-dev ssh sshpass'
}

dpdk_clone() {

	git_clone $SRC_DIR $DPDK_REPO $DPDK_VERSION
}

dpdk_pull() {

	git_pull "${DPDK_DIR}" "${DPDK_VERSION}"
}

dpdk_kni_build_disable() {

	sed -i s/CONFIG_RTE_LIBRTE_KNI=y/CONFIG_RTE_LIBRTE_KNI=n/ ${DPDK_DIR}/config/common_linuxapp
	sed -i s/CONFIG_RTE_KNI_KMOD=y/CONFIG_RTE_KNI_KMOD=n/ ${DPDK_DIR}/config/common_linuxapp
	sed -i s/CONFIG_RTE_LIBRTE_PMD_KNI=y/CONFIG_RTE_LIBRTE_PMD_KNI=n/ ${DPDK_DIR}/config/common_linuxapp
}

dpdk_igb_uio_build_disable() {

	sed -i s/CONFIG_RTE_EAL_IGB_UIO=y/CONFIG_RTE_EAL_IGB_UIO=n/ ${DPDK_DIR}/config/common_linuxapp
}

dpdk_userspace_config() {

	dpdk_kni_build_disable
	dpdk_igb_uio_build_disable
	sed -i s/CONFIG_RTE_APP_TEST=y/CONFIG_RTE_APP_TEST=n/ ${DPDK_DIR}/config/common_linuxapp
	sed -i s/CONFIG_RTE_TEST_PMD=y/CONFIG_RTE_TEST_PMD=n/ ${DPDK_DIR}/config/common_linuxapp
}

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
source ${TGT_SRC_DIR}/dpdk-box/app/utils/exec_utils.sh;\
source ${TGT_SRC_DIR}/dpdk-box/app/utils/git_utils.sh;\
source ${TGT_SRC_DIR}/dpdk-box/app/utils/dpdk_utils.sh;\
source ${TGT_SRC_DIR}/dpdk-box/runtime/dpdk_runtime.sh;\
yum -y install numactl-devel;\
dpdk_clone;\
dpdk_kni_build_disable;\
dpdk_build"
##################
echo "${remote_install_cmd}"
	exec_tgt "${remote_install_dir}" "${remote_install_cmd}"
}

set +x

