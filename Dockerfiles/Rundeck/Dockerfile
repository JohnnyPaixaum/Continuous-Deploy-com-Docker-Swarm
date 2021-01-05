FROM rundeck/rundeck:SNAPSHOT

MAINTAINER  <https://github.com/JohnnyPaixaum> <johnnysilva110@dockerhub.com>

USER root

###UTILS###
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
    apt-utils \
    curl \
    git \
    ca-certificates \
    software-properties-common iputils-ping && \
    rm -rf /var/cache/apt/archives && apt-get clean

###DOCKER###
RUN curl -fsSL https://get.docker.com/ | sh && usermod -aG docker root && \
    rm -rf /var/cache/apt/archives && apt-get clean

###RUNDECK-CLI###
RUN echo "deb https://dl.bintray.com/rundeck/rundeck-deb /" | sudo tee -a /etc/apt/sources.list && \
	curl "https://bintray.com/user/downloadSubjectPublicKey?username=bintray" > /tmp/bintray.gpg.key && \
	apt-key add - < /tmp/bintray.gpg.key && \
	apt-get -y install apt-transport-https && \
	apt-get -y update && \
	apt-get -y install rundeck-cli

VOLUME ["/home/rundeck/server/data"]
VOLUME ["/root/.ssh"]

EXPOSE 4440