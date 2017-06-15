#!/usr/bin/env bash

set -e

CURRENT_DIR=${1:-"/custom_shared"}
www_root="/var/www/html"  # apache httpd's assess files
declare -a pkgs=("httpd" "mariadb-server" "mariadb" "php" "php-mysql" "policycoreutils-python")

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
    sudo yum -y install $pkg
    wait
    log "info" "$pkg is installed."
  fi
done

# 2. check httpd
log "info" "Checking mariadb service.."
if ! sudo systemctl -q is-active httpd;then
  log "warning" "httpd not running.."
  sudo systemctl start httpd.service
  sudo systemctl enable httpd.service
fi
log "success" "OK\n"

# 3. mariadb configuration
log "info" "Checking mariadb service.."
if ! sudo systemctl -q is-active mariadb;then
  log "warning" "mariadb not running.."
  sudo systemctl start mariadb
  sudo systemctl enable mariadb # enable mariadb for autostart
fi
log "success" "OK\n"

# 4. checking MySQL root user
# For the 1st time, "mysql" is executed without password
# then after "upt_root_pwd.sql", "mysql" requires the root password.
# For that, we neglect with stderr as it will print "Access denied for user 'root'@'localhost'"
# and just notify with "info" message that password is already set.
log "info" "Checking MySQL root user.."
mysql < ${CURRENT_DIR}/upt_root_pwd.sql 2>/dev/null || log "info" "Password for root user is already set.\n"
log "success" "OK\n"

# 5. checking test index.php file
log "info" "Checking if Apache's $www_root is symlinked with $CURRENT_DIR..\n"
if [ ! -L "$www_root/index.php" ];then
  log "warning" "$www_root/index.php symlink not found. Creating symlink.."
  sudo ln -s $CURRENT_DIR/web_app/* $www_root
  sudo chmod -R +x $CURRENT_DIR/web_app
fi
log "success" "OK\n"

# 6. Allow HTTP request go through guest firewalls
log "info" "Checking firewall.."
if ! sudo firewall-cmd --list-services | grep http;then
  log "info" "HTTP not enabled in firewall. Allow HTTP traffic.."
  sudo firewall-cmd --permanent --zone=public --add-service=http
  sudo firewall-cmd --reload
fi
log "success" "OK\n"

# 7. Disable SELinux for HTTPD
log "info" "Disabling SELinux policy for httpd.."
sudo semanage permissive -a httpd_t
log "success" "OK\n"
log "success" "DONE: Provision completed"