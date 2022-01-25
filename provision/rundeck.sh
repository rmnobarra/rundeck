#!/bin/bash

apt-get update
apt-get install -y vim ansible openjdk-11-jdk gnupg2 curl git sqlite3

# Rundeck
#wget -q -O - 'https://bintray.com/user/downloadSubjectPublicKey?username=bintray' | apt-key add -
#echo 'deb https://rundeck.bintray.com/rundeck-deb /' > /etc/apt/sources.list.d/rundeck.list
curl -s https://packagecloud.io/install/repositories/pagerduty/rundeck/script.deb.sh | os=any dist=any bash

apt-get update
apt-get install -y rundeck rundeck-cli

# Rundeck
sed -i s/admin:admin/g /etc/rundeck/realm.properties
sed -i s/localhost/172.27.11.10/g /etc/rundeck/framework.properties
sed -i s/localhost/172.27.11.10/g /etc/rundeck/rundeck-config.properties

systemctl enable rundeckd
systemctl restart rundeckd
