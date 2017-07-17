<?php
  $servername = "db";
  $username = "s3cr3t";
  $password = "web_user";
  $hostanme = gethostname();

  echo "Connected to $hostanme\r\n"

  // Create connection
  $conn = new mysqli($servername, $username, $password);
  // Check connection
  if ($conn->connect_error) {
      die("Connection failed: " . $conn->connect_error);
  }
  echo "Connected successfully";
?>