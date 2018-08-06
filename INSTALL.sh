#!/bin/bash
# Installation DEVENV
set -e 
PKGS=$(dirname $(readlink -f "$0") )
DEVENV=/opt/DevEnv
mkdir -p $DEVENV

ln -s /opt/DevEnv/dev.env /etc/profile.d/devEnv.sh

##"Apache"
#echo -e "\n\nInstalling Apache ..."     && sleep 5 && sh $PKGS/apache-httpd/httpd.sh

##"Tomcat"
#echo -e "\n\nInstalling Tomcat ..."     && sleep 5 && sh $PKGS/apache-tomcat/tomcat.sh

##"Modjk"
#echo -e "\n\nInstalling Modjk ..."      && sleep 5 && sh $PKGS/apache-tomcat/modjk.sh

##"PostgreSQL"
#echo -e "\n\nInstalling PostgreSQL ..." && sleep 5 && sh $PKGS/postgres/postgreSQL.sh

##"MySQL"
#echo -e "\n\nInstalling MySQL ..."      && sleep 5 && sh $PKGS/mysql.sh  

##"PHP"
#echo -e "\n\nInstalling PHP ..."	     && sleep 5 && sh $PKGS/php/php.sh

##"Ruby"
#echo -e "\n\nInstalling Ruby ..."       && sleep 5 && sh $PKGS/ruby/ruby.sh

##"Git"
#echo -e "\n\nInstalling Git ..."        && sleep 5 && sh $PKGS/git/git.sh
