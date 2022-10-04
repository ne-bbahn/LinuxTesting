##### Execute these commands to set up your LAMP stack

cd /tmp 

wget https://raw.githubusercontent.com/bbnagitesting/LinuxTesting/LAMPAutoTest.sh

chmod +x LAMPAutoTest.sh

replace '192.168.53.144' '[your ip here]' -- ./LAMPAutoTest.sh

./LAMPAutoTest.sh

#You can also remove a # tag on the last line to install all the necessary files for setting up nagios core, plugins and NDOUtils
