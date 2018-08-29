#!/bin/bash
yum -y install nfs-utils libnfsidmap

systemctl enable rpcbind
systemctl enable nfs-server

systemctl start rpcbind
systemctl start nfs-server
systemctl start rpc-statd
systemctl start nfs-idmapd

mkdir -p /opt/psqlArchive
chmod 777 /opt/psqlArchive

source pgCluster.env
echo "#psqlNAS
/opt/psqlArchive $psql01/32(rw,sync,no_root_squash)
/opt/psqlArchive $psql02/32(rw,sync,no_root_squash)
" > /etc/exports

exportfs -r

# Configure Firewall
firewall-cmd --permanent --zone public --add-service mountd
firewall-cmd --permanent --zone public --add-service rpc-bind
firewall-cmd --permanent --zone public --add-service nfs
firewall-cmd --reload