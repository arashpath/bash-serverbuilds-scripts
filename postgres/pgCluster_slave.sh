#!/bin/bash
set -e
echo "Installing PostgreSQL"
PKGS=$(dirname $(readlink -f "$0") )

sh -x $PKGS/postgreSQL.sh 10

source /opt/postgresql/pg10/pg10.env

systemctl stop postgresql10
su - postgres

rm -rf $PGDATA/*
PGPASSWORD=repl@123 pg_basebackup -h psql01 -D $PGDATA -P -U replrole --wal-method=stream

cat <<EOF > $PGDATA/recovery.conf
standby_mode          = 'on'
primary_conninfo      = 'host=psql01 port=5432 user=replrole password=repl@123'
trigger_file = '/tmp/MasterNow'
restore_command = 'cp /mnt/pg_archive/%f "%p"'
EOF

chown -R postgres.postgres $PGDATA
chive/%f "%p"'
EOF

chown -R postgres.postgres $PGDATA
