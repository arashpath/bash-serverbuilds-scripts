#!/bin/bash
set -e
echo "Installing PostgreSQL"
PKGS=$(dirname $(readlink -f "$0") )

sh $PKGS/postgreSQL.sh 10

source /opt/postgresql/pg10/pg10.env
source $PKGS/pgCluster.env

systemctl stop postgresql10


rm -rf $PGDATA/*
PGPASSWORD='repl@123' \
pg_basebackup -h $psql01 -D $PGDATA -P -U replrole -X stream

cat <<EOF > $PGDATA/recovery.conf
standby_mode          = 'on'
primary_conninfo      = 'host=$psql01 port=5432 user=replrole password=repl@123 sslmode=require'
trigger_file          = '/tmp/MasterNow'
primary_slot_name     = 'replslot'
restore_command       = 'cp /mnt/pg_archive/%f "%p"'
EOF

chown -R postgres.postgres $PGDATA
systemctl start postgresql10
