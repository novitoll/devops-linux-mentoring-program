#!/usr/bin/env bash

set -e

web_ip=$1
db_ip=$2
mgmt_ip=$3

# install ansible on ansible-mgmt node
yum install -y epel-release
yum install -y ansible

# copy playbooks into /home/vagrant (from inside the mgmt node)
chown -R vagrant:vagrant /home/vagrant

# configure hosts file for our internal network defined by Vagrantfile
cat >> /etc/hosts <<EOL
$web_ip  web
$db_ip  db
$mgmt_ip ansible
EOL