#!/bin/bash

	
export SERVICE=`docker service ls | cut -c 20-44 | grep ${RD_JOB_NAME}` #CHECAR EXISTENCIA DO SERVIÇO

export VERSION=`docker image ls | grep ${RD_JOB_NAME} | cut -c 33-38` #GREBAR VERSÃO DA IMAGEM ATUAL

if [ ${SERVICE} = ${RD_JOB_NAME} ]; then

        docker service update --image ${RD_JOB_NAME}:${VERSION} ${RD_JOB_NAME} #ATUALIZANDO IMAGEM DO SERVIÇO
else

        docker service create --name ${RD_JOB_NAME} --network=net-proxy \
		--mount type=volume,source=${RD_JOB_NAME},target=/usr/share/nginx/html,volume-opt=type=none,volume-opt=device=/mnt/gluster_docker/volumes/${RD_JOB_NAME}/_data,volume-opt=o=bind \
		--replicas=3 --reserve-memory=20MB --reserve-memory=50MB --restart-condition=on-failure --update-parallelism=1 \
		--label traefik.frontend.rule=Host:${RD_JOB_NAME}.labary.local --label traefik.port=80 \
		--label traefik.docker.network=net-proxy --label traefik.backend.loadbalancer.method=drr \
		${RD_JOB_NAME}:1 #CRIANDO NOVO SERVIÇO
fi