##### Execute these commands to set up your LAMP stack quickly once you already know what you're doing.

cd /tmp 

wget https://raw.githubusercontent.com/bbnagitesting/LinuxTesting/LAMPAutoTest.sh

chmod +x LAMPAutoTest.sh

replace '[your_ip]' 'XXX.XXX.XXX.XXX' -- ./LAMPAutoTest.sh #where 'XXX.XXX.XXX.XXX' is your ip address

./LAMPAutoTest.sh

#You can also remove a # tag on the last line to install all the necessary files for setting up nagios core, plugins and NDOUtils
