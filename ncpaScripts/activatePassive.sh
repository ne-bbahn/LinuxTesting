#!/bin/bash

HOST=$1
USER="root"
PORT="22"

ssh -p "$PORT" "$USER@$HOST" << EOF

OS=$(grep -Eo '(Ubuntu|CentOS)' /etc/*release)

if [[ "$OS" == "Ubuntu" ]]; then
    sudo ufw allow 5693/tcp
elif [[ "$OS" == "CentOS" ]]; then
    sudo firewall-cmd --add-port=5693/tcp --permanent
    sudo firewall-cmd --reload
fi

sed -i 's/handlers = None/handlers = nrdp/' /usr/local/ncpa/etc/ncpa.cfg
sed -i '5,\$s/^#//' /usr/local/ncpa/etc/ncpa.cfg.d/example.cfg
sudo systemctl restart ncpa

EOF
