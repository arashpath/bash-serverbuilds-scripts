#!/bin/bash
# Installation DEVENV -------------------------------------------------------#
set -e
PKGS=$(dirname $(readlink -f "$0") )
DEVENV=/opt/DevEnv
# ---------------------------------------------------------------------------# 
tomcatURL="http://www-us.apache.org/dist/tomcat/tomcat-8/v8.5.32/bin/apache-tomcat-8.5.32.tar.gz"

# Checking Java -----------------------------------------------------------#
echo -e "\nChecking Java"
JAVA=$DEVENV/jdk8
$JAVA/bin/java -version

# Stopping all Tomcat --------------------------------------------------------#
echo -e "\nStopping all Tomcat\n"
ps -aef | grep [j]ava && systemctl stop tomcat?
sleep 2
systemctl stop tomcat?
sleep 10 ; ps -aef | grep [j]ava && systemctl stop tomcat?

# Updating Tomcat ---------------------------------------------------------#
echo -e "\nUpdating Tomcat\n"
wget -c $tomcatURL
tar -xzf $PKGS/$(echo $tomcatURL | awk -F\/ '{print $NF}') -C $DEVENV
mv $DEVENV/tomcat8-HOME{,_old}
mv $DEVENV/{apache-tomcat-8*,tomcat8-HOME}

echo -e "\nTomcat Update Completed\n"
/opt/APPS/*-tom0/bin/server.sh version

# Starting All Tomcat -------------------------------------------------------#
systemctl start tomcat0