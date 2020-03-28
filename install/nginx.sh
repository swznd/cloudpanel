#/bin/bash

echo "-----------------------"
echo "Installing Nginx"
echo "-----------------------"
sleep 1
echo "deb http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" > /etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
apt-get update
apt-get install -y nginx