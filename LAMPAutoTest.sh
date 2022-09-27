# LAMP install script (CentOS7 /tmp/LAMP_up.sh)

sudo yum install httpd
sudo systemctl start httpd.service
sudo systemctl enable httpd.service

sudo yum install mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

sudo mysql_secure_installation

sudo yum install php php-mysql
sudo systemctl restart httpd.service
"<?php ?>" >> /var/www/html/info.php

sudo yum install epel-release
sudo yum install phpmyadmin

echo Enter your computer's IP address
read myip
replace '127.0.0.1' $myip -- /etc/httpd/conf.d/phpMyAdmin.conf

sudo systemctl restart httpd
sudo systemctl restart mariadb.service

# now you should be able to log into [your CentOS VM ip]/phpMyAdmin with your mariadb credentials.
