#!/bin/bash

export RECEIVED01=`ping -c1 ${RD_OPTION_NODE01} | grep received | cut -c 24-25` 
export RECEIVED02=`ping -c1 ${RD_OPTION_NODE02} | grep received | cut -c 24-25`
export RECEIVED03=`ping -c1 ${RD_OPTION_NODE03} | grep received | cut -c 24-25`

<<COMMIT_Identify_Node_Online
Essa função é feita pelos blocos acima e abaixo, no qual, o bloco acima é responsavel por 'pingar' para os NÓS das maquinas Docker e armazenas a resposta n a variavel RECEIVED0..1..2..3,
onde será utilizada no bloco a baixo para identificar qual das variaveis retornou com o valor 1 ou mais, assim sinalizando que o NÓ em questão está ON para ser utilizado no resto do codigo
somente aquele que estiver ON. Isso é necessario devido a falta de um HA_Proxy na frente das maquinas do Cluster Docker.
COMMIT_Identify_Node_Online

if [ ${RECEIVED01} -ge 1 ]; then
    export IPOUT=${RD_OPTION_NODE01}   
	    elif [ ${RECEIVED02} -ge 1 ]; then
	        export IPOUT=${RD_OPTION_NODE02}
		        elif [ ${RECEIVED03} -ge 1 ]; then
		        export IPOUT=${RD_OPTION_NODE03}
fi
echo $IPOUT #EMITE O VALOR ARMAZENADO NA VARIAVEL IPOUT RELACIONADO AO NÓ QUE ESTÁ ON, A FIM DE DEBUG NOS LOGS DO RUNDECK.

export SERVICE=`docker service ls | cut -c 20-44 | grep ${RD_OPTION_PROJETO}` #CHECAR EXISTENCIA DO SERVICE DO PROJETO EXISTENTE NO GITLAB. 

if [[ "$RD_OPTION_PROJETO" = *"$SERVICE"* ]]; then #APÓS COMPARAR ACIMA A EXISTENCIA DO PREJETO ESSA LINHAS IRÁ VERIFICAR SE A VARIAVEL ESTÁ VAZIA, ASSIM CONSTATANTE A INEXISTENCIA DO SERVICE DO PROJETO.

    echo "Copiando projeto para servidor $IPOUT" #PRINTA O NÓ NO QUAL O SERVICE DO PROJETO SERÁ CRIADO, A FIM DE DEBUG NOS LOGS DO RUNDECK.
    ssh root@${IPOUT} "mkdir -p /mnt/gluster_docker/volumes/${RD_OPTION_PROJETO}/" #ENVIA COMANDO PARA O NÓ PARA CRIAR A PASTA NO QUAL O PROJETO SERÁ COPIADO E MONTADO PARA USO DO VOLUME DOS CONTAINERS.
    scp -vr /${RD_OPTION_RD-PATH}/${RD_OPTION_PROJETO}/* root@${IPOUT}:/${RD_OPTION_REMOTE-PATH}/${RD_OPTION_PROJETO}/ #CONPIA O PROJETO DO GITLAB PARA O LOCAL ONDE O VOLUME IRÁ SER MONTADO.
<<COMMIT_COMAND_DOCERSERVICECREATE
COMANDO QUE IRÁ CRIAR O SERVICE DO PROJETO, NO QUAL, ESTÁ PASSANDO A FORMA EM PATH QUE O VOLUME SERÁ CRIANDO, PARAMETROS DE COMPORTAMENTO DOS CONTAINERS E LABELS NECESSARIAS PARA O TRAEFIK.
AQUI SERÁ CRIADO VIA CLI, MAS PODE SER UTILIZADO UM ARQUIVO YAML PREFERENCIALMENTE VERSIONADO NO GITLAB.
COMMIT_COMAND_DOCERSERVICECREATE
    docker service create --name ${RD_OPTION_PROJETO} --network=net-proxy \
	--mount type=volume,source=${RD_OPTION_PROJETO},target=/usr/share/nginx/html,volume-opt=type=none,volume-opt=device=/mnt/gluster_docker/volumes/${RD_OPTION_PROJETO}/_data,volume-opt=o=bind \
	--replicas=3 --reserve-memory=20MB --reserve-memory=50MB --restart-condition=on-failure --update-parallelism=1 \
	--label traefik.frontend.rule=Host:${RD_OPTION_PROJETO}.labary.local --label traefik.port=80 --label traefik.enable=true \
	--label traefik.docker.network=net-proxy --label traefik.backend.loadbalancer.method=drr \
	${RD_OPTION_IMAGE} 

else
<<COMMIT_SCP-COMMAND
NA CONDIÇÃO DO SERVICE JA EXISTIR, O RUNDECK IRÁ SOBREPOR OS ARQUIVOS JÁ EXISTENTES.
ESSE PROCESSO SERÁ SUBSTITUIDO COM O NEXEUS_REPOSITORY, NECESSITANDO APENAS ATUALIZAR A IMAGE DO SERVICE.
COMMIT_SCP-COMMAND 
	echo "Atualizando projeto"
	scp -vr /home/rundeck/projects/${RD_OPTION_PROJETO}/* root@${IPOUT}:/mnt/gluster_docker/volumes/${RD_OPTION_PROJETO}/ 
   
fi