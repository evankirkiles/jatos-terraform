#!/bin/bash
# usage: initssl.sh domain_name registration_email enabled

# 0. if disable flag is set, exit immediately
if [ "$3" -eq "0" ]; then
  echo "Skipping setting up SSL..."
  exit
fi

# 0.5. install necessary addons
amazon-linux-extras install epel -y
yum install -y certbot python2-certbot-nginx

# 1. run certbot with the specified domain name
certbot --nginx -d $1 -m $2 -n --agree-tos \
  --config-dir=/study_assets/.ssl/config \
  --work-dir=/study_assets/.ssl/var