#!/bin/bash

#set -x

git_clone() {

	local SRC_DIR=$1
	local REPO_PATH=$2
	local REPO_BRANCH=$3

	cd $SRC_DIR
	git config --global http.sslVerify false
	exec_log "git clone ${REPO_PATH} -b ${REPO_BRANCH}"
	git config --global http.sslVerify true
	cd -
}

git_pull() {

	local REPO_ROOT=$1
	local REPO_BRANCH=$2

	cd $REPO_ROOT
	git config --global http.sslVerify false
	exec_log "git pull origin ${REPO_BRANCH}"
	git config --global http.sslVerify true
	cd -
}

#set +x
