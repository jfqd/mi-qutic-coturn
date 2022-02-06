#!/bin/bash

coturn_pwd

if /native/usr/sbin/mdata-get coturn_pwd 1>/dev/null 2>&1; then
  NEW_PWD=$(/native/usr/sbin/mdata-get coturn_pwd)
else
  NEW_PWD=$(dd if=/dev/urandom bs=32 count=1 2>/dev/null | shasum -a 256 | awk '{print $1}' | tr -d '\n')
fi
sed -i "s/#static-auth-secret=north/static-auth-secret=${NEW_PWD}/" /etc/turnserver.conf

HOSTNAME=$(hostname -f)
sed -i "s/#server-name=blackdow.carleon.gov/server-name=${HOSTNAME}/" /etc/turnserver.conf

DOMAIN=$(hostname -d)
sed -i "s/#realm=mycompany.org/realm=${DOMAIN}/" /etc/turnserver.conf

sed -i "s|#cert=/usr/local/etc/turn_server_cert.pem|cert=/etc/letsencrypt/live/${HOSTNAME}/fullchain.pem|" /etc/turnserver.conf
sed -i "s|#pkey=/usr/local/etc/turn_server_pkey.pem|pkey=/etc/letsencrypt/live/${HOSTNAME}/privkey.pem|" /etc/turnserver.conf

IP=$(ifconfig eth0 |grep 'inet ' |awk '{print $2}')
sed -i "s/#listening-ip=172.17.19.101/listening-ip=${IP}/" /etc/turnserver.conf
sed -i "s/#relay-ip=172.17.19.105/relay-ip=${IP}/" /etc/turnserver.conf

openssl dhparam -out /etc/dh2048.pem 2048

service coturn restart