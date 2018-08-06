#!/bin/bash

PKGS=$(dirname $(readlink -f "$0") )
PACK=$(whiptail --title "Web Server Setup for FSSAI" --checklist \
"Choose packages for installation :-" 15 60 5 \
"Apache" 	    "Only Apache HTTPD" 		ON  \
"Tomcat" 	    "Tomcat and Java" 		    OFF \
"Modjk" 	    "Connect Apache and Tomcat" OFF \
"PostgreSQL"	"PostgreSQL DataBase"	 	OFF \
"MySQL" 	    "MariaDB/MySQL DataBase" 	OFF \
"PHP" 		    "Apache and PHP" 		    OFF \
"Moodle"	    "Moodle Installation"		OFF \
"LDAP"		    "LDAP Installation"		    OFF 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Packages to be installed are:" $PACK
else
    echo "You chose Cancel."
	exit
fi

for i in $PACK
do
    echo -e "\n$i"
    sed -n "/$i/,+1s/^#//p" $PKGS/INSTALL.sh > $PKGS/run_INSTALL.sh
done 

sh $PKGS/run_INSTALL.sh
