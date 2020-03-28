#!/bin/bash

echo "-----------------------"
echo "Installing Let's Encrypt SSL"
echo "-----------------------"
sleep 1
apt-get update
apt-get install -y certbot python-certbot-nginx