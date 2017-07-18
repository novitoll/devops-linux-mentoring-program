FROM centos:7

LABEL maintainer="https://hub.docker.com/u/novitoll/"

COPY ./conf/nginx-server.conf /etc/nginx/conf.d/nginx-server.conf
COPY ./conf/php-fpm.conf /etc/php-fpm.d/php-fpm.conf
COPY ./index.php /var/www/html/index.php

RUN yum install -y php php-fpm php-mysql epel-release nginx

ENTRYPOINT ["nginx" "-g" "daemon on;"]

EXPOSE 80
CMD ["php-fpm"]