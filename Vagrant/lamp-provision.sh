#!/usr/bin/env bash

# LAMP (Linux Apache MySQL PHP) shell-provisioner
# Arguments are:
# - $1 - the path to the shared directory where .sql, .php files are located
# - $2 - (optional) if it's set, then "part", e.g. web or db will be installed on separate VM per Vagranfile instructions
#   if not, then both web and db will be installed together

set -e

shared_dir=${1:-"/custom_shared"}
part=$2

function log() {
  local level=$1
  local msg=$2

  case $level in
    "info")
    lvl_sym="[ ]" ;;
    "success")
    lvl_sym="[+]" ;;
    "warning")
    lvl_sym="[!]" ;;
    "error")
    lvl_sym="[-]" ;;
  esac

  printf "$lvl_sym $msg"

  if [ "$level" == "error" ]; then exit 1; fi
}

function install_pkgs() {
  local pkgs=("$@")

  # 0. Install missed packages
  for pkg in "${pkgs[@]}"; do
    log "info" "Checking if $pkg installed.."
    if rpm -aq | grep $pkg; then
      log "success" "OK\n"
    else
      log "warning" "$pkg is not installed. Installing.."
      sudo yum -y install $pkg
      log "info" "$pkg is installed."
    fi
    wait
  done
}

function provision_web() {
  local www_root="/var/www/html"  # apache httpd's assess files
  local current_dir=$1

  # 1. check httpd
  log "info" "Checking httpd service.."
  if ! sudo systemctl -q is-active httpd;then
    log "warning" "httpd not running.."
    sudo systemctl start httpd.service
    sudo systemctl enable httpd.service
  fi
  log "success" "OK\n"

  # 2. checking test index.php file
  log "info" "Checking if Apache's $www_root is symlinked with $current_dir..\n"
  if [ ! -L "$www_root/index.php" ];then
    log "warning" "$www_root/index.php symlink not found. Creating symlink.."
    sudo ln -s $current_dir/web_app/* $www_root
    sudo chmod -R +x $current_dir/web_app
  fi
  log "success" "OK\n"

  # 3. Disable SELinux for HTTPD
  log "info" "Disabling SELinux policy for httpd.."
  sudo semanage permissive -a httpd_t
  log "success" "OK\n"
}

function provision_db() {
  local current_dir=$1
  local grant_remote=$2  # if this is set, then DB VM will grant remote access to Web-app VM

  # 1. mariadb configuration
  log "info" "Checking mariadb service.."
  if ! sudo systemctl -q is-active mariadb;then
    log "warning" "mariadb not running.."
    sudo systemctl start mariadb
    sudo systemctl enable mariadb # enable mariadb for autostart
  fi
  log "success" "OK\n"

  # 2. checking MySQL root user
  # For the 1st time, "mysql" is executed without password
  # then after "upt_root_pwd.sql", "mysql" requires the root password.
  # For that, we neglect with stderr as it will print "Access denied for user 'root'@'localhost'"
  # and just notify with "info" message that password is already set.

  if [ ! -z $grant_remote ];then
    log "info" "Checking remote Web-app VM access to DB VM.."
    mysql < ${current_dir}/grant_remote_access.sql 2>/dev/null || log "info" "Already granted\n"
    log "info" "Allow MySQL public traffic.."
    sudo firewall-cmd --permanent --zone=public --add-service=mysql
    log "success" "OK\n"
  fi

  log "info" "Checking MySQL root user.."
  mysql < ${current_dir}/upt_root_pwd.sql 2>/dev/null || log "info" "Password for root user is already set.\n"
  log "success" "OK\n"
}

##########################################
# packages to install
declare -a packages=()

# pick packages per VM "part"
case $part in
  "web")
  log "info" "Installing WEB...\n"
  packages=("httpd" "policycoreutils-python" "php" "php-mysql")
  log "info" "AAAAAA $IS_REMOTE_DB"

  install_pkgs "${packages[@]}"
  provision_web $shared_dir ;;

  "db")
  log "info" "Installing DB...\n"
  packages=("mariadb-server" "mariadb")
  is_remote="true"

  install_pkgs "${packages[@]}"
  provision_db $shared_dir $is_remote;;

  *)
  log "info" "Installing WEB and DB...\n"
  packages=("httpd" "mariadb-server" "mariadb" "php" "php-mysql" "policycoreutils-python")
  install_pkgs "${packages[@]}"
  provision_web $shared_dir
  provision_db $shared_dir ;;

esac

# Allow HTTP request go through guest firewalls
log "info" "Checking firewall-cmd.."
if ! sudo firewall-cmd --list-services | grep http;then
  log "info" "HTTP not enabled in firewall. Allow HTTP traffic.."
  sudo firewall-cmd --permanent --zone=public --add-service=http
  sudo firewall-cmd --reload
fi
log "success" "OK\n"

log "success" "DONE: Provision completed"