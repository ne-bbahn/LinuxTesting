# LAMP install script

sudo yum install httpd
$ yes | ./LAMPAutoTest.sh
sudo systemctl start httpd.service
sudo systemctl enable httpd.service

sudo yum install mariadb-server
$ yes | ./LAMPAutoTest.sh
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
$ yes | ./LAMPAutoTest.sh
$ yes | ./LAMPAutoTest.sh
sudo systemctl restart httpd.service
"<?php ?>" >> /var/www/html/info.php

sudo yum install phpmyadmin
$ yes | ./LAMPAutoTest.sh
$ yes | ./LAMPAutoTest.sh


replace '127.0.0.1' 'your_ip_here' -- /etc/httpd/conf.d/phpMyAdmin.conf

sudo systemctl restart httpd
sudo systemctl restart mariadb.service

# now you should be able to log into [your CentOS VM ip]/phpMyAdmin with your mariadb credentials.
