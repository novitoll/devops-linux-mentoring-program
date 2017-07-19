FROM centos:7

LABEL maintainer="https://hub.docker.com/u/novitoll/"

ENV SCRIPTS_DIR /usr/share

RUN yum install -y php php-fpm php-mysql
RUN yum install -y epel-release \
    && yum install -y nginx

# nginx proxy to php-fpm socket
#COPY ./conf/nginx-server.conf /etc/nginx/conf.d/nginx-server.conf
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

COPY ./nginx.sh $SCRIPTS_DIR/nginx.sh
COPY ./startup.sh $SCRIPTS_DIR/startup.sh
COPY ./php-fpm.sh $SCRIPTS_DIR/php-fpm.sh

# PHP-fpm
COPY ./conf/php-fpm.conf /etc/php-fpm.d/www.conf
COPY ./index.php /usr/share/nginx/html/index.php

RUN chmod +x -R $SCRIPTS_DIR

EXPOSE 80
ENTRYPOINT ["/usr/share/startup.sh"]