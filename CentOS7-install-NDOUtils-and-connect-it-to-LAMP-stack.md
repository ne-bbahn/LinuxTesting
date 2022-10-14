# Nagios Core: setup NDOutils to store Nagios data in your LAMP stack
NOTE: this is a continuation of nagios-core-plugins setup guide, and you need to complete "CentOS7 install nagios-core-plugins" guide before moving on to this one. 
You should also have a LAMP stack set up, enabled and working
Also, some of these commands must be executed as root user in your CentOS7 terminal, so I suggest being logged in as root throughout and being very careful with making sure your commands are correct. 
# MAKE SURE TO BACK UP sysctl.conf as seen on line 40 or you may damage your OS. 

### guide I used:  https://support.nagios.com/kb/article/ndoutils-installing-ndoutils-406.html#CentOS

# Part 3: prepare nagios install & DB for NDOUtils
### ensure you have the necessary database packages
```
yum install -y mysql mysql-server mysql-devel
yum install -y mariadb mariadb-server mariadb-devel
```
### restart apache & db
```
systemctl restart httpd
systemctl restart mariadb.service
ps ax | grep mysql | grep -v grep # check that it's running
```

### if not already done, do the following to enable and start mariadb:
``` systemctl enable mariadb.service
systemctl start mariadb.service
```

### save password as 'mypassword'
`/usr/bin/mysqladmin -u root password 'mypassword'`

### log in with mysql/mariadb root password, NOTE!!: NO space between -p and password
`mysql -u root -p'mypassword' `

## now in SQL DB:
### create nagios database and NDOUtils user, grant that user necessary permissions
```
CREATE DATABASE nagios DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER 'ndoutils'@'localhost' IDENTIFIED BY 'ndoutils_password';
GRANT USAGE ON *.* TO 'ndoutils'@'localhost' IDENTIFIED BY 'ndoutils_password' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;
GRANT ALL PRIVILEGES ON nagios.* TO 'ndoutils'@'localhost' WITH GRANT OPTION ;
\q
```

### check to ensure that nagios db has been created
`echo 'show databases;' | mysql -u ndoutils -p'ndoutils_password' -h localhost # checks that DB has been created. `

# CREATE BACKUP of system controller SO YOU DON'T RUIN EVERYTHING #####
`cp /etc/sysctl.conf /etc/sysctl.conf_backup`

### edit kernel settings to make system output nagios data to NDOUtils optimally
```
sed -i '/msgmnb/d' /etc/sysctl.conf
sed -i '/msgmax/d' /etc/sysctl.conf
sed -i '/shmmax/d' /etc/sysctl.conf
sed -i '/shmall/d' /etc/sysctl.conf
printf "\n\nkernel.msgmnb = 131072000\n" >> /etc/sysctl.conf
printf "kernel.msgmax = 131072000\n" >> /etc/sysctl.conf
printf "kernel.shmmax = 4294967295\n" >> /etc/sysctl.conf
printf "kernel.shmall = 268435456\n" >> /etc/sysctl.conf
sysctl -e -p /etc/sysctl.conf
```

# Install NDOUtils
### in /tmp download and unpack NDOUtils
```
cd /tmp
wget -O ndoutils.tar.gz https://github.com/NagiosEnterprises/ndoutils/releases/download/ndoutils-2.1.3/ndoutils-2.1.3.tar.gz
tar xzf ndoutils.tar.gz
```

### configure and install NDOUtils
```
cd /tmp/ndoutils-2.1.3/
./configure
make all
make install
```

### in NDOUtils install folder, executed file preps database for nagios data
```
cd db/
./installdb -u 'ndoutils' -p 'ndoutils_password' -h 'localhost' -d nagios
cd .. # this should put you back in /tmp/ndoutils-2.1.3, if it does not, cd /tmp/ndoutils-2.1.3
```

### make sure db_user is ndoutils and db_pass  is ndoutils_password in /usr/local/nagios/etc/ndo2db.cfg -- check subnote X.1 if you need help with this

### configure NDOUtils config to have correct username and password
```
make install-config
mv /usr/local/nagios/etc/ndo2db.cfg-sample /usr/local/nagios/etc/ndo2db.cfg
sed -i 's/^db_user=.*/db_user=ndoutils/g' /usr/local/nagios/etc/ndo2db.cfg
sed -i 's/^db_pass=.*/db_pass=ndoutils_password/g' /usr/local/nagios/etc/ndo2db.cfg
mv /usr/local/nagios/etc/ndomod.cfg-sample /usr/local/nagios/etc/ndomod.cfg
```

### install NDOUtils Daemon (background process)
```
make install_init
systemctl enable ndo2db.service
systemctl start ndo2db.service
```

### configure nagios to use NDOUtils
```
printf "\n\n# NDOUtils Broker Module\n" >> /usr/local/nagios/etc/nagios.cfg
printf "broker_module=/usr/local/nagios/bin/ndomod.o config_file=/usr/local/nagios/etc/ndomod.cfg\n" >> /usr/local/nagios/etc/nagios.cfg 
```

### restart and enable nagios.service (systemctl), then check to be sure it's working. Have a wonderful day.  =^.^=


# Subnotes
## X.1: ensuring NDOUtils config has correct user/password
```
cd /usr/local/nagios/etc
grep -nr 'db_'
```
#### Here you should see at the bottom of ndo2db.cfg: 
db_user=ndoutils

db_pass=ndoutils_password
