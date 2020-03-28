#!/bin/bash

echo "-----------------------"
echo "Installing PHP $PHPVERSIONS"
echo "-----------------------"
sleep 1
curl -fsSL https://packages.sury.org/php/apt.gpg | apt-key add -
echo "deb https://packages.sury.org/php/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/php.list
apt update
IFS=','
for phpver in $PHPVERSIONS; do
    echo "Installing PHP $phpver"
    sleep 1
    `apt install -y php$phpver-cli php$phpver-fpm php$phpver-mysql php$phpver-zip php$phpver-iconv php$phpver-gd php$phpver-fileinfo php$phpver-exif php$phpver-mbstring php$phpver-gettex`
done