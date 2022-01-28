#!/bin/bash

apt-get update
apt-get install -y vim ansible openjdk-11-jdk gnupg2 curl git sqlite3 unzip

# Rundeck

curl -s https://packagecloud.io/install/repositories/pagerduty/rundeck/script.deb.sh | os=any dist=any bash
apt-get update
apt-get install -y rundeck rundeck-cli

# Rundeck configs

sed -i s/localhost/172.27.11.10/g /etc/rundeck/framework.properties
sed -i s/localhost/172.27.11.10/g /etc/rundeck/rundeck-config.properties

systemctl enable rundeckd
systemctl restart rundeckd

# Clone do repo

sudo -u sysadmin -s /bin/bash -c 'sudo git clone https://github.com/rmnobarra/rundeck.git'