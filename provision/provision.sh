#!/bin/bash

mkdir -p /root/.ssh
cp /vagrant/files/id_rsa* /root/.ssh
chmod 400 /root/.ssh/id_rsa*
cp /vagrant/files/id_rsa.pub /root/.ssh/authorized_keys

if [ "$(swapon -v)" == "" ]; then
  dd if=/dev/zero of=/swapfile bs=1M count=512
  chmod 0600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile       swap    swap    defaults        0       0' >> /etc/fstab
fi


useradd --shell /bin/bash --create-home sysadmin
sed 's/vagrant/sysadmin/g' /etc/sudoers.d/vagrant | sudo tee /etc/sudoers.d/sysadmin
mkdir -p /home/sysadmin/.ssh
cp /vagrant/files/id_rsa* /home/sysadmin/.ssh
chmod 400 /home/sysadmin/.ssh/id_rsa* && chown -R sysadmin:sysadmin /home/sysadmin/.ssh/*
cp /vagrant/files/id_rsa.pub /home/sysadmin/.ssh/authorized_keys


