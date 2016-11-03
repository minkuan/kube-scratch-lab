# kube-scratch-lab
echo "deb mirror://mirrors.ubuntu.com/mirrors.txt wily main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt wily-backports main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt wily-proposed main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt wily-security main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt wily-updates main restricted universe multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt wily main restricted universe multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt wily-backports main restricted universe multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt wily-proposed main restricted universe multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt wily-security main restricted universe multiverse
deb-src mirror://mirrors.ubuntu.com/mirrors.txt wily-updates main restricted universe multiverse"

aufs-tools cgroup-lite docker-engine git git-man liberror-perl libltdl7 libsystemd-journal0

sudo add-apt-repository -y ppa:openconnect/daily && sudo apt-get update -y && sudo apt-get install -y openconnect

## 目标

1. 从0到1建立kubernetes 1.5集群

	- 部署kubernetes集群到3台vagrant ubuntu/trusty64虚拟机
	- flannel(0.6.2) 管理kubernetes集群子网，overlay传输kubernetes集群网络通信
	- 部署kubernetes组件（如kubelet/kube-proxy/kube-apiserver/kube-controller-manager/kube-scheduler）为linux进程/服务
	- etcd kv-store存储flannel的子网配置
	- 设置docker bip为flannel网段

2. 管理业务服务
	- 开发业务服务
	- 发布
	- 外部调用
	- 内部调用-kube-dns?

3. kubernetes与etcd的交互
4. ubuntu/linux service机制

	etcd/flannel/docker/kubernetes(kubelet/kube-proxy/kube-apiserver/kube-controller-manager/kube-scheduler) kube-dashboard? kube-dns?

	- /etc/init/下的*.conf和*.override
	- service接受环境变量

## 步骤

1. 下载

		wget -c https://github.com/coreos/etcd/releases/download/v3.0.1/etcd-v3.0.1-linux-amd64.tar.gz
		wget -c https://github.com/coreos/flannel/releases/download/v0.6.2/flannel-v0.6.2-linux-amd64.tar.gz
2. 建立并起动vagrant虚拟机集群

		vagrant up

## 问题及其解决
1. vagrant内嵌docker provisioning时网速极慢，所以在虚拟机中连接VPN；但手工docker provision时，发生vagrant不能加入docker组问题。
  - 手工provision docker时，解决vagrant加入docker组问题：$ usermod -aG docker vagrant
  - * 改为手工provision docker后，整个kubernetes集群构建的时间，从>70分钟，缩短为17分钟！ * 
  	但是，在这种方式下，使用国内阿里云镜像安装docker.io，得到的是1.18版本的docker，整个kubernetes集群的状态正常，如kubectl get no将列出当前集群中的所有节点，等等；kubernetes 1.5要求docker版本>=1.21，因而整个kubernetes无法进行发布容器等管理容器的工作，比如新起容器将失败。
  - 造成速度慢的罪魁祸首
  	- 从archive.ubuntu.com安装linux-headers-$(uname -r)
				1 upgraded, 2 newly installed, 0 to remove and 25 not upgraded.
				Need to get 9,629 kB of archives.
				After this operation, 77.0 MB of additional disk space will be used.
				Get:1 http://archive.ubuntu.com/ubuntu/ trusty-updates/main dkms all 2.2.0.3-1.1ubuntu5.14.04.9 [65.7 kB]
				Get:2 http://archive.ubuntu.com/ubuntu/ trusty-proposed/main linux-headers-3.13.0-101 all 3.13.0-101.148 [8,867 kB]
				Get:3 http://archive.ubuntu.com/ubuntu/ trusty-proposed/main linux-headers-3.13.0-101-generic amd64 3.13.0-101.148 [697 kB]			
		- 最新版docker
				==> app-03: The following NEW packages will be installed:
				==> app-03:   docker-engine
				==> app-03: 0 upgraded, 1 newly installed, 0 to remove and 26 not upgraded.
				==> app-03: Need to get 19.2 MB of archives.
				==> app-03: After this operation, 102 MB of additional disk space will be used.
				==> app-03: Get:1 https://apt.dockerproject.org/repo/ ubuntu-trusty/main docker-engine amd64 1.12.3-0~trusty [19.2 MB]

2. app-03 etcd不能加入etcd集群。app-03 etcd起动时失败，导致etcd service起动不成功；app-01 etcd leader报错：无法连接app-03 etcd。重起etcd leader才能解决；显然，重起etcd leader在工程实践中应当是不可接受的。
3. etcd v3.1.0-rc版本报错：无法在0.0.0.0:2379找到etcd leader。
4. Flag --api-servers has been deprecated, Use --kubeconfig instead. Will be removed in a future version.
5. unknown flag: --experimental-flannel-overlay
6. vagrant共享目录映射错误

	Vagrant was unable to mount VirtualBox shared folders. This is usually because the filesystem "vboxsf" is not available. This filesystem is made available via the VirtualBox Guest Additions and kernel module. Please verify that these guest additions are properly installed in the guest. This is not a bug in Vagrant and is usually caused by a faulty Vagrant box. For context, the command attempted was: 
		mount -t vboxsf -o uid=1000,gid=1000 vagrant /vagrant 
	The error output from the command was: 
	: No such device

	解决办法：

	- 升级virtualbox为5.1版本
	- 升级vagrant为1.8.6版本
	- 安装vagrant-vbguest插件
			vagrant plugin install vagrant-vbguest

7. namespace local不存在

	报错信息如下：
		vagrant@app-03:/vagrant$ kubectl describe services/kubernetes-dashboard
		Error from server (NotFound): namespaces "local" not found

	原因：kubectl所使用的config中错误指定了"local" namespace
		vagrant@app-03:/vagrant$ kubectl config view -o yaml
		apiVersion: v1
		clusters:
		- cluster:
				insecure-skip-tls-verify: true
				server: http://44.0.0.103:8888
			name: vagrant
		contexts:
		- context:
				cluster: vagrant
				namespace: local
				user: ""
			name: local
		current-context: local
		kind: Config
		preferences: {}
		users: []
		vagrant@app-03:/vagrant$

	解决：将kubernetes配置的"local" namespace修改为"default"
		vagrant@app-03:/vagrant$ kubectl config set-context local --namespace=default
		context "local" set.

## 要点
1. ubuntu service upstart配置：*.conf, *.override, *.conf中接受环境变量
2. ruby编程编写Vagrantfile
3. vagrant shell provisioning过程中，shell脚本接受Vagrantfile传入的环境变量
4. flanneld使用etcd存储子网信息，作为etcd的客户端，访问etcd的127.0.0.1:2379。

## 集群管理门户
### kubectl
1. 设置当前管理的集群

		$ kubectl config set-cluster kube-from-scratch --server=http://44.0.0.103:8888 --api-version=1
		$ kubectl config set-context kube-from-scratch --cluster=kube-from-scratch
		$ kubectl config use-context kube-from-scratch
2. 设置管理员权限

### kube-dashboard
1. 部署

		kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml

## 接下来
1. kubernetes集群的管理
	- 新增节点
	- 某一个kubernetes节点失效...
2. etcd集群管理
	- 新增etcd节点；
	- 某一个etcd节点失效...

## 验证
1. 进程

		app-03:~$ ps -e -o pid,cmd | grep --color -E 'etcd|flannel|docker|kube' 
		3190 etcd
		3242 flanneld
		5005 grep --color=auto --color -E etcd|flannel|docker|kube
		31535 /usr/bin/dockerd --bip=44.1.53.1/24 --mtu=1472 --raw-logs
		31544 docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --shim docker-containerd-shim --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --runtime docker-runc
		31692 kubelet --kubeconfig=/var/lib/kubelet/kubeconfig --require-kubeconfig=true --hostname-override=44.0.0.103 --logtostderr=true
		31726 kube-proxy --master=http://44.0.0.103:8888 --proxy-mode=iptables --logtostderr=true
		31764 kube-apiserver --advertise-address=44.0.0.103 --storage-backend=etcd3 --service-cluster-ip-range=107.0.0.0/16 --logtostderr=true --etcd-servers=http://127.0.0.1:2379 --insecure-bind-address=44.0.0.103 --insecure-port=8888 --kubelet-https=false
		31796 kube-controller-manager --cluster-cidr=107.0.0.0/16 --cluster-name=vagrant --master=http://44.0.0.103:8888 --port=8890 --service-cluster-ip-range=107.0.0.0/16 --logtostderr=true
		31848 kube-scheduler --master=http://44.0.0.103:8888 --logtostderr=true
2. kubernetes

		$ kubectl get no
		NAME         STATUS     AGE
		44.0.0.101   NotReady   11h
		44.0.0.102   NotReady   11h
		44.0.0.103   NotReady   11h
		$ kubectl get svc
		NAME         CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
		kubernetes   107.0.0.1    <none>        443/TCP   11h
		$ kubectl get ns
		NAME          STATUS    AGE
		default       Active    12h
		kube-system   Active    12h
		$

## 详情
1. 全过程耗时约70分钟，主要时耗是vagrant docker provision

		minkuan@minkuan-X1:~/Documents/96-workspace/kube-scratch-lab$ date && vagrant up && date 
		2016年 10月 28日 星期五 08:17:48 CST
		Bringing machine 'app-01' up with 'virtualbox' provider...
		Bringing machine 'app-02' up with 'virtualbox' provider...
		Bringing machine 'app-03' up with 'virtualbox' provider...
		==> app-01: Importing base box 'ubuntu/trusty64'...
		==> app-01: Matching MAC address for NAT networking...
		==> app-01: Checking if box 'ubuntu/trusty64' is up to date...
		==> app-01: A newer version of the box 'ubuntu/trusty64' is available! You currently
		==> app-01: have version '20161014.0.0'. The latest is version '20161020.0.6'. Run
		==> app-01: `vagrant box update` to update.
		==> app-01: Setting the name of the VM: kube-scratch-lab_app-01_1477613891218_90809
		==> app-01: Clearing any previously set forwarded ports...
		==> app-01: Clearing any previously set network interfaces...
		==> app-01: Preparing network interfaces based on configuration...
		    app-01: Adapter 1: nat
		    app-01: Adapter 2: hostonly
		==> app-01: Forwarding ports...
		    app-01: 22 (guest) => 2222 (host) (adapter 1)
		==> app-01: Running 'pre-boot' VM customizations...
		==> app-01: Booting VM...
		==> app-01: Waiting for machine to boot. This may take a few minutes...
		    app-01: SSH address: 127.0.0.1:2222
		    app-01: SSH username: vagrant
		    app-01: SSH auth method: private key
		    app-01: 
		    app-01: Vagrant insecure key detected. Vagrant will automatically replace
		    app-01: this with a newly generated keypair for better security.
		    app-01: 
		    app-01: Inserting generated public key within guest...
		    app-01: Removing insecure key from the guest if it's present...
		    app-01: Key inserted! Disconnecting and reconnecting using new SSH key...
		==> app-01: Machine booted and ready!
		==> app-01: Checking for guest additions in VM...
		    app-01: Guest Additions Version: 4.3.36
		    app-01: VirtualBox Version: 5.0
		==> app-01: Setting hostname...
		==> app-01: Configuring and enabling network interfaces...
		==> app-01: Mounting shared folders...
		    app-01: /vagrant => /home/minkuan/Documents/96-workspace/kube-scratch-lab
		==> app-01: Running provisioner: fix-no-tty (shell)...
		    app-01: Running: inline script
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: ipv6-forwarding
		==> app-01: net.ipv4.ip_forward = 1
		==> app-01: net.ipv6.conf.all.forwarding = 1
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: openconnect
		==> app-01: + sudo add-apt-repository -y ppa:openconnect/daily
		==> app-01: gpg: 
		==> app-01: keyring `/tmp/tmpvs6xgsel/secring.gpg' created
		==> app-01: gpg: 
		==> app-01: keyring `/tmp/tmpvs6xgsel/pubring.gpg' created
		==> app-01: gpg: 
		==> app-01: requesting key 0FB9E84C from hkp server keyserver.ubuntu.com
		==> app-01: gpg: 
		==> app-01: /tmp/tmpvs6xgsel/trustdb.gpg: trustdb created
		==> app-01: gpg: 
		==> app-01: key 0FB9E84C: public key "Launchpad PPA for OpenConnect" imported
		==> app-01: gpg: 
		==> app-01: Total number processed: 1
		==> app-01: gpg: 
		==> app-01:               imported: 1
		==> app-01:   (RSA: 1)
		==> app-01: OK
		==> app-01: + '[' '!' -f /etc/apt/sources.list.bak ']'
		==> app-01: + cp /etc/apt/sources.list /etc/apt/sources.list.bak
		==> app-01: + sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse'
		==> app-01: + sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse'
		==> app-01: + sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse'
		==> app-01: + sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse'
		==> app-01: + sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse'
		==> app-01: + sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse'
		==> app-01: + sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse'
		==> app-01: + sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse'
		==> app-01: + sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse'
		==> app-01: + sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse'
		==> app-01: + sudo apt-get update -y -q
		==> app-01: Fetched 24.6 MB in 25s (972 kB/s)
		==> app-01: Reading package lists...
		==> app-01: + sudo apt-get install openconnect -y -q
		==> app-01: Reading package lists...
		==> app-01: Building dependency tree...
		==> app-01: Reading state information...
		==> app-01: The following extra packages will be installed:
		==> app-01:   iproute libgnutls28 libhogweed2 libnettle4 libopenconnect5 libproxy1
		==> app-01:   libstoken1 libtomcrypt0 libtommath0 vpnc-scripts
		==> app-01: Suggested packages:
		==> app-01:   gnutls-bin dnsmasq
		==> app-01: The following NEW packages will be installed:
		==> app-01:   iproute libgnutls28 libhogweed2 libnettle4 libopenconnect5 libproxy1
		==> app-01:   libstoken1 libtomcrypt0 libtommath0 openconnect vpnc-scripts
		==> app-01: 0 upgraded, 11 newly installed, 0 to remove and 15 not upgraded.
		==> app-01: Need to get 1,700 kB of archives.
		==> app-01: After this operation, 6,372 kB of additional disk space will be used.
		==> app-01: Get:11 http://mirrors.aliyun.com/ubuntu/ trusty/universe vpnc-scripts all 0.1~git20120602-2 [12.2 kB]
		==> app-01: dpkg-preconfigure: unable to re-open stdin: No such file or directory
		==> app-01: Fetched 1,700 kB in 2s (717 kB/s)
		==> app-01: Selecting previously unselected package libnettle4:amd64.
		==> app-01: (Reading database ... 62997 files and directories currently installed.)
		==> app-01: Preparing to unpack .../libnettle4_2.7.1-1ubuntu0.1_amd64.deb ...
		==> app-01: + sudo openconnect --background --passwd-on-stdin --reconnect-timeout=30 -uebing a03.blockcn.net:1443
		==> app-01: + echo 02d926368
		==> app-01: POST https://a03.blockcn.net:1443/
		==> app-01: Connected to 106.184.5.135:1443
		==> app-01: SSL negotiation with a03.blockcn.net
		==> app-01: Connected to HTTPS on a03.blockcn.net
		==> app-01: XML POST enabled
		==> app-01: Please enter your username.
		==> app-01: POST https://a03.blockcn.net:1443/auth
		==> app-01: Please enter your password.
		==> app-01: POST https://a03.blockcn.net:1443/auth
		==> app-01: Got CONNECT response: HTTP/1.1 200 CONNECTED
		==> app-01: CSTP connected. DPD 90, Keepalive 32400
		==> app-01: Set up DTLS failed; using SSL instead
		==> app-01: Connected as 192.168.11.181, using SSL + lzs
		==> app-01: Continuing in background; pid 3086
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: etcd
		==> app-01: + echo 'environments: 44.0.0.101, new, app-01=http:\/\/44.0.0.101:2380'
		==> app-01: environments: 44.0.0.101, new, app-01=http:\/\/44.0.0.101:2380
		==> app-01: + cd /opt/
		==> app-01: + mkdir /opt/etcd-v3.0.1
		==> app-01: + cp /vagrant/etcd-v3.0.1-linux-amd64.tar.gz /opt/
		==> app-01: + tar -zxf etcd-v3.0.1-linux-amd64.tar.gz -C etcd-v3.0.1 --strip-components=1
		==> app-01: + ln -s /opt/etcd-v3.0.1/etcd /usr/local/bin/etcd
		==> app-01: + ln -s /opt/etcd-v3.0.1/etcdctl /usr/local/bin/etcdctl
		==> app-01: + cp /vagrant/etcd.conf /etc/init/etcd.conf
		==> app-01: + sed -e s/MY_IP/44.0.0.101/g -e s/MY_CLUSTER_STATE/new/g -e 's/MY_CLUSTER/app-01=http:\/\/44.0.0.101:2380/g'
		==> app-01: + mkdir /var/lib/etcd
		==> app-01: + chown vagrant:vagrant /var/lib/etcd
		==> app-01: + mkdir /var/log/etcd
		==> app-01: + chown vagrant:vagrant /var/log/etcd
		==> app-01: + start etcd
		==> app-01: etcd start/running, process 3186
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: flannel
		==> app-01: + cd /opt/
		==> app-01: + mkdir /opt/flanneld-0.6.2
		==> app-01: + cp /vagrant/flannel-v0.6.2-linux-amd64.tar.gz /opt/
		==> app-01: + tar -zxf flannel-v0.6.2-linux-amd64.tar.gz -C flanneld-0.6.2
		==> app-01: + ln -s /opt/flanneld-0.6.2/flanneld /usr/local/bin/flanneld
		==> app-01: + cp /vagrant/flanneld.conf /etc/init/flanneld.conf
		==> app-01: + mkdir /var/log/flannel
		==> app-01: + chown vagrant:vagrant /var/log/flannel
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: flannel-config
		==> app-01: {
		==> app-01:   "Network": "44.0.0.0/8",
		==> app-01:   "SubnetLen": 24,
		==> app-01:   "SubnetMin": "44.1.0.0",
		==> app-01:   "SubnetMax": "44.10.0.0",
		==> app-01:   "Backend": {
		==> app-01:     "Type": "udp"
		==> app-01:   }
		==> app-01: }
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: flannel
		==> app-01: flanneld start/running, process 3266
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: etcd-add
		==> app-01: Added member named app-02 with ID 5eb12dd45b899c2 to cluster
		==> app-01: 
		==> app-01: ETCD_NAME="app-02"
		==> app-01: ETCD_INITIAL_CLUSTER="app-02=http://44.0.0.102:2380,app-01=http://44.0.0.101:2380"
		==> app-01: ETCD_INITIAL_CLUSTER_STATE="existing"
		==> app-01: Running provisioner: docker...
		    app-01: Installing Docker onto machine...
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: docker
		==> app-01: ++ awk '{print $2}'
		==> app-01: ++ grep -v grep
		==> app-01: ++ grep openconn
		==> app-01: ++ ps -fe
		==> app-01: + sudo kill 3086
		==> app-01: + cp /vagrant/docker.default /etc/default/docker
		==> app-01: + service docker stop
		==> app-01: docker stop/waiting
		==> app-01: + sudo ip link delete docker0
		==> app-01: + service docker start
		==> app-01: docker start/running, process 31768
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: kubernetes
		==> app-01: + cd /opt/
		==> app-01: + mkdir /opt/kubernetes-1.5.0
		==> app-01: + tar -zxvf /vagrant/kubernetes.tar.gz -C kubernetes-1.5.0 --strip-components=1
		==> app-01: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kubectl /usr/local/bin/kubectl
		==> app-01: + echo 'alias kubectl='\''kubectl --server=44.0.0.103:8888'\'''
		==> app-01: + tee -a /root/.bashrc
		==> app-01: alias kubectl='kubectl --server=44.0.0.103:8888'
		==> app-01: + source /root/.bashrc
		==> app-01: ++ '[' -z '' ']'
		==> app-01: ++ return
		==> app-01: + mkdir /var/log/kubernetes
		==> app-01: + chown vagrant:vagrant /var/log/kubernetes
		==> app-01: + chown -R vagrant:vagrant /opt/kubernetes-1.5.0
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: kubernetes
		==> app-01: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kubelet /usr/local/bin/kubelet
		==> app-01: + mkdir /var/lib/kubelet
		==> app-01: + cp /vagrant/.kubeconfig /var/lib/kubelet/kubeconfig
		==> app-01: + cp /vagrant/kubelet.conf /etc/init/kubelet.conf
		==> app-01: + env MY_IP=44.0.0.101
		==> app-01: XDG_SESSION_ID=2
		==> app-01: SHELL=/bin/bash
		==> app-01: TERM=vt100
		==> app-01: SSH_CLIENT=10.0.2.2 55674 22
		==> app-01: USER=root
		==> app-01: SUDO_USER=vagrant
		==> app-01: SUDO_UID=1000
		==> app-01: USERNAME=root
		==> app-01: MAIL=/var/mail/vagrant
		==> app-01: PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
		==> app-01: PWD=/home/vagrant
		==> app-01: LANG=en_US.UTF-8
		==> app-01: SHLVL=3
		==> app-01: HOME=/root
		==> app-01: SUDO_COMMAND=/bin/bash -l
		==> app-01: LOGNAME=root
		==> app-01: SSH_CONNECTION=10.0.2.2 55674 10.0.2.15 22
		==> app-01: XDG_RUNTIME_DIR=/run/user/1000
		==> app-01: SUDO_GID=1000
		==> app-01: IP=44.0.0.101
		==> app-01: _=/usr/bin/env
		==> app-01: MY_IP=44.0.0.101
		==> app-01: + start kubelet
		==> app-01: kubelet start/running, process 31926
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: kubernetes
		==> app-01: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kube-proxy /usr/local/bin/kube-proxy
		==> app-01: + cp /vagrant/kube-proxy.conf /etc/init/kube-proxy.conf
		==> app-01: + start kube-proxy
		==> app-01: kube-proxy start/running, process 31959
		==> app-02: Importing base box 'ubuntu/trusty64'...
		==> app-02: Matching MAC address for NAT networking...
		==> app-02: Checking if box 'ubuntu/trusty64' is up to date...
		==> app-02: A newer version of the box 'ubuntu/trusty64' is available! You currently
		==> app-02: have version '20161014.0.0'. The latest is version '20161020.0.6'. Run
		==> app-02: `vagrant box update` to update.
		==> app-02: Setting the name of the VM: kube-scratch-lab_app-02_1477615415849_67164
		==> app-02: Clearing any previously set forwarded ports...
		==> app-02: Fixed port collision for 22 => 2222. Now on port 2200.
		==> app-02: Clearing any previously set network interfaces...
		==> app-02: Preparing network interfaces based on configuration...
		    app-02: Adapter 1: nat
		    app-02: Adapter 2: hostonly
		==> app-02: Forwarding ports...
		    app-02: 22 (guest) => 2200 (host) (adapter 1)
		==> app-02: Running 'pre-boot' VM customizations...
		==> app-02: Booting VM...
		==> app-02: Waiting for machine to boot. This may take a few minutes...
		    app-02: SSH address: 127.0.0.1:2200
		    app-02: SSH username: vagrant
		    app-02: SSH auth method: private key
		    app-02: 
		    app-02: Vagrant insecure key detected. Vagrant will automatically replace
		    app-02: this with a newly generated keypair for better security.
		    app-02: 
		    app-02: Inserting generated public key within guest...
		    app-02: Removing insecure key from the guest if it's present...
		    app-02: Key inserted! Disconnecting and reconnecting using new SSH key...
		==> app-02: Machine booted and ready!
		==> app-02: Checking for guest additions in VM...
		    app-02: The guest additions on this VM do not match the installed version of
		    app-02: VirtualBox! In most cases this is fine, but in rare cases it can
		    app-02: prevent things such as shared folders from working properly. If you see
		    app-02: shared folder errors, please make sure the guest additions within the
		    app-02: virtual machine match the version of VirtualBox you have installed on
		    app-02: your host and reload your VM.
		    app-02: 
		    app-02: Guest Additions Version: 4.3.36
		    app-02: VirtualBox Version: 5.0
		==> app-02: Setting hostname...
		==> app-02: Configuring and enabling network interfaces...
		==> app-02: Mounting shared folders...
		    app-02: /vagrant => /home/minkuan/Documents/96-workspace/kube-scratch-lab
		==> app-02: Running provisioner: fix-no-tty (shell)...
		    app-02: Running: inline script
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: ipv6-forwarding
		==> app-02: net.ipv4.ip_forward = 1
		==> app-02: net.ipv6.conf.all.forwarding = 1
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: openconnect
		==> app-02: + sudo add-apt-repository -y ppa:openconnect/daily
		==> app-02: gpg: 
		==> app-02: keyring `/tmp/tmpsj7oxl2q/secring.gpg' created
		==> app-02: gpg: 
		==> app-02: keyring `/tmp/tmpsj7oxl2q/pubring.gpg' created
		==> app-02: gpg: 
		==> app-02: requesting key 0FB9E84C from hkp server keyserver.ubuntu.com
		==> app-02: gpg: 
		==> app-02: /tmp/tmpsj7oxl2q/trustdb.gpg: trustdb created
		==> app-02: gpg: 
		==> app-02: key 0FB9E84C: public key "Launchpad PPA for OpenConnect" imported
		==> app-02: gpg: 
		==> app-02: Total number processed: 1
		==> app-02: gpg: 
		==> app-02:               imported: 1
		==> app-02:   (RSA: 1)
		==> app-02: OK
		==> app-02: + '[' '!' -f /etc/apt/sources.list.bak ']'
		==> app-02: + cp /etc/apt/sources.list /etc/apt/sources.list.bak
		==> app-02: + sudo apt-get update -y -q
		==> app-02: Fetched 24.6 MB in 25s (949 kB/s)
		==> app-02: Reading package lists...
		==> app-02: + sudo apt-get install openconnect -y -q
		==> app-02: Reading package lists...
		==> app-02: Building dependency tree...
		==> app-02: Reading state information...
		==> app-02: The following extra packages will be installed:
		==> app-02:   iproute libgnutls28 libhogweed2 libnettle4 libopenconnect5 libproxy1
		==> app-02:   libstoken1 libtomcrypt0 libtommath0 vpnc-scripts
		==> app-02: Suggested packages:
		==> app-02:   gnutls-bin dnsmasq
		==> app-02: The following NEW packages will be installed:
		==> app-02:   iproute libgnutls28 libhogweed2 libnettle4 libopenconnect5 libproxy1
		==> app-02:   libstoken1 libtomcrypt0 libtommath0 openconnect vpnc-scripts
		==> app-02: 0 upgraded, 11 newly installed, 0 to remove and 15 not upgraded.
		==> app-02: Need to get 1,700 kB of archives.
		==> app-02: After this operation, 6,372 kB of additional disk space will be used.
		==> app-02: dpkg-preconfigure: unable to re-open stdin: No such file or directory
		==> app-02: Fetched 1,700 kB in 5s (294 kB/s)
		==> app-02: Selecting previously unselected package libnettle4:amd64.
		==> app-02: (Reading database ... 62997 files and directories currently installed.)
		==> app-02: + sudo openconnect --background --passwd-on-stdin --reconnect-timeout=30 -uebing a03.blockcn.net:1443
		==> app-02: + echo 02d926368
		==> app-02: POST https://a03.blockcn.net:1443/
		==> app-02: Connected to 106.184.5.135:1443
		==> app-02: SSL negotiation with a03.blockcn.net
		==> app-02: Connected to HTTPS on a03.blockcn.net
		==> app-02: XML POST enabled
		==> app-02: Please enter your username.
		==> app-02: POST https://a03.blockcn.net:1443/auth
		==> app-02: Please enter your password.
		==> app-02: POST https://a03.blockcn.net:1443/auth
		==> app-02: Got CONNECT response: HTTP/1.1 200 CONNECTED
		==> app-02: CSTP connected. DPD 90, Keepalive 32400
		==> app-02: Set up DTLS failed; using SSL instead
		==> app-02: Connected as 192.168.11.181, using SSL + lzs
		==> app-02: Continuing in background; pid 3073
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: etcd
		==> app-02: + echo 'environments: 44.0.0.102, existing, app-01=http:\/\/44.0.0.101:2380,app-02=http:\/\/44.0.0.102:2380'
		==> app-02: environments: 44.0.0.102, existing, app-01=http:\/\/44.0.0.101:2380,app-02=http:\/\/44.0.0.102:2380
		==> app-02: + cd /opt/
		==> app-02: + mkdir /opt/etcd-v3.0.1
		==> app-02: + cp /vagrant/etcd-v3.0.1-linux-amd64.tar.gz /opt/
		==> app-02: + tar -zxf etcd-v3.0.1-linux-amd64.tar.gz -C etcd-v3.0.1 --strip-components=1
		==> app-02: + ln -s /opt/etcd-v3.0.1/etcd /usr/local/bin/etcd
		==> app-02: + ln -s /opt/etcd-v3.0.1/etcdctl /usr/local/bin/etcdctl
		==> app-02: + cp /vagrant/etcd.conf /etc/init/etcd.conf
		==> app-02: + sed -e s/MY_IP/44.0.0.102/g -e s/MY_CLUSTER_STATE/existing/g -e 's/MY_CLUSTER/app-01=http:\/\/44.0.0.101:2380,app-02=http:\/\/44.0.0.102:2380/g'
		==> app-02: + mkdir /var/lib/etcd
		==> app-02: + chown vagrant:vagrant /var/lib/etcd
		==> app-02: + mkdir /var/log/etcd
		==> app-02: + chown vagrant:vagrant /var/log/etcd
		==> app-02: + start etcd
		==> app-02: etcd start/running, process 3173
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: flannel
		==> app-02: + cd /opt/
		==> app-02: + mkdir /opt/flanneld-0.6.2
		==> app-02: + cp /vagrant/flannel-v0.6.2-linux-amd64.tar.gz /opt/
		==> app-02: + tar -zxf flannel-v0.6.2-linux-amd64.tar.gz -C flanneld-0.6.2
		==> app-02: + ln -s /opt/flanneld-0.6.2/flanneld /usr/local/bin/flanneld
		==> app-02: + cp /vagrant/flanneld.conf /etc/init/flanneld.conf
		==> app-02: + mkdir /var/log/flannel
		==> app-02: + chown vagrant:vagrant /var/log/flannel
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: flannel
		==> app-02: flanneld start/running, process 3225
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: etcd-add
		==> app-02: Added member named app-03 with ID e9b82b39ade4f229 to cluster
		==> app-02: ETCD_NAME="app-03"
		==> app-02: ETCD_INITIAL_CLUSTER="app-02=http://44.0.0.102:2380,app-01=http://44.0.0.101:2380,app-03=http://44.0.0.103:2380"
		==> app-02: ETCD_INITIAL_CLUSTER_STATE="existing"
		==> app-02: Running provisioner: docker...
		    app-02: Installing Docker onto machine...
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: docker
		==> app-02: ++ awk '{print $2}'
		==> app-02: ++ grep -v grep
		==> app-02: ++ grep openconn
		==> app-02: ++ ps -fe
		==> app-02: + sudo kill 3073
		==> app-02: + cp /vagrant/docker.default /etc/default/docker
		==> app-02: + service docker stop
		==> app-02: docker stop/waiting
		==> app-02: + sudo ip link delete docker0
		==> app-02: + service docker start
		==> app-02: docker start/running, process 31541
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: kubernetes
		==> app-02: + cd /opt/
		==> app-02: + mkdir /opt/kubernetes-1.5.0
		==> app-02: + tar -zxvf /vagrant/kubernetes.tar.gz -C kubernetes-1.5.0 --strip-components=1
		==> app-02: + cd /opt/kubernetes-1.5.0/server/
		==> app-02: + tar -zxvf kubernetes-server-linux-amd64.tar.gz
		==> app-02: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kubectl /usr/local/bin/kubectl
		==> app-02: + echo 'alias kubectl='\''kubectl --server=44.0.0.103:8888'\'''
		==> app-02: + tee -a /root/.bashrc
		==> app-02: alias kubectl='kubectl --server=44.0.0.103:8888'
		==> app-02: + source /root/.bashrc
		==> app-02: ++ '[' -z '' ']'
		==> app-02: ++ return
		==> app-02: + mkdir /var/log/kubernetes
		==> app-02: + chown vagrant:vagrant /var/log/kubernetes
		==> app-02: + chown -R vagrant:vagrant /opt/kubernetes-1.5.0
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: kubernetes
		==> app-02: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kubelet /usr/local/bin/kubelet
		==> app-02: + mkdir /var/lib/kubelet
		==> app-02: + cp /vagrant/.kubeconfig /var/lib/kubelet/kubeconfig
		==> app-02: + cp /vagrant/kubelet.conf /etc/init/kubelet.conf
		==> app-02: + env MY_IP=44.0.0.102
		==> app-02: XDG_SESSION_ID=2
		==> app-02: SHELL=/bin/bash
		==> app-02: TERM=vt100
		==> app-02: SSH_CLIENT=10.0.2.2 36946 22
		==> app-02: USER=root
		==> app-02: SUDO_USER=vagrant
		==> app-02: SUDO_UID=1000
		==> app-02: USERNAME=root
		==> app-02: MAIL=/var/mail/vagrant
		==> app-02: PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
		==> app-02: PWD=/home/vagrant
		==> app-02: LANG=en_US.UTF-8
		==> app-02: SHLVL=3
		==> app-02: HOME=/root
		==> app-02: SUDO_COMMAND=/bin/bash -l
		==> app-02: LOGNAME=root
		==> app-02: SSH_CONNECTION=10.0.2.2 36946 10.0.2.15 22
		==> app-02: XDG_RUNTIME_DIR=/run/user/1000
		==> app-02: SUDO_GID=1000
		==> app-02: IP=44.0.0.102
		==> app-02: _=/usr/bin/env
		==> app-02: MY_IP=44.0.0.102
		==> app-02: + start kubelet
		==> app-02: kubelet start/running, process 31699
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: kubernetes
		==> app-02: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kube-proxy /usr/local/bin/kube-proxy
		==> app-02: + cp /vagrant/kube-proxy.conf /etc/init/kube-proxy.conf
		==> app-02: + start kube-proxy
		==> app-02: kube-proxy start/running, process 31732
		==> app-03: Importing base box 'ubuntu/trusty64'...
		==> app-03: Matching MAC address for NAT networking...
		==> app-03: Checking if box 'ubuntu/trusty64' is up to date...
		==> app-03: A newer version of the box 'ubuntu/trusty64' is available! You currently
		==> app-03: have version '20161014.0.0'. The latest is version '20161020.0.6'. Run
		==> app-03: `vagrant box update` to update.
		==> app-03: Setting the name of the VM: kube-scratch-lab_app-03_1477617181846_29171
		==> app-03: Clearing any previously set forwarded ports...
		==> app-03: Fixed port collision for 22 => 2222. Now on port 2201.
		==> app-03: Clearing any previously set network interfaces...
		==> app-03: Preparing network interfaces based on configuration...
		    app-03: Adapter 1: nat
		    app-03: Adapter 2: hostonly
		==> app-03: Forwarding ports...
		    app-03: 22 (guest) => 2201 (host) (adapter 1)
		==> app-03: Running 'pre-boot' VM customizations...
		==> app-03: Booting VM...
		==> app-03: Waiting for machine to boot. This may take a few minutes...
		    app-03: SSH address: 127.0.0.1:2201
		    app-03: SSH username: vagrant
		    app-03: SSH auth method: private key
		    app-03: Warning: Remote connection disconnect. Retrying...
		    app-03: 
		    app-03: Vagrant insecure key detected. Vagrant will automatically replace
		    app-03: this with a newly generated keypair for better security.
		    app-03: 
		    app-03: Inserting generated public key within guest...
		    app-03: Removing insecure key from the guest if it's present...
		    app-03: Key inserted! Disconnecting and reconnecting using new SSH key...
		==> app-03: Machine booted and ready!
		==> app-03: Checking for guest additions in VM...
		    app-03: The guest additions on this VM do not match the installed version of
		    app-03: VirtualBox! In most cases this is fine, but in rare cases it can
		    app-03: prevent things such as shared folders from working properly. If you see
		    app-03: shared folder errors, please make sure the guest additions within the
		    app-03: virtual machine match the version of VirtualBox you have installed on
		    app-03: your host and reload your VM.
		    app-03: 
		    app-03: Guest Additions Version: 4.3.36
		    app-03: VirtualBox Version: 5.0
		==> app-03: Setting hostname...
		==> app-03: Configuring and enabling network interfaces...
		==> app-03: Mounting shared folders...
		    app-03: /vagrant => /home/minkuan/Documents/96-workspace/kube-scratch-lab
		==> app-03: Running provisioner: fix-no-tty (shell)...
		    app-03: Running: inline script
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: ipv6-forwarding
		==> app-03: net.ipv4.ip_forward = 1
		==> app-03: net.ipv6.conf.all.forwarding = 1
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: openconnect
		==> app-03: + sudo add-apt-repository -y ppa:openconnect/daily
		==> app-03: gpg: 
		==> app-03: keyring `/tmp/tmpzqv7bw87/secring.gpg' created
		==> app-03: gpg: 
		==> app-03: keyring `/tmp/tmpzqv7bw87/pubring.gpg' created
		==> app-03: gpg: 
		==> app-03: requesting key 0FB9E84C from hkp server keyserver.ubuntu.com
		==> app-03: gpg: 
		==> app-03: /tmp/tmpzqv7bw87/trustdb.gpg: trustdb created
		==> app-03: gpg: 
		==> app-03: key 0FB9E84C: public key "Launchpad PPA for OpenConnect" imported
		==> app-03: gpg: 
		==> app-03: Total number processed: 1
		==> app-03: gpg: 
		==> app-03:               imported: 1
		==> app-03:   (RSA: 1)
		==> app-03: OK
		==> app-03: + '[' '!' -f /etc/apt/sources.list.bak ']'
		==> app-03: + cp /etc/apt/sources.list /etc/apt/sources.list.bak
		==> app-03: + sudo apt-get update -y -q
		==> app-03: Ign http://mirrors.aliyun.com trusty InRelease
		==> app-03: Fetched 24.6 MB in 25s (979 kB/s)
		==> app-03: Reading package lists...
		==> app-03: + sudo apt-get install openconnect -y -q
		==> app-03: Reading package lists...
		==> app-03: Building dependency tree...
		==> app-03: Reading state information...
		==> app-03: The following extra packages will be installed:
		==> app-03:   iproute libgnutls28 libhogweed2 libnettle4 libopenconnect5 libproxy1
		==> app-03:   libstoken1 libtomcrypt0 libtommath0 vpnc-scripts
		==> app-03: Suggested packages:
		==> app-03:   gnutls-bin dnsmasq
		==> app-03: The following NEW packages will be installed:
		==> app-03:   iproute libgnutls28 libhogweed2 libnettle4 libopenconnect5 libproxy1
		==> app-03:   libstoken1 libtomcrypt0 libtommath0 openconnect vpnc-scripts
		==> app-03: 0 upgraded, 11 newly installed, 0 to remove and 15 not upgraded.
		==> app-03: Need to get 1,700 kB of archives.
		==> app-03: After this operation, 6,372 kB of additional disk space will be used.
		==> app-03: dpkg-preconfigure: unable to re-open stdin: No such file or directory
		==> app-03: Fetched 1,700 kB in 1s (881 kB/s)
		==> app-03: Processing triggers for libc-bin (2.19-0ubuntu6.9) ...
		==> app-03: + sudo openconnect --background --passwd-on-stdin --reconnect-timeout=30 -uebing a03.blockcn.net:1443
		==> app-03: + echo 02d926368
		==> app-03: POST https://a03.blockcn.net:1443/
		==> app-03: Connected to 106.184.5.135:1443
		==> app-03: SSL negotiation with a03.blockcn.net
		==> app-03: Connected to HTTPS on a03.blockcn.net
		==> app-03: XML POST enabled
		==> app-03: Please enter your username.
		==> app-03: POST https://a03.blockcn.net:1443/auth
		==> app-03: Please enter your password.
		==> app-03: POST https://a03.blockcn.net:1443/auth
		==> app-03: Got CONNECT response: HTTP/1.1 200 CONNECTED
		==> app-03: CSTP connected. DPD 90, Keepalive 32400
		==> app-03: Set up DTLS failed; using SSL instead
		==> app-03: Connected as 192.168.11.181, using SSL + lzs
		==> app-03: Continuing in background; pid 3090
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: etcd
		==> app-03: + echo 'environments: 44.0.0.103, existing, app-01=http:\/\/44.0.0.101:2380,app-02=http:\/\/44.0.0.102:2380,app-03=http:\/\/44.0.0.103:2380'
		==> app-03: environments: 44.0.0.103, existing, app-01=http:\/\/44.0.0.101:2380,app-02=http:\/\/44.0.0.102:2380,app-03=http:\/\/44.0.0.103:2380
		==> app-03: + cd /opt/
		==> app-03: + mkdir /opt/etcd-v3.0.1
		==> app-03: + cp /vagrant/etcd-v3.0.1-linux-amd64.tar.gz /opt/
		==> app-03: + tar -zxf etcd-v3.0.1-linux-amd64.tar.gz -C etcd-v3.0.1 --strip-components=1
		==> app-03: + ln -s /opt/etcd-v3.0.1/etcd /usr/local/bin/etcd
		==> app-03: + ln -s /opt/etcd-v3.0.1/etcdctl /usr/local/bin/etcdctl
		==> app-03: + cp /vagrant/etcd.conf /etc/init/etcd.conf
		==> app-03: + sed -e s/MY_IP/44.0.0.103/g -e s/MY_CLUSTER_STATE/existing/g -e 's/MY_CLUSTER/app-01=http:\/\/44.0.0.101:2380,app-02=http:\/\/44.0.0.102:2380,app-03=http:\/\/44.0.0.103:2380/g'
		==> app-03: + mkdir /var/lib/etcd
		==> app-03: + chown vagrant:vagrant /var/lib/etcd
		==> app-03: + mkdir /var/log/etcd
		==> app-03: + chown vagrant:vagrant /var/log/etcd
		==> app-03: + start etcd
		==> app-03: etcd start/running, process 3190
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: flannel
		==> app-03: + cd /opt/
		==> app-03: + mkdir /opt/flanneld-0.6.2
		==> app-03: + cp /vagrant/flannel-v0.6.2-linux-amd64.tar.gz /opt/
		==> app-03: + tar -zxf flannel-v0.6.2-linux-amd64.tar.gz -C flanneld-0.6.2
		==> app-03: + ln -s /opt/flanneld-0.6.2/flanneld /usr/local/bin/flanneld
		==> app-03: + cp /vagrant/flanneld.conf /etc/init/flanneld.conf
		==> app-03: + mkdir /var/log/flannel
		==> app-03: + chown vagrant:vagrant /var/log/flannel
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: flannel
		==> app-03: flanneld start/running, process 3242
		==> app-03: Running provisioner: docker...
		    app-03: Installing Docker onto machine...
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: docker
		==> app-03: ++ awk '{print $2}'
		==> app-03: ++ grep -v grep
		==> app-03: ++ grep openconn
		==> app-03: ++ ps -fe
		==> app-03: + sudo kill 3090
		==> app-03: + cp /vagrant/docker.default /etc/default/docker
		==> app-03: + service docker stop
		==> app-03: docker stop/waiting
		==> app-03: + sudo ip link delete docker0
		==> app-03: + service docker start
		==> app-03: docker start/running, process 31535
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: kubernetes
		==> app-03: + cd /opt/
		==> app-03: + mkdir /opt/kubernetes-1.5.0
		==> app-03: + tar -zxvf /vagrant/kubernetes.tar.gz -C kubernetes-1.5.0 --strip-components=1
		==> app-03: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kubectl /usr/local/bin/kubectl
		==> app-03: + echo 'alias kubectl='\''kubectl --server=44.0.0.103:8888'\'''
		==> app-03: + tee -a /root/.bashrc
		==> app-03: alias kubectl='kubectl --server=44.0.0.103:8888'
		==> app-03: + source /root/.bashrc
		==> app-03: ++ '[' -z '' ']'
		==> app-03: ++ return
		==> app-03: + mkdir /var/log/kubernetes
		==> app-03: + chown vagrant:vagrant /var/log/kubernetes
		==> app-03: + chown -R vagrant:vagrant /opt/kubernetes-1.5.0
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: kubernetes
		==> app-03: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kubelet /usr/local/bin/kubelet
		==> app-03: + mkdir /var/lib/kubelet
		==> app-03: + cp /vagrant/.kubeconfig /var/lib/kubelet/kubeconfig
		==> app-03: + cp /vagrant/kubelet.conf /etc/init/kubelet.conf
		==> app-03: + env MY_IP=44.0.0.103
		==> app-03: XDG_SESSION_ID=2
		==> app-03: SHELL=/bin/bash
		==> app-03: TERM=vt100
		==> app-03: SSH_CLIENT=10.0.2.2 41588 22
		==> app-03: USER=root
		==> app-03: SUDO_USER=vagrant
		==> app-03: SUDO_UID=1000
		==> app-03: USERNAME=root
		==> app-03: MAIL=/var/mail/vagrant
		==> app-03: PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
		==> app-03: PWD=/home/vagrant
		==> app-03: LANG=en_US.UTF-8
		==> app-03: SHLVL=3
		==> app-03: HOME=/root
		==> app-03: SUDO_COMMAND=/bin/bash -l
		==> app-03: LOGNAME=root
		==> app-03: SSH_CONNECTION=10.0.2.2 41588 10.0.2.15 22
		==> app-03: XDG_RUNTIME_DIR=/run/user/1000
		==> app-03: SUDO_GID=1000
		==> app-03: IP=44.0.0.103
		==> app-03: _=/usr/bin/env
		==> app-03: MY_IP=44.0.0.103
		==> app-03: + start kubelet
		==> app-03: kubelet start/running, process 31692
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: kubernetes
		==> app-03: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kube-proxy /usr/local/bin/kube-proxy
		==> app-03: + cp /vagrant/kube-proxy.conf /etc/init/kube-proxy.conf
		==> app-03: + start kube-proxy
		==> app-03: kube-proxy start/running, process 31726
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: kubernetes
		==> app-03: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kube-apiserver /usr/local/bin/kube-apiserver
		==> app-03: + cp /vagrant/kube-apiserver.conf /etc/init/kube-apiserver.conf
		==> app-03: + start kube-apiserver
		==> app-03: kube-apiserver start/running, process 31764
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: kubernetes
		==> app-03: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kube-controller-manager /usr/local/bin/kube-controller-manager
		==> app-03: + cp /vagrant/kube-controller-manager.conf /etc/init/kube-controller-manager.conf
		==> app-03: + start kube-controller-manager
		==> app-03: kube-controller-manager start/running, process 31796
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: kubernetes
		==> app-03: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kube-scheduler /usr/local/bin/kube-scheduler
		==> app-03: + cp /vagrant/kube-scheduler.conf /etc/init/kube-scheduler.conf
		==> app-03: + start kube-scheduler
		==> app-03: kube-scheduler start/running, process 31848
		2016年 10月 28日 星期五 09:28:25 CST
		minkuan@minkuan-X1:~/Documents/96-workspace/kube-scratch-lab$ 
	
2. 优化为手工provision docker后，缩短为17分钟！其中还包括解决virtualbox guest additions版本问题。

		minkuan@minkuan-X1:~/Documents/96-workspace/kube-scratch-lab$ date && vagrant up && date
		2016年 11月 01日 星期二 23:40:02 CST
		Bringing machine 'app-01' up with 'virtualbox' provider...
		Bringing machine 'app-02' up with 'virtualbox' provider...
		Bringing machine 'app-03' up with 'virtualbox' provider...
		==> app-01: Importing base box 'ubuntu/trusty64'...
		==> app-01: Matching MAC address for NAT networking...
		==> app-01: Checking if box 'ubuntu/trusty64' is up to date...
		==> app-01: There was a problem while downloading the metadata for your box
		==> app-01: to check for updates. This is not an error, since it is usually due
		==> app-01: to temporary network problems. This is just a warning. The problem
		==> app-01: encountered was:
		==> app-01: 
		==> app-01: Couldn't resolve host 'atlas.hashicorp.com'
		==> app-01: 
		==> app-01: If you want to check for box updates, verify your network connection
		==> app-01: is valid and try again.
		==> app-01: Setting the name of the VM: kube-scratch-lab_app-01_1478014845397_71312
		==> app-01: Clearing any previously set forwarded ports...
		==> app-01: Clearing any previously set network interfaces...
		==> app-01: Preparing network interfaces based on configuration...
		    app-01: Adapter 1: nat
		    app-01: Adapter 2: hostonly
		==> app-01: Forwarding ports...
		    app-01: 22 (guest) => 2222 (host) (adapter 1)
		==> app-01: Running 'pre-boot' VM customizations...
		==> app-01: Booting VM...
		==> app-01: Waiting for machine to boot. This may take a few minutes...
		    app-01: SSH address: 127.0.0.1:2222
		    app-01: SSH username: vagrant
		    app-01: SSH auth method: private key
		    app-01: Warning: Remote connection disconnect. Retrying...
		    app-01: 
		    app-01: Vagrant insecure key detected. Vagrant will automatically replace
		    app-01: this with a newly generated keypair for better security.
		    app-01: 
		    app-01: Inserting generated public key within guest...
		    app-01: Removing insecure key from the guest if it's present...
		    app-01: Key inserted! Disconnecting and reconnecting using new SSH key...
		==> app-01: Machine booted and ready!
		[app-01] GuestAdditions versions on your host (5.1.8) and guest (4.3.36) do not match.
		stdin: is not a tty
		 * Stopping VirtualBox Additions
		   ...done.
		stdin: is not a tty
		Reading package lists...
		Building dependency tree...
		Reading state information...
		The following packages were automatically installed and are no longer required:
		  acl at-spi2-core colord dconf-gsettings-backend dconf-service dkms fakeroot
		  fontconfig fontconfig-config fonts-dejavu-core gcc gcc-4.8
		  hicolor-icon-theme libasan0 libasound2 libasound2-data libatk-bridge2.0-0
		  libatk1.0-0 libatk1.0-data libatomic1 libatspi2.0-0 libavahi-client3
		  libavahi-common-data libavahi-common3 libc-dev-bin libc6-dev
		  libcairo-gobject2 libcairo2 libcanberra-gtk3-0 libcanberra-gtk3-module
		  libcanberra0 libcolord1 libcolorhug1 libcups2 libdatrie1 libdconf1
		  libdrm-intel1 libdrm-nouveau2 libdrm-radeon1 libexif12 libfakeroot
		  libfontconfig1 libfontenc1 libgcc-4.8-dev libgd3 libgdk-pixbuf2.0-0
		  libgdk-pixbuf2.0-common libgl1-mesa-dri libgl1-mesa-glx libglapi-mesa
		  libgomp1 libgphoto2-6 libgphoto2-l10n libgphoto2-port10 libgraphite2-3
		  libgtk-3-0 libgtk-3-bin libgtk-3-common libgudev-1.0-0 libgusb2
		  libharfbuzz0b libice6 libieee1284-3 libitm1 libjasper1 libjbig0
		  libjpeg-turbo8 libjpeg8 liblcms2-2 libllvm3.4 libltdl7 libnotify-bin
		  libnotify4 libogg0 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0
		  libpciaccess0 libpixman-1-0 libquadmath0 libsane libsane-common libsm6
		  libtdb1 libthai-data libthai0 libtiff5 libtsan0 libtxc-dxtn-s2tc0 libv4l-0
		  libv4lconvert0 libvorbis0a libvorbisfile3 libvpx1 libwayland-client0
		  libwayland-cursor0 libx11-xcb1 libxaw7 libxcb-dri2-0 libxcb-dri3-0
		  libxcb-glx0 libxcb-present0 libxcb-render0 libxcb-shm0 libxcb-sync1
		  libxcomposite1 libxcursor1 libxdamage1 libxfixes3 libxfont1 libxi6
		  libxinerama1 libxkbcommon0 libxkbfile1 libxmu6 libxpm4 libxrandr2
		  libxrender1 libxshmfence1 libxt6 libxtst6 libxxf86vm1 linux-libc-dev
		  manpages-dev notification-daemon sound-theme-freedesktop x11-common
		  x11-xkb-utils xfonts-base xfonts-encodings xfonts-utils xserver-common
		  xserver-xorg-core
		Use 'apt-get autoremove' to remove them.
		The following packages will be REMOVED:
		  virtualbox-guest-dkms* virtualbox-guest-utils* virtualbox-guest-x11*
		0 upgraded, 0 newly installed, 3 to remove and 0 not upgraded.
		After this operation, 12.1 MB disk space will be freed.
		(Reading database ... 62997 files and directories currently installed.)
		Removing virtualbox-guest-dkms (4.3.36-dfsg-1+deb8u1ubuntu1.14.04.1) ...
		-------- Uninstall Beginning --------
		Module:  virtualbox-guest
		Version: 4.3.36
		Kernel:  3.13.0-98-generic (x86_64)
		-------------------------------------
		Status: Before uninstall, this module version was ACTIVE on this kernel.
		vboxguest.ko:
		 - Uninstallation
		   - Deleting from: /lib/modules/3.13.0-98-generic/updates/dkms/
		 - Original module
		   - No original module was found for this module on this kernel.
		   - Use the dkms install command to reinstall any previous module version.
		vboxsf.ko:
		 - Uninstallation
		   - Deleting from: /lib/modules/3.13.0-98-generic/updates/dkms/
		 - Original module
		   - No original module was found for this module on this kernel.
		   - Use the dkms install command to reinstall any previous module version.
		vboxvideo.ko:
		 - Uninstallation
		   - Deleting from: /lib/modules/3.13.0-98-generic/updates/dkms/
		 - Original module
		   - No original module was found for this module on this kernel.
		   - Use the dkms install command to reinstall any previous module version.
		depmod....
		DKMS: uninstall completed.
		------------------------------
		Deleting module version: 4.3.36
		completely from the DKMS tree.
		------------------------------
		Done.
		Removing virtualbox-guest-x11 (4.3.36-dfsg-1+deb8u1ubuntu1.14.04.1) ...
		Purging configuration files for virtualbox-guest-x11 (4.3.36-dfsg-1+deb8u1ubuntu1.14.04.1) ...
		Removing virtualbox-guest-utils (4.3.36-dfsg-1+deb8u1ubuntu1.14.04.1) ...
		Purging configuration files for virtualbox-guest-utils (4.3.36-dfsg-1+deb8u1ubuntu1.14.04.1) ...
		Processing triggers for man-db (2.6.7.1-1ubuntu1) ...
		Processing triggers for libc-bin (2.19-0ubuntu6.9) ...
		stdin: is not a tty
		Reading package lists...
		Building dependency tree...
		Reading state information...
		dkms is already the newest version.
		dkms set to manually installed.
		linux-headers-3.13.0-98-generic is already the newest version.
		linux-headers-3.13.0-98-generic set to manually installed.
		The following packages were automatically installed and are no longer required:
		  acl at-spi2-core colord dconf-gsettings-backend dconf-service fontconfig
		  fontconfig-config fonts-dejavu-core hicolor-icon-theme libasound2
		  libasound2-data libatk-bridge2.0-0 libatk1.0-0 libatk1.0-data libatspi2.0-0
		  libavahi-client3 libavahi-common-data libavahi-common3 libcairo-gobject2
		  libcairo2 libcanberra-gtk3-0 libcanberra-gtk3-module libcanberra0 libcolord1
		  libcolorhug1 libcups2 libdatrie1 libdconf1 libdrm-intel1 libdrm-nouveau2
		  libdrm-radeon1 libexif12 libfontconfig1 libfontenc1 libgd3
		  libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgl1-mesa-dri libgl1-mesa-glx
		  libglapi-mesa libgphoto2-6 libgphoto2-l10n libgphoto2-port10 libgraphite2-3
		  libgtk-3-0 libgtk-3-bin libgtk-3-common libgudev-1.0-0 libgusb2
		  libharfbuzz0b libice6 libieee1284-3 libjasper1 libjbig0 libjpeg-turbo8
		  libjpeg8 liblcms2-2 libllvm3.4 libltdl7 libnotify-bin libnotify4 libogg0
		  libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpciaccess0
		  libpixman-1-0 libsane libsane-common libsm6 libtdb1 libthai-data libthai0
		  libtiff5 libtxc-dxtn-s2tc0 libv4l-0 libv4lconvert0 libvorbis0a
		  libvorbisfile3 libvpx1 libwayland-client0 libwayland-cursor0 libx11-xcb1
		  libxaw7 libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0 libxcb-present0
		  libxcb-render0 libxcb-shm0 libxcb-sync1 libxcomposite1 libxcursor1
		  libxdamage1 libxfixes3 libxfont1 libxi6 libxinerama1 libxkbcommon0
		  libxkbfile1 libxmu6 libxpm4 libxrandr2 libxrender1 libxshmfence1 libxt6
		  libxtst6 libxxf86vm1 notification-daemon sound-theme-freedesktop x11-common
		  x11-xkb-utils xfonts-base xfonts-encodings xfonts-utils xserver-common
		  xserver-xorg-core
		Use 'apt-get autoremove' to remove them.
		0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
		Copy iso file /usr/share/virtualbox/VBoxGuestAdditions.iso into the box /tmp/VBoxGuestAdditions.iso
		stdin: is not a tty
		mount: block device /tmp/VBoxGuestAdditions.iso is write-protected, mounting read-only
		Installing Virtualbox Guest Additions 5.1.8 - guest version is 4.3.36
		stdin: is not a tty
		Verifying archive integrity... All good.
		Uncompressing VirtualBox 5.1.8 Guest Additions for Linux...........
		VirtualBox Guest Additions installer
		Copying additional installer modules ...
		Installing additional modules ...
		vboxadd.sh: Building Guest Additions kernel modules.
		vboxadd.sh: Starting the VirtualBox Guest Additions.
		Could not find the X.Org or XFree86 Window System, skipping.
		stdin: is not a tty
		Got different reports about installed GuestAdditions version:
		Virtualbox on your host claims:   4.3.36
		VBoxService inside the vm claims: 5.1.8
		Going on, assuming VBoxService is correct...
		Got different reports about installed GuestAdditions version:
		Virtualbox on your host claims:   4.3.36
		VBoxService inside the vm claims: 5.1.8
		Going on, assuming VBoxService is correct...
		==> app-01: Checking for guest additions in VM...
		    app-01: The guest additions on this VM do not match the installed version of
		    app-01: VirtualBox! In most cases this is fine, but in rare cases it can
		    app-01: prevent things such as shared folders from working properly. If you see
		    app-01: shared folder errors, please make sure the guest additions within the
		    app-01: virtual machine match the version of VirtualBox you have installed on
		    app-01: your host and reload your VM.
		    app-01: 
		    app-01: Guest Additions Version: 4.3.36
		    app-01: VirtualBox Version: 5.1
		==> app-01: Setting hostname...
		==> app-01: Configuring and enabling network interfaces...
		==> app-01: Mounting shared folders...
		    app-01: /vagrant => /home/minkuan/Documents/96-workspace/kube-scratch-lab
		==> app-01: Running provisioner: fix-no-tty (shell)...
		    app-01: Running: inline script
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: ipv6-forwarding
		==> app-01: net.ipv4.ip_forward = 1
		==> app-01: net.ipv6.conf.all.forwarding = 1
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: etcd
		==> app-01: + echo 'environments: 44.0.0.101, new, app-01=http:\/\/44.0.0.101:2380'
		==> app-01: environments: 44.0.0.101, new, app-01=http:\/\/44.0.0.101:2380
		==> app-01: + cd /opt/
		==> app-01: + mkdir /opt/etcd-v3.0.1
		==> app-01: + cp /vagrant/etcd-v3.0.1-linux-amd64.tar.gz /opt/
		==> app-01: + tar -zxf etcd-v3.0.1-linux-amd64.tar.gz -C etcd-v3.0.1 --strip-components=1
		==> app-01: + ln -s /opt/etcd-v3.0.1/etcd /usr/local/bin/etcd
		==> app-01: + ln -s /opt/etcd-v3.0.1/etcdctl /usr/local/bin/etcdctl
		==> app-01: + cp /vagrant/etcd.conf /etc/init/etcd.conf
		==> app-01: + sed -e s/MY_IP/44.0.0.101/g -e s/MY_CLUSTER_STATE/new/g -e 's/MY_CLUSTER/app-01=http:\/\/44.0.0.101:2380/g'
		==> app-01: + mkdir /var/lib/etcd
		==> app-01: + chown vagrant:vagrant /var/lib/etcd
		==> app-01: + mkdir /var/log/etcd
		==> app-01: + chown vagrant:vagrant /var/log/etcd
		==> app-01: + start etcd
		==> app-01: etcd start/running, process 5557
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: flannel
		==> app-01: + cd /opt/
		==> app-01: + mkdir /opt/flanneld-0.6.2
		==> app-01: + cp /vagrant/flannel-v0.6.2-linux-amd64.tar.gz /opt/
		==> app-01: + tar -zxf flannel-v0.6.2-linux-amd64.tar.gz -C flanneld-0.6.2
		==> app-01: + ln -s /opt/flanneld-0.6.2/flanneld /usr/local/bin/flanneld
		==> app-01: + cp /vagrant/flanneld.conf /etc/init/flanneld.conf
		==> app-01: + mkdir /var/log/flannel
		==> app-01: + chown vagrant:vagrant /var/log/flannel
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: flannel-config
		==> app-01: {
		==> app-01:   "Network": "44.0.0.0/8",
		==> app-01:   "SubnetLen": 24,
		==> app-01:   "SubnetMin": "44.1.0.0",
		==> app-01:   "SubnetMax": "44.10.0.0",
		==> app-01:   "Backend": {
		==> app-01:     "Type": "udp"
		==> app-01:   }
		==> app-01: }
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: flannel
		==> app-01: flanneld start/running, process 5637
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: etcd-add
		==> app-01: Added member named app-02 with ID b485eaaa2fd229ff to cluster
		==> app-01: 
		==> app-01: ETCD_NAME="app-02"
		==> app-01: ETCD_INITIAL_CLUSTER="app-01=http://44.0.0.101:2380,app-02=http://44.0.0.102:2380"
		==> app-01: ETCD_INITIAL_CLUSTER_STATE="existing"
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: docker
		==> app-01: deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
		==> app-01: deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
		==> app-01: deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
		==> app-01: deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
		==> app-01: deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
		==> app-01: deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
		==> app-01: deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
		==> app-01: deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
		==> app-01: deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
		==> app-01: deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
		==> app-01: + apt-get update -qq
		==> app-01: + apt-get install -y docker.io
		==> app-01: Reading package lists...
		==> app-01: Building dependency tree...
		==> app-01: Reading state information...
		==> app-01: The following packages were automatically installed and are no longer required:
		==> app-01:   acl at-spi2-core colord dconf-gsettings-backend dconf-service fontconfig
		==> app-01:   fontconfig-config fonts-dejavu-core hicolor-icon-theme libasound2
		==> app-01:   libasound2-data libatk-bridge2.0-0 libatk1.0-0 libatk1.0-data libatspi2.0-0
		==> app-01:   libavahi-client3 libavahi-common-data libavahi-common3 libcairo-gobject2
		==> app-01:   libcairo2 libcanberra-gtk3-0 libcanberra-gtk3-module libcanberra0 libcolord1
		==> app-01:   libcolorhug1 libcups2 libdatrie1 libdconf1 libdrm-intel1 libdrm-nouveau2
		==> app-01:   libdrm-radeon1 libexif12 libfontconfig1 libfontenc1 libgd3
		==> app-01:   libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgl1-mesa-dri libgl1-mesa-glx
		==> app-01:   libglapi-mesa libgphoto2-6 libgphoto2-l10n libgphoto2-port10 libgraphite2-3
		==> app-01:   libgtk-3-0 libgtk-3-bin libgtk-3-common libgudev-1.0-0 libgusb2
		==> app-01:   libharfbuzz0b libice6 libieee1284-3 libjasper1 libjbig0 libjpeg-turbo8
		==> app-01:   libjpeg8 liblcms2-2 libllvm3.4 libltdl7 libnotify-bin libnotify4 libogg0
		==> app-01:   libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpciaccess0
		==> app-01:   libpixman-1-0 libsane libsane-common libsm6 libtdb1 libthai-data libthai0
		==> app-01:   libtiff5 libtxc-dxtn-s2tc0 libv4l-0 libv4lconvert0 libvorbis0a
		==> app-01:   libvorbisfile3 libvpx1 libwayland-client0 libwayland-cursor0 libx11-xcb1
		==> app-01:   libxaw7 libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0 libxcb-present0
		==> app-01:   libxcb-render0 libxcb-shm0 libxcb-sync1 libxcomposite1 libxcursor1
		==> app-01:   libxdamage1 libxfixes3 libxfont1 libxi6 libxinerama1 libxkbcommon0
		==> app-01:   libxkbfile1 libxmu6 libxpm4 libxrandr2 libxrender1 libxshmfence1 libxt6
		==> app-01:   libxtst6 libxxf86vm1 notification-daemon sound-theme-freedesktop x11-common
		==> app-01:   x11-xkb-utils xfonts-base xfonts-encodings xfonts-utils xserver-common
		==> app-01:   xserver-xorg-core
		==> app-01: Use 'apt-get autoremove' to remove them.
		==> app-01: The following extra packages will be installed:
		==> app-01:   aufs-tools cgroup-lite git git-man liberror-perl
		==> app-01: Suggested packages:
		==> app-01:   btrfs-tools debootstrap lxc rinse git-daemon-run git-daemon-sysvinit git-doc
		==> app-01:   git-el git-email git-gui gitk gitweb git-arch git-bzr git-cvs git-mediawiki
		==> app-01:   git-svn
		==> app-01: The following NEW packages will be installed:
		==> app-01:   aufs-tools cgroup-lite docker.io git git-man liberror-perl
		==> app-01: 0 upgraded, 6 newly installed, 0 to remove and 15 not upgraded.
		==> app-01: Need to get 8,150 kB of archives.
		==> app-01: After this operation, 51.4 MB of additional disk space will be used.
		==> app-01: Get:1 http://mirrors.aliyun.com/ubuntu/ trusty/universe aufs-tools amd64 1:3.2+20130722-1.1 [92.3 kB]
		==> app-01: Get:2 http://mirrors.aliyun.com/ubuntu/ trusty-updates/universe docker.io amd64 1.6.2~dfsg1-1ubuntu4~14.04.1 [4,749 kB]
		==> app-01: Get:3 http://mirrors.aliyun.com/ubuntu/ trusty/main liberror-perl all 0.17-1.1 [21.1 kB]
		==> app-01: Get:4 http://mirrors.aliyun.com/ubuntu/ trusty-security/main git-man all 1:1.9.1-1ubuntu0.3 [699 kB]
		==> app-01: Get:5 http://mirrors.aliyun.com/ubuntu/ trusty-security/main git amd64 1:1.9.1-1ubuntu0.3 [2,586 kB]
		==> app-01: Get:6 http://mirrors.aliyun.com/ubuntu/ trusty/main cgroup-lite all 1.9 [3,918 B]
		==> app-01: dpkg-preconfigure: unable to re-open stdin: No such file or directory
		==> app-01: Fetched 8,150 kB in 2min 39s (51.3 kB/s)
		==> app-01: Selecting previously unselected package aufs-tools.
		==> app-01: (Reading database ... 62722 files and directories currently installed.)
		==> app-01: Preparing to unpack .../aufs-tools_1%3a3.2+20130722-1.1_amd64.deb ...
		==> app-01: Unpacking aufs-tools (1:3.2+20130722-1.1) ...
		==> app-01: Selecting previously unselected package docker.io.
		==> app-01: Preparing to unpack .../docker.io_1.6.2~dfsg1-1ubuntu4~14.04.1_amd64.deb ...
		==> app-01: Unpacking docker.io (1.6.2~dfsg1-1ubuntu4~14.04.1) ...
		==> app-01: Selecting previously unselected package liberror-perl.
		==> app-01: Preparing to unpack .../liberror-perl_0.17-1.1_all.deb ...
		==> app-01: Unpacking liberror-perl (0.17-1.1) ...
		==> app-01: Selecting previously unselected package git-man.
		==> app-01: Preparing to unpack .../git-man_1%3a1.9.1-1ubuntu0.3_all.deb ...
		==> app-01: Unpacking git-man (1:1.9.1-1ubuntu0.3) ...
		==> app-01: Selecting previously unselected package git.
		==> app-01: Preparing to unpack .../git_1%3a1.9.1-1ubuntu0.3_amd64.deb ...
		==> app-01: Unpacking git (1:1.9.1-1ubuntu0.3) ...
		==> app-01: Selecting previously unselected package cgroup-lite.
		==> app-01: Preparing to unpack .../cgroup-lite_1.9_all.deb ...
		==> app-01: Unpacking cgroup-lite (1.9) ...
		==> app-01: Processing triggers for man-db (2.6.7.1-1ubuntu1) ...
		==> app-01: Processing triggers for ureadahead (0.100.0-16) ...
		==> app-01: Setting up aufs-tools (1:3.2+20130722-1.1) ...
		==> app-01: Setting up docker.io (1.6.2~dfsg1-1ubuntu4~14.04.1) ...
		==> app-01: Adding group `docker' (GID 113) ...
		==> app-01: Done.
		==> app-01: docker start/running, process 8280
		==> app-01: Setting up liberror-perl (0.17-1.1) ...
		==> app-01: Setting up git-man (1:1.9.1-1ubuntu0.3) ...
		==> app-01: Setting up git (1:1.9.1-1ubuntu0.3) ...
		==> app-01: Setting up cgroup-lite (1.9) ...
		==> app-01: cgroup-lite start/running
		==> app-01: Processing triggers for libc-bin (2.19-0ubuntu6.9) ...
		==> app-01: Processing triggers for ureadahead (0.100.0-16) ...
		==> app-01: + service docker status
		==> app-01: docker start/running, process 8280
		==> app-01: + service docker stop
		==> app-01: docker stop/waiting
		==> app-01: + groupadd docker
		==> app-01: groupadd: group 'docker' already exists
		==> app-01: + usermod -aG docker vagrant
		==> app-01: + '[' -f /run/flannel/subnet.env ']'
		==> app-01: + . /run/flannel/subnet.env
		==> app-01: ++ FLANNEL_NETWORK=44.0.0.0/8
		==> app-01: ++ FLANNEL_SUBNET=44.1.38.1/24
		==> app-01: ++ FLANNEL_MTU=1472
		==> app-01: ++ FLANNEL_IPMASQ=false
		==> app-01: + sudo sed -i s/DOCKER_OPTS=/#DOCKER_OPTS=/g /etc/default/docker
		==> app-01: + sudo tee -a /etc/default/docker
		==> app-01: + echo 'DOCKER_OPTS="--bip=44.1.38.1/24 --mtu=1472"'
		==> app-01: DOCKER_OPTS="--bip=44.1.38.1/24 --mtu=1472"
		==> app-01: + service docker stop
		==> app-01: stop: Unknown instance: 
		==> app-01: + sudo ip link delete docker0
		==> app-01: Cannot find device "docker0"
		==> app-01: + service docker start
		==> app-01: docker start/running, process 8463
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: kubernetes
		==> app-01: + cd /opt/
		==> app-01: + mkdir /opt/kubernetes-1.5.0
		==> app-01: + tar -zxf /vagrant/kubernetes.tar.gz -C kubernetes-1.5.0 --strip-components=1
		==> app-01: + cd /opt/kubernetes-1.5.0/server/
		==> app-01: + tar -zxf kubernetes-server-linux-amd64.tar.gz
		==> app-01: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kubectl /usr/local/bin/kubectl
		==> app-01: + echo 'alias kubectl='\''kubectl --server=44.0.0.103:8888'\'''
		==> app-01: + tee -a /root/.bashrc
		==> app-01: alias kubectl='kubectl --server=44.0.0.103:8888'
		==> app-01: + source /root/.bashrc
		==> app-01: ++ '[' -z '' ']'
		==> app-01: ++ return
		==> app-01: + mkdir /var/log/kubernetes
		==> app-01: + chown vagrant:vagrant /var/log/kubernetes
		==> app-01: + chown -R vagrant:vagrant /opt/kubernetes-1.5.0
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: kubernetes
		==> app-01: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kubelet /usr/local/bin/kubelet
		==> app-01: + mkdir /var/lib/kubelet
		==> app-01: + cp /vagrant/.kubeconfig /var/lib/kubelet/kubeconfig
		==> app-01: + cp /vagrant/kubelet.conf /etc/init/kubelet.conf
		==> app-01: + env MY_IP=44.0.0.101
		==> app-01: XDG_SESSION_ID=2
		==> app-01: SHELL=/bin/bash
		==> app-01: TERM=vt100
		==> app-01: SSH_CLIENT=10.0.2.2 58102 22
		==> app-01: USER=root
		==> app-01: SUDO_USER=vagrant
		==> app-01: SUDO_UID=1000
		==> app-01: USERNAME=root
		==> app-01: MAIL=/var/mail/vagrant
		==> app-01: PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
		==> app-01: PWD=/home/vagrant
		==> app-01: LANG=en_US.UTF-8
		==> app-01: SHLVL=3
		==> app-01: HOME=/root
		==> app-01: SUDO_COMMAND=/bin/bash -l
		==> app-01: LOGNAME=root
		==> app-01: SSH_CONNECTION=10.0.2.2 58102 10.0.2.15 22
		==> app-01: XDG_RUNTIME_DIR=/run/user/1000
		==> app-01: SUDO_GID=1000
		==> app-01: IP=44.0.0.101
		==> app-01: _=/usr/bin/env
		==> app-01: MY_IP=44.0.0.101
		==> app-01: + start kubelet
		==> app-01: kubelet start/running, process 8598
		==> app-01: Running provisioner: shell...
		    app-01: Running: script: kubernetes
		==> app-01: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kube-proxy /usr/local/bin/kube-proxy
		==> app-01: + cp /vagrant/kube-proxy.conf /etc/init/kube-proxy.conf
		==> app-01: + start kube-proxy
		==> app-01: kube-proxy start/running, process 8631
		==> app-02: Importing base box 'ubuntu/trusty64'...
		==> app-02: Matching MAC address for NAT networking...
		==> app-02: Checking if box 'ubuntu/trusty64' is up to date...
		==> app-02: There was a problem while downloading the metadata for your box
		==> app-02: to check for updates. This is not an error, since it is usually due
		==> app-02: to temporary network problems. This is just a warning. The problem
		==> app-02: encountered was:
		==> app-02: 
		==> app-02: Couldn't resolve host 'atlas.hashicorp.com'
		==> app-02: 
		==> app-02: If you want to check for box updates, verify your network connection
		==> app-02: is valid and try again.
		==> app-02: Setting the name of the VM: kube-scratch-lab_app-02_1478015264574_89170
		==> app-02: Clearing any previously set forwarded ports...
		==> app-02: Fixed port collision for 22 => 2222. Now on port 2200.
		==> app-02: Clearing any previously set network interfaces...
		==> app-02: Preparing network interfaces based on configuration...
		    app-02: Adapter 1: nat
		    app-02: Adapter 2: hostonly
		==> app-02: Forwarding ports...
		    app-02: 22 (guest) => 2200 (host) (adapter 1)
		==> app-02: Running 'pre-boot' VM customizations...
		==> app-02: Booting VM...
		==> app-02: Waiting for machine to boot. This may take a few minutes...
		    app-02: SSH address: 127.0.0.1:2200
		    app-02: SSH username: vagrant
		    app-02: SSH auth method: private key
		    app-02: Warning: Remote connection disconnect. Retrying...
		    app-02: Warning: Remote connection disconnect. Retrying...
		    app-02: 
		    app-02: Vagrant insecure key detected. Vagrant will automatically replace
		    app-02: this with a newly generated keypair for better security.
		    app-02: 
		    app-02: Inserting generated public key within guest...
		    app-02: Removing insecure key from the guest if it's present...
		    app-02: Key inserted! Disconnecting and reconnecting using new SSH key...
		==> app-02: Machine booted and ready!
		[app-02] GuestAdditions versions on your host (5.1.8) and guest (4.3.36) do not match.
		stdin: is not a tty
		 * Stopping VirtualBox Additions
		   ...done.
		stdin: is not a tty
		Reading package lists...
		Building dependency tree...
		Reading state information...
		The following packages were automatically installed and are no longer required:
		  acl at-spi2-core colord dconf-gsettings-backend dconf-service dkms fakeroot
		  fontconfig fontconfig-config fonts-dejavu-core gcc gcc-4.8
		  hicolor-icon-theme libasan0 libasound2 libasound2-data libatk-bridge2.0-0
		  libatk1.0-0 libatk1.0-data libatomic1 libatspi2.0-0 libavahi-client3
		  libavahi-common-data libavahi-common3 libc-dev-bin libc6-dev
		  libcairo-gobject2 libcairo2 libcanberra-gtk3-0 libcanberra-gtk3-module
		  libcanberra0 libcolord1 libcolorhug1 libcups2 libdatrie1 libdconf1
		  libdrm-intel1 libdrm-nouveau2 libdrm-radeon1 libexif12 libfakeroot
		  libfontconfig1 libfontenc1 libgcc-4.8-dev libgd3 libgdk-pixbuf2.0-0
		  libgdk-pixbuf2.0-common libgl1-mesa-dri libgl1-mesa-glx libglapi-mesa
		  libgomp1 libgphoto2-6 libgphoto2-l10n libgphoto2-port10 libgraphite2-3
		  libgtk-3-0 libgtk-3-bin libgtk-3-common libgudev-1.0-0 libgusb2
		  libharfbuzz0b libice6 libieee1284-3 libitm1 libjasper1 libjbig0
		  libjpeg-turbo8 libjpeg8 liblcms2-2 libllvm3.4 libltdl7 libnotify-bin
		  libnotify4 libogg0 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0
		  libpciaccess0 libpixman-1-0 libquadmath0 libsane libsane-common libsm6
		  libtdb1 libthai-data libthai0 libtiff5 libtsan0 libtxc-dxtn-s2tc0 libv4l-0
		  libv4lconvert0 libvorbis0a libvorbisfile3 libvpx1 libwayland-client0
		  libwayland-cursor0 libx11-xcb1 libxaw7 libxcb-dri2-0 libxcb-dri3-0
		  libxcb-glx0 libxcb-present0 libxcb-render0 libxcb-shm0 libxcb-sync1
		  libxcomposite1 libxcursor1 libxdamage1 libxfixes3 libxfont1 libxi6
		  libxinerama1 libxkbcommon0 libxkbfile1 libxmu6 libxpm4 libxrandr2
		  libxrender1 libxshmfence1 libxt6 libxtst6 libxxf86vm1 linux-libc-dev
		  manpages-dev notification-daemon sound-theme-freedesktop x11-common
		  x11-xkb-utils xfonts-base xfonts-encodings xfonts-utils xserver-common
		  xserver-xorg-core
		Use 'apt-get autoremove' to remove them.
		The following packages will be REMOVED:
		  virtualbox-guest-dkms* virtualbox-guest-utils* virtualbox-guest-x11*
		0 upgraded, 0 newly installed, 3 to remove and 0 not upgraded.
		After this operation, 12.1 MB disk space will be freed.
		(Reading database ... 62997 files and directories currently installed.)
		Removing virtualbox-guest-dkms (4.3.36-dfsg-1+deb8u1ubuntu1.14.04.1) ...
		-------- Uninstall Beginning --------
		Module:  virtualbox-guest
		Version: 4.3.36
		Kernel:  3.13.0-98-generic (x86_64)
		-------------------------------------
		Status: Before uninstall, this module version was ACTIVE on this kernel.
		vboxguest.ko:
		 - Uninstallation
		   - Deleting from: /lib/modules/3.13.0-98-generic/updates/dkms/
		 - Original module
		   - No original module was found for this module on this kernel.
		   - Use the dkms install command to reinstall any previous module version.
		vboxsf.ko:
		 - Uninstallation
		   - Deleting from: /lib/modules/3.13.0-98-generic/updates/dkms/
		 - Original module
		   - No original module was found for this module on this kernel.
		   - Use the dkms install command to reinstall any previous module version.
		vboxvideo.ko:
		 - Uninstallation
		   - Deleting from: /lib/modules/3.13.0-98-generic/updates/dkms/
		 - Original module
		   - No original module was found for this module on this kernel.
		   - Use the dkms install command to reinstall any previous module version.
		depmod....
		DKMS: uninstall completed.
		------------------------------
		Deleting module version: 4.3.36
		completely from the DKMS tree.
		------------------------------
		Done.
		Removing virtualbox-guest-x11 (4.3.36-dfsg-1+deb8u1ubuntu1.14.04.1) ...
		Purging configuration files for virtualbox-guest-x11 (4.3.36-dfsg-1+deb8u1ubuntu1.14.04.1) ...
		Removing virtualbox-guest-utils (4.3.36-dfsg-1+deb8u1ubuntu1.14.04.1) ...
		Purging configuration files for virtualbox-guest-utils (4.3.36-dfsg-1+deb8u1ubuntu1.14.04.1) ...
		Processing triggers for man-db (2.6.7.1-1ubuntu1) ...
		Processing triggers for libc-bin (2.19-0ubuntu6.9) ...
		stdin: is not a tty
		Reading package lists...
		Building dependency tree...
		Reading state information...
		dkms is already the newest version.
		dkms set to manually installed.
		linux-headers-3.13.0-98-generic is already the newest version.
		linux-headers-3.13.0-98-generic set to manually installed.
		The following packages were automatically installed and are no longer required:
		  acl at-spi2-core colord dconf-gsettings-backend dconf-service fontconfig
		  fontconfig-config fonts-dejavu-core hicolor-icon-theme libasound2
		  libasound2-data libatk-bridge2.0-0 libatk1.0-0 libatk1.0-data libatspi2.0-0
		  libavahi-client3 libavahi-common-data libavahi-common3 libcairo-gobject2
		  libcairo2 libcanberra-gtk3-0 libcanberra-gtk3-module libcanberra0 libcolord1
		  libcolorhug1 libcups2 libdatrie1 libdconf1 libdrm-intel1 libdrm-nouveau2
		  libdrm-radeon1 libexif12 libfontconfig1 libfontenc1 libgd3
		  libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgl1-mesa-dri libgl1-mesa-glx
		  libglapi-mesa libgphoto2-6 libgphoto2-l10n libgphoto2-port10 libgraphite2-3
		  libgtk-3-0 libgtk-3-bin libgtk-3-common libgudev-1.0-0 libgusb2
		  libharfbuzz0b libice6 libieee1284-3 libjasper1 libjbig0 libjpeg-turbo8
		  libjpeg8 liblcms2-2 libllvm3.4 libltdl7 libnotify-bin libnotify4 libogg0
		  libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpciaccess0
		  libpixman-1-0 libsane libsane-common libsm6 libtdb1 libthai-data libthai0
		  libtiff5 libtxc-dxtn-s2tc0 libv4l-0 libv4lconvert0 libvorbis0a
		  libvorbisfile3 libvpx1 libwayland-client0 libwayland-cursor0 libx11-xcb1
		  libxaw7 libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0 libxcb-present0
		  libxcb-render0 libxcb-shm0 libxcb-sync1 libxcomposite1 libxcursor1
		  libxdamage1 libxfixes3 libxfont1 libxi6 libxinerama1 libxkbcommon0
		  libxkbfile1 libxmu6 libxpm4 libxrandr2 libxrender1 libxshmfence1 libxt6
		  libxtst6 libxxf86vm1 notification-daemon sound-theme-freedesktop x11-common
		  x11-xkb-utils xfonts-base xfonts-encodings xfonts-utils xserver-common
		  xserver-xorg-core
		Use 'apt-get autoremove' to remove them.
		0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
		Copy iso file /usr/share/virtualbox/VBoxGuestAdditions.iso into the box /tmp/VBoxGuestAdditions.iso
		stdin: is not a tty
		mount: block device /tmp/VBoxGuestAdditions.iso is write-protected, mounting read-only
		Installing Virtualbox Guest Additions 5.1.8 - guest version is 4.3.36
		stdin: is not a tty
		Verifying archive integrity... All good.
		Uncompressing VirtualBox 5.1.8 Guest Additions for Linux...........
		VirtualBox Guest Additions installer
		Copying additional installer modules ...
		Installing additional modules ...
		vboxadd.sh: Building Guest Additions kernel modules.
		vboxadd.sh: Starting the VirtualBox Guest Additions.
		
		Could not find the X.Org or XFree86 Window System, skipping.
		stdin: is not a tty
		
		Got different reports about installed GuestAdditions version:
		Virtualbox on your host claims:   4.3.36
		VBoxService inside the vm claims: 5.1.8
		Going on, assuming VBoxService is correct...
		Got different reports about installed GuestAdditions version:
		Virtualbox on your host claims:   4.3.36
		VBoxService inside the vm claims: 5.1.8
		Going on, assuming VBoxService is correct...
		==> app-02: Checking for guest additions in VM...
		    app-02: The guest additions on this VM do not match the installed version of
		    app-02: VirtualBox! In most cases this is fine, but in rare cases it can
		    app-02: prevent things such as shared folders from working properly. If you see
		    app-02: shared folder errors, please make sure the guest additions within the
		    app-02: virtual machine match the version of VirtualBox you have installed on
		    app-02: your host and reload your VM.
		    app-02: 
		    app-02: Guest Additions Version: 4.3.36
		    app-02: VirtualBox Version: 5.1
		==> app-02: Setting hostname...
		==> app-02: Configuring and enabling network interfaces...
		==> app-02: Mounting shared folders...
		    app-02: /vagrant => /home/minkuan/Documents/96-workspace/kube-scratch-lab
		==> app-02: Running provisioner: fix-no-tty (shell)...
		    app-02: Running: inline script
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: ipv6-forwarding
		==> app-02: net.ipv4.ip_forward = 1
		==> app-02: net.ipv6.conf.all.forwarding = 1
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: etcd
		==> app-02: + echo 'environments: 44.0.0.102, existing, app-01=http:\/\/44.0.0.101:2380,app-02=http:\/\/44.0.0.102:2380'
		==> app-02: environments: 44.0.0.102, existing, app-01=http:\/\/44.0.0.101:2380,app-02=http:\/\/44.0.0.102:2380
		==> app-02: + cd /opt/
		==> app-02: + mkdir /opt/etcd-v3.0.1
		==> app-02: + cp /vagrant/etcd-v3.0.1-linux-amd64.tar.gz /opt/
		==> app-02: + tar -zxf etcd-v3.0.1-linux-amd64.tar.gz -C etcd-v3.0.1 --strip-components=1
		==> app-02: + ln -s /opt/etcd-v3.0.1/etcd /usr/local/bin/etcd
		==> app-02: + ln -s /opt/etcd-v3.0.1/etcdctl /usr/local/bin/etcdctl
		==> app-02: + cp /vagrant/etcd.conf /etc/init/etcd.conf
		==> app-02: + sed -e s/MY_IP/44.0.0.102/g -e s/MY_CLUSTER_STATE/existing/g -e 's/MY_CLUSTER/app-01=http:\/\/44.0.0.101:2380,app-02=http:\/\/44.0.0.102:2380/g'
		==> app-02: + mkdir /var/lib/etcd
		==> app-02: + chown vagrant:vagrant /var/lib/etcd
		==> app-02: + mkdir /var/log/etcd
		==> app-02: + chown vagrant:vagrant /var/log/etcd
		==> app-02: + start etcd
		==> app-02: etcd start/running, process 5557
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: flannel
		==> app-02: + cd /opt/
		==> app-02: + mkdir /opt/flanneld-0.6.2
		==> app-02: + cp /vagrant/flannel-v0.6.2-linux-amd64.tar.gz /opt/
		==> app-02: + tar -zxf flannel-v0.6.2-linux-amd64.tar.gz -C flanneld-0.6.2
		==> app-02: + ln -s /opt/flanneld-0.6.2/flanneld /usr/local/bin/flanneld
		==> app-02: + cp /vagrant/flanneld.conf /etc/init/flanneld.conf
		==> app-02: + mkdir /var/log/flannel
		==> app-02: + chown vagrant:vagrant /var/log/flannel
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: flannel
		==> app-02: flanneld start/running, process 5609
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: etcd-add
		==> app-02: Added member named app-03 with ID b13aae94df26f6b4 to cluster
		==> app-02: ETCD_NAME="app-03"
		==> app-02: ETCD_INITIAL_CLUSTER="app-01=http://44.0.0.101:2380,app-03=http://44.0.0.103:2380,app-02=http://44.0.0.102:2380"
		==> app-02: ETCD_INITIAL_CLUSTER_STATE="existing"
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: docker
		==> app-02: deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
		==> app-02: deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
		==> app-02: deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
		==> app-02: deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
		==> app-02: deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
		==> app-02: deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
		==> app-02: deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
		==> app-02: deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
		==> app-02: deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
		==> app-02: deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
		==> app-02: + apt-get update -qq
		==> app-02: + apt-get install -y docker.io
		==> app-02: Reading package lists...
		==> app-02: Building dependency tree...
		==> app-02: Reading state information...
		==> app-02: The following packages were automatically installed and are no longer required:
		==> app-02:   acl at-spi2-core colord dconf-gsettings-backend dconf-service fontconfig
		==> app-02:   fontconfig-config fonts-dejavu-core hicolor-icon-theme libasound2
		==> app-02:   libasound2-data libatk-bridge2.0-0 libatk1.0-0 libatk1.0-data libatspi2.0-0
		==> app-02:   libavahi-client3 libavahi-common-data libavahi-common3 libcairo-gobject2
		==> app-02:   libcairo2 libcanberra-gtk3-0 libcanberra-gtk3-module libcanberra0 libcolord1
		==> app-02:   libcolorhug1 libcups2 libdatrie1 libdconf1 libdrm-intel1 libdrm-nouveau2
		==> app-02:   libdrm-radeon1 libexif12 libfontconfig1 libfontenc1 libgd3
		==> app-02:   libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgl1-mesa-dri libgl1-mesa-glx
		==> app-02:   libglapi-mesa libgphoto2-6 libgphoto2-l10n libgphoto2-port10 libgraphite2-3
		==> app-02:   libgtk-3-0 libgtk-3-bin libgtk-3-common libgudev-1.0-0 libgusb2
		==> app-02:   libharfbuzz0b libice6 libieee1284-3 libjasper1 libjbig0 libjpeg-turbo8
		==> app-02:   libjpeg8 liblcms2-2 libllvm3.4 libltdl7 libnotify-bin libnotify4 libogg0
		==> app-02:   libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpciaccess0
		==> app-02:   libpixman-1-0 libsane libsane-common libsm6 libtdb1 libthai-data libthai0
		==> app-02:   libtiff5 libtxc-dxtn-s2tc0 libv4l-0 libv4lconvert0 libvorbis0a
		==> app-02:   libvorbisfile3 libvpx1 libwayland-client0 libwayland-cursor0 libx11-xcb1
		==> app-02:   libxaw7 libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0 libxcb-present0
		==> app-02:   libxcb-render0 libxcb-shm0 libxcb-sync1 libxcomposite1 libxcursor1
		==> app-02:   libxdamage1 libxfixes3 libxfont1 libxi6 libxinerama1 libxkbcommon0
		==> app-02:   libxkbfile1 libxmu6 libxpm4 libxrandr2 libxrender1 libxshmfence1 libxt6
		==> app-02:   libxtst6 libxxf86vm1 notification-daemon sound-theme-freedesktop x11-common
		==> app-02:   x11-xkb-utils xfonts-base xfonts-encodings xfonts-utils xserver-common
		==> app-02:   xserver-xorg-core
		==> app-02: Use 'apt-get autoremove' to remove them.
		==> app-02: The following extra packages will be installed:
		==> app-02:   aufs-tools cgroup-lite git git-man liberror-perl
		==> app-02: Suggested packages:
		==> app-02:   btrfs-tools debootstrap lxc rinse git-daemon-run git-daemon-sysvinit git-doc
		==> app-02:   git-el git-email git-gui gitk gitweb git-arch git-bzr git-cvs git-mediawiki
		==> app-02:   git-svn
		==> app-02: The following NEW packages will be installed:
		==> app-02:   aufs-tools cgroup-lite docker.io git git-man liberror-perl
		==> app-02: 0 upgraded, 6 newly installed, 0 to remove and 15 not upgraded.
		==> app-02: Need to get 8,150 kB of archives.
		==> app-02: After this operation, 51.4 MB of additional disk space will be used.
		==> app-02: Get:1 http://mirrors.aliyun.com/ubuntu/ trusty/universe aufs-tools amd64 1:3.2+20130722-1.1 [92.3 kB]
		==> app-02: Get:2 http://mirrors.aliyun.com/ubuntu/ trusty-updates/universe docker.io amd64 1.6.2~dfsg1-1ubuntu4~14.04.1 [4,749 kB]
		==> app-02: Get:3 http://mirrors.aliyun.com/ubuntu/ trusty/main liberror-perl all 0.17-1.1 [21.1 kB]
		==> app-02: Get:4 http://mirrors.aliyun.com/ubuntu/ trusty-security/main git-man all 1:1.9.1-1ubuntu0.3 [699 kB]
		==> app-02: Get:5 http://mirrors.aliyun.com/ubuntu/ trusty-security/main git amd64 1:1.9.1-1ubuntu0.3 [2,586 kB]
		==> app-02: Get:6 http://mirrors.aliyun.com/ubuntu/ trusty/main cgroup-lite all 1.9 [3,918 B]
		==> app-02: dpkg-preconfigure: unable to re-open stdin: No such file or directory
		==> app-02: Fetched 8,150 kB in 1min 32s (87.9 kB/s)
		==> app-02: Selecting previously unselected package aufs-tools.
		==> app-02: (Reading database ... 62722 files and directories currently installed.)
		==> app-02: Preparing to unpack .../aufs-tools_1%3a3.2+20130722-1.1_amd64.deb ...
		==> app-02: Unpacking aufs-tools (1:3.2+20130722-1.1) ...
		==> app-02: Selecting previously unselected package docker.io.
		==> app-02: Preparing to unpack .../docker.io_1.6.2~dfsg1-1ubuntu4~14.04.1_amd64.deb ...
		==> app-02: Unpacking docker.io (1.6.2~dfsg1-1ubuntu4~14.04.1) ...
		==> app-02: Selecting previously unselected package liberror-perl.
		==> app-02: Preparing to unpack .../liberror-perl_0.17-1.1_all.deb ...
		==> app-02: Unpacking liberror-perl (0.17-1.1) ...
		==> app-02: Selecting previously unselected package git-man.
		==> app-02: Preparing to unpack .../git-man_1%3a1.9.1-1ubuntu0.3_all.deb ...
		==> app-02: Unpacking git-man (1:1.9.1-1ubuntu0.3) ...
		==> app-02: Selecting previously unselected package git.
		==> app-02: Preparing to unpack .../git_1%3a1.9.1-1ubuntu0.3_amd64.deb ...
		==> app-02: Unpacking git (1:1.9.1-1ubuntu0.3) ...
		==> app-02: Selecting previously unselected package cgroup-lite.
		==> app-02: Preparing to unpack .../cgroup-lite_1.9_all.deb ...
		==> app-02: Unpacking cgroup-lite (1.9) ...
		==> app-02: Processing triggers for man-db (2.6.7.1-1ubuntu1) ...
		==> app-02: Processing triggers for ureadahead (0.100.0-16) ...
		==> app-02: Setting up aufs-tools (1:3.2+20130722-1.1) ...
		==> app-02: Setting up docker.io (1.6.2~dfsg1-1ubuntu4~14.04.1) ...
		==> app-02: Adding group `docker' (GID 113) ...
		==> app-02: Done.
		==> app-02: docker start/running, process 8253
		==> app-02: Setting up liberror-perl (0.17-1.1) ...
		==> app-02: Setting up git-man (1:1.9.1-1ubuntu0.3) ...
		==> app-02: Setting up git (1:1.9.1-1ubuntu0.3) ...
		==> app-02: Setting up cgroup-lite (1.9) ...
		==> app-02: cgroup-lite start/running
		==> app-02: Processing triggers for libc-bin (2.19-0ubuntu6.9) ...
		==> app-02: Processing triggers for ureadahead (0.100.0-16) ...
		==> app-02: + service docker status
		==> app-02: docker start/running, process 8253
		==> app-02: + service docker stop
		==> app-02: docker stop/waiting
		==> app-02: + groupadd docker
		==> app-02: groupadd: group 'docker' already exists
		==> app-02: + usermod -aG docker vagrant
		==> app-02: + '[' -f /run/flannel/subnet.env ']'
		==> app-02: + . /run/flannel/subnet.env
		==> app-02: ++ FLANNEL_NETWORK=44.0.0.0/8
		==> app-02: ++ FLANNEL_SUBNET=44.1.40.1/24
		==> app-02: ++ FLANNEL_MTU=1472
		==> app-02: ++ FLANNEL_IPMASQ=false
		==> app-02: + sudo sed -i s/DOCKER_OPTS=/#DOCKER_OPTS=/g /etc/default/docker
		==> app-02: + sudo tee -a /etc/default/docker
		==> app-02: + echo 'DOCKER_OPTS="--bip=44.1.40.1/24 --mtu=1472"'
		==> app-02: DOCKER_OPTS="--bip=44.1.40.1/24 --mtu=1472"
		==> app-02: + service docker stop
		==> app-02: stop: Unknown instance: 
		==> app-02: + sudo ip link delete docker0
		==> app-02: Cannot find device "docker0"
		==> app-02: + service docker start
		==> app-02: docker start/running, process 8435
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: kubernetes
		==> app-02: + cd /opt/
		==> app-02: + mkdir /opt/kubernetes-1.5.0
		==> app-02: + tar -zxf /vagrant/kubernetes.tar.gz -C kubernetes-1.5.0 --strip-components=1
		==> app-02: + cd /opt/kubernetes-1.5.0/server/
		==> app-02: + tar -zxf kubernetes-server-linux-amd64.tar.gz
		==> app-02: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kubectl /usr/local/bin/kubectl
		==> app-02: + echo 'alias kubectl='\''kubectl --server=44.0.0.103:8888'\'''
		==> app-02: + tee -a /root/.bashrc
		==> app-02: alias kubectl='kubectl --server=44.0.0.103:8888'
		==> app-02: + source /root/.bashrc
		==> app-02: ++ '[' -z '' ']'
		==> app-02: ++ return
		==> app-02: + mkdir /var/log/kubernetes
		==> app-02: + chown vagrant:vagrant /var/log/kubernetes
		==> app-02: + chown -R vagrant:vagrant /opt/kubernetes-1.5.0
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: kubernetes
		==> app-02: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kubelet /usr/local/bin/kubelet
		==> app-02: + mkdir /var/lib/kubelet
		==> app-02: + cp /vagrant/.kubeconfig /var/lib/kubelet/kubeconfig
		==> app-02: + cp /vagrant/kubelet.conf /etc/init/kubelet.conf
		==> app-02: + env MY_IP=44.0.0.102
		==> app-02: XDG_SESSION_ID=2
		==> app-02: SHELL=/bin/bash
		==> app-02: TERM=vt100
		==> app-02: SSH_CLIENT=10.0.2.2 39192 22
		==> app-02: USER=root
		==> app-02: SUDO_USER=vagrant
		==> app-02: SUDO_UID=1000
		==> app-02: USERNAME=root
		==> app-02: MAIL=/var/mail/vagrant
		==> app-02: PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
		==> app-02: PWD=/home/vagrant
		==> app-02: LANG=en_US.UTF-8
		==> app-02: SHLVL=3
		==> app-02: HOME=/root
		==> app-02: SUDO_COMMAND=/bin/bash -l
		==> app-02: LOGNAME=root
		==> app-02: SSH_CONNECTION=10.0.2.2 39192 10.0.2.15 22
		==> app-02: XDG_RUNTIME_DIR=/run/user/1000
		==> app-02: SUDO_GID=1000
		==> app-02: IP=44.0.0.102
		==> app-02: _=/usr/bin/env
		==> app-02: MY_IP=44.0.0.102
		==> app-02: + start kubelet
		==> app-02: kubelet start/running, process 8570
		==> app-02: Running provisioner: shell...
		    app-02: Running: script: kubernetes
		==> app-02: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kube-proxy /usr/local/bin/kube-proxy
		==> app-02: + cp /vagrant/kube-proxy.conf /etc/init/kube-proxy.conf
		==> app-02: + start kube-proxy
		==> app-02: kube-proxy start/running, process 8603
		==> app-03: Importing base box 'ubuntu/trusty64'...
		==> app-03: Matching MAC address for NAT networking...
		==> app-03: Checking if box 'ubuntu/trusty64' is up to date...
		==> app-03: There was a problem while downloading the metadata for your box
		==> app-03: to check for updates. This is not an error, since it is usually due
		==> app-03: to temporary network problems. This is just a warning. The problem
		==> app-03: encountered was:
		==> app-03: 
		==> app-03: Couldn't resolve host 'atlas.hashicorp.com'
		==> app-03: 
		==> app-03: If you want to check for box updates, verify your network connection
		==> app-03: is valid and try again.
		==> app-03: Setting the name of the VM: kube-scratch-lab_app-03_1478015618199_98767
		==> app-03: Clearing any previously set forwarded ports...
		==> app-03: Fixed port collision for 22 => 2222. Now on port 2201.
		==> app-03: Clearing any previously set network interfaces...
		==> app-03: Preparing network interfaces based on configuration...
		    app-03: Adapter 1: nat
		    app-03: Adapter 2: hostonly
		==> app-03: Forwarding ports...
		    app-03: 22 (guest) => 2201 (host) (adapter 1)
		==> app-03: Running 'pre-boot' VM customizations...
		==> app-03: Booting VM...
		==> app-03: Waiting for machine to boot. This may take a few minutes...
		    app-03: SSH address: 127.0.0.1:2201
		    app-03: SSH username: vagrant
		    app-03: SSH auth method: private key
		    app-03: Warning: Remote connection disconnect. Retrying...
		    app-03: Warning: Remote connection disconnect. Retrying...
		    app-03: 
		    app-03: Vagrant insecure key detected. Vagrant will automatically replace
		    app-03: this with a newly generated keypair for better security.
		    app-03: 
		    app-03: Inserting generated public key within guest...
		    app-03: Removing insecure key from the guest if it's present...
		    app-03: Key inserted! Disconnecting and reconnecting using new SSH key...
		==> app-03: Machine booted and ready!
		[app-03] GuestAdditions versions on your host (5.1.8) and guest (4.3.36) do not match.
		stdin: is not a tty
		 * Stopping VirtualBox Additions
		   ...done.
		stdin: is not a tty
		Reading package lists...
		Building dependency tree...
		Reading state information...
		The following packages were automatically installed and are no longer required:
		  acl at-spi2-core colord dconf-gsettings-backend dconf-service dkms fakeroot
		  fontconfig fontconfig-config fonts-dejavu-core gcc gcc-4.8
		  hicolor-icon-theme libasan0 libasound2 libasound2-data libatk-bridge2.0-0
		  libatk1.0-0 libatk1.0-data libatomic1 libatspi2.0-0 libavahi-client3
		  libavahi-common-data libavahi-common3 libc-dev-bin libc6-dev
		  libcairo-gobject2 libcairo2 libcanberra-gtk3-0 libcanberra-gtk3-module
		  libcanberra0 libcolord1 libcolorhug1 libcups2 libdatrie1 libdconf1
		  libdrm-intel1 libdrm-nouveau2 libdrm-radeon1 libexif12 libfakeroot
		  libfontconfig1 libfontenc1 libgcc-4.8-dev libgd3 libgdk-pixbuf2.0-0
		  libgdk-pixbuf2.0-common libgl1-mesa-dri libgl1-mesa-glx libglapi-mesa
		  libgomp1 libgphoto2-6 libgphoto2-l10n libgphoto2-port10 libgraphite2-3
		  libgtk-3-0 libgtk-3-bin libgtk-3-common libgudev-1.0-0 libgusb2
		  libharfbuzz0b libice6 libieee1284-3 libitm1 libjasper1 libjbig0
		  libjpeg-turbo8 libjpeg8 liblcms2-2 libllvm3.4 libltdl7 libnotify-bin
		  libnotify4 libogg0 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0
		  libpciaccess0 libpixman-1-0 libquadmath0 libsane libsane-common libsm6
		  libtdb1 libthai-data libthai0 libtiff5 libtsan0 libtxc-dxtn-s2tc0 libv4l-0
		  libv4lconvert0 libvorbis0a libvorbisfile3 libvpx1 libwayland-client0
		  libwayland-cursor0 libx11-xcb1 libxaw7 libxcb-dri2-0 libxcb-dri3-0
		  libxcb-glx0 libxcb-present0 libxcb-render0 libxcb-shm0 libxcb-sync1
		  libxcomposite1 libxcursor1 libxdamage1 libxfixes3 libxfont1 libxi6
		  libxinerama1 libxkbcommon0 libxkbfile1 libxmu6 libxpm4 libxrandr2
		  libxrender1 libxshmfence1 libxt6 libxtst6 libxxf86vm1 linux-libc-dev
		  manpages-dev notification-daemon sound-theme-freedesktop x11-common
		  x11-xkb-utils xfonts-base xfonts-encodings xfonts-utils xserver-common
		  xserver-xorg-core
		Use 'apt-get autoremove' to remove them.
		The following packages will be REMOVED:
		  virtualbox-guest-dkms* virtualbox-guest-utils* virtualbox-guest-x11*
		0 upgraded, 0 newly installed, 3 to remove and 0 not upgraded.
		After this operation, 12.1 MB disk space will be freed.
		(Reading database ... 62997 files and directories currently installed.)
		Removing virtualbox-guest-dkms (4.3.36-dfsg-1+deb8u1ubuntu1.14.04.1) ...
		-------- Uninstall Beginning --------
		Module:  virtualbox-guest
		Version: 4.3.36
		Kernel:  3.13.0-98-generic (x86_64)
		-------------------------------------
		Status: Before uninstall, this module version was ACTIVE on this kernel.
		vboxguest.ko:
		 - Uninstallation
		   - Deleting from: /lib/modules/3.13.0-98-generic/updates/dkms/
		 - Original module
		   - No original module was found for this module on this kernel.
		   - Use the dkms install command to reinstall any previous module version.
		vboxsf.ko:
		 - Uninstallation
		   - Deleting from: /lib/modules/3.13.0-98-generic/updates/dkms/
		 - Original module
		   - No original module was found for this module on this kernel.
		   - Use the dkms install command to reinstall any previous module version.
		vboxvideo.ko:
		 - Uninstallation
		   - Deleting from: /lib/modules/3.13.0-98-generic/updates/dkms/
		 - Original module
		   - No original module was found for this module on this kernel.
		   - Use the dkms install command to reinstall any previous module version.
		depmod....
		DKMS: uninstall completed.
		------------------------------
		Deleting module version: 4.3.36
		completely from the DKMS tree.
		------------------------------
		Done.
		Removing virtualbox-guest-x11 (4.3.36-dfsg-1+deb8u1ubuntu1.14.04.1) ...
		Purging configuration files for virtualbox-guest-x11 (4.3.36-dfsg-1+deb8u1ubuntu1.14.04.1) ...
		Removing virtualbox-guest-utils (4.3.36-dfsg-1+deb8u1ubuntu1.14.04.1) ...
		Purging configuration files for virtualbox-guest-utils (4.3.36-dfsg-1+deb8u1ubuntu1.14.04.1) ...
		Processing triggers for man-db (2.6.7.1-1ubuntu1) ...
		Processing triggers for libc-bin (2.19-0ubuntu6.9) ...
		stdin: is not a tty
		Reading package lists...
		Building dependency tree...
		Reading state information...
		dkms is already the newest version.
		dkms set to manually installed.
		linux-headers-3.13.0-98-generic is already the newest version.
		linux-headers-3.13.0-98-generic set to manually installed.
		The following packages were automatically installed and are no longer required:
		  acl at-spi2-core colord dconf-gsettings-backend dconf-service fontconfig
		  fontconfig-config fonts-dejavu-core hicolor-icon-theme libasound2
		  libasound2-data libatk-bridge2.0-0 libatk1.0-0 libatk1.0-data libatspi2.0-0
		  libavahi-client3 libavahi-common-data libavahi-common3 libcairo-gobject2
		  libcairo2 libcanberra-gtk3-0 libcanberra-gtk3-module libcanberra0 libcolord1
		  libcolorhug1 libcups2 libdatrie1 libdconf1 libdrm-intel1 libdrm-nouveau2
		  libdrm-radeon1 libexif12 libfontconfig1 libfontenc1 libgd3
		  libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgl1-mesa-dri libgl1-mesa-glx
		  libglapi-mesa libgphoto2-6 libgphoto2-l10n libgphoto2-port10 libgraphite2-3
		  libgtk-3-0 libgtk-3-bin libgtk-3-common libgudev-1.0-0 libgusb2
		  libharfbuzz0b libice6 libieee1284-3 libjasper1 libjbig0 libjpeg-turbo8
		  libjpeg8 liblcms2-2 libllvm3.4 libltdl7 libnotify-bin libnotify4 libogg0
		  libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpciaccess0
		  libpixman-1-0 libsane libsane-common libsm6 libtdb1 libthai-data libthai0
		  libtiff5 libtxc-dxtn-s2tc0 libv4l-0 libv4lconvert0 libvorbis0a
		  libvorbisfile3 libvpx1 libwayland-client0 libwayland-cursor0 libx11-xcb1
		  libxaw7 libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0 libxcb-present0
		  libxcb-render0 libxcb-shm0 libxcb-sync1 libxcomposite1 libxcursor1
		  libxdamage1 libxfixes3 libxfont1 libxi6 libxinerama1 libxkbcommon0
		  libxkbfile1 libxmu6 libxpm4 libxrandr2 libxrender1 libxshmfence1 libxt6
		  libxtst6 libxxf86vm1 notification-daemon sound-theme-freedesktop x11-common
		  x11-xkb-utils xfonts-base xfonts-encodings xfonts-utils xserver-common
		  xserver-xorg-core
		Use 'apt-get autoremove' to remove them.
		0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
		Copy iso file /usr/share/virtualbox/VBoxGuestAdditions.iso into the box /tmp/VBoxGuestAdditions.iso
		stdin: is not a tty
		mount: block device /tmp/VBoxGuestAdditions.iso is write-protected, mounting read-only
		Installing Virtualbox Guest Additions 5.1.8 - guest version is 4.3.36
		stdin: is not a tty
		Verifying archive integrity... All good.
		Uncompressing VirtualBox 5.1.8 Guest Additions for Linux...........
		VirtualBox Guest Additions installer
		Copying additional installer modules ...
		Installing additional modules ...
		vboxadd.sh: Building Guest Additions kernel modules.
		vboxadd.sh: Starting the VirtualBox Guest Additions.
		Could not find the X.Org or XFree86 Window System, skipping.
		stdin: is not a tty
		Got different reports about installed GuestAdditions version:
		Virtualbox on your host claims:   4.3.36
		VBoxService inside the vm claims: 5.1.8
		Going on, assuming VBoxService is correct...
		Got different reports about installed GuestAdditions version:
		Virtualbox on your host claims:   4.3.36
		VBoxService inside the vm claims: 5.1.8
		Going on, assuming VBoxService is correct...
		==> app-03: Checking for guest additions in VM...
		    app-03: The guest additions on this VM do not match the installed version of
		    app-03: VirtualBox! In most cases this is fine, but in rare cases it can
		    app-03: prevent things such as shared folders from working properly. If you see
		    app-03: shared folder errors, please make sure the guest additions within the
		    app-03: virtual machine match the version of VirtualBox you have installed on
		    app-03: your host and reload your VM.
		    app-03: 
		    app-03: Guest Additions Version: 4.3.36
		    app-03: VirtualBox Version: 5.1
		==> app-03: Setting hostname...
		==> app-03: Configuring and enabling network interfaces...
		==> app-03: Mounting shared folders...
		    app-03: /vagrant => /home/minkuan/Documents/96-workspace/kube-scratch-lab
		==> app-03: Running provisioner: fix-no-tty (shell)...
		    app-03: Running: inline script
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: ipv6-forwarding
		==> app-03: net.ipv4.ip_forward = 1
		==> app-03: net.ipv6.conf.all.forwarding = 1
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: etcd
		==> app-03: + echo 'environments: 44.0.0.103, existing, app-01=http:\/\/44.0.0.101:2380,app-02=http:\/\/44.0.0.102:2380,app-03=http:\/\/44.0.0.103:2380'
		==> app-03: environments: 44.0.0.103, existing, app-01=http:\/\/44.0.0.101:2380,app-02=http:\/\/44.0.0.102:2380,app-03=http:\/\/44.0.0.103:2380
		==> app-03: + cd /opt/
		==> app-03: + mkdir /opt/etcd-v3.0.1
		==> app-03: + cp /vagrant/etcd-v3.0.1-linux-amd64.tar.gz /opt/
		==> app-03: + tar -zxf etcd-v3.0.1-linux-amd64.tar.gz -C etcd-v3.0.1 --strip-components=1
		==> app-03: + ln -s /opt/etcd-v3.0.1/etcd /usr/local/bin/etcd
		==> app-03: + ln -s /opt/etcd-v3.0.1/etcdctl /usr/local/bin/etcdctl
		==> app-03: + cp /vagrant/etcd.conf /etc/init/etcd.conf
		==> app-03: + sed -e s/MY_IP/44.0.0.103/g -e s/MY_CLUSTER_STATE/existing/g -e 's/MY_CLUSTER/app-01=http:\/\/44.0.0.101:2380,app-02=http:\/\/44.0.0.102:2380,app-03=http:\/\/44.0.0.103:2380/g'
		==> app-03: + mkdir /var/lib/etcd
		==> app-03: + chown vagrant:vagrant /var/lib/etcd
		==> app-03: + mkdir /var/log/etcd
		==> app-03: + chown vagrant:vagrant /var/log/etcd
		==> app-03: + start etcd
		==> app-03: etcd start/running, process 5571
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: flannel
		==> app-03: + cd /opt/
		==> app-03: + mkdir /opt/flanneld-0.6.2
		==> app-03: + cp /vagrant/flannel-v0.6.2-linux-amd64.tar.gz /opt/
		==> app-03: + tar -zxf flannel-v0.6.2-linux-amd64.tar.gz -C flanneld-0.6.2
		==> app-03: + ln -s /opt/flanneld-0.6.2/flanneld /usr/local/bin/flanneld
		==> app-03: + cp /vagrant/flanneld.conf /etc/init/flanneld.conf
		==> app-03: + mkdir /var/log/flannel
		==> app-03: + chown vagrant:vagrant /var/log/flannel
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: flannel
		==> app-03: flanneld start/running, process 5623
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: docker
		==> app-03: deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
		==> app-03: deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
		==> app-03: deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
		==> app-03: deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
		==> app-03: deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
		==> app-03: deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
		==> app-03: deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
		==> app-03: deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
		==> app-03: deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
		==> app-03: deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
		==> app-03: + apt-get update -qq
		==> app-03: + apt-get install -y docker.io
		==> app-03: Reading package lists...
		==> app-03: Building dependency tree...
		==> app-03: 
		==> app-03: Reading state information...
		==> app-03: The following packages were automatically installed and are no longer required:
		==> app-03:   acl at-spi2-core colord dconf-gsettings-backend dconf-service fontconfig
		==> app-03:   fontconfig-config fonts-dejavu-core hicolor-icon-theme libasound2
		==> app-03:   libasound2-data libatk-bridge2.0-0 libatk1.0-0 libatk1.0-data libatspi2.0-0
		==> app-03:   libavahi-client3 libavahi-common-data libavahi-common3 libcairo-gobject2
		==> app-03:   libcairo2 libcanberra-gtk3-0 libcanberra-gtk3-module libcanberra0 libcolord1
		==> app-03:   libcolorhug1 libcups2 libdatrie1 libdconf1 libdrm-intel1 libdrm-nouveau2
		==> app-03:   libdrm-radeon1 libexif12 libfontconfig1 libfontenc1 libgd3
		==> app-03:   libgdk-pixbuf2.0-0 libgdk-pixbuf2.0-common libgl1-mesa-dri libgl1-mesa-glx
		==> app-03:   libglapi-mesa libgphoto2-6 libgphoto2-l10n libgphoto2-port10 libgraphite2-3
		==> app-03:   libgtk-3-0 libgtk-3-bin libgtk-3-common libgudev-1.0-0 libgusb2
		==> app-03:   libharfbuzz0b libice6 libieee1284-3 libjasper1 libjbig0 libjpeg-turbo8
		==> app-03:   libjpeg8 liblcms2-2 libllvm3.4 libltdl7 libnotify-bin libnotify4 libogg0
		==> app-03:   libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpciaccess0
		==> app-03:   libpixman-1-0 libsane libsane-common libsm6 libtdb1 libthai-data libthai0
		==> app-03:   libtiff5 libtxc-dxtn-s2tc0 libv4l-0 libv4lconvert0 libvorbis0a
		==> app-03:   libvorbisfile3 libvpx1 libwayland-client0 libwayland-cursor0 libx11-xcb1
		==> app-03:   libxaw7 libxcb-dri2-0 libxcb-dri3-0 libxcb-glx0 libxcb-present0
		==> app-03:   libxcb-render0 libxcb-shm0 libxcb-sync1 libxcomposite1 libxcursor1
		==> app-03:   libxdamage1 libxfixes3 libxfont1 libxi6 libxinerama1 libxkbcommon0
		==> app-03:   libxkbfile1 libxmu6 libxpm4 libxrandr2 libxrender1 libxshmfence1 libxt6
		==> app-03:   libxtst6 libxxf86vm1 notification-daemon sound-theme-freedesktop x11-common
		==> app-03:   x11-xkb-utils xfonts-base xfonts-encodings xfonts-utils xserver-common
		==> app-03:   xserver-xorg-core
		==> app-03: Use 'apt-get autoremove' to remove them.
		==> app-03: The following extra packages will be installed:
		==> app-03:   aufs-tools cgroup-lite git git-man liberror-perl
		==> app-03: Suggested packages:
		==> app-03:   btrfs-tools debootstrap lxc rinse git-daemon-run git-daemon-sysvinit git-doc
		==> app-03:   git-el git-email git-gui gitk gitweb git-arch git-bzr git-cvs git-mediawiki
		==> app-03:   git-svn
		==> app-03: The following NEW packages will be installed:
		==> app-03:   aufs-tools cgroup-lite docker.io git git-man liberror-perl
		==> app-03: 0 upgraded, 6 newly installed, 0 to remove and 15 not upgraded.
		==> app-03: Need to get 8,150 kB of archives.
		==> app-03: After this operation, 51.4 MB of additional disk space will be used.
		==> app-03: Get:1 http://mirrors.aliyun.com/ubuntu/ trusty/universe aufs-tools amd64 1:3.2+20130722-1.1 [92.3 kB]
		==> app-03: Get:2 http://mirrors.aliyun.com/ubuntu/ trusty-updates/universe docker.io amd64 1.6.2~dfsg1-1ubuntu4~14.04.1 [4,749 kB]
		==> app-03: Get:3 http://mirrors.aliyun.com/ubuntu/ trusty/main liberror-perl all 0.17-1.1 [21.1 kB]
		==> app-03: Get:4 http://mirrors.aliyun.com/ubuntu/ trusty-security/main git-man all 1:1.9.1-1ubuntu0.3 [699 kB]
		==> app-03: Get:5 http://mirrors.aliyun.com/ubuntu/ trusty-security/main git amd64 1:1.9.1-1ubuntu0.3 [2,586 kB]
		==> app-03: Get:6 http://mirrors.aliyun.com/ubuntu/ trusty/main cgroup-lite all 1.9 [3,918 B]
		==> app-03: dpkg-preconfigure: unable to re-open stdin: No such file or directory
		==> app-03: Fetched 8,150 kB in 25s (318 kB/s)
		==> app-03: Selecting previously unselected package aufs-tools.
		==> app-03: (Reading database ... 62722 files and directories currently installed.)
		==> app-03: Preparing to unpack .../aufs-tools_1%3a3.2+20130722-1.1_amd64.deb ...
		==> app-03: Unpacking aufs-tools (1:3.2+20130722-1.1) ...
		==> app-03: Selecting previously unselected package docker.io.
		==> app-03: Preparing to unpack .../docker.io_1.6.2~dfsg1-1ubuntu4~14.04.1_amd64.deb ...
		==> app-03: Unpacking docker.io (1.6.2~dfsg1-1ubuntu4~14.04.1) ...
		==> app-03: Selecting previously unselected package liberror-perl.
		==> app-03: Preparing to unpack .../liberror-perl_0.17-1.1_all.deb ...
		==> app-03: Unpacking liberror-perl (0.17-1.1) ...
		==> app-03: Selecting previously unselected package git-man.
		==> app-03: Preparing to unpack .../git-man_1%3a1.9.1-1ubuntu0.3_all.deb ...
		==> app-03: Unpacking git-man (1:1.9.1-1ubuntu0.3) ...
		==> app-03: Selecting previously unselected package git.
		==> app-03: Preparing to unpack .../git_1%3a1.9.1-1ubuntu0.3_amd64.deb ...
		==> app-03: Unpacking git (1:1.9.1-1ubuntu0.3) ...
		==> app-03: Selecting previously unselected package cgroup-lite.
		==> app-03: Preparing to unpack .../cgroup-lite_1.9_all.deb ...
		==> app-03: Unpacking cgroup-lite (1.9) ...
		==> app-03: Processing triggers for man-db (2.6.7.1-1ubuntu1) ...
		==> app-03: Processing triggers for ureadahead (0.100.0-16) ...
		==> app-03: Setting up aufs-tools (1:3.2+20130722-1.1) ...
		==> app-03: Setting up docker.io (1.6.2~dfsg1-1ubuntu4~14.04.1) ...
		==> app-03: Adding group `docker' (GID 113) ...
		==> app-03: Done.
		==> app-03: docker start/running, process 8258
		==> app-03: Setting up liberror-perl (0.17-1.1) ...
		==> app-03: Setting up git-man (1:1.9.1-1ubuntu0.3) ...
		==> app-03: Setting up git (1:1.9.1-1ubuntu0.3) ...
		==> app-03: Setting up cgroup-lite (1.9) ...
		==> app-03: cgroup-lite start/running
		==> app-03: Processing triggers for libc-bin (2.19-0ubuntu6.9) ...
		==> app-03: Processing triggers for ureadahead (0.100.0-16) ...
		==> app-03: + service docker status
		==> app-03: docker start/running, process 8258
		==> app-03: + service docker stop
		==> app-03: docker stop/waiting
		==> app-03: + groupadd docker
		==> app-03: groupadd: group 'docker' already exists
		==> app-03: + usermod -aG docker vagrant
		==> app-03: + '[' -f /run/flannel/subnet.env ']'
		==> app-03: + . /run/flannel/subnet.env
		==> app-03: ++ FLANNEL_NETWORK=44.0.0.0/8
		==> app-03: ++ FLANNEL_SUBNET=44.1.20.1/24
		==> app-03: ++ FLANNEL_MTU=1472
		==> app-03: ++ FLANNEL_IPMASQ=false
		==> app-03: + sudo sed -i s/DOCKER_OPTS=/#DOCKER_OPTS=/g /etc/default/docker
		==> app-03: + sudo tee -a /etc/default/docker
		==> app-03: + echo 'DOCKER_OPTS="--bip=44.1.20.1/24 --mtu=1472"'
		==> app-03: DOCKER_OPTS="--bip=44.1.20.1/24 --mtu=1472"
		==> app-03: + service docker stop
		==> app-03: stop: Unknown instance: 
		==> app-03: + sudo ip link delete docker0
		==> app-03: Cannot find device "docker0"
		==> app-03: + service docker start
		==> app-03: docker start/running, process 8439
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: kubernetes
		==> app-03: + cd /opt/
		==> app-03: + mkdir /opt/kubernetes-1.5.0
		==> app-03: + tar -zxf /vagrant/kubernetes.tar.gz -C kubernetes-1.5.0 --strip-components=1
		==> app-03: + cd /opt/kubernetes-1.5.0/server/
		==> app-03: + tar -zxf kubernetes-server-linux-amd64.tar.gz
		==> app-03: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kubectl /usr/local/bin/kubectl
		==> app-03: + echo 'alias kubectl='\''kubectl --server=44.0.0.103:8888'\'''
		==> app-03: + tee -a /root/.bashrc
		==> app-03: alias kubectl='kubectl --server=44.0.0.103:8888'
		==> app-03: + source /root/.bashrc
		==> app-03: ++ '[' -z '' ']'
		==> app-03: ++ return
		==> app-03: + mkdir /var/log/kubernetes
		==> app-03: + chown vagrant:vagrant /var/log/kubernetes
		==> app-03: + chown -R vagrant:vagrant /opt/kubernetes-1.5.0
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: kubernetes
		==> app-03: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kubelet /usr/local/bin/kubelet
		==> app-03: + mkdir /var/lib/kubelet
		==> app-03: + cp /vagrant/.kubeconfig /var/lib/kubelet/kubeconfig
		==> app-03: + cp /vagrant/kubelet.conf /etc/init/kubelet.conf
		==> app-03: + env MY_IP=44.0.0.103
		==> app-03: XDG_SESSION_ID=2
		==> app-03: SHELL=/bin/bash
		==> app-03: TERM=vt100
		==> app-03: SSH_CLIENT=10.0.2.2 41302 22
		==> app-03: USER=root
		==> app-03: SUDO_USER=vagrant
		==> app-03: SUDO_UID=1000
		==> app-03: USERNAME=root
		==> app-03: MAIL=/var/mail/vagrant
		==> app-03: PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
		==> app-03: PWD=/home/vagrant
		==> app-03: LANG=en_US.UTF-8
		==> app-03: SHLVL=3
		==> app-03: HOME=/root
		==> app-03: SUDO_COMMAND=/bin/bash -l
		==> app-03: LOGNAME=root
		==> app-03: SSH_CONNECTION=10.0.2.2 41302 10.0.2.15 22
		==> app-03: XDG_RUNTIME_DIR=/run/user/1000
		==> app-03: SUDO_GID=1000
		==> app-03: IP=44.0.0.103
		==> app-03: _=/usr/bin/env
		==> app-03: MY_IP=44.0.0.103
		==> app-03: + start kubelet
		==> app-03: kubelet start/running, process 8574
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: kubernetes
		==> app-03: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kube-proxy /usr/local/bin/kube-proxy
		==> app-03: + cp /vagrant/kube-proxy.conf /etc/init/kube-proxy.conf
		==> app-03: + start kube-proxy
		==> app-03: kube-proxy start/running, process 8607
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: kubernetes
		==> app-03: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kube-apiserver /usr/local/bin/kube-apiserver
		==> app-03: + cp /vagrant/kube-apiserver.conf /etc/init/kube-apiserver.conf
		==> app-03: + start kube-apiserver
		==> app-03: kube-apiserver start/running, process 8652
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: kubernetes
		==> app-03: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kube-controller-manager /usr/local/bin/kube-controller-manager
		==> app-03: + cp /vagrant/kube-controller-manager.conf /etc/init/kube-controller-manager.conf
		==> app-03: + start kube-controller-manager
		==> app-03: kube-controller-manager start/running, process 8702
		==> app-03: Running provisioner: shell...
		    app-03: Running: script: kubernetes
		==> app-03: + ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kube-scheduler /usr/local/bin/kube-scheduler
		==> app-03: + cp /vagrant/kube-scheduler.conf /etc/init/kube-scheduler.conf
		==> app-03: + start kube-scheduler
		==> app-03: kube-scheduler start/running, process 8728
		2016年 11月 01日 星期二 23:57:34 CST
