#!/usr/bin/env bash

set -e

# LAMP (Linux Apache MySQL PHP) shell-provisioner
# Arguments are:
# - $1 - the path to the shared directory where .sql, .php files are located
# - $2 - (optional) if it's set, then "part", e.g. web or db will be installed on separate VM per Vagranfile instructions
#   if not, then both web and db will be installed together

CUSTOM_SHARED=${1:-"/custom_shared"}
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

  # 1. check httpd
  log "info" "Checking httpd service.."
  if ! sudo systemctl -q is-active httpd;then
    log "warning" "httpd not running.."
    sudo systemctl start httpd.service
    sudo systemctl enable httpd.service
  fi
  log "success" "OK\n"

  # 2. checking test index.php file
  log "info" "Checking if Apache's $www_root is symlinked with $CUSTOM_SHARED..\n"
  if [ ! -L "$www_root/index.php" ];then
    log "warning" "$www_root/index.php symlink not found. Creating symlink.."
    sudo ln -s $CUSTOM_SHARED/index.php $www_root
    sudo chmod +x $CUSTOM_SHARED
  fi
  log "success" "OK\n"

  # 3. Disable SELinux for HTTPD
  log "info" "Disabling SELinux policy for httpd.."
  sudo semanage permissive -a httpd_t
  log "success" "OK\n"

  # 4. Apache httpd ENV vars
  log "info" "Checking Apache env vars.."
  if [ ! -f /etc/httpd/conf.d/vars.conf ];then
    REMOTE_DB_HOST=${DB_HOST:-"localhost"}
    sudo printf "SetEnv REMOTE_DB_HOST $REMOTE_DB_HOST\n" >> /etc/httpd/conf.d/vars.conf
    sudo printf "SetEnv DB_USER $DB_USER\n" >> /etc/httpd/conf.d/vars.conf
    sudo printf "SetEnv DB_PWD $DB_PWD\n" >> /etc/httpd/conf.d/vars.conf
    sudo systemctl restart httpd.service
  fi
  log "success" "OK\n"
}

function provision_db() {
  local grant_remote=$1  # if this is set, then DB VM will grant remote access to Web-app VM

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
    mysql < ${CUSTOM_SHARED}/grant_remote_access.sql 2>/dev/null || log "info" "Already granted\n"
    log "success" "OK\n"

    if ! sudo firewall-cmd --list-services | grep mysql;then
      log "info" "Allow MySQL public traffic.."
      sudo firewall-cmd --permanent --zone=public --add-service=mysql
      log "success" "OK\n"
    fi
  fi

  log "info" "Checking MySQL root user.."
  mysql < ${CUSTOM_SHARED}/upt_root_pwd.sql 2>/dev/null || log "info" "Password for root user is already set.\n"
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

  install_pkgs "${packages[@]}"
  provision_web ;;

  "db")
  log "info" "Installing DB...\n"
  packages=("mariadb-server" "mariadb")
  is_remote="true"

  install_pkgs "${packages[@]}"
  provision_db $is_remote;;

  *)
  log "info" "Installing WEB and DB...\n"
  packages=("httpd" "mariadb-server" "mariadb" "php" "php-mysql" "policycoreutils-python")
  install_pkgs "${packages[@]}"
  provision_web
  provision_db ;;

esac

### Common provision steps
# Allow HTTP request go through guest firewalls
log "info" "Checking firewall-cmd.."
if ! sudo firewall-cmd --list-services | grep http;then
  log "info" "HTTP not enabled in firewall. Allow HTTP traffic.."
  sudo firewall-cmd --permanent --zone=public --add-service=http
  sudo firewall-cmd --reload
fi
log "success" "OK\n"

log "success" "DONE: Provision completed"