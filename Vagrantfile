# -*- mode: ruby -*-
# vi: set ft=ruby :

$instances = 3
$instance_name_prefix = "app"
$app_cpus = 1
$app_mem = 1024

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/trusty64"
  # eth0多IP问题，虚拟机子网不能互通。
  # config.vm.box_url = "file:///home/minkuan/vm-install/ubuntu-trusty64-docker-2.box"
  # config.ssh.private_key_path = "/home/minkuan/.ssh/id_rsa_vagrant"
  # config.ssh.username = 'vagrant'
  # config.ssh.password = 'vagrant'
  # config.ssh.forward_agent = true
  config.vm.provision "fix-no-tty", type: "shell" do |s|
        s.privileged = false
        s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

  config.vm.provision "shell", name:"ipv6-forwarding", inline: "sudo sed -i 's/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/g' /etc/sysctl.conf && sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf && sudo sysctl -p /etc/sysctl.conf"

  # config.vm.provision "shell", path: "openconnect.sh", name: "openconnect"

  (1..$instances).each do |i|
    config.vm.define vm_name = "%s-%02d"%[$instance_name_prefix, i] do |config|
      config.vm.hostname = vm_name
      # set the vm mem and cpu allocations
      config.vm.provider :virtualbox do |vb|
        vb.memory = $app_mem
        vb.cpus = $app_cpus
        #vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        #vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
      end

      # create a private network
      ip = "44.0.0.#{i+100}"
      config.vm.network :private_network, ip: ip

      # section A - etcd
      state = "new"
      cluster = "app-01=http:\\/\\/44.0.0.101:2380"
      if i > 1
        state = "existing"
        (2..i).each do |j|
          cluster = "#{cluster},app-0#{j}=http:\\/\\/44.0.0.#{j+100}:2380"
        end
      end
      # 注意给etcd.sh传递了3个环境变量，etcd.sh将使用这3个环境变量。
      config.vm.provision "shell", path: "etcd.sh", name: "etcd", env:{"IP"=>ip, "CLUSTER_STATE"=>state, "CLUSTER"=>cluster}

      # section B - flannel
      config.vm.provision "shell", path: "flanneld.sh", name: "flannel"
      if i == 1
        config.vm.provision "shell", name: "flannel-config", inline: "etcdctl mkdir /network; etcdctl mk /network/config < /vagrant/flanneld.json"
      end
      config.vm.provision "shell", name: "flannel", inline: "start flanneld"
      if $instances > 1 && i < $instances
        # etcdctl member add可能失败，因为app-02上的etcd可能找不到leader（根据0.0.0.0:2379）。
        config.vm.provision "shell", name: "etcd-add", inline: "etcdctl member add app-0#{i+1} http://44.0.0.#{i+101}:2380"
      end

      # section C - docker 注意这里使用vagrant自身内嵌提供的docker构建. vagrant built-in docker provision速度太慢！
      # config.vm.provision "docker"
      config.vm.provision "shell", name: "docker", path: "docker.sh"

      # section D - kubernetes
      config.vm.provision "shell", name: "kubernetes", path: "kubernetes.sh"
      config.vm.provision "shell", name: "kubernetes", path: "kubelet.sh", env:{"IP"=>ip}
      config.vm.provision "shell", name: "kubernetes", path: "kube-proxy.sh"
      if i == $instances
        config.vm.provision "shell", name: "kubernetes", path: "kube-apiserver.sh"
        config.vm.provision "shell", name: "kubernetes", path: "kube-controller-manager.sh"
        config.vm.provision "shell", name: "kubernetes", path: "kube-scheduler.sh"
      end

    end
  end
end
