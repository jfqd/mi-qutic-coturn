#!/usr/bin/bash

IP=$(ifconfig eth0 |grep 'inet ' |awk '{print $2}')
HOSTNAME=$(hostname -f)
DOMAIN=$(hostname -d)

if /native/usr/sbin/mdata-get coturn_pwd 1>/dev/null 2>&1; then
  NEW_PWD=$(/native/usr/sbin/mdata-get coturn_pwd)
else
  NEW_PWD=$(dd if=/dev/urandom bs=32 count=1 2>/dev/null | shasum -a 256 | awk '{print $1}' | tr -d '\n')
fi

sed -i \
    -e "s/#listening-port=3478/listening-port=3478/" \
    -e "s/#tls-listening-port=5349/tls-listening-port=5349/" \
    -e "s/#listening-ip=172.17.19.101/listening-ip=${IP}/" \
    -e "s/#relay-ip=172.17.19.105/relay-ip=${IP}/" \
    -e "s/#fingerprint/fingerprint/" \
    -e "s/#use-auth-secret/use-auth-secret/" \
    -e "s/#static-auth-secret=north/static-auth-secret=${NEW_PWD}/" \
    -e "s/#server-name=blackdow.carleon.gov/server-name=${HOSTNAME}/" \
    -e "s/#realm=mycompany.org/realm=${DOMAIN}/" \
    -e "s/#total-quota=0/total-quota=100/" \
    -e "s/# bps-capacity=0/bps-capacity=0/" \
    -e "s/#stale-nonce=600/stale-nonce/" \
    -e "s|#cert=/usr/local/etc/turn_server_cert.pem|cert=/etc/coturn/fullchain.pem|" \
    -e "s|#pkey=/usr/local/etc/turn_server_pkey.pem|pkey=/etc/coturn/privkey.pem|" \
    -e "s/#cipher-list=\"DEFAULT\"/cipher-list=\"ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384\"/" \
    -e "s/#dh-file=<DH-PEM-file-name>/dh-file=/etc/dh2048.pem/" \
    -e "s/#no-stdout-log/no-stdout-log/" \
    -e "s/#no-multicast-peers/no-multicast-peers/" \
    -e "s/#no-tlsv1/no-tlsv1/" \
    -e "s/#no-tlsv1_1/no-tlsv1_1/" \
    /etc/turnserver.conf

openssl dhparam -out /etc/dh2048.pem 2048

systemctl stop coturn || true
sleep 5
systemctl start coturn || true
