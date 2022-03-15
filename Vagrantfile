# -*- mode: ruby -*-
# vi: set ft=ruby :

vms = {
  'rundeck' => {'memory' => '2048', 'cpus' => 2, 'ip' => '10', 'box' => 'debian/buster64', 'provision' => 'rundeck.sh'},
  'minion' => {'memory' => '1024', 'cpus' => 1, 'ip' => '20', 'box' => 'debian/buster64','provision' => 'minion.sh'},
  'docker' => {'memory' => '1024', 'cpus' => 1, 'ip' => '100', 'box' => 'debian/buster64', 'provision' => 'docker.sh'},
  'centos' => {'memory' => '1024', 'cpus' => 1, 'ip' => '110', 'box' => 'centos/7', 'provision' => 'centos.sh'},
}

Vagrant.configure('2') do |config|

  config.vm.box_check_update = false

  vms.each do |name, conf|
    config.vm.define "#{name}" do |k|
      k.vm.box = "#{conf['box']}"
      k.vm.hostname = "#{name}.example.com"
      k.vm.network 'private_network', ip: "172.27.11.#{conf['ip']}"
      k.vm.provider 'virtualbox' do |vb|
        vb.memory = conf['memory']
        vb.cpus = conf['cpus']
      end
      k.vm.provider 'libvirt' do |lv|
        lv.memory = conf['memory']
        lv.cpus = conf['cpus']
        lv.cputopology :sockets => 1, :cores => conf['cpus'], :threads => '1'
      end
      k.vm.provision 'shell', path: "provision/#{conf['provision']}", args: "#{conf['ip']}"
    end
  end

  config.vm.provision 'shell', path: 'provision/provision.sh'
end
