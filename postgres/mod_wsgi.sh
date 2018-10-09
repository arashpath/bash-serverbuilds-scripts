#!/bin/bash
set -e
wsgiURL="https://github.com/GrahamDumpleton/mod_wsgi/archive/4.6.4.tar.gz" 

echo -e "\nInstalling mod_wsgi Connector\n"
wget -c $wsgiURL
tar -xzvf $(echo $wsgiURL | awk -F\/ '{print $NF}')
cd mod_wsgi-*/
./configure -q --with-apxs=/opt/apache/bin/apxs && make -s && make -s install 

