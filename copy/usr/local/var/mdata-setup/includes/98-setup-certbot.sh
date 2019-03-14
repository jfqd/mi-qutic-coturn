#!/bin/bash

HOSTNAME=$(hostname -f)
certbot register -m report@qutic.com --agree-tos
certbot certonly --standalone --preferred-challenges http -d $HOSTNAME

echo "renew_hook = systemctl reload coturn" > /etc/letsencrypt/renewal/$HOSTNAME.conf