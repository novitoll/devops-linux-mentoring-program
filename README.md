### DevOps mentoring program tasks (Linux infrastructure)
---

Repository should include separate directories for the dedicated technology:
- Vagrant (v1.9.5, CentOS 7, VirtualBox 15.04)

  There are 2 Vagrantfiles in the `/Vagrant` directory:
    - `../single_vm/Vagrantfile` produces 1 VM on CentOS:7 image with PHP, MariabDB (MySQL), Apache HTTPd, and is provisioned  with Bash script
    - `../multiple_vms/Vagrantfile` produces 2 VMs on CentOS:7 image with "web" (PHP, Apache HTTPd) node and "db" (MariaDB) node, and is provisioned with Bash script with additional argument for the node definition

  SELinux is set permissive for httpd process here.
  
  *Execute command on /Vagrant directory:* `vagrant up`

- Docker (v17.06.0-ce, CentOS 7, Docker-Compose 1.14.0)
  
  There are 3 Dockerfiles to produce 4 CentOS:7 based containers: 1 image for Nginx Load Balancer, 1 image for DB, 1 image for 2 web nodes with PHP & PHP-fpm with Nginx as proxy (requests are redirected to php-fpm unix domain socket).
  
  *Execute command on /Docker directory:* `sudo docker-compose up`
  
    ```bash
    $ sudo docker ps
    CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                  NAMES
  33be4ca61a7f        docker_load_balancer   "/usr/sbin/nginx -..."   17 hours ago        Up 15 seconds       0.0.0.0:8080->80/tcp   load_balancer
  507d1553c9a9        docker_web_2           "/usr/share/startu..."   17 hours ago        Up 16 seconds       80/tcp                 web_2
  55eb9eaf4f57        docker_web_1           "/usr/share/startu..."   17 hours ago        Up 16 seconds       80/tcp                 web_1
  01c4085670d5        docker_db              "/bin/bash /db/ini..."   17 hours ago        Up 17 seconds       3306/tcp               db
    ```


- Ansible

```bash
$ vagrant up
$ vagrant ssh ansible
$ sudo ansible-playbook /home/vagrant/my_repo/Ansible/node/site.yml

localhost:8080 -> Connected successfully
```

- AWS
- POC (Proof-of-concept: all techs in one test project as the infrastructure)

### License
MIT
