#!/bin/bash

DB_PASSWD=admin

docker run -p 3306:3306 --restart always --name mysql8 \
    -v /opt/mysql/conf:/etc/mysql \
    -v /opt/mysql/log:/var/log/mysql \
    -v /opt/mysql/data:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=$DB_PASSWD -d mysql:8.0.18
docker cp mysql8.0.18:/etc/mysql/ /opt/mysql/conf

# 新建jiradb库  新建用户授权  jirauser,xxxxxx
CREATE DATABASE jiradb CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER jirauser IDENTIFIED BY 'xxxxxx';
GRANT ALL ON jiradb.* to 'jirauser'@'%' ;

# 新建wikidb库 wikiuser , xxxxxx
CREATE DATABASE wikidb CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER wikiuser IDENTIFIED BY 'xxxxxx';
GRANT ALL ON wikidb.* to 'wikiuser'@'%' ;

# 设置全局的事务隔离级别为 读取已提交
set global transaction_isolation='read-committed';

cat << 'EOF' > Dockerfile 
FROM cptactionhank/atlassian-jira-software:latest

USER root

# 将代理破解包加入容器
COPY "atlassian-agent.jar" /opt/atlassian/jira/

# mysql驱动拷贝
COPY "mysql-connector-java-8.0.19.jar" /opt/atlassian/jira/lib/

# 设置启动加载代理包
RUN echo 'export CATALINA_OPTS="-javaagent:/opt/atlassian/jira/atlassian-agent.jar ${CATALINA_OPTS}"' >> /opt/atlassian/jira/bin/setenv.sh
EOF