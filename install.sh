#!/bin/bash
echo "-----------------------"
echo "This Script Will Install Nginx, MariaDB and PHP for Debian"
echo "Please Make Sure this box is running on clean Debian"
echo "-----------------------"
echo ""

OPTIONS=h:t:
LONGOPTS=hostname:,timezone:php:,db:,dbversion:,dbpass:,ip:,ipv6:,sendmail,imagick
PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
eval set -- "$PARSED"

PHPVERSIONS=7.4
DB=mariadb
DBVERSION=
DBPASS=
TIMEZONE=UTC
SENDMAIL=n
IMAGEMAGICK=n
IPADDR=
IPADDRV6=

while true; do
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
        --dbversion)
            DBVERSION="$2"
            shift 2
            ;;
        --dbpass)
            DBPASS="$2"
            shift 2
            ;;
        --ip)
            IPADDR="$2"
            shift 2
            ;;
        --ipv6)
            IPADDRV6="$2"
            shift 2
            ;;
        --s|--sendmail)
            SENDMAIL=y
            shift 1
            ;;
        --i|--imagick)
            IMAGEMAGICK=y
            shift 1
            ;;
        #  -- means the end of the arguments; drop this, and break out of the while loop
        --)
            shift
            break
            ;;
        # If invalid options were passed, then getopt should have reported an error
        *)
            echo "Wrong arguments $1"
            exit 3
            ;;
    esac
done

getIPAddress() {
    echo "Getting Public IP Address..."
    sleep 1
    if [ -z "$IPADDR" ]; then
        IPADDR=`ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'`
    fi

    if [ -z "$IPADDRV6" ]; then
        IPADDRV6=`ip -o route get to 2001:4860:4860::8888 | sed -n 's/.*src \([a-f0-9:]\+\).*/\1/p'`
    fi
}

setHostname() {
    if [ -z "$HOSTNAME" ]; then
        read -p "Hostname: " HOSTNAME
        setHostname
    else
        echo "Setting Hostname to $HOSTNAME..."
        sleep 1
        hostname $HOSTNAME
        echo $HOSTNAME > /etc/hostname
        echo "127.0.0.1 $HOSTNAME" >> /etc/hosts
    fi
}

setTimezone() {
    echo "Setting Timezone to $TIMEZONE..."
    sleep 1
    timedatectl set-timezone $TIMEZONE
}

installEssential() {
    apt-get update
    apt-get upgrade -y
    apt-get install -y curl gnupg2 ca-certificates lsb-release software-properties-common dirmngr apt-transport-https openssl
}

installNginx() {
    echo "-----------------------"
    echo "Installing Nginx"
    echo "-----------------------"
    sleep 1
    echo "deb http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" > /etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
    apt-get update
    apt-get install -y nginx
}

installLetsEncrypt() {
    echo "-----------------------"
    echo "Installing Let's Encrypt SSL"
    echo "-----------------------"
    sleep 1
    apt-get update
    apt-get install -y certbot python-certbot-nginx
}

installMySQL() {
    if [ -z "$DBVERSION" ]; then
        DBVERSION=8.0
    fi

    echo "-----------------------"
    echo "Installing MySQL ${DBVERSION}"
    echo "-----------------------"
    sleep 1
    apt-key adv --keyserver keys.gnupg.net --recv-keys 8C718D3B5072E1F5
    echo "deb http://repo.mysql.com/apt/debian `lsb_release -cs`  mysql-${DBVERSION}" > /etc/apt/sources.list.d/mysql.list
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-community-server mysql-community-client-core mysql-community-client mysql-common
}

installMariaDB() {
    if [ -z "$DBVERSION" ]; then
        DBVERSION=10.4
    fi

    echo "-----------------------"
    echo "Installing MariaDB ${DBVERSION}"
    echo "-----------------------"
    sleep 1
    `curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | bash -s -- --mariadb-server-version="mariadb-${DBVERSION}"`
    apt-get install -y mariadb-server mariadb-client
}

secureMySQL() {
    echo "Securing MariaDB/MySQL Instalation ..."
    sleep 1

    if [ -z "$DBPASS" ]; then
        DBPASS=`openssl rand -base64 64 | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1`
    fi

    # Make sure that NOBODY can access the server without a password
    SQL_QUERY="ALTER USER 'root'@'localhost' IDENTIFIED BY '${DBPASS}';"
    # Reomove anonymous users
    SQL_QUERY="${SQL_QUERY} DELETE FROM mysql.user WHERE User='';"
    # Remove Remote Root
    SQL_QUERY="${SQL_QUERY} DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    # Kill off the demo database
    SQL_QUERY="${SQL_QUERY} DROP DATABASE IF EXISTS test;"
    SQL_QUERY="${SQL_QUERY} DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    # Make our changes take effect
    SQL_QUERY="${SQL_QUERY} FLUSH PRIVILEGES;"

    if mysql -uroot -e "${SQL_QUERY}"; then
        echo "Securing MariaDB/MySQL installation Success"
    else
        echo "Error when securing MariaDB/MySQL Installation"
    fi
}

installPHP() {
    echo "-----------------------"
    echo "Installing PHP $PHPVERSIONS"
    echo "-----------------------"
    PHPPACKAGE="php$phpver-cli php$phpver-fpm php$phpver-mysql php$phpver-json php$phpver-readline php$phpver-zip php$phpver-iconv php$phpver-gd php$phpver-fileinfo php$phpver-exif php$phpver-mbstring php$phpver-gettex"

    if [ "IMAGEMAGICK" = "y" ]; then
        PHPPACKAGE="php$phpver-imagick"
    fi

    sleep 1
    curl -fsSL https://packages.sury.org/php/apt.gpg | apt-key add -
    echo "deb https://packages.sury.org/php/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/php.list
    apt-get update
    IFS=','
    for phpver in $PHPVERSIONS; do
        echo "Installing PHP $phpver"
        sleep 1
        apt-get install -y PHPPACKAGE
    done
}

installSendmail() {
    echo "-----------------------"
    echo "Installing Sendmail"
    echo "-----------------------"
    sleep 1
    apt-get -y install sendmail

    if [ ! -z "$IPADDRV6" ]; then
        echo "CLIENT_OPTIONS(\`Family=inet6,Addr=::ffff:$IPADDR')dnl" >> /etc/mail/sendmail.mc
    fi
}

getIPAddress
setHostname
setTimezone

installNginx
installLetsEncrypt

if [ ! -z "$DB" ]; then
    if [ "$DB" = "mysql" ]; then
        installMySQL
    fi

    if [ "$DB" = "mariadb" ]; then
        installMariaDB
    fi

    secureMySQL
fi

if [ "$SENDMAIL" = "y" ]; then
    installSendmail
fi

installPHP

echo ""
echo ""
echo "Installed Successfully"
echo ""
echo "Here is your system information:"
echo "IPv4                : $IPADDR"
echo "IPv6                : $IPADDRV6"
echo "Hostname            : $HOSTNAME"
echo "MySQL Root Password : $DBPASS"
