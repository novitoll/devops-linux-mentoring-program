#!/usr/bin/env bash

set -e

declare -a pkgs=("httpd" "mariadb-server" "mariadb" "php" "php-mysql")

log() {
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

# 1. Install missed packages
for pkg in "${pkgs[@]}"; do
  log "info" "Checking $pkg.."
  if rpm -aq | grep $pkg; then
    log "success" "OK\n"
  else
    log "warning" "$pkg is not installed. Installing.."
#    || log "error" "Error during installation of $pkg."
    sudo yum -y install $pkg
    wait
    log "info" "$pkg is installed."
  fi
done

# 2. mariadb configuration
log "info" "Checking mariadb service.."
if sudo systemctl -q is-active mariadb;then
  log "success" "OK\n"
else
  log "warning" "mariadb not running.."
  sudo systemctl start mariadb
  sudo systemctl enable mariadb
fi

# 3. checking MySQL root user
#mysql < ./init.sql ||

#https://raw.githubusercontent.com/mrysbekov/epam_mentoring/master/mysql_test.php
