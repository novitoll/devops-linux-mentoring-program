#!/bin/bash

yum install -y php php-mysql httpd

service httpd start

cat >> /var/www/html/index.php << EOF
<?php
  \$servername = "rds-mysql-1.cz7l2q90uve5.us-east-1.rds.amazonaws.com";
  \$username = "db_user";
  \$password = "p@ssword";
  // Create connection
  \$conn = new mysqli(\$servername, \$username, \$password);
  // Check connection
  if (\$conn->connect_error) {
      die("Connection failed: " . \$conn->connect_error);
  }
  echo "Connected successfully";
?>
EOF

chmod 664 /var/www/html/index.php

chown apache:apache /var/www/html/index.php
