UPDATE mysql.user
    SET authentication_string = PASSWORD('$3cr3t'), password_expired = 'N'
    WHERE User = 'root' AND Host = 'localhost' AND authentication_string = '';
FLUSH PRIVILEGES;