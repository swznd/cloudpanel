#!/bin/bash
echo "-----------------------"
echo "This Script Will Install Nginx, MariaDB and PHP for Debian"
echo "Please Make Sure this box is running on clean Debian"
echo "-----------------------"
echo ""

apt-get update
apt-get upgrade -y
apt-get install -y curl gnupg2 ca-certificates lsb-release software-properties-common dirmngr apt-transport-https openssl

OPTIONS=h:t:
LONGOPTS=hostname:,timezone:php:,db:,dbversion:,dbpass:
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
eval set -- "$PARSED"

PHPVERSIONS=7.4
DB=mariadb
DBVERSION=10.4
DBPASS=$(openssl rand -base64 64 | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
TIMEZONE=UTC

while true; do
    echo "$1"
    case "$1" in
        -h|--hostname)
            HOSTNAME="$2"
            shift 2
            ;;
        -t|--timezone)
            TIMEZONE="$2"
            shift 2
            ;;
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
        *)
            echo "Wrong arguments"
            exit 3
            ;;
    esac
done

export PHPVERSIONS
export DBVERSION
export DBPASS

setHostname() {
    if [ -z "$HOSTNAME" ]; then
        read -p "Hostname: " HOSTNAME
        setHostname
    else
        echo "Setting Hostname to $HOSTNAME..."
        sleep 1
        hostname $HOSTNAME
        echo $HOSTNAME > /etc/hostname
    fi
}

setTimezone() {
    echo "Setting Timezone to $TIMEZONE..."
    sleep 1
    timedatectl set-timezone $TIMEZONE
}

installer() {
    DIRNAME=$(dirname "$0")

    sh "$DIRNAME/install/nginx.sh"
    sh "$DIRNAME/install/letsencrypt.sh"

    if [[ "$DB" == "mariadb" ]]; then
        sh "$DIRNAME/install/mariadb.sh"
    fi
    
    sh "$DIRNAME/install/php.sh"
}

setHostname
setTimezone
installer