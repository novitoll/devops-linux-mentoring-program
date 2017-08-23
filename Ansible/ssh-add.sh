#!/usr/bin/env bash

cat ./ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys

chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys
