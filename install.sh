#!/bin/bash
echo "-----------------------"
echo "This Script Will Install Nginx, MariaDB and PHP for Debian"
echo "Please Make Sure this box is running on clean Debian"
echo "-----------------------"
echo ""

# apt update
# apt install -y curl gnupg2 ca-certificates lsb-release software-properties-common dirmngr apt-transport-https openssl getopt

OPTIONS=
LONGOPTS=php:,db:,dbversion:,dbpass:
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
eval set -- "$PARSED"

PHPVERSIONS=7.4
DB=mariadb
DBVERSION=10.4
DBPASS=$(openssl rand -base64 64 | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)

while true; do
    echo "$1"
    case "$1" in
        --php)
            PHPVERSIONS="$2"
            shift 2
            ;;
        --db)
            DB="$2"
            shift 2
            ;;
        --db)
            DBVERSION="$2"
            shift 2
            ;;
        --dbpass)
            DBPASS="$2"
            shift 2
            ;;
        --)
            shift
            break
            ;;
    esac
done

export PHPVERSIONS
export DBVERSION
export DBPASS
