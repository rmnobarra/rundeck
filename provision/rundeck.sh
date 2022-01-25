#!/bin/bash

apt-get update
apt-get install -y vim ansible openjdk-11-jdk gnupg2 curl git sqlite3

# Rundeck

curl -s https://packagecloud.io/install/repositories/pagerduty/rundeck/script.deb.sh | os=any dist=any bash
apt-get update
apt-get install -y rundeck rundeck-cli

# Rundeck configs

sed -i s/admin:admin/g /etc/rundeck/realm.properties
sed -i s/localhost/172.27.11.10/g /etc/rundeck/framework.properties
sed -i s/localhost/172.27.11.10/g /etc/rundeck/rundeck-config.properties

systemctl enable rundeckd
systemctl restart rundeckd

# Clone do repo

ssh-keygen -F github.com || ssh-keyscan github.com >> ~/.ssh/known_hosts
git clone git@github.com:rmnobarra/rundeck.git
