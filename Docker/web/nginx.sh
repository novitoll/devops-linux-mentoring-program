#!/bin/sh
#
# nginx - this script starts and stops the nginx daemon
#
# chkconfig:   - 85 15
# description:  NGINX is an HTTP(S) server, HTTP(S) reverse \
#               proxy and IMAP/POP3 proxy server
# processname: nginx
# config:      /etc/nginx/nginx.conf
# config:      /etc/sysconfig/nginx
# pidfile:     /var/run/nginx.pid

# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0

nginx="/usr/sbin/nginx"
prog=$(basename $nginx)

NGINX_CONF_FILE="/etc/nginx/nginx.conf"
NGINX_PID_FILE="/run/nginx.pid"

[ -f /etc/sysconfig/nginx ] && . /etc/sysconfig/nginx

lockfile=/var/lock/subsys/nginx

make_dirs() {
  # make required directories
  user=`$nginx -V 2>&1 | grep "configure arguments:.*--user=" | sed 's/[^*]*--user=\([^ ]*\).*/\1/g' -`
  if [ -n "$user" ]; then
    if [ -z "`grep $user /etc/passwd`" ]; then
      useradd -M -s /bin/nologin $user
    fi
    options=`$nginx -V 2>&1 | grep 'configure arguments:'`
    for opt in $options; do
      if [ `echo $opt | grep '.*-temp-path'` ]; then
        value=`echo $opt | cut -d "=" -f 2`
        if [ ! -d "$value" ]; then
          # echo "creating" $value
          mkdir -p $value && chown -R $user $value
        fi
      fi
    done
  fi
}

start() {
  [ -x $nginx ] || exit 5
  [ -f $NGINX_CONF_FILE ] || exit 6
  make_dirs
  echo -n $"Starting $prog: "
  $nginx -c $NGINX_CONF_FILE -g "daemon off;"
  retval=$?
  echo
  [ $retval -eq 0 ] && touch $lockfile
  return $retval
}

stop() {
  echo -n $"Stopping $prog: "
  killproc
  retval=$?
  echo
  [ $retval -eq 0 ] && rm $lockfile
  return $retval
}

configtest() {
  $nginx -t -c $NGINX_CONF_FILE
}

killproc() {
    PIDS=$(ps ax | grep -v grep | grep -e "nginx:.*process" | awk '{printf $1 "\n"}')
    for pid in $PIDS; do
      kill -9 $pid
    done
    wait $PIDS 2>/dev/null
}

case "$1" in
    start)
        $1
        ;;
    stop)
        $1
        ;;
    restart|configtest)
        $1
        ;;
    *)
        echo $"Usage: $0 {start|stop|configtest}"
        exit 2
esac
