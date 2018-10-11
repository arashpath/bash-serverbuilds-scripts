#!/bin/bash
# Installation DEVENV -------------------------------------------------------#
set -e
PKGS=$(dirname $(readlink -f "$0") )
DEVENV=/opt/DevEnv
mkdir -p $DEVENV
# URL  ----------------------------------------------------------------------# 
tomcatURL="https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.34/bin/apache-tomcat-8.5.34.tar.gz"
javaURL="http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.tar.gz"
# Common Fnc ----------------------------------------------------------------# 
function pkg_n() {
  #Get Package name from URL
  echo $1 | awk -F/ '{print $NF}'
}
function pkg_f() {
  #Get Folder Name Tar Package
  tar -tf $1 | awk -F/ 'NR==1{print $1}'
}
# Installing Java -----------------------------------------------------------#
echo -e "\nInstalling Java\n"
wget -P $PKGS -c --no-check-certificate --no-cookies \
  --header "Cookie: oraclelicense=accept-securebackup-cookie" $javaURL 
tar -xzf $PKGS/$(pkg_n $javaURL) -C $DEVENV
mv $DEVENV/$(pkg_f $(pkg_n $javaURL))/ $DEVENV/jdk

JAVA=$DEVENV/jdk
echo -e "\nJava Installation Completed\n"
$JAVA/bin/java -version

# Installing Tomcat ---------------------------------------------------------#
echo -e "\nInstalling Tomcat\n"
wget -P $PKGS -c $tomcatURL
tar -xzf $PKGS/$(pkg_n $tomcatURL) -C $DEVENV
mv $DEVENV/$(pkg_f $(pkg_n $tomcatURL))/ $DEVENV/tomcat-HOME
HOME=$DEVENV/tomcat-HOME
BASE=/opt/APPS/default-tom0

mkdir -p $BASE/{bin,conf,logs,work,webapps,temp}
cp $HOME/conf/{server.xml,web.xml} $BASE/conf/

cat <<EOF > $BASE/bin/server.sh
export CATALINA_HOME=$HOME
export CATALINA_BASE=$BASE
export JAVA_HOME=$JAVA
\$CATALINA_HOME/bin/catalina.sh \$@
EOF

chmod +x $BASE/bin/server.sh

cp -a $HOME/webapps/examples $BASE/webapps/

# Set Logrotate
# logrotate -d -f /etc/logrotate.conf
cat <<EOF > /etc/logrotate.d/tomcat
/opt/APPS/*-tom?/logs/catalina.out {
        copytruncate   
        daily   
        rotate 7   
        compress   
        missingok  
}
EOF

# Tomcat SystemCtl Script ----------------------#
cat <<EOF > /etc/systemd/system/tomcat0.service
# Systemd unit file for tomcat0 8080 port
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=CATALINA_HOME=$HOME
Environment=CATALINA_BASE=$BASE
Environment=CATALINA_PID=$BASE/temp/tomcat.pid

ExecStart=/bin/sh -c '$BASE/bin/server.sh start'
ExecStop=/bin/sh -c '$BASE/bin/server.sh stop'

RestartSec=30
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo -e "\nTomcat Installation Completed\n"
$BASE/bin/server.sh version
