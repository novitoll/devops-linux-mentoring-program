<?php
  // if (getenv('IS_REMOTE_DB') == true) {
    $servername = "192.168.56.102";
  // } else {
  //   $servername = "localhost";
  // }

  $username = "root";
  $password = "$3cr3t";
  // Create connection
  $conn = new mysqli($servername, $username, $password);
  // Check connection
  if ($conn->connect_error) {
      die("Connection failed: " . $conn->connect_error);
  }
  echo "Connected successfully";
?>