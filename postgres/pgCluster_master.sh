#!/bin/bash
set -e
echo "Installing PostgreSQL"
PKGS=$(dirname $(readlink -f "$0") )

sh -x $PKGS/postgreSQL.sh 10

source /opt/postgresql/pg10/pg10.env

# Genetating pg_ssl Keys
echo "Configuring SSL Connection..."
openssl genrsa 4096 > $PGDATA/server.key

openssl req -new -sha256 \
    -key $PGDATA/server.key \
    -subj "/C=IN/ST=NewDelhi/O=FSSAI/OU=IT
    /CN=fssai.gov.in" >  $PGDATA/server.csr

openssl x509 -req -days 3650 \
    -in $PGDATA/server.csr \
    -signkey $PGDATA/server.key \
    -out $PGDATA/server.crt

chmod 600 $PGDATA/server.*
chown postgres.postgres $PGDATA/server.*

sed -i '/ssl = off/s/^#ssl = off/ssl = on/
/ssl_cert_file/s/^#//
/ssl_key_file/s/^#//
' $PGDATA/postgresql.conf

# Setting Up Archiving
echo "Configuring Archiving..."
# Recomended NAS must be mounted at /mnt/pg_archive
NAS_path="/mnt/pgNAS"
mkdir -p $NAS_path/pg_archive
chown -R postgres.postgres $NAS_path/pg_archive

archive_cmd="archive_command = 'test ! -f $NAS_path/pg_archive/%f && cp %p $NAS_path/pg_archive/%f'"

sed -i "/wal_level =/s/^.*$/wal_level = replica/
s/max_wal_senders = .*/max_wal_senders = 3/
s/wal_keep_segments = .*/wal_keep_segments = 32/
/archive_mode =/ {
    s/^#//
    s/ = off/ = on/
}
/archive_command =/ {
    i$archive_cmd
}
/hot_standby = on/ {
    s/^#//
}
" $PGDATA/postgresql.conf


# Creating Replication Role and Permission
echo "Configuring Replication..."

psql -c "set password_encryption = 'scram-sha-256';"
psql -c "CREATE ROLE replrole WITH REPLICATION LOGIN PASSWORD 'repl@123';"
psql -c "SELECT * FROM pg_create_physical_replication_slot('replslot');"

echo "# Replication
hostssl     replication     replrole       psql01     scram-sha-256
hostssl     replication     replrole       psql02     scram-sha-256
" >> $PGDATA/pg_hba.conf

systemctl restart postgresql10