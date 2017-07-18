FROM centos:7

LABEL maintainer="https://hub.docker.com/u/novitoll/"

COPY ./init.sh /db/init.sh

RUN yum install -y mariadb-server mariadb-client \
    && yum clean all \
    && chmod +x /db/init.sh

VOLUME /var/lib/mysql

EXPOSE 3306
ENTRYPOINT ["/bin/bash", "/db/init.sh"]