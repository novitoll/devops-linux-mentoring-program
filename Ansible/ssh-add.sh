#!/usr/bin/env bash

touch /root/.ssh/authorized_keys
cat /vagrant/node/ssh/id_rsa.pub >> /root/.ssh/authorized_keys

chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
