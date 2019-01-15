#!/bin/bash

set +x

print_log() {

	local log_file="/tmp/img_log.log"
	local log_format="\n$(date +"%Y.%m.%d %H:%M:%S") $1"
	shift
	printf "${log_format}" "$@" >> ${log_file}
}

exec_log() {

	local exec_cmd="$@"
	local exec_result="$($@)"

	print_log ">> [%s]\n%s\n%s\n" "${exec_cmd}" "${exec_result}" "---"
	echo "${exec_result}"
}

exec_remote() {

	#echo
	#echo "<<<< exec_remote >>>>"
	#echo
	set +x
	local remote_dir="$1"
	local remote_cmd="$2"
	local remote_ip="$3"
	local remote_user="$4"
	local remote_pass="$5"

	local exec_cmd="cd ${remote_dir}; ${remote_cmd}"
	local ssh_verb="${remote_user}@${remote_ip} /bin/bash -c '${exec_cmd}'"
	local ssh_cmd="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${ssh_verb}"
	local sshpass_cmd="sshpass -p ${remote_pass} ${ssh_cmd}"
	local ssh_result="$(${sshpass_cmd})"
	print_log ">>> [%s]\n%s\n%s\n" "ssh ${ssh_verb}" "${ssh_result}" "---"
	echo "${ssh_result}"
	set +x
}

exec_tgt() {

	#echo
	#echo "<<<< exec_tgt >>>>"
	#echo
	set +x
	local remote_dir="$1"
	local remote_cmd="$2"

	exec_remote ${remote_dir} "${remote_cmd}" ${TGT_IP} ${TGT_USER} ${TGT_PASS}
	set +x
}

exec_apt_update() {

	apt-get -y update && apt-get install -y dialog apt-utils
}

exec_apt_install() {

	exec_log "apt-get install -y --no-install-recommends $@"
}

exec_apt_clean() {

	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
}

exec_install_node() {

	cd /tmp
	apt-get install -y curl
	curl -sL https://deb.nodesource.com/setup_11.x | bash -
	apt-get install -y nodejs
	apt-get install -y npm
	npm install -g http-server
	npm install -g bower
	apt-get -y install jq wget
	cd -
}

exec_yum_install() {

	yum -y update
	exec_log "yum install -y $@"
}

set +x
