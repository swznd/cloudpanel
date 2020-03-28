#!/bin/bash

echo "-----------------------"
echo "Installing Let's Encrypt SSL"
echo "-----------------------"
sleep 1
apt update
apt install -y certbot python-certbot-nginx