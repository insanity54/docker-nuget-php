#!/bin/sh

set -ex

# Exit if necessary environment variables are not set
if [ -z "$MYSQL_USERNAME" -o -z "$MYSQL_PASSWORD" -o -z "$MYSQL_DBNAME" ]; then
    echo >&2 'error: Docker does not know how to connect php with your mysql instance.'
    echo >&2 '  You need to specify MYSQL_USERNAME, MYSQL_PASSWORD, and MYSQL_DBNAME as build args in the php service section your docker-compose.yml file'
    exit 1
fi

# Configure simple-nuget-server

# Set randomly generated API key
echo $(date +%s | sha256sum | base64 | head -c 32; echo) > $APP_BASE/.api-key
echo "Auto-Generated NuGet API key: $(cat $APP_BASE/.api-key)"
sed -i $APP_BASE/inc/config.php -e "s!ChangeThisKey!$(cat $APP_BASE/.api-key)!"

# Set URL, usernames & passwords to mysql server
sed -i $APP_BASE/inc/config.php -e "s!sqlite:../db/packages.sqlite3!mysql:host=mysql;dbname=$MYSQL_DBNAME!"
echo "Config::\$dbUsername = '$MYSQL_USERNAME';" >> $APP_BASE/inc/config.php
echo "Config::\$dbPassword = '$MYSQL_PASSWORD';" >> $APP_BASE/inc/config.php

# start php-fpm
exec "$@"
