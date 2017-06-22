<?php
  $servername = getenv("REMOTE_DB_HOST");
  $username = getenv("DB_USER");
  $password = getenv("DB_PWD");
  // Create connection
  $conn = new mysqli($servername, $username, $password);
  // Check connection
  if ($conn->connect_error) {
      die("Connection failed: " . $conn->connect_error);
  }
  echo "Connected successfully";
?>