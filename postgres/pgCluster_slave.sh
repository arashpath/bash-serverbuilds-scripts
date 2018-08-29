#!/bin/bash
set -e
echo "Installing PostgreSQL"
PKGS=$(dirname $(readlink -f "$0") )

sh -x $PKGS/postgreSQL.sh 10

source /opt/postgresql/pg10/pg10.env
source $PKGS/pgCluster.env

systemctl stop postgresql10


rm -rf $PGDATA/*
PGPASSWORD=repl@123 pg_basebackup -h psql01 -D $PGDATA -P -U replrole --wal-method=stream

cat <<EOF > $PGDATA/recovery.conf
standby_mode          = 'on'
primary_conninfo      = 'host=$psql01 port=5432 user=replrole password=repl@123'
primary_slot_name     = 'replslot'
trigger_file          = '/tmp/MasterNow'
restore_command       = 'cp /mnt/pg_archive/%f "%p"'
EOF

chown -R postgres.postgres $PGDATA
systemctl start postgresql10