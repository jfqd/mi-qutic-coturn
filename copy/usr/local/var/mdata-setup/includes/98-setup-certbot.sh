#!/usr/bin/bash

HOSTNAME=$(hostname)

if /native/usr/sbin/mdata-get mail_auth_user 1>/dev/null 2>&1; then
  EMAIL=$(/native/usr/sbin/mdata-get mail_auth_user)
fi

certbot register -n -m ${EMAIL} --agree-tos || true
certbot certonly --standalone --preferred-challenges http -d $HOSTNAME || true

echo "renew_hook = /usr/local/bin/coturn-hook" > /etc/letsencrypt/renewal/$HOSTNAME.conf

# get tls working with coturn
/usr/local/bin/coturn-hook || true
