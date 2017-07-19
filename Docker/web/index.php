<?php
  $servername = "db";
  $username = "web_user";
  $password = "s3cr3t";
  $hostanme = gethostname();

  echo "Connected to $hostanme\r\n";

  // Create connection
  $conn = new mysqli($servername, $username, $password);
  // Check connection
  if ($conn->connect_error) {
      die("Connection failed: " . $conn->connect_error);
  }
  echo "Connected successfully";
?>