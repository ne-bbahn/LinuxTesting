# install nagios plugins Linux

## Or just follow this: https://support.nagios.com/kb/article.php?id=96&show_category=58

# Part 1: Nagios Core
`yum install -y gcc glibc glibc-common wget gd gd-devel perl postfix unzip  #install necessary prerequisite packages`

### in the /tmp folder download and unzip nagios core (replace 4.4.2 with most recent version)
```
cd /tmp
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.2.tar.gz
tar xzf nagioscore.tar.gz
```

### navigate to extracted folder, set up and install Nagios core content
```
cd /tmp/nagioscore-nagios-4.4.2
./configure
make all
make install-groups-users
usermod -a -G nagios apache
make install
make install-daemoninit
make install-config
make install-commandmode
make install-webconf
```

### restart apache 
`systemctl restart httpd`

### set password for nagiosadmin
`htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin`

# Part 2: Nagios Plugins
#### I followed this: https://support.nagios.com/kb/article/nagios-plugins-installing-nagios-plugins-from-source-569.html
### install prereqs
`yum install -y gcc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils epel-release perl-Net-SNMP`

### navigate back to /tmp folder, download and unpack nagios plugins
```
cd /tmp
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.4.0.tar.gz
tar zxf nagios-plugins.tar.gz
cd /tmp/nagios-plugins-release-2.4.0/
```
### setup, configure & install
```
./tools/setup
./configure
make
make install
systemctl start nagios
```

### navigate to XXX.XXX.XXX.XXX/nagios and log in
