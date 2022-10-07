# LAMP install script

# you will need to run "replace 'your_ip_here' '[your ip address]' -- LAMPAutoTest.sh"

sudo yum install -y httpd
sudo systemctl start httpd.service
sudo systemctl enable httpd.service

sudo yum install -y mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb

sudo mysql_secure_installation
# at this point it will ask for root password, it will be "" 
# set a password
# Y
# Disallow root login remotely? n  # this is important unless you want to have to make a new user or have to login with your linux client
# Y
# Y

sudo yum install -y php php-mysql
sudo systemctl restart httpd.service
"<?php ?>" >> /var/www/html/info.php

sudo yum install -y epel-release
sudo yum install -y phpmyadmin

replace '127.0.0.1' '[your_ip]' -- /etc/httpd/conf.d/phpMyAdmin.conf

sudo systemctl restart httpd
sudo systemctl restart mariadb.service

# now you should be able to log into [your CentOS VM ip]/phpMyAdmin with your mariadb credentials.

# install a bunch of stuff to get ready for nagios, nagios plugins and NDOUtils. Just uncomment it to run :D
# sudo yum install -y gcc glibc-common wget gd gd-devel perl postfix unzip make gettext automake autoconf openssl-devel net-snmp net-snmp-utils epel-release perl-Net-SNMP mysql mysql-server mysql-devel mariadb mariadb-server mariadb-devel
