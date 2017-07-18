FROM centos:7

LABEL maintainer="https://hub.docker.com/u/novitoll/"

COPY ./init.sh /db/init.sh

RUN yum install -y mariadb-server \
    && yum clean all \
    && chmod +x /db/init.sh

VOLUME /var/lib/mysql

ENTRYPOINT ["/db/init.sh"]

EXPOSE 3306
#CMD ["/db/init.sh"]