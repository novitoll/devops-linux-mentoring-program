FROM centos:7

LABEL maintainer="https://hub.docker.com/u/novitoll/"

COPY . /db
WORKDIR /db

RUN yum install -y mariadb-server

EXPOSE 3306

#CMD ["mysql < /init.sql"]