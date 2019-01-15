#!/bin/bash

DOCKER_INST=${1:-dpdk-box}
IMG_DOMAIN=${2:-local}
DPDK_VERSION=${3:-v17.11-rc4}

docker volume rm $(docker volume ls -qf dangling=true)
#docker network rm $(docker network ls | grep "bridge" | awk '/ / { print $1 }')
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
docker rmi $(docker images | grep "none" | awk '/ / { print $3 }')
docker rm $(docker ps -qa --no-trunc --filter "status=exited")

case ${IMG_DOMAIN} in
	"hub")
	IMG_TAG=shrewdthingsltd/dpdk-box:$DPDK_VERSION
	docker pull $IMG_TAG
	;;
	*)
	IMG_TAG=local/dpdk-box:$DPDK_VERSION
	DPDK_REPO="https://github.com/ShrewdThingsLtd/dpdk.git"
	docker build \
		-t $IMG_TAG \
		--build-arg IMG_DPDK_REPO=$DPDK_REPO \
		--build-arg IMG_DPDK_VERSION=$DPDK_VERSION \
		./
	;;
esac

docker kill $DOCKER_INST
docker rm $DOCKER_INST
docker run \
	-t \
	-d \
	--rm \
	--net=host \
	--privileged \
	-v /mnt/huge:/mnt/huge \
	--device=/dev/uio0:/dev/uio0 \
	--env DOCKER_INST=$DOCKER_INST \
	--hostname=$DOCKER_INST \
	--name=$DOCKER_INST \
	$IMG_TAG \
	/bin/bash
