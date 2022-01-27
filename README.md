# Rundeck

O Rundeck é um software muito eficiente que pode nos ajudar em agendamentos de tasks, atividades de automação, execução de jobs dos mais variadostipos, Automação de CD (Continuous Delivery) e muito mais.

Existem duas versões do Rundeck, a Community e Enterprise, onde há diferenças razoáveis entre as duas versões. 

As diferenças entre community e enterprise você encontra um bom resumo [aqui](https://www.rundeck.com/community-vs-enterprise).

O Rundeck é divido basicamente em:

Projects: Que consiste de uma coleção de jobs e node sources. Em resumo, uma forma de
organizar seu ambiente, que pode ser Projects por cliente, tipo de ambiente (dev, hmg,pre), tecnologias (projetos ansible, projeto terraform) e por ai.

Node Sources: Os hosts que o Rundeck irá gerenciar (incluindo ele mesmo)

Jobs: É o que você deseja executar.

Em um job você encontra:

Workflow: Um ou mais passo dentro um job

Options: Serve para o  usuário do job inserir algum dado, responder pergunta, etc.

Nodes: O destino, alvo, host  que executará o job.

Schedule: O agendamento deste job.

Notifications: Envia uma notificação em cada situação do job, executado com sucesso, com falha, ao iniciar, ao terminar. Tem diversos plugins, integrando como por exemplo
por email, slack e telegram.

O rundeck ainda conta com uma ferramenta chamada "Comandos" que serve para executar comandos remotamente em qualquer nó em seu projeto e também a opção de disponibilizar determinado job ou log via webhook.

O propósito desse lab é exercitar algumas situações da vida real, onde teremos um servidor Rundeck orientado a webhooks e utilizando como fonte da verdade, um repositório git.

*Existe chaves ssh neste repositório, caso leve a prod, PELO AMOR DE DEUS, não commite chaves, senhas, etc. Isto aqui é um LAB*

### OBS: Para executar esse lab é necessário ter o Vagrant / Virtualbox instalado.

## Como usar?

Os passos para executar o lab consistem em:

1. Executar o Vagrantfile

```bash
vagrant up
```

2. Executar script para adicionar o usuário rundeck ao ambiente.

```bash
./files/scripts/script.sh
```

3. Acesse a interface do rundeck em http://172.27.11.10:4440 (user admin, senha admin)

4. Crie o projeto gitops.

5. Crie uma tarefa chamada "clone-repo". Em workflow, selecione Script - Executar script in line. Adicione
o conteúdo:

```bash
#!/bin/bash

sudo su - sysadmin -c 'git clone https://github.com/rmnobarra/rundeck.git || (cd /home/sysadmin/rundeck ; git pull)'
```

Em nodes, marque "Executar localmente"

Salve tudo e execute o script.

Neste momento temos esse repositório dentro do home do usuário sysadmin no servidor Rundeck.

6. Em configurações de projeto, vá em "editar nós"

7. Na opção Ansible Resource Model Source em "Add a New Node Source", configures os seguintes parâmetros:

```
ansible inventory File path: /home/sysadmin/rundeck/files/ansible/inventory

Ansible config file path: /home/sysadmin/rundeck/files/ansible

SSH Connection

SSH Authentication: privateKey

SSH User: sysadmin

SSH Key file path: /home/sysadmin/rundeck/files/id_rsa

Privilege Escalation

marcar Use become privilege escalation.

Privilege escalation method: sudo

Ainda em configurações de projeto, vá em "editar configuração" > Default executor de Nó e altere o valor:

SSH Key File path: /home/sysadmin/rundeck/files/id_rsa

A partir daqui, o esperado é que exista 3 nós no projeto: Rundeck, Minion e Docker.

8. Crie uma nova tarefa chamada minion, em workflow, selecione Ansible Playbook Workflow Node Step e adicione
o conteúdo:

Ansible base directory path: /home/sysadmin/rundeck/files/ansible

Playbook: /home/sysadmin/rundeck/files/ansible/playbooks/minion.yaml

SSH User: sysadmin

SSH Key File path: /home/sysadmin/rundeck/files/id_rsa

Na aba Nodes, coloque: name: 172.27.11.20. Clique em salvar.

9. Execute o playbook.

Aqui o esperado é que um nginx tenha sido instalado com sucesso no servidor minion, é possível validar acessando:
http://172.27.11.20/

10. Clique em webhook e Create Webook. Nomei-o como restart minion e em Handler Configuration, selecione
Run job e escolha o job "minion".

Clique em salvar e copie a url do webhook para utilizarmos logo mais.

Agora, toda vez que fizermos POST para essa url, o job será executado.

11. Vamos criar um nova tarefa chamada docker, em workflow, selecione Ansible Playbook Workflow Node Step e adicione o conteúdo:

Ansible base directory path: /home/sysadmin/rundeck/files/ansible

Playbook: /home/sysadmin/rundeck/files/ansible/playbooks/docker.yaml

SSH User: sysadmin

SSH Key File path: /home/sysadmin/rundeck/files/id_rsa

Na aba Nodes, coloque: name: 172.27.11.100. Clique em salvar.

12. Execute o playbook.

O esperado aqui é ter docker e docker compose instalado na máquina docker.

Podemos validar se tudo foi instalado corretamente, executando o comando

```bash
vagrant ssh docker -- -t 'sudo docker version && docker-compose version'
```

13. Vamos criar um nova tarefa chamada observabilidade, em workflow, selecione Ansible Playbook Workflow Node Step e adicione o conteúdo:

Ansible base directory path: /home/sysadmin/rundeck/files/ansible

Playbook: /home/sysadmin/rundeck/files/ansible/playbooks/observabilidade.yaml

SSH User: sysadmin

SSH Key File path: /home/sysadmin/rundeck/files/id_rsa

Na aba Nodes, coloque: name: 172.27.11.100. Clique em salvar.

14. Execute o playbook.

Aqui se tudo ocorreu bem, teremos a stack prometheus, alertmanager, blackbox exporter e grafana instalada no servidor Docker. Podemos validar os serviços acessando-os:

Grafana:

http://172.27.11.100:3000/login (user admin, senha 9uT46ZKE)

Prometheus:

http://172.27.11.100:9090

BlackBox Exporter:

http://172.27.11.100:9115

Alertmanager:

http://172.27.11.100:9093

15. Ajuste o arquivo /alertmanager/config.yml com a url do webhook

16. Crie uma nova tarefa chamada "restart-container". Em opções, defina:

Tipo de opção: Texto
Nome da opção: container_name
Rótulo da Opção: container_name
Valores permitidos: Lista: grafana, alertmanager, prometheus, blackbox_exporter
Restrições: Imposta de valores permitidos

Em Workflow, selecione Script Executar script in line e adicione o conteúdo:

```bash
#!/bin/bash

CONTAINER_PATH="/home/sysadmin/rundeck/files/compose"
cd $CONTAINER_PATH && sudo docker-compose restart @option.container_name@
```

Na aba Nodes, adicione name: 172.27.11.100 e salve tudo.

17. Volte a tarefa e veja que agora podemos reinicar os containeres que estão em execução na máquina Docker.

18. Efetue o restart do container alertmanager.

19. Agora vamos simular uma parada do serviço nginx na máquina minion, para isso, execute:

```bash
vagrant ssh minion -- -t 'sudo service nginx stop'
```

20. O esperado é que o serviço tenha parado e com isso, erro ao tentar acessar: http://172.27.11.20/

21. Aqui seria bom deixar 2 abas abertas, uma com o alertmanager e uma com Atividades do Rundeck.

http://172.27.11.100:9093/#/alerts

http://172.27.11.10:4440/project/gitops/activity

Na aba do rundeck, marque "Auto refresh"

22. Espere o alertmanager enviar o POST para o rundeck executar a tarefa minion.

23. Verifique se o serviço do nginx voltou a funcionar.

24. Para finalizar o lab:

```bash
vagrant destroy -f
```