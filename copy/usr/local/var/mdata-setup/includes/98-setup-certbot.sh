#!/bin/bash

HOSTNAME=$(hostname -f)

if /native/usr/sbin/mdata-get mail_auth_user 1>/dev/null 2>&1; then
  EMAIL=$(/native/usr/sbin/mdata-get mail_auth_user)
fi

certbot register -n -m ${EMAIL} --agree-tos
certbot certonly --standalone --preferred-challenges http -d $HOSTNAME

echo "renew_hook = systemctl reload coturn" > /etc/letsencrypt/renewal/$HOSTNAME.conf