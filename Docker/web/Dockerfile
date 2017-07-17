FROM centos:7

LABEL maintainer="https://hub.docker.com/u/novitoll/"

COPY . /web
WORKDIR /web

RUN yum install -y php php-fpm php-mysql

EXPOSE 80

CMD ["php-fpm"]