#!/bin/bash

source pgCluster.conf

yum -y install nfs-utils libnfsidmap
systemctl enable rpcbind
systemctl start rpcbind
showmount -e $NASsvr

#Mounting NAS OnClient
mkdir -p /mnt/pgNAS
echo "
$NASsvr:/opt/psqlArchive /mnt/pgNAS nfs rw,sync,hard,intr 0 0" >> /etc/fstab

mount -a