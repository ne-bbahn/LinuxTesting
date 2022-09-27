# LAMP install script

# you will need to run "replace '127.0.0.1' '[your ip]' -- LAMPAutoTest.sh"

sudo yum install httpd
sudo systemctl start httpd.service
sudo systemctl enable httpd.service

sudo yum install mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

sudo mysql_secure_installation
# at this point it will ask for root password, it will be "" 
# set a password
# Y
# Disallow root login remotely? n  # this is important unless you want to have to make a new user or have to login with your linux client
# Y
# Y

sudo yum install php php-mysql
sudo systemctl restart httpd.service
"<?php ?>" >> /var/www/html/info.php

sudo yum install epel-release
sudo yum install phpmyadmin

replace '127.0.0.1' 'your_ip_here' -- /etc/httpd/conf.d/phpMyAdmin.conf

sudo systemctl restart httpd
sudo systemctl restart mariadb.service

# now you should be able to log into [your CentOS VM ip]/phpMyAdmin with your mariadb credentials.
