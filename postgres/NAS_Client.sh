#!/bin/bash
set -e
PKGS=$(dirname $(readlink -f "$0") )
source $PKGS/pgCluster.env

yum -y install nfs-utils libnfsidmap
systemctl enable rpcbind
systemctl start rpcbind
showmount -e $NASsvr

#Mounting NAS OnClient
mkdir -p /mnt/pgNAS
echo "
$NASsvr:/opt/psqlArchive $NAS_path nfs rw,sync,hard,intr 0 0" >> /etc/fstab

mount -a
