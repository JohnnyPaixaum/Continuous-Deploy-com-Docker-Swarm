#!/bin/bash

export RECEIVED01=`ping -c1 ${RD_OPTION_NODE01} | grep received | cut -c 24-25`
export RECEIVED02=`ping -c1 ${RD_OPTION_NODE02} | grep received | cut -c 24-25`
export RECEIVED03=`ping -c1 ${RD_OPTION_NODE03} | grep received | cut -c 24-25`

if [ ${RECEIVED01} -ge 1 ]; then
    export IPOUT=${RD_OPTION_NODE01}   
	    elif [ ${RECEIVED02} -ge 1 ]; then
	        export IPOUT=${RD_OPTION_NODE02}
		        elif [ ${RECEIVED03} -ge 1 ]; then
		        export IPOUT=${RD_OPTION_NODE03}
fi
echo $IPOUT

export SERVICE=`docker service ls | cut -c 20-44 | grep ${RD_OPTION_PROJETO}` #CHECAR EXISTENCIA DO SERVIÇO

if [[ "$RD_OPTION_PROJETO" = *"$SERVICE"* ]]; then

    echo "Copiando projeto para servidor $IPOUT"
    ssh root@${IPOUT} "mkdir -p /mnt/gluster_docker/volumes/${RD_OPTION_PROJETO}/_data"
    scp -vr /home/rundeck/projects/${RD_OPTION_PROJETO}/scm/* root@${IPOUT}:/mnt/gluster_docker/volumes/${RD_OPTION_PROJETO}/_data/
    docker service create --name ${RD_OPTION_PROJETO} --network=net-proxy \
	--mount type=volume,source=${RD_OPTION_PROJETO},target=/usr/share/nginx/html,volume-opt=type=none,volume-opt=device=/mnt/gluster_docker/volumes/${RD_OPTION_PROJETO}/_data,volume-opt=o=bind \
	--replicas=3 --reserve-memory=20MB --reserve-memory=50MB --restart-condition=on-failure --update-parallelism=1 \
	--label traefik.frontend.rule=Host:${RD_OPTION_PROJETO}.labary.local --label traefik.port=80 --label traefik.enable=true \
	--label traefik.docker.network=net-proxy --label traefik.backend.loadbalancer.method=drr \
	${RD_OPTION_IMAGE} 

else

	echo "Atualizando projeto"
	scp -vr /home/rundeck/projects/${RD_OPTION_PROJETO}/scm/* root@${IPOUT}:/mnt/gluster_docker/volumes/${RD_OPTION_PROJETO}/_data/ 
        
fi