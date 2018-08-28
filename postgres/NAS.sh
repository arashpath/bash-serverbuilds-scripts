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

echo "#psqlNAS
/opt/psqlArchive 192.168.227.131/30(rw,sync,no_root_squash)" > /etc/exports

exportfs -r

# Configure Firewall
firewall-cmd --permanent --zone public --add-service mountd
firewall-cmd --permanent --zone public --add-service rpc-bind
firewall-cmd --permanent --zone public --add-service nfs
firewall-cmd --reload

#-------------------------------
#OnClient
yum -y install nfs-utils libnfsidmap
systemctl enable rpcbind
systemctl start rpcbind
showmount -e 192.168.227.130
mkdir -p /mnt/pgNAS
#mount 192.168.227.130:/opt/psqlNAS /mnt/pg_archive
echo "
192.168.227.130:/opt/psqlArchive /mnt/pgNAS nfs rw,sync,hard,intr 0 0" >> /etc/fstab

mount -a
