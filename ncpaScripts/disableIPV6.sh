#!/bin/bash

HOST=$1
USER="root"
PASS="welcome"
PORT="22"

ssh -p "$PORT" "$USER@$HOST" << EOF

sudo sed -i 's/community_string = mytoken/community_string = my%token/' /usr/local/ncpa/etc/ncpa.cfg
sudo sed -i '/GRUB_CMDLINE_LINUX=/ s/"$/ ipv6.disable=1"/' /etc/default/grub && sudo grub2-mkconfig -o /boot/grub2/grub.cfg && sudo reboot

EOF
