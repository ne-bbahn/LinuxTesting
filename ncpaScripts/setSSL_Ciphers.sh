#!/bin/bash

HOST=$1
USER="root"
PASS="welcome"
PORT="22"

ssh -p "$PORT" "$USER@$HOST" << EOF

sed -i 's/# ssl_ciphers = <list of ciphers>/ssl_ciphers = AES256-GCM-SHA384:AES256-SHA256:AES256-SHA:CAMELLIA256-SHA/' /usr/local/ncpa/etc/ncpa.cfg
systemctl restart ncpa

EOF
