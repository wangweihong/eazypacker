#!/bin/bash

set -ex

JenkinName="jenkins"

docker network create jenkins
# https://www.jenkins.io/doc/book/installing/docker/

docker run --name jenkins-docker --rm --detach \
    --privileged --network jenkins --network-alias docker \
    --env DOCKER_TLS_CERTDIR=/certs \
    --volume jenkins-docker-certs:/certs/client \
    --volume jenkins-data:/var/jenkins_home \
    --publish 2376:2376 \
    docker:dind --storage-driver overlay2

cat << 'EOF' >Dockerfile

FROM jenkins/jenkins:2.440.3-jdk17
USER root

# 定义构建参数
ARG HTTP_PROXY
# 设置代理环境变量
ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTP_PROXY

RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"

EOF

docker build --build-arg HTTP_PROXY=$HTTP_PROXY -t myjenkins-blueocean:2.440.3-1 .

# 必须设置-u=0 https://stackoverflow.com/questions/44065827/jenkins-wrong-volume-permissions
docker run -u=0 --name $JenkinName --restart=on-failure --detach \
    --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
    --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
    --publish 8080:8080 --publish 50000:50000 \
    --volume jenkins-data:/var/jenkins_home \
    --volume jenkins-docker-certs:/certs/client:ro \
    myjenkins-blueocean:2.440.3-1


INITIAL_PASSWORD=$(docker exec $JenkinName cat /var/jenkins_home/secrets/initialAdminPassword)