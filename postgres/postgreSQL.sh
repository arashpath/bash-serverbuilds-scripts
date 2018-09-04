#!/bin/bash
set -e
echo "Installing PostgreSQL"
PKGS=$(dirname $(readlink -f "$0") )

datadir='/opt/psqlDATA'
pgpass='pg+est'

psqlURL95="http://oscg-downloads.s3.amazonaws.com/packages/postgresql-9.5.6-1-x64-bigsql.rpm"
psqlURL96="http://oscg-downloads.s3.amazonaws.com/packages/postgresql-9.6.9-1-x64-bigsql.rpm"
psqlURL10="http://oscg-downloads.s3.amazonaws.com/packages/postgresql-10.4-1-x64-bigsql.rpm"

if [[ $# -eq 0 ]] ; then
    pgVer="10"
else
    pgVer=$1
fi

urlVar=psqlURL${pgVer} 
psqlURL=${!urlVar}

#case "$1" in
#    1) echo 'you gave 1' ;;
#    *) echo 'you gave something else' ;;
#esac
test -f $PKGS/pgCluster.env && source $PKGS/pgCluster.env 

wget -c $psqlURL
yum -y localinstall $PKGS/$(echo $psqlURL | awk -F'/' '{print $NF}')
echo $pgpass > /tmp/passwdfile
/opt/postgresql/pgc init pg$pgVer --datadir=$datadir --pwfile="/tmp/passwdfile"
rm -f /tmp/passwdfile
#echo "source /opt/postgresql/pg95/pg95.env" >> ~/.bash_profile
ln -s /opt/postgresql/pg$pgVer/pg"$pgVer".env /etc/profile.d/pg"$pgVer".sh

systemctl enable postgresql$pgVer 
systemctl start postgresql$pgVer
source /opt/postgresql/pg$pgVer/pg"$pgVer".env
echo "PostgreSQL Installed .."
pg_config --version
