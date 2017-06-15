DELETE FROM mysql.user WHERE User = '';

-- update root password if authentication_string is not set
UPDATE mysql.user
    SET PASSWORD = PASSWORD('$3cr3t')
    WHERE User = 'root' AND Host = 'localhost' AND Password = '';
FLUSH PRIVILEGES;