FROM centos:7

LABEL maintainer="https://hub.docker.com/u/novitoll/"

ENV SCRIPTS_DIR /usr/share

# nginx proxy to php-fpm socket
ADD ./conf/nginx-server.conf /etc/nginx/conf.d/nginx-server.conf
ADD ./nginx.sh $SCRIPTS_DIR/nginx.sh

# PHP-fpm
ADD ./conf/php-fpm.conf /etc/php-fpm.d/php-fpm.conf
ADD ./php-fpm.sh $SCRIPTS_DIR/php-fpm.sh

ADD ./startup.sh $SCRIPTS_DIR/startup.sh

COPY ./index.php /var/www/html/index.php

RUN yum install -y php php-fpm php-mysql
RUN yum install -y epel-release \
    && yum install -y nginx

ENTRYPOINT ["/usr/sbin/nginx", "-g", "daemon on;"]

EXPOSE 80
CMD ["/bin/bash", "$SCRIPTS_DIR/php-fpm.sh"]