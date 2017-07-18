#!/bin/sh

set -m

/usr/bin/mysqld_safe &

RET=1

while [[ RET -ne 0 ]]; do
      sleep 3
      mysql -uroot -e "status" > /dev/null
      RET=$?
done

mysql -uroot -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%';"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;"
mysql -uroot -e "FLUSH PRIVILEGES;"

fg