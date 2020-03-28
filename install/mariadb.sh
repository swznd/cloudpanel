#/bin/bash

echo "-----------------------"
echo "Installing MariaDB ${DBVERSION}"
echo "-----------------------"
sleep 1
`curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash -s -- --mariadb-server-version="mariadb-${DBVERSION}"`
apt install -y mariadb-server mariadb-client

echo "Securing MariaDB Instalation ..."
# Make sure that NOBODY can access the server without a password
SQL_QUERY="ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_PASS}';"
# Reomove anonymous users
SQL_QUERY="${SQL_QUERY} DELETE FROM mysql.user WHERE User='';"
# Remove Remote Root
SQL_QUERY="${SQL_QUERY} DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
# Kill off the demo database
SQL_QUERY="${SQL_QUERY} DROP DATABASE DATABASE IF EXISTS test;"
SQL_QUERY="${SQL_QUERY} DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
# Make our changes take effect
SQL_QUERY="${SQL_QUERY} FLUSH PRIVILEGES;"

if mysql -uroot -e "${SQL_QUERY}"; then
    echo "Securing MariaDB installation Success"
else
    echo "Error when securing MariaDB Installation"
