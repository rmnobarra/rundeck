#!/bin/bash

echo "Adicionado usuário sysadmin no ambiente"

SYSADMIN_USER='sudo useradd --shell /bin/bash'
for x in $(vagrant status | grep 'running' | cut -d' ' -f1); do vagrant ssh $x -c "$SYSADMIN_USER"; done

echo "Adicionando usuario sysadmin ao sudoers"

SYSADMIN_SUDOERS="sudo sed 's/vagrant/sysadmin/g' /etc/sudoers.d/vagrant | sudo tee /etc/sudoers.d/sysadmin"
for y in $(vagrant status | grep 'running' | cut -d' ' -f1); do vagrant ssh $y -c "$SYSADMIN_SUDOERS"; done

echo "Copiando chave pública para o usuário sysadmin"

SYSADMIN_KEY="$(vagrant ssh sysadmin -c 'sudo cat /root/.ssh/id_rsa.pub' < /dev/null)"
SYSADMIN_SSH="sudo -u sysadmin -s /bin/bash -c 'mkdir -p ~/.ssh && echo "$SYSADMIN_KEY" > ~/.ssh/authorized_keys'"
for z in $(vagrant status | grep 'running' | cut -d' ' -f1); do vagrant ssh $z -c "$SYSADMIN_SSH"; done

echo "Copiando chave pública para o usuario sysadmin somente no servidor sysadmin"

SYSADMIN_KEY="$(vagrant ssh sysadmin -c 'sudo cat /root/.ssh/id_rsa' < /dev/null)"
SYSADMIN_SSH="sudo -u sysadmin -s /bin/bash -c 'mkdir -p ~/.ssh && echo "$SYSADMIN_KEY" > ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa'"
vagrant ssh sysadmin -c "$SYSADMIN_SSH"




