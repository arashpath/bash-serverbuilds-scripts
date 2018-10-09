#!/bin/bash
# -*- coding: utf-8 -*-

echo "Installing Moodle"
# Installation DEVENV -------------------------------------------------------#
set -e
PKGS=$(dirname $(readlink -f "$0") )
DEVENV=/opt/DevEnv

# Custom Settings for Moodle ------------------------------------------------#
tar -xzvf $PKGS/php-5.6.*.tar.gz -C $DEVENV/PHP/lib/ php-5.6.31/php.ini-development
mv $DEVENV/PHP/lib/php-5.6.31/php.ini-development $DEVENV/PHP/lib/php.ini
sed -i '
        s/^max_execution_time = 30$/max_execution_time = 120/
        s/^max_input_time = 60$/max_input_time = 300/
        s/^post_max_size = 8M$/post_max_size = 40M/
        s/^upload_max_filesize = 2M$/upload_max_filesize = 40M/
        s|^;date.timezone =$|date.timezone = "Asia/Kolkata"|
        /\[opcache\]/ a zend_extension=opcache.so
        s/^;opcache.enable=0$/opcache.enable=1/     
        s/^;opcache.enable_cli=0$/opcache.enable_cli=0/
        s/^;opcache.memory_consumption=64$/opcache.memory_consumption=128/
        s/^;opcache.interned_strings_buffer=4$/opcache.interned_strings_buffer=8/
        s/^;opcache.max_accelerated_files=2000$/opcache.max_accelerated_files=10000/
        s/^;opcache.revalidate_freq=2$/opcache.revalidate_freq=60/
        s/^;opcache.fast_shutdown=0$/opcache.fast_shutdown=1/
        s/^;always_populate_raw_post_data = -1/always_populate_raw_post_data = -1/
' /opt/DevEnv/PHP/lib/php.ini


#wget "https://download.moodle.org/stable33/moodle-3.3.1.tgz"
mkdir -p /opt/APPS/
tar -xzf $PKGS/moodle-3.3.1.tgz -C /opt/APPS/
mkdir -p /opt/docs/moodledata
chown daemon.daemon /opt/docs/moodledata /opt/APPS/moodle

source /opt/postgresql/pg95.env 
psql -c "CREATE ROLE mdluser LOGIN ENCRYPTED PASSWORD 'moodle@123' NOINHERIT VALID UNTIL 'infinity';"
psql -c "CREATE DATABASE moodle WITH ENCODING='UTF8' OWNER mdluser;"

sudo -u daemon /opt/DevEnv/PHP/bin/php /opt/APPS/moodle/admin/cli/install.php --lang=en \
--wwwroot=http://mywebsite/moodle \
--dataroot=/opt/docs/moodledata \
--dbtype='pgsql' \
--dbhost='psqlsnfdb' \
--dbname='moodle' \
--dbuser='mdluser' \
--dbpass='moodle@123' \
--fullname='NewMoodleSite' \
--shortname='NewSite' \
--adminuser='admin' \
--adminpass='admin@123' \
--adminemail='admin@mail.com' \
--agree-license \
--non-interactive

ln -s /opt/APPS/moodle /opt/apache/htdocs/moodle
