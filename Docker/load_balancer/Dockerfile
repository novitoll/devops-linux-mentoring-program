FROM centos:7

LABEL maintainer="https://hub.docker.com/u/novitoll/"

ADD . /load_balancer
WORKDIR /load_balancer

RUN yum install -y nginx

EXPOSE 80

CMD ["/usr/sbin/nginx", "-g", "daemon off;"]