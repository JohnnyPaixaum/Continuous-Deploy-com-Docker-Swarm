#!/bin/bash

RD_JOB_NAME=teste

#CHECAR EXISTENCIA DA IMAGEM E ARMAZENAR EM VARIAVEL
export IMAGE=`docker image ls | grep $RD_JOB_NAME | cut -c 1-30` 
echo $IMAGE

if [ ${IMAGE} = ${RD_JOB_NAME} ]; then		
	export OLDVERSION=`docker image ls | grep $IMAGE | cut -c 33-38` #FILTRO PARA GREBAR ANTIGA VERSÃO E ARMAZENAR EM VARIAVEL
	echo $(($OLDVERSION+1))
		#CRIANDO NOVA IMAGEM
	cd /home/rundeck/projects/${RD_JOB_NAME}/scm/ && \
    echo -e "FROM "httpd:latest"\nCOPY projeto/. /usr/local/apache2/htdocs\nVOLUME /usr/local/apache2/htdocs" > Dockerfile && \
     docker build -t ${RD_JOB_NAME}:$((${OLDVERSION}+1)) . #passar via ssh
    	#APAGANDO IMAGEM ANTIGA
    #docker image rm ${RD_JOB_NAME}:${OLDVERSION} #passar via ssh

else
		#CRIANDO IMAGEM
    cd /home/rundeck/projects/${RD_JOB_NAME}/scm/ && \
    echo -e "FROM "httpd:latest"\nCOPY projeto/. /usr/local/apache2/htdocs\nVOLUME /usr/local/apache2/htdocs" > Dockerfile && \
    docker build -t ${RD_JOB_NAME}:1 . #passar via ssh
fi