CREATE USER 'web_user'@'web';
GRANT ALL PRIVILEGES ON *.* TO 'web_user'@'web' IDENTIFIED BY 'password' WITH GRANT OPTION;
FLUSH PRIVILEGES;