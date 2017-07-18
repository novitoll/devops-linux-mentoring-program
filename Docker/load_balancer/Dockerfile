FROM centos:7

LABEL maintainer="https://hub.docker.com/u/novitoll/"

COPY ./conf/nginx_load_balance.conf /etc/nginx/conf.d/nginx_load_balance.conf

RUN yum install -y epel-release \
 && yum install -y nginx

RUN setenforce 0

EXPOSE 80
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]