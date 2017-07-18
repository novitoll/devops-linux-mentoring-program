#!/bin/bash

# Start php-fpm
"${SCRIPTS_DIR}"/php-fpm.sh start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start php-fpm: $status"
  exit $status
fi

# Start nginx
"${SCRIPTS_DIR}"/nginx.sh start
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start nginx: $status"
  exit $status
fi
