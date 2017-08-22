#!/usr/bin/env bash

set -e

home_dir="/home/vagrant"
git_repo="https://github.com/Novitoll/devops-linux-mentoring-program.git"
git_repo_dir="$home_dir/my_repo"

# install ansible on ansible node
sudo yum install -y epel-release
sudo yum install -y ansible

echo "Ansible version is $(ansible --version)"

# install git
yum install -y git

# copy repo to ansbile VM
if [ ! -d $git_repo_dir ]; then
    echo "No repository found. Cloning Git repo $git_repo.."
    git clone $git_repo $git_repo_dir;
else
    echo "Pulling Git repo.."
    git pull $git_repo $git_repo_dir;
fi

# check SSH RSA keys
if [ ! -f $home_dir/.ssh/id_rsa ]; then
    ssh-keygen -f $home_dir/.ssh/id_rsa -t rsa -N ''
fi

# configure hosts file for our internal network defined by Vagrantfile
# TODO: need to check this for idempotence
cat $git_repo_dir/Ansible/node/hosts >> /etc/hosts
cat $git_repo_dir/Ansible/node/ansible.cfg >> $home_dir/ansible.cfg

chown -R vagrant:vagrant $home_dir

# execute ssh-add playbook to copy SSH to web and db
ansible-playbook $git_repo_dir/Ansible/node/playbooks/ssh-add.yml

# execute web playbook
#ansible-playbook $git_repo_dir/Ansible/node/playbooks/web.yml
#
## execute db playbook
#ansible-playbook $git_repo_dir/Ansible/node/playbooks/db.yml