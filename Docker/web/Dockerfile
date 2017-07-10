FROM centos:7

LABEL maintainer="https://hub.docker.com/u/novitoll/"

ADD . /web
WORKDIR /web

RUN yum install -y php php-fpm php-mysql

EXPOSE 80 9000

CMD ["php-fpm"]