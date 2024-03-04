#!/bin/bash

HOST=$1
USER="root"
PASS="welcome"
PORT="22"

ssh -p "$PORT" "$USER@$HOST" << EOF

firewall-cmd --add-port=5693/tcp --permanent
firewall-cmd --reload
sed -i 's/handlers = None/handlers = nrdp/' /usr/local/ncpa/etc/ncpa.cfg
sed -i '5,\$s/^#//' /usr/local/ncpa/etc/ncpa.cfg.d/example.cfg
sudo systemctl restart ncpa

EOF
