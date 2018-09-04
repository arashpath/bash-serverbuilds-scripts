#!/bin/bash
set -e
PKGS=$(dirname $(readlink -f "$0") )

pgAdminURL="https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v3.2/pip/pgadmin4-3.2-py2.py3-none-any.whl"
pgDIR=/opt/APPS/pgadmin4

mkdir -p $pgDIR # Making pgAdmin Dir
# Installing pip
yum -y groupinstall 'Development Tools' 
yum -y install python-devel wget
pip -V || ( curl "https://bootstrap.pypa.io/get-pip.py" -o "$PKGS/get-pip.py" &&
    python $PKGS/get-pip.py )
wget -c $pgAdminURL # Downloading pgAdmin
# Creating VirtualEnv 
pip install virtualenv
virtualenv $pgDIR/.env
source $pgDIR/.env/bin/activate
pip install $PKGS/$(echo $pgAdminURL | awk -F\/ '{print $NF}')
python $pgDIR/.env/lib/python2.7/site-packages/pgadmin4/pgAdmin4.py
