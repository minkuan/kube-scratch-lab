# kube-scratch-lab

## 目标

基于vagrant(1.8.1) ubuntu(Ubuntu 14.04.5 LTS, vagrant ubuntu/trusty64)虚拟机，从0到1建立kubernetes 1.5集群

1. 以flannel(0.6.2)作为kubernetes网络管理组件，管理kubernetes集群子网，overlay网络数据
2. 以etcd kv-store存储flannel的子网配置
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
2. app-03 etcd不能加入etcd集群。app-03 etcd起动时失败，导致etcd service起动不成功；app-01 etcd leader报错：无法连接app-03 etcd。重起etcd leader才能解决；显然，重起etcd leader在工程实践中应当是不可接受的。
3. etcd v3.1.0-rc版本报错：无法在0.0.0.0:2379找到etcd leader。
4. Flag --api-servers has been deprecated, Use --kubeconfig instead. Will be removed in a future version.
5. unknown flag: --experimental-flannel-overlay

## 要点
1. ubuntu service upstart配置：*.conf, *.override, *.conf中接受环境变量
2. ruby编程编写Vagrantfile
3. vagrant shell provisioning过程中，shell脚本接受Vagrantfile传入的环境变量
4. flanneld使用etcd存储子网信息，作为etcd的客户端，访问etcd的127.0.0.1:2379。

## 接下来
1. kubernetes集群的管理
	- 新增节点
	- 某一个kubernetes节点失效...
2. etcd集群管理
	- 新增etcd节点；
	- 某一个etcd节点失效...

## 详情
全过程耗时约70分钟，主要时耗是vagrant docker provision

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
	    app-01: The guest additions on this VM do not match the installed version of
	    app-01: VirtualBox! In most cases this is fine, but in rare cases it can
	    app-01: prevent things such as shared folders from working properly. If you see
	    app-01: shared folder errors, please make sure the guest additions within the
	    app-01: virtual machine match the version of VirtualBox you have installed on
	    app-01: your host and reload your VM.
	    app-01: 
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
	==> app-01: Ign http://mirrors.aliyun.com trusty InRelease
	==> app-01: Get:1 http://mirrors.aliyun.com trusty-security InRelease [65.9 kB]
	==> app-01: Get:2 http://mirrors.aliyun.com trusty-updates InRelease [65.9 kB]
	==> app-01: Get:3 http://mirrors.aliyun.com trusty-proposed InRelease [65.9 kB]
	==> app-01: Get:4 http://mirrors.aliyun.com trusty-backports InRelease [65.9 kB]
	==> app-01: Get:5 http://ppa.launchpad.net trusty InRelease [16.0 kB]
	==> app-01: Get:6 http://mirrors.aliyun.com trusty Release.gpg [933 B]
	==> app-01: Get:7 http://mirrors.aliyun.com trusty-security/main Sources [120 kB]
	==> app-01: Get:8 http://mirrors.aliyun.com trusty-security/restricted Sources [4,064 B]
	==> app-01: Get:9 http://mirrors.aliyun.com trusty-security/universe Sources [44.7 kB]
	==> app-01: Get:10 http://mirrors.aliyun.com trusty-security/multiverse Sources [3,202 B]
	==> app-01: Get:11 http://mirrors.aliyun.com trusty-security/main amd64 Packages [542 kB]
	==> app-01: Get:12 http://ppa.launchpad.net trusty/main Translation-en [713 B]
	==> app-01: Get:13 http://mirrors.aliyun.com trusty-security/restricted amd64 Packages [13.0 kB]
	==> app-01: Get:14 http://mirrors.aliyun.com trusty-security/universe amd64 Packages [141 kB]
	==> app-01: Get:15 http://ppa.launchpad.net trusty/main amd64 Packages [1,706 B]
	==> app-01: Get:16 http://mirrors.aliyun.com trusty-security/multiverse amd64 Packages [5,199 B]
	==> app-01: Get:17 http://mirrors.aliyun.com trusty-security/main Translation-en [298 kB]
	==> app-01: Get:18 http://mirrors.aliyun.com trusty-security/multiverse Translation-en [2,848 B]
	==> app-01: Get:19 http://mirrors.aliyun.com trusty-security/restricted Translation-en [3,206 B]
	==> app-01: Get:20 http://mirrors.aliyun.com trusty-security/universe Translation-en [84.3 kB]
	==> app-01: Get:21 http://mirrors.aliyun.com trusty-updates/main Sources [383 kB]
	==> app-01: Get:22 http://mirrors.aliyun.com trusty-updates/restricted Sources [5,360 B]
	==> app-01: Get:23 http://mirrors.aliyun.com trusty-updates/universe Sources [169 kB]
	==> app-01: Get:24 http://mirrors.aliyun.com trusty-updates/multiverse Sources [7,531 B]
	==> app-01: Get:25 http://mirrors.aliyun.com trusty-updates/main amd64 Packages [910 kB]
	==> app-01: Get:26 http://mirrors.aliyun.com trusty-updates/restricted amd64 Packages [15.9 kB]
	==> app-01: Get:27 http://mirrors.aliyun.com trusty-updates/universe amd64 Packages [387 kB]
	==> app-01: Get:28 http://mirrors.aliyun.com trusty-updates/multiverse amd64 Packages [15.0 kB]
	==> app-01: Get:29 http://mirrors.aliyun.com trusty-updates/main Translation-en [443 kB]
	==> app-01: Get:30 http://mirrors.aliyun.com trusty-updates/multiverse Translation-en [7,931 B]
	==> app-01: Get:31 http://mirrors.aliyun.com trusty-updates/restricted Translation-en [3,699 B]
	==> app-01: Get:32 http://mirrors.aliyun.com trusty-updates/universe Translation-en [205 kB]
	==> app-01: Get:33 http://mirrors.aliyun.com trusty-proposed/main Sources [116 kB]
	==> app-01: Get:34 http://mirrors.aliyun.com trusty-proposed/restricted Sources [28 B]
	==> app-01: Get:35 http://mirrors.aliyun.com trusty-proposed/universe Sources [16.9 kB]
	==> app-01: Get:36 http://mirrors.aliyun.com trusty-proposed/multiverse Sources [28 B]
	==> app-01: Get:37 http://mirrors.aliyun.com trusty-proposed/main amd64 Packages [99.4 kB]
	==> app-01: Get:38 http://mirrors.aliyun.com trusty-proposed/restricted amd64 Packages [28 B]
	==> app-01: Get:39 http://mirrors.aliyun.com trusty-proposed/universe amd64 Packages [12.1 kB]
	==> app-01: Get:40 http://mirrors.aliyun.com trusty-proposed/multiverse amd64 Packages [28 B]
	==> app-01: Get:41 http://mirrors.aliyun.com trusty-proposed/main Translation-en [34.3 kB]
	==> app-01: Get:42 http://mirrors.aliyun.com trusty-proposed/multiverse Translation-en [28 B]
	==> app-01: Get:43 http://mirrors.aliyun.com trusty-proposed/restricted Translation-en [28 B]
	==> app-01: Get:44 http://mirrors.aliyun.com trusty-proposed/universe Translation-en [10.8 kB]
	==> app-01: Get:45 http://mirrors.aliyun.com trusty-backports/main Sources [9,646 B]
	==> app-01: Get:46 http://mirrors.aliyun.com trusty-backports/restricted Sources [28 B]
	==> app-01: Get:47 http://mirrors.aliyun.com trusty-backports/universe Sources [35.2 kB]
	==> app-01: Get:48 http://mirrors.aliyun.com trusty-backports/multiverse Sources [1,898 B]
	==> app-01: Get:49 http://mirrors.aliyun.com trusty-backports/main amd64 Packages [13.3 kB]
	==> app-01: Get:50 http://mirrors.aliyun.com trusty-backports/restricted amd64 Packages [28 B]
	==> app-01: Get:51 http://mirrors.aliyun.com trusty-backports/universe amd64 Packages [43.2 kB]
	==> app-01: Get:52 http://mirrors.aliyun.com trusty-backports/multiverse amd64 Packages [1,571 B]
	==> app-01: Get:53 http://mirrors.aliyun.com trusty-backports/main Translation-en [7,493 B]
	==> app-01: Get:54 http://mirrors.aliyun.com trusty-backports/multiverse Translation-en [1,215 B]
	==> app-01: Get:55 http://mirrors.aliyun.com trusty-backports/restricted Translation-en [28 B]
	==> app-01: Get:56 http://mirrors.aliyun.com trusty-backports/universe Translation-en [36.8 kB]
	==> app-01: Get:57 http://mirrors.aliyun.com trusty Release [58.5 kB]
	==> app-01: Get:58 http://mirrors.aliyun.com trusty/main Sources [1,064 kB]
	==> app-01: Get:59 http://mirrors.aliyun.com trusty/restricted Sources [5,433 B]
	==> app-01: Get:60 http://mirrors.aliyun.com trusty/universe Sources [6,399 kB]
	==> app-01: Get:61 http://mirrors.aliyun.com trusty/multiverse Sources [174 kB]
	==> app-01: Get:62 http://mirrors.aliyun.com trusty/main amd64 Packages [1,350 kB]
	==> app-01: Get:63 http://mirrors.aliyun.com trusty/restricted amd64 Packages [13.0 kB]
	==> app-01: Get:64 http://mirrors.aliyun.com trusty/universe amd64 Packages [5,859 kB]
	==> app-01: Get:65 http://mirrors.aliyun.com trusty/multiverse amd64 Packages [132 kB]
	==> app-01: Get:66 http://mirrors.aliyun.com trusty/main Translation-en [762 kB]
	==> app-01: Get:67 http://mirrors.aliyun.com trusty/multiverse Translation-en [102 kB]
	==> app-01: Get:68 http://mirrors.aliyun.com trusty/restricted Translation-en [3,457 B]
	==> app-01: Get:69 http://mirrors.aliyun.com trusty/universe Translation-en [4,089 kB]
	==> app-01: Ign http://mirrors.aliyun.com trusty/main Translation-en_US
	==> app-01: Ign http://mirrors.aliyun.com trusty/multiverse Translation-en_US
	==> app-01: Ign http://mirrors.aliyun.com trusty/restricted Translation-en_US
	==> app-01: Ign http://mirrors.aliyun.com trusty/universe Translation-en_US
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
	==> app-01: Get:1 http://mirrors.aliyun.com/ubuntu/ trusty-security/main libnettle4 amd64 2.7.1-1ubuntu0.1 [102 kB]
	==> app-01: Get:2 http://mirrors.aliyun.com/ubuntu/ trusty-security/main libhogweed2 amd64 2.7.1-1ubuntu0.1 [124 kB]
	==> app-01: Get:3 http://ppa.launchpad.net/openconnect/daily/ubuntu/ trusty/main libopenconnect5 amd64 7.06-0~2492~ubuntu14.04.1 [105 kB]
	==> app-01: Get:4 http://mirrors.aliyun.com/ubuntu/ trusty-security/universe libgnutls28 amd64 3.2.11-2ubuntu1.1 [540 kB]
	==> app-01: Get:5 http://ppa.launchpad.net/openconnect/daily/ubuntu/ trusty/main openconnect amd64 7.06-0~2492~ubuntu14.04.1 [418 kB]
	==> app-01: Get:6 http://mirrors.aliyun.com/ubuntu/ trusty/main libproxy1 amd64 0.4.11-0ubuntu4 [56.2 kB]
	==> app-01: Get:7 http://mirrors.aliyun.com/ubuntu/ trusty/main libtommath0 amd64 0.42.0-1build1 [55.6 kB]
	==> app-01: Get:8 http://mirrors.aliyun.com/ubuntu/ trusty/universe libtomcrypt0 amd64 1.17-5 [272 kB]
	==> app-01: Get:9 http://mirrors.aliyun.com/ubuntu/ trusty/universe libstoken1 amd64 0.2-1 [13.0 kB]
	==> app-01: Get:10 http://mirrors.aliyun.com/ubuntu/ trusty-updates/main iproute all 1:3.12.0-2ubuntu1 [2,392 B]
	==> app-01: Get:11 http://mirrors.aliyun.com/ubuntu/ trusty/universe vpnc-scripts all 0.1~git20120602-2 [12.2 kB]
	==> app-01: dpkg-preconfigure: unable to re-open stdin: No such file or directory
	==> app-01: Fetched 1,700 kB in 2s (717 kB/s)
	==> app-01: Selecting previously unselected package libnettle4:amd64.
	==> app-01: (Reading database ... 62997 files and directories currently installed.)
	==> app-01: Preparing to unpack .../libnettle4_2.7.1-1ubuntu0.1_amd64.deb ...
	==> app-01: Unpacking libnettle4:amd64 (2.7.1-1ubuntu0.1) ...
	==> app-01: Selecting previously unselected package libhogweed2:amd64.
	==> app-01: Preparing to unpack .../libhogweed2_2.7.1-1ubuntu0.1_amd64.deb ...
	==> app-01: Unpacking libhogweed2:amd64 (2.7.1-1ubuntu0.1) ...
	==> app-01: Selecting previously unselected package libgnutls28:amd64.
	==> app-01: Preparing to unpack .../libgnutls28_3.2.11-2ubuntu1.1_amd64.deb ...
	==> app-01: Unpacking libgnutls28:amd64 (3.2.11-2ubuntu1.1) ...
	==> app-01: Selecting previously unselected package libproxy1:amd64.
	==> app-01: Preparing to unpack .../libproxy1_0.4.11-0ubuntu4_amd64.deb ...
	==> app-01: Unpacking libproxy1:amd64 (0.4.11-0ubuntu4) ...
	==> app-01: Selecting previously unselected package libtommath0.
	==> app-01: Preparing to unpack .../libtommath0_0.42.0-1build1_amd64.deb ...
	==> app-01: Unpacking libtommath0 (0.42.0-1build1) ...
	==> app-01: Selecting previously unselected package libtomcrypt0:amd64.
	==> app-01: Preparing to unpack .../libtomcrypt0_1.17-5_amd64.deb ...
	==> app-01: Unpacking libtomcrypt0:amd64 (1.17-5) ...
	==> app-01: Selecting previously unselected package libstoken1:amd64.
	==> app-01: Preparing to unpack .../libstoken1_0.2-1_amd64.deb ...
	==> app-01: Unpacking libstoken1:amd64 (0.2-1) ...
	==> app-01: Selecting previously unselected package libopenconnect5:amd64.
	==> app-01: Preparing to unpack .../libopenconnect5_7.06-0~2492~ubuntu14.04.1_amd64.deb ...
	==> app-01: Unpacking libopenconnect5:amd64 (7.06-0~2492~ubuntu14.04.1) ...
	==> app-01: Selecting previously unselected package iproute.
	==> app-01: Preparing to unpack .../iproute_1%3a3.12.0-2ubuntu1_all.deb ...
	==> app-01: Unpacking iproute (1:3.12.0-2ubuntu1) ...
	==> app-01: Selecting previously unselected package vpnc-scripts.
	==> app-01: Preparing to unpack .../vpnc-scripts_0.1~git20120602-2_all.deb ...
	==> app-01: Unpacking vpnc-scripts (0.1~git20120602-2) ...
	==> app-01: Selecting previously unselected package openconnect.
	==> app-01: Preparing to unpack .../openconnect_7.06-0~2492~ubuntu14.04.1_amd64.deb ...
	==> app-01: Unpacking openconnect (7.06-0~2492~ubuntu14.04.1) ...
	==> app-01: Processing triggers for man-db (2.6.7.1-1ubuntu1) ...
	==> app-01: Setting up libnettle4:amd64 (2.7.1-1ubuntu0.1) ...
	==> app-01: Setting up libhogweed2:amd64 (2.7.1-1ubuntu0.1) ...
	==> app-01: Setting up libgnutls28:amd64 (3.2.11-2ubuntu1.1) ...
	==> app-01: Setting up libproxy1:amd64 (0.4.11-0ubuntu4) ...
	==> app-01: Setting up libtommath0 (0.42.0-1build1) ...
	==> app-01: Setting up libtomcrypt0:amd64 (1.17-5) ...
	==> app-01: Setting up libstoken1:amd64 (0.2-1) ...
	==> app-01: Setting up libopenconnect5:amd64 (7.06-0~2492~ubuntu14.04.1) ...
	==> app-01: Setting up iproute (1:3.12.0-2ubuntu1) ...
	==> app-01: Setting up vpnc-scripts (0.1~git20120602-2) ...
	==> app-01: Setting up openconnect (7.06-0~2492~ubuntu14.04.1) ...
	==> app-01: Processing triggers for libc-bin (2.19-0ubuntu6.9) ...
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
	==> app-01: kubernetes/third_party/
	==> app-01: kubernetes/third_party/htpasswd/
	==> app-01: kubernetes/third_party/htpasswd/htpasswd.py
	==> app-01: kubernetes/third_party/htpasswd/COPYING
	==> app-01: kubernetes/README.md
	==> app-01: kubernetes/docs/
	==> app-01: kubernetes/docs/api-reference/
	==> app-01: kubernetes/docs/api-reference/policy/
	==> app-01: kubernetes/docs/api-reference/policy/v1alpha1/
	==> app-01: kubernetes/docs/api-reference/policy/v1alpha1/operations.html
	==> app-01: kubernetes/docs/api-reference/policy/v1alpha1/definitions.html
	==> app-01: kubernetes/docs/api-reference/README.md
	==> app-01: kubernetes/docs/api-reference/v1/
	==> app-01: kubernetes/docs/api-reference/v1/operations.html
	==> app-01: kubernetes/docs/api-reference/v1/definitions.md
	==> app-01: kubernetes/docs/api-reference/v1/operations.md
	==> app-01: kubernetes/docs/api-reference/v1/definitions.html
	==> app-01: kubernetes/docs/api-reference/authorization.k8s.io/
	==> app-01: kubernetes/docs/api-reference/authorization.k8s.io/v1beta1/
	==> app-01: kubernetes/docs/api-reference/authorization.k8s.io/v1beta1/operations.html
	==> app-01: kubernetes/docs/api-reference/authorization.k8s.io/v1beta1/definitions.html
	==> app-01: kubernetes/docs/api-reference/labels-annotations-taints.md
	==> app-01: kubernetes/docs/api-reference/autoscaling/
	==> app-01: kubernetes/docs/api-reference/autoscaling/v1/
	==> app-01: kubernetes/docs/api-reference/autoscaling/v1/operations.html
	==> app-01: kubernetes/docs/api-reference/autoscaling/v1/definitions.html
	==> app-01: kubernetes/docs/api-reference/rbac.authorization.k8s.io/
	==> app-01: kubernetes/docs/api-reference/rbac.authorization.k8s.io/v1alpha1/
	==> app-01: kubernetes/docs/api-reference/rbac.authorization.k8s.io/v1alpha1/operations.html
	==> app-01: kubernetes/docs/api-reference/rbac.authorization.k8s.io/v1alpha1/definitions.html
	==> app-01: kubernetes/docs/api-reference/certificates.k8s.io/
	==> app-01: kubernetes/docs/api-reference/certificates.k8s.io/v1alpha1/
	==> app-01: kubernetes/docs/api-reference/certificates.k8s.io/v1alpha1/operations.html
	==> app-01: kubernetes/docs/api-reference/certificates.k8s.io/v1alpha1/definitions.html
	==> app-01: kubernetes/docs/api-reference/authentication.k8s.io/
	==> app-01: kubernetes/docs/api-reference/authentication.k8s.io/v1beta1/
	==> app-01: kubernetes/docs/api-reference/authentication.k8s.io/v1beta1/operations.html
	==> app-01: kubernetes/docs/api-reference/authentication.k8s.io/v1beta1/definitions.html
	==> app-01: kubernetes/docs/api-reference/apps/
	==> app-01: kubernetes/docs/api-reference/apps/v1alpha1/
	==> app-01: kubernetes/docs/api-reference/apps/v1alpha1/operations.html
	==> app-01: kubernetes/docs/api-reference/apps/v1alpha1/definitions.html
	==> app-01: kubernetes/docs/api-reference/extensions/
	==> app-01: kubernetes/docs/api-reference/extensions/v1beta1/
	==> app-01: kubernetes/docs/api-reference/extensions/v1beta1/operations.html
	==> app-01: kubernetes/docs/api-reference/extensions/v1beta1/definitions.md
	==> app-01: kubernetes/docs/api-reference/extensions/v1beta1/operations.md
	==> app-01: kubernetes/docs/api-reference/extensions/v1beta1/definitions.html
	==> app-01: kubernetes/docs/api-reference/batch/
	==> app-01: kubernetes/docs/api-reference/batch/v1/
	==> app-01: kubernetes/docs/api-reference/batch/v1/operations.html
	==> app-01: kubernetes/docs/api-reference/batch/v1/definitions.html
	==> app-01: kubernetes/docs/api-reference/batch/v2alpha1/
	==> app-01: kubernetes/docs/api-reference/batch/v2alpha1/operations.html
	==> app-01: kubernetes/docs/api-reference/batch/v2alpha1/definitions.html
	==> app-01: kubernetes/docs/api-reference/storage.k8s.io/
	==> app-01: kubernetes/docs/api-reference/storage.k8s.io/v1beta1/
	==> app-01: kubernetes/docs/api-reference/storage.k8s.io/v1beta1/operations.html
	==> app-01: kubernetes/docs/api-reference/storage.k8s.io/v1beta1/definitions.html
	==> app-01: kubernetes/docs/getting-started-guides/
	==> app-01: kubernetes/docs/getting-started-guides/mesos.md
	==> app-01: kubernetes/docs/getting-started-guides/scratch.md
	==> app-01: kubernetes/docs/getting-started-guides/dcos.md
	==> app-01: kubernetes/docs/getting-started-guides/libvirt-coreos.md
	==> app-01: kubernetes/docs/getting-started-guides/README.md
	==> app-01: kubernetes/docs/getting-started-guides/azure.md
	==> app-01: kubernetes/docs/getting-started-guides/ubuntu-calico.md
	==> app-01: kubernetes/docs/getting-started-guides/aws.md
	==> app-01: kubernetes/docs/getting-started-guides/gce.md
	==> app-01: kubernetes/docs/getting-started-guides/coreos/
	==> app-01: kubernetes/docs/getting-started-guides/coreos/coreos_multinode_cluster.md
	==> app-01: kubernetes/docs/getting-started-guides/coreos/bare_metal_offline.md
	==> app-01: kubernetes/docs/getting-started-guides/coreos/bare_metal_calico.md
	==> app-01: kubernetes/docs/getting-started-guides/coreos/azure/
	==> app-01: kubernetes/docs/getting-started-guides/coreos/azure/README.md
	==> app-01: kubernetes/docs/getting-started-guides/centos/
	==> app-01: kubernetes/docs/getting-started-guides/centos/centos_manual_config.md
	==> app-01: kubernetes/docs/getting-started-guides/docker.md
	==> app-01: kubernetes/docs/getting-started-guides/docker-multinode.md
	==> app-01: kubernetes/docs/getting-started-guides/coreos.md
	==> app-01: kubernetes/docs/getting-started-guides/ovirt.md
	==> app-01: kubernetes/docs/getting-started-guides/juju.md
	==> app-01: kubernetes/docs/getting-started-guides/rackspace.md
	==> app-01: kubernetes/docs/getting-started-guides/rkt/
	==> app-01: kubernetes/docs/getting-started-guides/rkt/README.md
	==> app-01: kubernetes/docs/getting-started-guides/rkt/notes.md
	==> app-01: kubernetes/docs/getting-started-guides/ubuntu.md
	==> app-01: kubernetes/docs/getting-started-guides/cloudstack.md
	==> app-01: kubernetes/docs/getting-started-guides/mesos-docker.md
	==> app-01: kubernetes/docs/getting-started-guides/vsphere.md
	==> app-01: kubernetes/docs/getting-started-guides/logging.md
	==> app-01: kubernetes/docs/getting-started-guides/logging-elasticsearch.md
	==> app-01: kubernetes/docs/getting-started-guides/binary_release.md
	==> app-01: kubernetes/docs/getting-started-guides/fedora/
	==> app-01: kubernetes/docs/getting-started-guides/fedora/fedora_ansible_config.md
	==> app-01: kubernetes/docs/getting-started-guides/fedora/fedora_manual_config.md
	==> app-01: kubernetes/docs/getting-started-guides/fedora/flannel_multi_node_cluster.md
	==> app-01: kubernetes/docs/README.md
	==> app-01: kubernetes/docs/design/
	==> app-01: kubernetes/docs/design/admission_control_resource_quota.md
	==> app-01: kubernetes/docs/design/ubernetes-design.png
	==> app-01: kubernetes/docs/design/ubernetes-cluster-state.png
	==> app-01: kubernetes/docs/design/expansion.md
	==> app-01: kubernetes/docs/design/namespaces.md
	==> app-01: kubernetes/docs/design/clustering.md
	==> app-01: kubernetes/docs/design/resource-qos.md
	==> app-01: kubernetes/docs/design/taint-toleration-dedicated.md
	==> app-01: kubernetes/docs/design/indexed-job.md
	==> app-01: kubernetes/docs/design/principles.md
	==> app-01: kubernetes/docs/design/README.md
	==> app-01: kubernetes/docs/design/enhance-pluggable-policy.md
	==> app-01: kubernetes/docs/design/identifiers.md
	==> app-01: kubernetes/docs/design/admission_control_limit_range.md
	==> app-01: kubernetes/docs/design/security.md
	==> app-01: kubernetes/docs/design/simple-rolling-update.md
	==> app-01: kubernetes/docs/design/podaffinity.md
	==> app-01: kubernetes/docs/design/federation-phase-1.md
	==> app-01: kubernetes/docs/design/architecture.dia
	==> app-01: kubernetes/docs/design/versioning.md
	==> app-01: kubernetes/docs/design/resources.md
	==> app-01: kubernetes/docs/design/persistent-storage.md
	==> app-01: kubernetes/docs/design/event_compression.md
	==> app-01: kubernetes/docs/design/ubernetes-scheduling.png
	==> app-01: kubernetes/docs/design/volume-snapshotting.png
	==> app-01: kubernetes/docs/design/daemon.md
	==> app-01: kubernetes/docs/design/extending-api.md
	==> app-01: kubernetes/docs/design/architecture.md
	==> app-01: kubernetes/docs/design/secrets.md
	==> app-01: kubernetes/docs/design/command_execution_port_forwarding.md
	==> app-01: kubernetes/docs/design/networking.md
	==> app-01: kubernetes/docs/design/nodeaffinity.md
	==> app-01: kubernetes/docs/design/downward_api_resources_limits_requests.md
	==> app-01: kubernetes/docs/design/selector-generation.md
	==> app-01: kubernetes/docs/design/horizontal-pod-autoscaler.md
	==> app-01: kubernetes/docs/design/seccomp.md
	==> app-01: kubernetes/docs/design/clustering/
	==> app-01: kubernetes/docs/design/clustering/dynamic.png
	==> app-01: kubernetes/docs/design/clustering/README.md
	==> app-01: kubernetes/docs/design/clustering/dynamic.seqdiag
	==> app-01: kubernetes/docs/design/clustering/Dockerfile
	==> app-01: kubernetes/docs/design/clustering/.gitignore
	==> app-01: kubernetes/docs/design/clustering/static.seqdiag
	==> app-01: kubernetes/docs/design/clustering/static.png
	==> app-01: kubernetes/docs/design/clustering/Makefile
	==> app-01: kubernetes/docs/design/architecture.svg
	==> app-01: kubernetes/docs/design/control-plane-resilience.md
	==> app-01: kubernetes/docs/design/security_context.md
	==> app-01: kubernetes/docs/design/scheduler_extender.md
	==> app-01: kubernetes/docs/design/volume-snapshotting.md
	==> app-01: kubernetes/docs/design/metadata-policy.md
	==> app-01: kubernetes/docs/design/architecture.png
	==> app-01: kubernetes/docs/design/aws_under_the_hood.md
	==> app-01: kubernetes/docs/design/admission_control.md
	==> app-01: kubernetes/docs/design/federated-services.md
	==> app-01: kubernetes/docs/design/service_accounts.md
	==> app-01: kubernetes/docs/design/access.md
	==> app-01: kubernetes/docs/design/selinux.md
	==> app-01: kubernetes/docs/design/configmap.md
	==> app-01: kubernetes/docs/OWNERS
	==> app-01: kubernetes/docs/proposals/
	==> app-01: kubernetes/docs/proposals/kubectl-login.md
	==> app-01: kubernetes/docs/proposals/resource-quota-scoping.md
	==> app-01: kubernetes/docs/proposals/kubelet-systemd.md
	==> app-01: kubernetes/docs/proposals/protobuf.md
	==> app-01: kubernetes/docs/proposals/gpu-support.md
	==> app-01: kubernetes/docs/proposals/kubelet-hypercontainer-runtime.md
	==> app-01: kubernetes/docs/proposals/templates.md
	==> app-01: kubernetes/docs/proposals/multiple-schedulers.md
	==> app-01: kubernetes/docs/proposals/garbage-collection.md
	==> app-01: kubernetes/docs/proposals/runtimeconfig.md
	==> app-01: kubernetes/docs/proposals/controller-ref.md
	==> app-01: kubernetes/docs/proposals/pod-resource-management.md
	==> app-01: kubernetes/docs/proposals/pod-security-context.md
	==> app-01: kubernetes/docs/proposals/high-availability.md
	==> app-01: kubernetes/docs/proposals/volumes.md
	==> app-01: kubernetes/docs/proposals/local-cluster-ux.md
	==> app-01: kubernetes/docs/proposals/volume-selectors.md
	==> app-01: kubernetes/docs/proposals/rescheduling.md
	==> app-01: kubernetes/docs/proposals/scalability-testing.md
	==> app-01: kubernetes/docs/proposals/client-package-structure.md
	==> app-01: kubernetes/docs/proposals/apiserver-watch.md
	==> app-01: kubernetes/docs/proposals/custom-metrics.md
	==> app-01: kubernetes/docs/proposals/runtime-client-server.md
	==> app-01: kubernetes/docs/proposals/federated-api-servers.md
	==> app-01: kubernetes/docs/proposals/release-notes.md
	==> app-01: kubernetes/docs/proposals/service-discovery.md
	==> app-01: kubernetes/docs/proposals/external-lb-source-ip-preservation.md
	==> app-01: kubernetes/docs/proposals/job.md
	==> app-01: kubernetes/docs/proposals/federation-lite.md
	==> app-01: kubernetes/docs/proposals/volume-provisioning.md
	==> app-01: kubernetes/docs/proposals/deployment.md
	==> app-01: kubernetes/docs/proposals/pod-lifecycle-event-generator.md
	==> app-01: kubernetes/docs/proposals/resource-metrics-api.md
	==> app-01: kubernetes/docs/proposals/image-provenance.md
	==> app-01: kubernetes/docs/proposals/kubelet-eviction.md
	==> app-01: kubernetes/docs/proposals/node-allocatable.md
	==> app-01: kubernetes/docs/proposals/secret-configmap-downwarapi-file-mode.md
	==> app-01: kubernetes/docs/proposals/disk-accounting.md
	==> app-01: kubernetes/docs/proposals/rescheduler.md
	==> app-01: kubernetes/docs/proposals/rescheduling-for-critical-pods.md
	==> app-01: kubernetes/docs/proposals/metrics-plumbing.md
	==> app-01: kubernetes/docs/proposals/selinux-enhancements.md
	==> app-01: kubernetes/docs/proposals/initial-resources.md
	==> app-01: kubernetes/docs/proposals/container-runtime-interface-v1.md
	==> app-01: kubernetes/docs/proposals/security-context-constraints.md
	==> app-01: kubernetes/docs/proposals/node-allocatable.png
	==> app-01: kubernetes/docs/proposals/scheduledjob.md
	==> app-01: kubernetes/docs/proposals/performance-related-monitoring.md
	==> app-01: kubernetes/docs/proposals/pod-cache.png
	==> app-01: kubernetes/docs/proposals/network-policy.md
	==> app-01: kubernetes/docs/proposals/multi-platform.md
	==> app-01: kubernetes/docs/proposals/runtime-pod-cache.md
	==> app-01: kubernetes/docs/proposals/kubemark.md
	==> app-01: kubernetes/docs/proposals/flannel-integration.md
	==> app-01: kubernetes/docs/proposals/kubelet-auth.md
	==> app-01: kubernetes/docs/proposals/api-group.md
	==> app-01: kubernetes/docs/proposals/federation-high-level-arch.png
	==> app-01: kubernetes/docs/proposals/dramatically-simplify-cluster-creation.md
	==> app-01: kubernetes/docs/proposals/images/
	==> app-01: kubernetes/docs/proposals/images/.gitignore
	==> app-01: kubernetes/docs/proposals/cluster-deployment.md
	==> app-01: kubernetes/docs/proposals/apparmor.md
	==> app-01: kubernetes/docs/proposals/pleg.png
	==> app-01: kubernetes/docs/proposals/federation.md
	==> app-01: kubernetes/docs/proposals/kubelet-tls-bootstrap.md
	==> app-01: kubernetes/docs/proposals/Kubemark_architecture.png
	==> app-01: kubernetes/docs/proposals/container-init.md
	==> app-01: kubernetes/docs/proposals/service-external-name.md
	==> app-01: kubernetes/docs/proposals/deploy.md
	==> app-01: kubernetes/docs/proposals/volume-ownership-management.md
	==> app-01: kubernetes/docs/proposals/self-hosted-kubelet.md
	==> app-01: kubernetes/docs/user-guide/
	==> app-01: kubernetes/docs/user-guide/security-context.md
	==> app-01: kubernetes/docs/user-guide/namespaces.md
	==> app-01: kubernetes/docs/user-guide/debugging-services.md
	==> app-01: kubernetes/docs/user-guide/connecting-to-applications-port-forward.md
	==> app-01: kubernetes/docs/user-guide/ingress.md
	==> app-01: kubernetes/docs/user-guide/README.md
	==> app-01: kubernetes/docs/user-guide/accessing-the-cluster.md
	==> app-01: kubernetes/docs/user-guide/horizontal-pod-autoscaling/
	==> app-01: kubernetes/docs/user-guide/horizontal-pod-autoscaling/README.md
	==> app-01: kubernetes/docs/user-guide/identifiers.md
	==> app-01: kubernetes/docs/user-guide/simple-nginx.md
	==> app-01: kubernetes/docs/user-guide/images.md
	==> app-01: kubernetes/docs/user-guide/kubectl-overview.md
	==> app-01: kubernetes/docs/user-guide/volumes.md
	==> app-01: kubernetes/docs/user-guide/deployments.md
	==> app-01: kubernetes/docs/user-guide/persistent-volumes.md
	==> app-01: kubernetes/docs/user-guide/deploying-applications.md
	==> app-01: kubernetes/docs/user-guide/jobs.md
	==> app-01: kubernetes/docs/user-guide/node-selection/
	==> app-01: kubernetes/docs/user-guide/node-selection/README.md
	==> app-01: kubernetes/docs/user-guide/downward-api/
	==> app-01: kubernetes/docs/user-guide/downward-api/README.md
	==> app-01: kubernetes/docs/user-guide/downward-api/volume/
	==> app-01: kubernetes/docs/user-guide/downward-api/volume/README.md
	==> app-01: kubernetes/docs/user-guide/application-troubleshooting.md
	==> app-01: kubernetes/docs/user-guide/getting-into-containers.md
	==> app-01: kubernetes/docs/user-guide/config-best-practices.md
	==> app-01: kubernetes/docs/user-guide/kubeconfig-file.md
	==> app-01: kubernetes/docs/user-guide/containers.md
	==> app-01: kubernetes/docs/user-guide/introspection-and-debugging.md
	==> app-01: kubernetes/docs/user-guide/update-demo/
	==> app-01: kubernetes/docs/user-guide/update-demo/README.md
	==> app-01: kubernetes/docs/user-guide/resourcequota/
	==> app-01: kubernetes/docs/user-guide/resourcequota/README.md
	==> app-01: kubernetes/docs/user-guide/configmap/
	==> app-01: kubernetes/docs/user-guide/configmap/README.md
	==> app-01: kubernetes/docs/user-guide/compute-resources.md
	==> app-01: kubernetes/docs/user-guide/ui.md
	==> app-01: kubernetes/docs/user-guide/labels.md
	==> app-01: kubernetes/docs/user-guide/environment-guide/
	==> app-01: kubernetes/docs/user-guide/environment-guide/README.md
	==> app-01: kubernetes/docs/user-guide/environment-guide/containers/
	==> app-01: kubernetes/docs/user-guide/environment-guide/containers/README.md
	==> app-01: kubernetes/docs/user-guide/container-environment.md
	==> app-01: kubernetes/docs/user-guide/production-pods.md
	==> app-01: kubernetes/docs/user-guide/liveness/
	==> app-01: kubernetes/docs/user-guide/liveness/README.md
	==> app-01: kubernetes/docs/user-guide/downward-api.md
	==> app-01: kubernetes/docs/user-guide/services-firewalls.md
	==> app-01: kubernetes/docs/user-guide/sharing-clusters.md
	==> app-01: kubernetes/docs/user-guide/docker-cli-to-kubectl.md
	==> app-01: kubernetes/docs/user-guide/configuring-containers.md
	==> app-01: kubernetes/docs/user-guide/working-with-resources.md
	==> app-01: kubernetes/docs/user-guide/simple-yaml.md
	==> app-01: kubernetes/docs/user-guide/logging-demo/
	==> app-01: kubernetes/docs/user-guide/logging-demo/README.md
	==> app-01: kubernetes/docs/user-guide/connecting-applications.md
	==> app-01: kubernetes/docs/user-guide/jsonpath.md
	==> app-01: kubernetes/docs/user-guide/secrets.md
	==> app-01: kubernetes/docs/user-guide/connecting-to-applications-proxy.md
	==> app-01: kubernetes/docs/user-guide/pods.md
	==> app-01: kubernetes/docs/user-guide/persistent-volumes/
	==> app-01: kubernetes/docs/user-guide/persistent-volumes/README.md
	==> app-01: kubernetes/docs/user-guide/kubectl-cheatsheet.md
	==> app-01: kubernetes/docs/user-guide/replication-controller.md
	==> app-01: kubernetes/docs/user-guide/services.md
	==> app-01: kubernetes/docs/user-guide/managing-deployments.md
	==> app-01: kubernetes/docs/user-guide/horizontal-pod-autoscaler.md
	==> app-01: kubernetes/docs/user-guide/secrets/
	==> app-01: kubernetes/docs/user-guide/secrets/README.md
	==> app-01: kubernetes/docs/user-guide/walkthrough/
	==> app-01: kubernetes/docs/user-guide/walkthrough/README.md
	==> app-01: kubernetes/docs/user-guide/walkthrough/k8s201.md
	==> app-01: kubernetes/docs/user-guide/monitoring.md
	==> app-01: kubernetes/docs/user-guide/logging.md
	==> app-01: kubernetes/docs/user-guide/overview.md
	==> app-01: kubernetes/docs/user-guide/pod-states.md
	==> app-01: kubernetes/docs/user-guide/annotations.md
	==> app-01: kubernetes/docs/user-guide/prereqs.md
	==> app-01: kubernetes/docs/user-guide/kubectl/
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_create_quota.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_version.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_rolling-update.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_exec.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_create_service_nodeport.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_rollout_pause.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_top_pod.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_get.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_config_set-cluster.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_config_unset.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_create_namespace.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_replace.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_create_serviceaccount.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_create_deployment.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_create_secret_docker-registry.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_create_service.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_logs.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_expose.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_config_delete-cluster.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_cordon.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_create_secret_tls.md
	==> app-01: kubernetes/docs/user-guide/kubectl/.files_generated
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_taint.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_rollout_resume.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_delete.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_top-node.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_explain.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_cluster-info_dump.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_rollout_history.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_edit.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_apply.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_run.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_rollout_status.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_annotate.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_set.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_set_image.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_top-pod.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_create_secret.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_config_get-contexts.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_create_configmap.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_create_secret_generic.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_rollout.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_config_set-credentials.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_config_view.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_port-forward.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_config_set-context.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_drain.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_rollout_undo.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_top.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_create_service_clusterip.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_describe.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_attach.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_label.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_cluster-info.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_options.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_config.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_completion.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_create_service_loadbalancer.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_top_node.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_config_get-clusters.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_convert.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_autoscale.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_scale.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_api-versions.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_config_delete-context.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_stop.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_create.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_config_current-context.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_uncordon.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_patch.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_config_use-context.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_config_set.md
	==> app-01: kubernetes/docs/user-guide/kubectl/kubectl_proxy.md
	==> app-01: kubernetes/docs/user-guide/quick-start.md
	==> app-01: kubernetes/docs/user-guide/known-issues.md
	==> app-01: kubernetes/docs/user-guide/pod-templates.md
	==> app-01: kubernetes/docs/user-guide/service-accounts.md
	==> app-01: kubernetes/docs/user-guide/configmap.md
	==> app-01: kubernetes/docs/warning.png
	==> app-01: kubernetes/docs/admin/
	==> app-01: kubernetes/docs/admin/network-plugins.md
	==> app-01: kubernetes/docs/admin/limitrange/
	==> app-01: kubernetes/docs/admin/limitrange/README.md
	==> app-01: kubernetes/docs/admin/dns.md
	==> app-01: kubernetes/docs/admin/federation-controller-manager.md
	==> app-01: kubernetes/docs/admin/kube-scheduler.md
	==> app-01: kubernetes/docs/admin/namespaces.md
	==> app-01: kubernetes/docs/admin/garbage-collection.md
	==> app-01: kubernetes/docs/admin/README.md
	==> app-01: kubernetes/docs/admin/introduction.md
	==> app-01: kubernetes/docs/admin/high-availability.md
	==> app-01: kubernetes/docs/admin/daemons.md
	==> app-01: kubernetes/docs/admin/master-node-communication.md
	==> app-01: kubernetes/docs/admin/kubelet.md
	==> app-01: kubernetes/docs/admin/federation-apiserver.md
	==> app-01: kubernetes/docs/admin/ovs-networking.md
	==> app-01: kubernetes/docs/admin/resourcequota/
	==> app-01: kubernetes/docs/admin/resourcequota/README.md
	==> app-01: kubernetes/docs/admin/cluster-management.md
	==> app-01: kubernetes/docs/admin/etcd.md
	==> app-01: kubernetes/docs/admin/accessing-the-api.md
	==> app-01: kubernetes/docs/admin/salt.md
	==> app-01: kubernetes/docs/admin/authentication.md
	==> app-01: kubernetes/docs/admin/cluster-troubleshooting.md
	==> app-01: kubernetes/docs/admin/static-pods.md
	==> app-01: kubernetes/docs/admin/service-accounts-admin.md
	==> app-01: kubernetes/docs/admin/cluster-components.md
	==> app-01: kubernetes/docs/admin/multi-cluster.md
	==> app-01: kubernetes/docs/admin/cluster-large.md
	==> app-01: kubernetes/docs/admin/admission-controllers.md
	==> app-01: kubernetes/docs/admin/networking.md
	==> app-01: kubernetes/docs/admin/kube-proxy.md
	==> app-01: kubernetes/docs/admin/kube-controller-manager.md
	==> app-01: kubernetes/docs/admin/namespaces/
	==> app-01: kubernetes/docs/admin/namespaces/README.md
	==> app-01: kubernetes/docs/admin/kube-apiserver.md
	==> app-01: kubernetes/docs/admin/node.md
	==> app-01: kubernetes/docs/admin/authorization.md
	==> app-01: kubernetes/docs/admin/resource-quota.md
	==> app-01: kubernetes/docs/reporting-security-issues.md
	==> app-01: kubernetes/docs/whatisk8s.md
	==> app-01: kubernetes/docs/devel/
	==> app-01: kubernetes/docs/devel/development.md
	==> app-01: kubernetes/docs/devel/instrumentation.md
	==> app-01: kubernetes/docs/devel/pr_workflow.png
	==> app-01: kubernetes/docs/devel/local-cluster/
	==> app-01: kubernetes/docs/devel/local-cluster/vagrant.md
	==> app-01: kubernetes/docs/devel/local-cluster/local.md
	==> app-01: kubernetes/docs/devel/local-cluster/docker.md
	==> app-01: kubernetes/docs/devel/local-cluster/k8s-singlenode-docker.png
	==> app-01: kubernetes/docs/devel/coding-conventions.md
	==> app-01: kubernetes/docs/devel/flaky-tests.md
	==> app-01: kubernetes/docs/devel/README.md
	==> app-01: kubernetes/docs/devel/running-locally.md
	==> app-01: kubernetes/docs/devel/testing.md
	==> app-01: kubernetes/docs/devel/owners.md
	==> app-01: kubernetes/docs/devel/writing-good-e2e-tests.md
	==> app-01: kubernetes/docs/devel/community-expectations.md
	==> app-01: kubernetes/docs/devel/adding-an-APIGroup.md
	==> app-01: kubernetes/docs/devel/gubernator-images/
	==> app-01: kubernetes/docs/devel/gubernator-images/testfailures.png
	==> app-01: kubernetes/docs/devel/gubernator-images/filterpage.png
	==> app-01: kubernetes/docs/devel/gubernator-images/skipping2.png
	==> app-01: kubernetes/docs/devel/gubernator-images/filterpage3.png
	==> app-01: kubernetes/docs/devel/gubernator-images/filterpage2.png
	==> app-01: kubernetes/docs/devel/gubernator-images/filterpage1.png
	==> app-01: kubernetes/docs/devel/gubernator-images/skipping1.png
	==> app-01: kubernetes/docs/devel/e2e-node-tests.md
	==> app-01: kubernetes/docs/devel/on-call-rotations.md
	==> app-01: kubernetes/docs/devel/profiling.md
	==> app-01: kubernetes/docs/devel/issues.md
	==> app-01: kubernetes/docs/devel/client-libraries.md
	==> app-01: kubernetes/docs/devel/on-call-user-support.md
	==> app-01: kubernetes/docs/devel/node-performance-testing.md
	==> app-01: kubernetes/docs/devel/automation.md
	==> app-01: kubernetes/docs/devel/developer-guides/
	==> app-01: kubernetes/docs/devel/developer-guides/vagrant.md
	==> app-01: kubernetes/docs/devel/go-code.md
	==> app-01: kubernetes/docs/devel/kubectl-conventions.md
	==> app-01: kubernetes/docs/devel/godep.md
	==> app-01: kubernetes/docs/devel/api-conventions.md
	==> app-01: kubernetes/docs/devel/getting-builds.md
	==> app-01: kubernetes/docs/devel/mesos-style.md
	==> app-01: kubernetes/docs/devel/collab.md
	==> app-01: kubernetes/docs/devel/kubemark-guide.md
	==> app-01: kubernetes/docs/devel/cherry-picks.md
	==> app-01: kubernetes/docs/devel/gubernator.md
	==> app-01: kubernetes/docs/devel/pr_workflow.dia
	==> app-01: kubernetes/docs/devel/faster_reviews.md
	==> app-01: kubernetes/docs/devel/update-release-docs.md
	==> app-01: kubernetes/docs/devel/e2e-tests.md
	==> app-01: kubernetes/docs/devel/api_changes.md
	==> app-01: kubernetes/docs/devel/cli-roadmap.md
	==> app-01: kubernetes/docs/devel/generating-clientset.md
	==> app-01: kubernetes/docs/devel/pull-requests.md
	==> app-01: kubernetes/docs/devel/logging.md
	==> app-01: kubernetes/docs/devel/git_workflow.png
	==> app-01: kubernetes/docs/devel/writing-a-getting-started-guide.md
	==> app-01: kubernetes/docs/devel/scheduler_algorithm.md
	==> app-01: kubernetes/docs/devel/updating-docs-for-feature-changes.md
	==> app-01: kubernetes/docs/devel/on-call-build-cop.md
	==> app-01: kubernetes/docs/devel/scheduler.md
	==> app-01: kubernetes/docs/devel/how-to-doc.md
	==> app-01: kubernetes/docs/images/
	==> app-01: kubernetes/docs/images/newgui.png
	==> app-01: kubernetes/docs/yaml/
	==> app-01: kubernetes/docs/yaml/kubectl/
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_completion.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_scale.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_top-node.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_api-versions.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_taint.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_version.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_apply.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_exec.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_delete.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_autoscale.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_port-forward.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_edit.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_options.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_create.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_top-pod.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_cordon.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_stop.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_attach.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_expose.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_proxy.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_config.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_annotate.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_drain.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_explain.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_describe.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_cluster-info.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_patch.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_logs.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_rolling-update.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_convert.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_run.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_label.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_replace.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_rollout.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_top.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_uncordon.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_set.yaml
	==> app-01: kubernetes/docs/yaml/kubectl/kubectl_get.yaml
	==> app-01: kubernetes/docs/roadmap.md
	==> app-01: kubernetes/docs/man/
	==> app-01: kubernetes/docs/man/man1/
	==> app-01: kubernetes/docs/man/man1/kubectl.1
	==> app-01: kubernetes/docs/man/man1/kubectl-config-view.1
	==> app-01: kubernetes/docs/man/man1/kube-scheduler.1
	==> app-01: kubernetes/docs/man/man1/kubectl-expose.1
	==> app-01: kubernetes/docs/man/man1/kubectl-create-service-nodeport.1
	==> app-01: kubernetes/docs/man/man1/kubectl-edit.1
	==> app-01: kubernetes/docs/man/man1/kubectl-config-get-contexts.1
	==> app-01: kubernetes/docs/man/man1/kubectl-autoscale.1
	==> app-01: kubernetes/docs/man/man1/kubectl-get.1
	==> app-01: kubernetes/docs/man/man1/kubectl-create-service.1
	==> app-01: kubernetes/docs/man/man1/kubectl-create-configmap.1
	==> app-01: kubernetes/docs/man/man1/kubectl-describe.1
	==> app-01: kubernetes/docs/man/man1/kubectl-config.1
	==> app-01: kubernetes/docs/man/man1/kubectl-proxy.1
	==> app-01: kubernetes/docs/man/man1/kube-controller-manager.1
	==> app-01: kubernetes/docs/man/man1/kubectl-config-current-context.1
	==> app-01: kubernetes/docs/man/man1/kubectl-create-service-clusterip.1
	==> app-01: kubernetes/docs/man/man1/kubectl-create-serviceaccount.1
	==> app-01: kubernetes/docs/man/man1/kubectl-uncordon.1
	==> app-01: kubernetes/docs/man/man1/kubectl-rollout-history.1
	==> app-01: kubernetes/docs/man/man1/kubectl-config-set-credentials.1
	==> app-01: kubernetes/docs/man/man1/.files_generated
	==> app-01: kubernetes/docs/man/man1/kubectl-config-set-context.1
	==> app-01: kubernetes/docs/man/man1/kubectl-patch.1
	==> app-01: kubernetes/docs/man/man1/kubectl-create.1
	==> app-01: kubernetes/docs/man/man1/kubectl-exec.1
	==> app-01: kubernetes/docs/man/man1/kubectl-config-use-context.1
	==> app-01: kubernetes/docs/man/man1/kubelet.1
	==> app-01: kubernetes/docs/man/man1/kubectl-label.1
	==> app-01: kubernetes/docs/man/man1/kubectl-scale.1
	==> app-01: kubernetes/docs/man/man1/kubectl-delete.1
	==> app-01: kubernetes/docs/man/man1/kubectl-cluster-info.1
	==> app-01: kubernetes/docs/man/man1/kubectl-options.1
	==> app-01: kubernetes/docs/man/man1/kubectl-set-image.1
	==> app-01: kubernetes/docs/man/man1/kubectl-replace.1
	==> app-01: kubernetes/docs/man/man1/kubectl-create-service-loadbalancer.1
	==> app-01: kubernetes/docs/man/man1/kubectl-rollout-pause.1
	==> app-01: kubernetes/docs/man/man1/kubectl-config-get-clusters.1
	==> app-01: kubernetes/docs/man/man1/kubectl-taint.1
	==> app-01: kubernetes/docs/man/man1/kubectl-config-delete-cluster.1
	==> app-01: kubernetes/docs/man/man1/kubectl-create-secret-generic.1
	==> app-01: kubernetes/docs/man/man1/kubectl-config-set.1
	==> app-01: kubernetes/docs/man/man1/kubectl-version.1
	==> app-01: kubernetes/docs/man/man1/kubectl-explain.1
	==> app-01: kubernetes/docs/man/man1/kubectl-create-secret-docker-registry.1
	==> app-01: kubernetes/docs/man/man1/kubectl-apply.1
	==> app-01: kubernetes/docs/man/man1/kube-proxy.1
	==> app-01: kubernetes/docs/man/man1/kubectl-create-secret-tls.1
	==> app-01: kubernetes/docs/man/man1/kubectl-cluster-info-dump.1
	==> app-01: kubernetes/docs/man/man1/kubectl-api-versions.1
	==> app-01: kubernetes/docs/man/man1/kubectl-stop.1
	==> app-01: kubernetes/docs/man/man1/kubectl-config-unset.1
	==> app-01: kubernetes/docs/man/man1/kubectl-rollout-resume.1
	==> app-01: kubernetes/docs/man/man1/kube-apiserver.1
	==> app-01: kubernetes/docs/man/man1/kubectl-rollout.1
	==> app-01: kubernetes/docs/man/man1/kubectl-rolling-update.1
	==> app-01: kubernetes/docs/man/man1/kubectl-attach.1
	==> app-01: kubernetes/docs/man/man1/kubectl-rollout-status.1
	==> app-01: kubernetes/docs/man/man1/kubectl-cordon.1
	==> app-01: kubernetes/docs/man/man1/kubectl-config-delete-context.1
	==> app-01: kubernetes/docs/man/man1/kubectl-rollout-undo.1
	==> app-01: kubernetes/docs/man/man1/kubectl-create-quota.1
	==> app-01: kubernetes/docs/man/man1/kubectl-run.1
	==> app-01: kubernetes/docs/man/man1/kubectl-annotate.1
	==> app-01: kubernetes/docs/man/man1/kubectl-convert.1
	==> app-01: kubernetes/docs/man/man1/kubectl-top.1
	==> app-01: kubernetes/docs/man/man1/kubectl-logs.1
	==> app-01: kubernetes/docs/man/man1/kubectl-create-namespace.1
	==> app-01: kubernetes/docs/man/man1/kubectl-create-secret.1
	==> app-01: kubernetes/docs/man/man1/kubectl-create-deployment.1
	==> app-01: kubernetes/docs/man/man1/kubectl-set.1
	==> app-01: kubernetes/docs/man/man1/kubectl-completion.1
	==> app-01: kubernetes/docs/man/man1/kubectl-config-set-cluster.1
	==> app-01: kubernetes/docs/man/man1/kubectl-port-forward.1
	==> app-01: kubernetes/docs/man/man1/kubectl-drain.1
	==> app-01: kubernetes/docs/man/man1/kubectl-top-pod.1
	==> app-01: kubernetes/docs/man/man1/kubectl-top-node.1
	==> app-01: kubernetes/docs/api.md
	==> app-01: kubernetes/docs/troubleshooting.md
	==> app-01: kubernetes/cluster/
	==> app-01: kubernetes/cluster/aws/
	==> app-01: kubernetes/cluster/aws/templates/
	==> app-01: kubernetes/cluster/aws/templates/iam/
	==> app-01: kubernetes/cluster/aws/templates/iam/kubernetes-minion-policy.json
	==> app-01: kubernetes/cluster/aws/templates/iam/kubernetes-master-role.json
	==> app-01: kubernetes/cluster/aws/templates/iam/kubernetes-minion-role.json
	==> app-01: kubernetes/cluster/aws/templates/iam/kubernetes-master-policy.json
	==> app-01: kubernetes/cluster/aws/templates/configure-vm-aws.sh
	==> app-01: kubernetes/cluster/aws/templates/format-disks.sh
	==> app-01: kubernetes/cluster/aws/config-default.sh
	==> app-01: kubernetes/cluster/aws/wily/
	==> app-01: kubernetes/cluster/aws/wily/util.sh
	==> app-01: kubernetes/cluster/aws/util.sh
	==> app-01: kubernetes/cluster/aws/config-test.sh
	==> app-01: kubernetes/cluster/aws/common/
	==> app-01: kubernetes/cluster/aws/common/common.sh
	==> app-01: kubernetes/cluster/aws/options.md
	==> app-01: kubernetes/cluster/aws/jessie/
	==> app-01: kubernetes/cluster/aws/jessie/util.sh
	==> app-01: kubernetes/cluster/update-storage-objects.sh
	==> app-01: kubernetes/cluster/vsphere/
	==> app-01: kubernetes/cluster/vsphere/templates/
	==> app-01: kubernetes/cluster/vsphere/templates/salt-master.sh
	==> app-01: kubernetes/cluster/vsphere/templates/hostname.sh
	==> app-01: kubernetes/cluster/vsphere/templates/install-release.sh
	==> app-01: kubernetes/cluster/vsphere/templates/create-dynamic-salt-files.sh
	==> app-01: kubernetes/cluster/vsphere/templates/salt-minion.sh
	==> app-01: kubernetes/cluster/vsphere/config-common.sh
	==> app-01: kubernetes/cluster/vsphere/config-default.sh
	==> app-01: kubernetes/cluster/vsphere/util.sh
	==> app-01: kubernetes/cluster/vsphere/config-test.sh
	==> app-01: kubernetes/cluster/photon-controller/
	==> app-01: kubernetes/cluster/photon-controller/setup-prereq.sh
	==> app-01: kubernetes/cluster/photon-controller/templates/
	==> app-01: kubernetes/cluster/photon-controller/templates/salt-master.sh
	==> app-01: kubernetes/cluster/photon-controller/templates/hostname.sh
	==> app-01: kubernetes/cluster/photon-controller/templates/install-release.sh
	==> app-01: kubernetes/cluster/photon-controller/templates/README
	==> app-01: kubernetes/cluster/photon-controller/templates/create-dynamic-salt-files.sh
	==> app-01: kubernetes/cluster/photon-controller/templates/salt-minion.sh
	==> app-01: kubernetes/cluster/photon-controller/config-common.sh
	==> app-01: kubernetes/cluster/photon-controller/config-default.sh
	==> app-01: kubernetes/cluster/photon-controller/util.sh
	==> app-01: kubernetes/cluster/photon-controller/config-test.sh
	==> app-01: kubernetes/cluster/README.md
	==> app-01: kubernetes/cluster/gke/
	==> app-01: kubernetes/cluster/gke/config-common.sh
	==> app-01: kubernetes/cluster/gke/config-default.sh
	==> app-01: kubernetes/cluster/gke/make-it-stop.sh
	==> app-01: kubernetes/cluster/gke/util.sh
	==> app-01: kubernetes/cluster/gke/config-test.sh
	==> app-01: kubernetes/cluster/validate-cluster.sh
	==> app-01: kubernetes/cluster/get-kube-local.sh
	==> app-01: kubernetes/cluster/kubemark/
	==> app-01: kubernetes/cluster/kubemark/config-default.sh
	==> app-01: kubernetes/cluster/kubemark/util.sh
	==> app-01: kubernetes/cluster/OWNERS
	==> app-01: kubernetes/cluster/log-dump.sh
	==> app-01: kubernetes/cluster/test-network.sh
	==> app-01: kubernetes/cluster/openstack-heat/
	==> app-01: kubernetes/cluster/openstack-heat/config-default.sh
	==> app-01: kubernetes/cluster/openstack-heat/kubernetes-heat/
	==> app-01: kubernetes/cluster/openstack-heat/kubernetes-heat/kubeminion.yaml
	==> app-01: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/
	==> app-01: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/deploy-kube-auth-files-master.yaml
	==> app-01: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/provision-network-master.sh
	==> app-01: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/configure-proxy.sh
	==> app-01: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/write-heat-params.yaml
	==> app-01: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/configure-salt.yaml
	==> app-01: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/hostname-hack.sh
	==> app-01: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/kube-user.yaml
	==> app-01: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/provision-network-node.sh
	==> app-01: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/run-salt.sh
	==> app-01: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/hostname-hack.yaml
	==> app-01: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/deploy-kube-auth-files-node.yaml
	==> app-01: kubernetes/cluster/openstack-heat/kubernetes-heat/kubecluster.yaml
	==> app-01: kubernetes/cluster/openstack-heat/openrc-swift.sh
	==> app-01: kubernetes/cluster/openstack-heat/util.sh
	==> app-01: kubernetes/cluster/openstack-heat/config-test.sh
	==> app-01: kubernetes/cluster/openstack-heat/openrc-default.sh
	==> app-01: kubernetes/cluster/openstack-heat/config-image.sh
	==> app-01: kubernetes/cluster/kubectl.sh
	==> app-01: kubernetes/cluster/lib/
	==> app-01: kubernetes/cluster/lib/util.sh
	==> app-01: kubernetes/cluster/lib/logging.sh
	==> app-01: kubernetes/cluster/rackspace/
	==> app-01: kubernetes/cluster/rackspace/authorization.sh
	==> app-01: kubernetes/cluster/rackspace/cloud-config/
	==> app-01: kubernetes/cluster/rackspace/cloud-config/node-cloud-config.yaml
	==> app-01: kubernetes/cluster/rackspace/cloud-config/master-cloud-config.yaml
	==> app-01: kubernetes/cluster/rackspace/config-default.sh
	==> app-01: kubernetes/cluster/rackspace/util.sh
	==> app-01: kubernetes/cluster/rackspace/kube-up.sh
	==> app-01: kubernetes/cluster/centos/
	==> app-01: kubernetes/cluster/centos/config-build.sh
	==> app-01: kubernetes/cluster/centos/config-default.sh
	==> app-01: kubernetes/cluster/centos/master/
	==> app-01: kubernetes/cluster/centos/master/scripts/
	==> app-01: kubernetes/cluster/centos/master/scripts/scheduler.sh
	==> app-01: kubernetes/cluster/centos/master/scripts/controller-manager.sh
	==> app-01: kubernetes/cluster/centos/master/scripts/apiserver.sh
	==> app-01: kubernetes/cluster/centos/master/scripts/etcd.sh
	==> app-01: kubernetes/cluster/centos/build.sh
	==> app-01: kubernetes/cluster/centos/util.sh
	==> app-01: kubernetes/cluster/centos/node/
	==> app-01: kubernetes/cluster/centos/node/scripts/
	==> app-01: kubernetes/cluster/centos/node/scripts/flannel.sh
	==> app-01: kubernetes/cluster/centos/node/scripts/proxy.sh
	==> app-01: kubernetes/cluster/centos/node/scripts/kubelet.sh
	==> app-01: kubernetes/cluster/centos/node/scripts/docker.sh
	==> app-01: kubernetes/cluster/centos/node/bin/
	==> app-01: kubernetes/cluster/centos/node/bin/remove-docker0.sh
	==> app-01: kubernetes/cluster/centos/node/bin/mk-docker-opts.sh
	==> app-01: kubernetes/cluster/centos/config-test.sh
	==> app-01: kubernetes/cluster/centos/.gitignore
	==> app-01: kubernetes/cluster/libvirt-coreos/
	==> app-01: kubernetes/cluster/libvirt-coreos/README.md
	==> app-01: kubernetes/cluster/libvirt-coreos/config-default.sh
	==> app-01: kubernetes/cluster/libvirt-coreos/util.sh
	==> app-01: kubernetes/cluster/libvirt-coreos/user_data.yml
	==> app-01: kubernetes/cluster/libvirt-coreos/config-test.sh
	==> app-01: kubernetes/cluster/libvirt-coreos/namespace.yaml
	==> app-01: kubernetes/cluster/libvirt-coreos/.gitignore
	==> app-01: kubernetes/cluster/libvirt-coreos/network_kubernetes_pods.xml
	==> app-01: kubernetes/cluster/libvirt-coreos/forShellEval.sed
	==> app-01: kubernetes/cluster/libvirt-coreos/openssl.cnf
	==> app-01: kubernetes/cluster/libvirt-coreos/user_data_master.yml
	==> app-01: kubernetes/cluster/libvirt-coreos/node-openssl.cnf
	==> app-01: kubernetes/cluster/libvirt-coreos/coreos.xml
	==> app-01: kubernetes/cluster/libvirt-coreos/network_kubernetes_global.xml
	==> app-01: kubernetes/cluster/libvirt-coreos/user_data_minion.yml
	==> app-01: kubernetes/cluster/ubuntu/
	==> app-01: kubernetes/cluster/ubuntu/config-default.sh
	==> app-01: kubernetes/cluster/ubuntu/reconfDocker.sh
	==> app-01: kubernetes/cluster/ubuntu/master/
	==> app-01: kubernetes/cluster/ubuntu/master/init_scripts/
	==> app-01: kubernetes/cluster/ubuntu/master/init_scripts/etcd
	==> app-01: kubernetes/cluster/ubuntu/master/init_scripts/kube-scheduler
	==> app-01: kubernetes/cluster/ubuntu/master/init_scripts/kube-controller-manager
	==> app-01: kubernetes/cluster/ubuntu/master/init_scripts/kube-apiserver
	==> app-01: kubernetes/cluster/ubuntu/master/init_conf/
	==> app-01: kubernetes/cluster/ubuntu/master/init_conf/kube-scheduler.conf
	==> app-01: kubernetes/cluster/ubuntu/master/init_conf/kube-controller-manager.conf
	==> app-01: kubernetes/cluster/ubuntu/master/init_conf/kube-apiserver.conf
	==> app-01: kubernetes/cluster/ubuntu/master/init_conf/etcd.conf
	==> app-01: kubernetes/cluster/ubuntu/master-flannel/
	==> app-01: kubernetes/cluster/ubuntu/master-flannel/init_scripts/
	==> app-01: kubernetes/cluster/ubuntu/master-flannel/init_scripts/flanneld
	==> app-01: kubernetes/cluster/ubuntu/master-flannel/init_conf/
	==> app-01: kubernetes/cluster/ubuntu/master-flannel/init_conf/flanneld.conf
	==> app-01: kubernetes/cluster/ubuntu/util.sh
	==> app-01: kubernetes/cluster/ubuntu/config-test.sh
	==> app-01: kubernetes/cluster/ubuntu/namespace.yaml
	==> app-01: kubernetes/cluster/ubuntu/.gitignore
	==> app-01: kubernetes/cluster/ubuntu/minion/
	==> app-01: kubernetes/cluster/ubuntu/minion/init_scripts/
	==> app-01: kubernetes/cluster/ubuntu/minion/init_scripts/kubelet
	==> app-01: kubernetes/cluster/ubuntu/minion/init_scripts/kube-proxy
	==> app-01: kubernetes/cluster/ubuntu/minion/init_conf/
	==> app-01: kubernetes/cluster/ubuntu/minion/init_conf/kubelet.conf
	==> app-01: kubernetes/cluster/ubuntu/minion/init_conf/kube-proxy.conf
	==> app-01: kubernetes/cluster/ubuntu/download-release.sh
	==> app-01: kubernetes/cluster/ubuntu/minion-flannel/
	==> app-01: kubernetes/cluster/ubuntu/minion-flannel/init_scripts/
	==> app-01: kubernetes/cluster/ubuntu/minion-flannel/init_scripts/flanneld
	==> app-01: kubernetes/cluster/ubuntu/minion-flannel/init_conf/
	==> app-01: kubernetes/cluster/ubuntu/minion-flannel/init_conf/flanneld.conf
	==> app-01: kubernetes/cluster/ubuntu/deployAddons.sh
	==> app-01: kubernetes/cluster/local/
	==> app-01: kubernetes/cluster/local/util.sh
	==> app-01: kubernetes/cluster/get-kube-binaries.sh
	==> app-01: kubernetes/cluster/common.sh
	==> app-01: kubernetes/cluster/juju/
	==> app-01: kubernetes/cluster/juju/kube-system-ns.yaml
	==> app-01: kubernetes/cluster/juju/config-default.sh
	==> app-01: kubernetes/cluster/juju/layers/
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/layer.yaml
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/metadata.yaml
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/templates/
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/templates/kubedns-svc.yaml
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/templates/master.json
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/templates/docker-compose.yml
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/templates/kubedns-rc.yaml
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/tests/
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/tests/tests.yaml
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/config.yaml
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/README.md
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/actions.yaml
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/actions/
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/actions/guestbook-example
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/icon.svg
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/reactive/
	==> app-01: kubernetes/cluster/juju/layers/kubernetes/reactive/k8s.py
	==> app-01: kubernetes/cluster/juju/identify-leaders.py
	==> app-01: kubernetes/cluster/juju/util.sh
	==> app-01: kubernetes/cluster/juju/config-test.sh
	==> app-01: kubernetes/cluster/juju/return-node-ips.py
	==> app-01: kubernetes/cluster/juju/bundles/
	==> app-01: kubernetes/cluster/juju/bundles/README.md
	==> app-01: kubernetes/cluster/juju/bundles/local.yaml.base
	==> app-01: kubernetes/cluster/juju/prereqs/
	==> app-01: kubernetes/cluster/juju/prereqs/ubuntu-juju.sh
	==> app-01: kubernetes/cluster/kube-up.sh
	==> app-01: kubernetes/cluster/kube-util.sh
	==> app-01: kubernetes/cluster/options.md
	==> app-01: kubernetes/cluster/mesos/
	==> app-01: kubernetes/cluster/mesos/docker/
	==> app-01: kubernetes/cluster/mesos/docker/static-pod.json
	==> app-01: kubernetes/cluster/mesos/docker/socat/
	==> app-01: kubernetes/cluster/mesos/docker/socat/build.sh
	==> app-01: kubernetes/cluster/mesos/docker/socat/Dockerfile
	==> app-01: kubernetes/cluster/mesos/docker/static-pods-ns.yaml
	==> app-01: kubernetes/cluster/mesos/docker/kube-system-ns.yaml
	==> app-01: kubernetes/cluster/mesos/docker/config-default.sh
	==> app-01: kubernetes/cluster/mesos/docker/OWNERS
	==> app-01: kubernetes/cluster/mesos/docker/util.sh
	==> app-01: kubernetes/cluster/mesos/docker/config-test.sh
	==> app-01: kubernetes/cluster/mesos/docker/.gitignore
	==> app-01: kubernetes/cluster/mesos/docker/common/
	==> app-01: kubernetes/cluster/mesos/docker/common/bin/
	==> app-01: kubernetes/cluster/mesos/docker/common/bin/await-file
	==> app-01: kubernetes/cluster/mesos/docker/common/bin/health-check
	==> app-01: kubernetes/cluster/mesos/docker/common/bin/await-health-check
	==> app-01: kubernetes/cluster/mesos/docker/deploy-dns.sh
	==> app-01: kubernetes/cluster/mesos/docker/docker-compose.yml
	==> app-01: kubernetes/cluster/mesos/docker/test/
	==> app-01: kubernetes/cluster/mesos/docker/test/build.sh
	==> app-01: kubernetes/cluster/mesos/docker/test/Dockerfile
	==> app-01: kubernetes/cluster/mesos/docker/test/bin/
	==> app-01: kubernetes/cluster/mesos/docker/test/bin/install-etcd.sh
	==> app-01: kubernetes/cluster/mesos/docker/deploy-addons.sh
	==> app-01: kubernetes/cluster/mesos/docker/km/
	==> app-01: kubernetes/cluster/mesos/docker/km/build.sh
	==> app-01: kubernetes/cluster/mesos/docker/km/Dockerfile
	==> app-01: kubernetes/cluster/mesos/docker/km/.gitignore
	==> app-01: kubernetes/cluster/mesos/docker/km/opt/
	==> app-01: kubernetes/cluster/mesos/docker/km/opt/mesos-cloud.conf
	==> app-01: kubernetes/cluster/mesos/docker/deploy-ui.sh
	==> app-01: kubernetes/cluster/images/
	==> app-01: kubernetes/cluster/images/kube-discovery/
	==> app-01: kubernetes/cluster/images/kube-discovery/README.md
	==> app-01: kubernetes/cluster/images/kube-discovery/Dockerfile
	==> app-01: kubernetes/cluster/images/kube-discovery/Makefile
	==> app-01: kubernetes/cluster/images/etcd-empty-dir-cleanup/
	==> app-01: kubernetes/cluster/images/etcd-empty-dir-cleanup/Dockerfile
	==> app-01: kubernetes/cluster/images/etcd-empty-dir-cleanup/etcd-empty-dir-cleanup.sh
	==> app-01: kubernetes/cluster/images/etcd-empty-dir-cleanup/Makefile
	==> app-01: kubernetes/cluster/images/etcd/
	==> app-01: kubernetes/cluster/images/etcd/attachlease/
	==> app-01: kubernetes/cluster/images/etcd/attachlease/attachlease.go
	==> app-01: kubernetes/cluster/images/etcd/README.md
	==> app-01: kubernetes/cluster/images/etcd/Dockerfile
	==> app-01: kubernetes/cluster/images/etcd/migrate-if-needed.sh
	==> app-01: kubernetes/cluster/images/etcd/Makefile
	==> app-01: kubernetes/cluster/images/etcd/rollback/
	==> app-01: kubernetes/cluster/images/etcd/rollback/rollback.go
	==> app-01: kubernetes/cluster/images/etcd/rollback/README.md
	==> app-01: kubernetes/cluster/images/kubemark/
	==> app-01: kubernetes/cluster/images/kubemark/kubemark.sh
	==> app-01: kubernetes/cluster/images/kubemark/Dockerfile
	==> app-01: kubernetes/cluster/images/kubemark/Makefile
	==> app-01: kubernetes/cluster/images/kubemark/build-kubemark.sh
	==> app-01: kubernetes/cluster/images/hyperkube/
	==> app-01: kubernetes/cluster/images/hyperkube/README.md
	==> app-01: kubernetes/cluster/images/hyperkube/setup-files.sh
	==> app-01: kubernetes/cluster/images/hyperkube/Dockerfile
	==> app-01: kubernetes/cluster/images/hyperkube/kube-proxy-ds.yaml
	==> app-01: kubernetes/cluster/images/hyperkube/cni-conf/
	==> app-01: kubernetes/cluster/images/hyperkube/cni-conf/10-containernet.conf
	==> app-01: kubernetes/cluster/images/hyperkube/cni-conf/99-loopback.conf
	==> app-01: kubernetes/cluster/images/hyperkube/copy-addons.sh
	==> app-01: kubernetes/cluster/images/hyperkube/static-pods/
	==> app-01: kubernetes/cluster/images/hyperkube/static-pods/kube-proxy.json
	==> app-01: kubernetes/cluster/images/hyperkube/static-pods/master-multi.json
	==> app-01: kubernetes/cluster/images/hyperkube/static-pods/master.json
	==> app-01: kubernetes/cluster/images/hyperkube/static-pods/addon-manager-singlenode.json
	==> app-01: kubernetes/cluster/images/hyperkube/static-pods/etcd.json
	==> app-01: kubernetes/cluster/images/hyperkube/static-pods/addon-manager-multinode.json
	==> app-01: kubernetes/cluster/images/hyperkube/Makefile
	==> app-01: kubernetes/cluster/skeleton/
	==> app-01: kubernetes/cluster/skeleton/util.sh
	==> app-01: kubernetes/cluster/kube-down.sh
	==> app-01: kubernetes/cluster/get-kube.sh
	==> app-01: kubernetes/cluster/test-e2e.sh
	==> app-01: kubernetes/cluster/ovirt/
	==> app-01: kubernetes/cluster/ovirt/ovirt-cloud.conf
	==> app-01: kubernetes/cluster/azure-legacy/
	==> app-01: kubernetes/cluster/azure-legacy/templates/
	==> app-01: kubernetes/cluster/azure-legacy/templates/salt-master.sh
	==> app-01: kubernetes/cluster/azure-legacy/templates/common.sh
	==> app-01: kubernetes/cluster/azure-legacy/templates/download-release.sh
	==> app-01: kubernetes/cluster/azure-legacy/templates/create-dynamic-salt-files.sh
	==> app-01: kubernetes/cluster/azure-legacy/templates/salt-minion.sh
	==> app-01: kubernetes/cluster/azure-legacy/templates/create-kubeconfig.sh
	==> app-01: kubernetes/cluster/azure-legacy/config-default.sh
	==> app-01: kubernetes/cluster/azure-legacy/util.sh
	==> app-01: kubernetes/cluster/azure-legacy/.gitignore
	==> app-01: kubernetes/cluster/vagrant/
	==> app-01: kubernetes/cluster/vagrant/provision-network-master.sh
	==> app-01: kubernetes/cluster/vagrant/config-default.sh
	==> app-01: kubernetes/cluster/vagrant/OWNERS
	==> app-01: kubernetes/cluster/vagrant/util.sh
	==> app-01: kubernetes/cluster/vagrant/pod-ip-test.sh
	==> app-01: kubernetes/cluster/vagrant/config-test.sh
	==> app-01: kubernetes/cluster/vagrant/provision-node.sh
	==> app-01: kubernetes/cluster/vagrant/provision-network-node.sh
	==> app-01: kubernetes/cluster/vagrant/provision-utils.sh
	==> app-01: kubernetes/cluster/vagrant/provision-master.sh
	==> app-01: kubernetes/cluster/gce/
	==> app-01: kubernetes/cluster/gce/config-common.sh
	==> app-01: kubernetes/cluster/gce/config-default.sh
	==> app-01: kubernetes/cluster/gce/trusty/
	==> app-01: kubernetes/cluster/gce/trusty/helper.sh
	==> app-01: kubernetes/cluster/gce/trusty/node-helper.sh
	==> app-01: kubernetes/cluster/gce/trusty/node.yaml
	==> app-01: kubernetes/cluster/gce/trusty/master.yaml
	==> app-01: kubernetes/cluster/gce/trusty/configure.sh
	==> app-01: kubernetes/cluster/gce/trusty/master-helper.sh
	==> app-01: kubernetes/cluster/gce/trusty/configure-helper.sh
	==> app-01: kubernetes/cluster/gce/list-resources.sh
	==> app-01: kubernetes/cluster/gce/delete-stranded-load-balancers.sh
	==> app-01: kubernetes/cluster/gce/util.sh
	==> app-01: kubernetes/cluster/gce/coreos/
	==> app-01: kubernetes/cluster/gce/coreos/master-rkt.yaml
	==> app-01: kubernetes/cluster/gce/coreos/configure-kubelet.sh
	==> app-01: kubernetes/cluster/gce/coreos/node-helper.sh
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/kube-apiserver.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/kube-addon-manager.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/etcd-events.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/kube-system.json
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/kubelet-config.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/kube-controller-manager.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/kubeproxy-config.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/kube-scheduler.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/fluentd-elasticsearch/
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/fluentd-elasticsearch/kibana-controller.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/fluentd-elasticsearch/es-controller.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/fluentd-elasticsearch/es-service.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/fluentd-elasticsearch/kibana-service.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/google/
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/google/heapster-service.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/google/heapster-controller.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/heapster-service.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/influxdb-grafana-controller.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/grafana-service.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/heapster-controller.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/influxdb-service.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/standalone/
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/standalone/heapster-service.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/standalone/heapster-controller.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/googleinfluxdb/
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/googleinfluxdb/heapster-controller-combined.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/namespace.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/registry/
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/registry/registry-rc.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/registry/registry-svc.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/registry/registry-pvc.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/registry/registry-pv.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/node-problem-detector/
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/node-problem-detector/node-problem-detector.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/dashboard/
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/dashboard/dashboard-controller.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/dashboard/dashboard-service.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/dns/
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/dns/skydns-rc.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/dns/skydns-svc.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-loadbalancing/
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-loadbalancing/glbc/
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-loadbalancing/glbc/glbc-controller.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-loadbalancing/glbc/default-svc.yaml
	==> app-01: kubernetes/cluster/gce/coreos/kube-manifests/etcd.yaml
	==> app-01: kubernetes/cluster/gce/coreos/master-docker.yaml
	==> app-01: kubernetes/cluster/gce/coreos/master-helper.sh
	==> app-01: kubernetes/cluster/gce/coreos/node-docker.yaml
	==> app-01: kubernetes/cluster/gce/coreos/configure-node.sh
	==> app-01: kubernetes/cluster/gce/coreos/node-rkt.yaml
	==> app-01: kubernetes/cluster/gce/config-test.sh
	==> app-01: kubernetes/cluster/gce/gci/
	==> app-01: kubernetes/cluster/gce/gci/helper.sh
	==> app-01: kubernetes/cluster/gce/gci/README.md
	==> app-01: kubernetes/cluster/gce/gci/health-monitor.sh
	==> app-01: kubernetes/cluster/gce/gci/node-helper.sh
	==> app-01: kubernetes/cluster/gce/gci/node.yaml
	==> app-01: kubernetes/cluster/gce/gci/master.yaml
	==> app-01: kubernetes/cluster/gce/gci/configure.sh
	==> app-01: kubernetes/cluster/gce/gci/master-helper.sh
	==> app-01: kubernetes/cluster/gce/gci/configure-helper.sh
	==> app-01: kubernetes/cluster/gce/debian/
	==> app-01: kubernetes/cluster/gce/debian/node-helper.sh
	==> app-01: kubernetes/cluster/gce/debian/master-helper.sh
	==> app-01: kubernetes/cluster/gce/configure-vm.sh
	==> app-01: kubernetes/cluster/gce/upgrade.sh
	==> app-01: kubernetes/cluster/addons/
	==> app-01: kubernetes/cluster/addons/podsecuritypolicies/
	==> app-01: kubernetes/cluster/addons/podsecuritypolicies/privileged.yaml
	==> app-01: kubernetes/cluster/addons/fluentd-gcp/
	==> app-01: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/
	==> app-01: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/README.md
	==> app-01: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/google-fluentd-journal.conf
	==> app-01: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/Dockerfile
	==> app-01: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/google-fluentd.conf
	==> app-01: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/Makefile
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-controller.yaml
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/es-controller.yaml
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/es-service.yaml
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/elasticsearch.yml
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/run.sh
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/Dockerfile
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/template-k8s-logstash.json
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/Makefile
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/elasticsearch_logging_discovery.go
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-image/
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-image/run.sh
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-image/Dockerfile
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-image/Makefile
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-service.yaml
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/README.md
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/build.sh
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/Dockerfile
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/td-agent.conf
	==> app-01: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/Makefile
	==> app-01: kubernetes/cluster/addons/etcd-empty-dir-cleanup/
	==> app-01: kubernetes/cluster/addons/etcd-empty-dir-cleanup/etcd-empty-dir-cleanup.yaml
	==> app-01: kubernetes/cluster/addons/README.md
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/README.md
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/google/
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/google/heapster-service.yaml
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/google/heapster-controller.yaml
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/influxdb/
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/influxdb/heapster-service.yaml
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/influxdb/influxdb-grafana-controller.yaml
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/influxdb/grafana-service.yaml
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/influxdb/heapster-controller.yaml
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/influxdb/influxdb-service.yaml
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/standalone/
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/standalone/heapster-service.yaml
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/standalone/heapster-controller.yaml
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/googleinfluxdb/
	==> app-01: kubernetes/cluster/addons/cluster-monitoring/googleinfluxdb/heapster-controller-combined.yaml
	==> app-01: kubernetes/cluster/addons/addon-manager/
	==> app-01: kubernetes/cluster/addons/addon-manager/README.md
	==> app-01: kubernetes/cluster/addons/addon-manager/kube-addons.sh
	==> app-01: kubernetes/cluster/addons/addon-manager/Dockerfile
	==> app-01: kubernetes/cluster/addons/addon-manager/namespace.yaml
	==> app-01: kubernetes/cluster/addons/addon-manager/kube-addon-update.sh
	==> app-01: kubernetes/cluster/addons/addon-manager/Makefile
	==> app-01: kubernetes/cluster/addons/gci/
	==> app-01: kubernetes/cluster/addons/gci/README.md
	==> app-01: kubernetes/cluster/addons/gci/fluentd-gcp.yaml
	==> app-01: kubernetes/cluster/addons/registry/
	==> app-01: kubernetes/cluster/addons/registry/registry-pv.yaml.in
	==> app-01: kubernetes/cluster/addons/registry/README.md
	==> app-01: kubernetes/cluster/addons/registry/gcs/
	==> app-01: kubernetes/cluster/addons/registry/gcs/README.md
	==> app-01: kubernetes/cluster/addons/registry/gcs/registry-gcs-rc.yaml
	==> app-01: kubernetes/cluster/addons/registry/registry-rc.yaml
	==> app-01: kubernetes/cluster/addons/registry/registry-svc.yaml
	==> app-01: kubernetes/cluster/addons/registry/registry-pvc.yaml.in
	==> app-01: kubernetes/cluster/addons/registry/tls/
	==> app-01: kubernetes/cluster/addons/registry/tls/README.md
	==> app-01: kubernetes/cluster/addons/registry/tls/registry-tls-rc.yaml
	==> app-01: kubernetes/cluster/addons/registry/tls/registry-tls-svc.yaml
	==> app-01: kubernetes/cluster/addons/registry/auth/
	==> app-01: kubernetes/cluster/addons/registry/auth/README.md
	==> app-01: kubernetes/cluster/addons/registry/auth/registry-auth-rc.yaml
	==> app-01: kubernetes/cluster/addons/registry/images/
	==> app-01: kubernetes/cluster/addons/registry/images/proxy.conf.in
	==> app-01: kubernetes/cluster/addons/registry/images/Dockerfile
	==> app-01: kubernetes/cluster/addons/registry/images/proxy.conf.insecure.in
	==> app-01: kubernetes/cluster/addons/registry/images/Makefile
	==> app-01: kubernetes/cluster/addons/registry/images/run_proxy.sh
	==> app-01: kubernetes/cluster/addons/node-problem-detector/
	==> app-01: kubernetes/cluster/addons/node-problem-detector/README.md
	==> app-01: kubernetes/cluster/addons/node-problem-detector/MAINTAINERS.md
	==> app-01: kubernetes/cluster/addons/node-problem-detector/node-problem-detector.yaml
	==> app-01: kubernetes/cluster/addons/dashboard/
	==> app-01: kubernetes/cluster/addons/dashboard/dashboard-controller.yaml
	==> app-01: kubernetes/cluster/addons/dashboard/README.md
	==> app-01: kubernetes/cluster/addons/dashboard/MAINTAINERS.md
	==> app-01: kubernetes/cluster/addons/dashboard/dashboard-service.yaml
	==> app-01: kubernetes/cluster/addons/calico-policy-controller/
	==> app-01: kubernetes/cluster/addons/calico-policy-controller/README.md
	==> app-01: kubernetes/cluster/addons/calico-policy-controller/MAINTAINERS.md
	==> app-01: kubernetes/cluster/addons/calico-policy-controller/calico-policy-controller.yaml
	==> app-01: kubernetes/cluster/addons/calico-policy-controller/calico-etcd-service.yaml
	==> app-01: kubernetes/cluster/addons/calico-policy-controller/calico-etcd-petset.yaml
	==> app-01: kubernetes/cluster/addons/python-image/
	==> app-01: kubernetes/cluster/addons/python-image/README.md
	==> app-01: kubernetes/cluster/addons/python-image/Dockerfile
	==> app-01: kubernetes/cluster/addons/python-image/Makefile
	==> app-01: kubernetes/cluster/addons/dns/
	==> app-01: kubernetes/cluster/addons/dns/transforms2salt.sed
	==> app-01: kubernetes/cluster/addons/dns/README.md
	==> app-01: kubernetes/cluster/addons/dns/skydns-svc.yaml.base
	==> app-01: kubernetes/cluster/addons/dns/skydns-svc.yaml.in
	==> app-01: kubernetes/cluster/addons/dns/transforms2sed.sed
	==> app-01: kubernetes/cluster/addons/dns/skydns-svc.yaml.sed
	==> app-01: kubernetes/cluster/addons/dns/skydns-rc.yaml.base
	==> app-01: kubernetes/cluster/addons/dns/skydns-rc.yaml.in
	==> app-01: kubernetes/cluster/addons/dns/skydns-rc.yaml.sed
	==> app-01: kubernetes/cluster/addons/dns/Makefile
	==> app-01: kubernetes/cluster/addons/cluster-loadbalancing/
	==> app-01: kubernetes/cluster/addons/cluster-loadbalancing/MAINTAINERS.md
	==> app-01: kubernetes/cluster/addons/cluster-loadbalancing/glbc/
	==> app-01: kubernetes/cluster/addons/cluster-loadbalancing/glbc/README.md
	==> app-01: kubernetes/cluster/addons/cluster-loadbalancing/glbc/default-svc-controller.yaml
	==> app-01: kubernetes/cluster/addons/cluster-loadbalancing/glbc/default-svc.yaml
	==> app-01: kubernetes/cluster/test-smoke.sh
	==> app-01: kubernetes/cluster/kube-push.sh
	==> app-01: kubernetes/cluster/azure/
	==> app-01: kubernetes/cluster/azure/config-default.sh
	==> app-01: kubernetes/cluster/azure/util.sh
	==> app-01: kubernetes/cluster/azure/.gitignore
	==> app-01: kubernetes/version
	==> app-01: kubernetes/LICENSES
	==> app-01: kubernetes/federation/
	==> app-01: kubernetes/federation/cluster/
	==> app-01: kubernetes/federation/cluster/federation-up.sh
	==> app-01: kubernetes/federation/cluster/common.sh
	==> app-01: kubernetes/federation/cluster/template.go
	==> app-01: kubernetes/federation/cluster/federation-down.sh
	==> app-01: kubernetes/federation/manifests/
	==> app-01: kubernetes/federation/manifests/federation-controller-manager-deployment.yaml
	==> app-01: kubernetes/federation/manifests/federation-etcd-pvc.yaml
	==> app-01: kubernetes/federation/manifests/federation-ns.yaml
	==> app-01: kubernetes/federation/manifests/.gitignore
	==> app-01: kubernetes/federation/manifests/federation-apiserver-deployment.yaml
	==> app-01: kubernetes/federation/manifests/federation-apiserver-lb-service.yaml
	==> app-01: kubernetes/federation/manifests/federation-apiserver-cluster-service.yaml
	==> app-01: kubernetes/federation/manifests/federation-apiserver-nodeport-service.yaml
	==> app-01: kubernetes/federation/manifests/federation-apiserver-secrets.yaml
	==> app-01: kubernetes/federation/deploy/
	==> app-01: kubernetes/federation/deploy/deploy.sh
	==> app-01: kubernetes/federation/deploy/config.json.sample
	==> app-01: kubernetes/server/
	==> app-01: kubernetes/server/kubernetes-salt.tar.gz
	==> app-01: kubernetes/server/kubernetes-manifests.tar.gz
	==> app-01: kubernetes/server/kubernetes-server-linux-arm.tar.gz
	==> app-01: kubernetes/server/kubernetes-server-linux-arm64.tar.gz
	==> app-01: kubernetes/server/kubernetes-server-linux-amd64.tar.gz
	==> app-01: kubernetes/Vagrantfile
	==> app-01: kubernetes/examples/
	==> app-01: kubernetes/examples/doc.go
	==> app-01: kubernetes/examples/README.md
	==> app-01: kubernetes/examples/simple-nginx.md
	==> app-01: kubernetes/examples/runtime-constraints/
	==> app-01: kubernetes/examples/runtime-constraints/README.md
	==> app-01: kubernetes/examples/OWNERS
	==> app-01: kubernetes/examples/phabricator/
	==> app-01: kubernetes/examples/phabricator/php-phabricator/
	==> app-01: kubernetes/examples/phabricator/php-phabricator/run.sh
	==> app-01: kubernetes/examples/phabricator/php-phabricator/Dockerfile
	==> app-01: kubernetes/examples/phabricator/php-phabricator/000-default.conf
	==> app-01: kubernetes/examples/phabricator/README.md
	==> app-01: kubernetes/examples/phabricator/phabricator-controller.json
	==> app-01: kubernetes/examples/phabricator/phabricator-service.json
	==> app-01: kubernetes/examples/phabricator/teardown.sh
	==> app-01: kubernetes/examples/phabricator/setup.sh
	==> app-01: kubernetes/examples/cockroachdb/
	==> app-01: kubernetes/examples/cockroachdb/README.md
	==> app-01: kubernetes/examples/cockroachdb/minikube.sh
	==> app-01: kubernetes/examples/cockroachdb/demo.sh
	==> app-01: kubernetes/examples/cockroachdb/cockroachdb-petset.yaml
	==> app-01: kubernetes/examples/javaweb-tomcat-sidecar/
	==> app-01: kubernetes/examples/javaweb-tomcat-sidecar/README.md
	==> app-01: kubernetes/examples/javaweb-tomcat-sidecar/javaweb.yaml
	==> app-01: kubernetes/examples/javaweb-tomcat-sidecar/javaweb-2.yaml
	==> app-01: kubernetes/examples/javaweb-tomcat-sidecar/workflow.png
	==> app-01: kubernetes/examples/experimental/
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/README.md
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/glusterfs-dp.yaml
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/aws-ebs.yaml
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/glusterfs-provisioning-secret.yaml
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/claim1.json
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/rbd/
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/rbd/ceph-secret-admin.yaml
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/rbd/rbd-storage-class.yaml
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/rbd/ceph-secret-user.yaml
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/rbd/pod.yaml
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/quobyte/
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/quobyte/quobyte-admin-secret.yaml
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/quobyte/example-pod.yaml
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/quobyte/quobyte-storage-class.yaml
	==> app-01: kubernetes/examples/experimental/persistent-volume-provisioning/gce-pd.yaml
	==> app-01: kubernetes/examples/examples_test.go
	==> app-01: kubernetes/examples/nodesjs-mongodb/
	==> app-01: kubernetes/examples/nodesjs-mongodb/README.md
	==> app-01: kubernetes/examples/nodesjs-mongodb/mongo-controller.yaml
	==> app-01: kubernetes/examples/nodesjs-mongodb/web-service.yaml
	==> app-01: kubernetes/examples/nodesjs-mongodb/web-controller.yaml
	==> app-01: kubernetes/examples/nodesjs-mongodb/mongo-service.yaml
	==> app-01: kubernetes/examples/nodesjs-mongodb/web-controller-demo.yaml
	==> app-01: kubernetes/examples/mysql-wordpress-pd/
	==> app-01: kubernetes/examples/mysql-wordpress-pd/README.md
	==> app-01: kubernetes/examples/mysql-wordpress-pd/OWNERS
	==> app-01: kubernetes/examples/mysql-wordpress-pd/WordPress.png
	==> app-01: kubernetes/examples/mysql-wordpress-pd/gce-volumes.yaml
	==> app-01: kubernetes/examples/mysql-wordpress-pd/mysql-deployment.yaml
	==> app-01: kubernetes/examples/mysql-wordpress-pd/wordpress-deployment.yaml
	==> app-01: kubernetes/examples/mysql-wordpress-pd/local-volumes.yaml
	==> app-01: kubernetes/examples/mysql-cinder-pd/
	==> app-01: kubernetes/examples/mysql-cinder-pd/mysql.yaml
	==> app-01: kubernetes/examples/mysql-cinder-pd/README.md
	==> app-01: kubernetes/examples/mysql-cinder-pd/mysql-service.yaml
	==> app-01: kubernetes/examples/openshift-origin/
	==> app-01: kubernetes/examples/openshift-origin/openshift-controller.yaml
	==> app-01: kubernetes/examples/openshift-origin/README.md
	==> app-01: kubernetes/examples/openshift-origin/openshift-origin-namespace.yaml
	==> app-01: kubernetes/examples/openshift-origin/etcd-discovery-service.yaml
	==> app-01: kubernetes/examples/openshift-origin/etcd-service.yaml
	==> app-01: kubernetes/examples/openshift-origin/.gitignore
	==> app-01: kubernetes/examples/openshift-origin/openshift-service.yaml
	==> app-01: kubernetes/examples/openshift-origin/cleanup.sh
	==> app-01: kubernetes/examples/openshift-origin/etcd-discovery-controller.yaml
	==> app-01: kubernetes/examples/openshift-origin/create.sh
	==> app-01: kubernetes/examples/openshift-origin/secret.json
	==> app-01: kubernetes/examples/openshift-origin/etcd-controller.yaml
	==> app-01: kubernetes/examples/javaee/
	==> app-01: kubernetes/examples/javaee/README.md
	==> app-01: kubernetes/examples/javaee/wildfly-rc.yaml
	==> app-01: kubernetes/examples/javaee/mysql-pod.yaml
	==> app-01: kubernetes/examples/javaee/mysql-service.yaml
	==> app-01: kubernetes/examples/newrelic/
	==> app-01: kubernetes/examples/newrelic/newrelic-config.yaml
	==> app-01: kubernetes/examples/newrelic/README.md
	==> app-01: kubernetes/examples/newrelic/nrconfig.env
	==> app-01: kubernetes/examples/newrelic/newrelic-config-template.yaml
	==> app-01: kubernetes/examples/newrelic/config-to-secret.sh
	==> app-01: kubernetes/examples/newrelic/newrelic-daemonset.yaml
	==> app-01: kubernetes/examples/scheduler-policy-config-with-extender.json
	==> app-01: kubernetes/examples/storm/
	==> app-01: kubernetes/examples/storm/README.md
	==> app-01: kubernetes/examples/storm/storm-nimbus-service.json
	==> app-01: kubernetes/examples/storm/zookeeper.json
	==> app-01: kubernetes/examples/storm/zookeeper-service.json
	==> app-01: kubernetes/examples/storm/storm-worker-controller.json
	==> app-01: kubernetes/examples/storm/storm-nimbus.json
	==> app-01: kubernetes/examples/https-nginx/
	==> app-01: kubernetes/examples/https-nginx/README.md
	==> app-01: kubernetes/examples/https-nginx/Dockerfile
	==> app-01: kubernetes/examples/https-nginx/make_secret.go
	==> app-01: kubernetes/examples/https-nginx/nginx-app.yaml
	==> app-01: kubernetes/examples/https-nginx/default.conf
	==> app-01: kubernetes/examples/https-nginx/Makefile
	==> app-01: kubernetes/examples/https-nginx/index2.html
	==> app-01: kubernetes/examples/https-nginx/auto-reload-nginx.sh
	==> app-01: kubernetes/examples/explorer/
	==> app-01: kubernetes/examples/explorer/README.md
	==> app-01: kubernetes/examples/explorer/Dockerfile
	==> app-01: kubernetes/examples/explorer/Makefile
	==> app-01: kubernetes/examples/explorer/pod.yaml
	==> app-01: kubernetes/examples/explorer/explorer.go
	==> app-01: kubernetes/examples/job/
	==> app-01: kubernetes/examples/job/expansions/
	==> app-01: kubernetes/examples/job/expansions/README.md
	==> app-01: kubernetes/examples/job/work-queue-1/
	==> app-01: kubernetes/examples/job/work-queue-1/README.md
	==> app-01: kubernetes/examples/job/work-queue-2/
	==> app-01: kubernetes/examples/job/work-queue-2/README.md
	==> app-01: kubernetes/examples/cluster-dns/
	==> app-01: kubernetes/examples/cluster-dns/namespace-prod.yaml
	==> app-01: kubernetes/examples/cluster-dns/dns-backend-rc.yaml
	==> app-01: kubernetes/examples/cluster-dns/README.md
	==> app-01: kubernetes/examples/cluster-dns/namespace-dev.yaml
	==> app-01: kubernetes/examples/cluster-dns/images/
	==> app-01: kubernetes/examples/cluster-dns/images/frontend/
	==> app-01: kubernetes/examples/cluster-dns/images/frontend/client.py
	==> app-01: kubernetes/examples/cluster-dns/images/frontend/Dockerfile
	==> app-01: kubernetes/examples/cluster-dns/images/frontend/Makefile
	==> app-01: kubernetes/examples/cluster-dns/images/backend/
	==> app-01: kubernetes/examples/cluster-dns/images/backend/Dockerfile
	==> app-01: kubernetes/examples/cluster-dns/images/backend/Makefile
	==> app-01: kubernetes/examples/cluster-dns/images/backend/server.py
	==> app-01: kubernetes/examples/cluster-dns/dns-frontend-pod.yaml
	==> app-01: kubernetes/examples/cluster-dns/dns-backend-service.yaml
	==> app-01: kubernetes/examples/elasticsearch/
	==> app-01: kubernetes/examples/elasticsearch/es-svc.yaml
	==> app-01: kubernetes/examples/elasticsearch/production_cluster/
	==> app-01: kubernetes/examples/elasticsearch/production_cluster/es-svc.yaml
	==> app-01: kubernetes/examples/elasticsearch/production_cluster/service-account.yaml
	==> app-01: kubernetes/examples/elasticsearch/production_cluster/README.md
	==> app-01: kubernetes/examples/elasticsearch/production_cluster/es-discovery-svc.yaml
	==> app-01: kubernetes/examples/elasticsearch/production_cluster/es-master-rc.yaml
	==> app-01: kubernetes/examples/elasticsearch/production_cluster/es-client-rc.yaml
	==> app-01: kubernetes/examples/elasticsearch/production_cluster/es-data-rc.yaml
	==> app-01: kubernetes/examples/elasticsearch/service-account.yaml
	==> app-01: kubernetes/examples/elasticsearch/README.md
	==> app-01: kubernetes/examples/elasticsearch/es-rc.yaml
	==> app-01: kubernetes/examples/sysdig-cloud/
	==> app-01: kubernetes/examples/sysdig-cloud/README.md
	==> app-01: kubernetes/examples/sysdig-cloud/sysdig-rc.yaml
	==> app-01: kubernetes/examples/sysdig-cloud/sysdig-daemonset.yaml
	==> app-01: kubernetes/examples/selenium/
	==> app-01: kubernetes/examples/selenium/README.md
	==> app-01: kubernetes/examples/selenium/selenium-hub-rc.yaml
	==> app-01: kubernetes/examples/selenium/selenium-test.py
	==> app-01: kubernetes/examples/selenium/selenium-node-chrome-rc.yaml
	==> app-01: kubernetes/examples/selenium/selenium-node-firefox-rc.yaml
	==> app-01: kubernetes/examples/selenium/selenium-hub-svc.yaml
	==> app-01: kubernetes/examples/guestbook-go/
	==> app-01: kubernetes/examples/guestbook-go/redis-master-service.json
	==> app-01: kubernetes/examples/guestbook-go/README.md
	==> app-01: kubernetes/examples/guestbook-go/redis-slave-controller.json
	==> app-01: kubernetes/examples/guestbook-go/redis-master-controller.json
	==> app-01: kubernetes/examples/guestbook-go/guestbook-page.png
	==> app-01: kubernetes/examples/guestbook-go/_src/
	==> app-01: kubernetes/examples/guestbook-go/_src/README.md
	==> app-01: kubernetes/examples/guestbook-go/_src/Dockerfile
	==> app-01: kubernetes/examples/guestbook-go/_src/main.go
	==> app-01: kubernetes/examples/guestbook-go/_src/Makefile
	==> app-01: kubernetes/examples/guestbook-go/_src/guestbook/
	==> app-01: kubernetes/examples/guestbook-go/_src/guestbook/Dockerfile
	==> app-01: kubernetes/examples/guestbook-go/_src/public/
	==> app-01: kubernetes/examples/guestbook-go/_src/public/index.html
	==> app-01: kubernetes/examples/guestbook-go/_src/public/script.js
	==> app-01: kubernetes/examples/guestbook-go/_src/public/style.css
	==> app-01: kubernetes/examples/guestbook-go/guestbook-controller.json
	==> app-01: kubernetes/examples/guestbook-go/guestbook-service.json
	==> app-01: kubernetes/examples/guestbook-go/redis-slave-service.json
	==> app-01: kubernetes/examples/sharing-clusters/
	==> app-01: kubernetes/examples/sharing-clusters/README.md
	==> app-01: kubernetes/examples/sharing-clusters/make_secret.go
	==> app-01: kubernetes/examples/k8petstore/
	==> app-01: kubernetes/examples/k8petstore/k8petstore-nodeport.sh
	==> app-01: kubernetes/examples/k8petstore/README.md
	==> app-01: kubernetes/examples/k8petstore/k8petstore-loadbalancer.sh
	==> app-01: kubernetes/examples/k8petstore/k8petstore.sh
	==> app-01: kubernetes/examples/k8petstore/redis-slave/
	==> app-01: kubernetes/examples/k8petstore/redis-slave/etc_redis_redis.conf
	==> app-01: kubernetes/examples/k8petstore/redis-slave/run.sh
	==> app-01: kubernetes/examples/k8petstore/redis-slave/Dockerfile
	==> app-01: kubernetes/examples/k8petstore/redis/
	==> app-01: kubernetes/examples/k8petstore/redis/etc_redis_redis.conf
	==> app-01: kubernetes/examples/k8petstore/redis/Dockerfile
	==> app-01: kubernetes/examples/k8petstore/redis-master/
	==> app-01: kubernetes/examples/k8petstore/redis-master/etc_redis_redis.conf
	==> app-01: kubernetes/examples/k8petstore/redis-master/Dockerfile
	==> app-01: kubernetes/examples/k8petstore/docker-machine-dev.sh
	==> app-01: kubernetes/examples/k8petstore/k8petstore.dot
	==> app-01: kubernetes/examples/k8petstore/bps-data-generator/
	==> app-01: kubernetes/examples/k8petstore/bps-data-generator/README.md
	==> app-01: kubernetes/examples/k8petstore/build-push-containers.sh
	==> app-01: kubernetes/examples/k8petstore/web-server/
	==> app-01: kubernetes/examples/k8petstore/web-server/src/
	==> app-01: kubernetes/examples/k8petstore/web-server/src/main.go
	==> app-01: kubernetes/examples/k8petstore/web-server/test.sh
	==> app-01: kubernetes/examples/k8petstore/web-server/Dockerfile
	==> app-01: kubernetes/examples/k8petstore/web-server/dump.rdb
	==> app-01: kubernetes/examples/k8petstore/web-server/static/
	==> app-01: kubernetes/examples/k8petstore/web-server/static/histogram.js
	==> app-01: kubernetes/examples/k8petstore/web-server/static/index.html
	==> app-01: kubernetes/examples/k8petstore/web-server/static/script.js
	==> app-01: kubernetes/examples/k8petstore/web-server/static/style.css
	==> app-01: kubernetes/examples/storage/
	==> app-01: kubernetes/examples/storage/redis/
	==> app-01: kubernetes/examples/storage/redis/README.md
	==> app-01: kubernetes/examples/storage/redis/image/
	==> app-01: kubernetes/examples/storage/redis/image/run.sh
	==> app-01: kubernetes/examples/storage/redis/image/Dockerfile
	==> app-01: kubernetes/examples/storage/redis/image/redis-slave.conf
	==> app-01: kubernetes/examples/storage/redis/image/redis-master.conf
	==> app-01: kubernetes/examples/storage/redis/redis-controller.yaml
	==> app-01: kubernetes/examples/storage/redis/redis-sentinel-controller.yaml
	==> app-01: kubernetes/examples/storage/redis/redis-proxy.yaml
	==> app-01: kubernetes/examples/storage/redis/redis-sentinel-service.yaml
	==> app-01: kubernetes/examples/storage/redis/redis-master.yaml
	==> app-01: kubernetes/examples/storage/mysql-galera/
	==> app-01: kubernetes/examples/storage/mysql-galera/README.md
	==> app-01: kubernetes/examples/storage/mysql-galera/pxc-node1.yaml
	==> app-01: kubernetes/examples/storage/mysql-galera/image/
	==> app-01: kubernetes/examples/storage/mysql-galera/image/Dockerfile
	==> app-01: kubernetes/examples/storage/mysql-galera/image/docker-entrypoint.sh
	==> app-01: kubernetes/examples/storage/mysql-galera/image/my.cnf
	==> app-01: kubernetes/examples/storage/mysql-galera/image/cluster.cnf
	==> app-01: kubernetes/examples/storage/mysql-galera/pxc-node3.yaml
	==> app-01: kubernetes/examples/storage/mysql-galera/pxc-cluster-service.yaml
	==> app-01: kubernetes/examples/storage/mysql-galera/pxc-node2.yaml
	==> app-01: kubernetes/examples/storage/cassandra/
	==> app-01: kubernetes/examples/storage/cassandra/README.md
	==> app-01: kubernetes/examples/storage/cassandra/cassandra-daemonset.yaml
	==> app-01: kubernetes/examples/storage/cassandra/image/
	==> app-01: kubernetes/examples/storage/cassandra/image/Dockerfile
	==> app-01: kubernetes/examples/storage/cassandra/image/files/
	==> app-01: kubernetes/examples/storage/cassandra/image/files/run.sh
	==> app-01: kubernetes/examples/storage/cassandra/image/files/cassandra.list
	==> app-01: kubernetes/examples/storage/cassandra/image/files/ready-probe.sh
	==> app-01: kubernetes/examples/storage/cassandra/image/files/cassandra.yaml
	==> app-01: kubernetes/examples/storage/cassandra/image/files/kubernetes-cassandra.jar
	==> app-01: kubernetes/examples/storage/cassandra/image/files/logback.xml
	==> app-01: kubernetes/examples/storage/cassandra/image/files/java.list
	==> app-01: kubernetes/examples/storage/cassandra/image/Makefile
	==> app-01: kubernetes/examples/storage/cassandra/cassandra-petset.yaml
	==> app-01: kubernetes/examples/storage/cassandra/cassandra-service.yaml
	==> app-01: kubernetes/examples/storage/cassandra/cassandra-controller.yaml
	==> app-01: kubernetes/examples/storage/cassandra/java/
	==> app-01: kubernetes/examples/storage/cassandra/java/src/
	==> app-01: kubernetes/examples/storage/cassandra/java/src/main/
	==> app-01: kubernetes/examples/storage/cassandra/java/src/main/java/
	==> app-01: kubernetes/examples/storage/cassandra/java/src/main/java/io/
	==> app-01: kubernetes/examples/storage/cassandra/java/src/main/java/io/k8s/
	==> app-01: kubernetes/examples/storage/cassandra/java/src/main/java/io/k8s/cassandra/
	==> app-01: kubernetes/examples/storage/cassandra/java/src/main/java/io/k8s/cassandra/KubernetesSeedProvider.java
	==> app-01: kubernetes/examples/storage/cassandra/java/src/test/
	==> app-01: kubernetes/examples/storage/cassandra/java/src/test/resources/
	==> app-01: kubernetes/examples/storage/cassandra/java/src/test/resources/cassandra.yaml
	==> app-01: kubernetes/examples/storage/cassandra/java/src/test/resources/logback-test.xml
	==> app-01: kubernetes/examples/storage/cassandra/java/src/test/java/
	==> app-01: kubernetes/examples/storage/cassandra/java/src/test/java/io/
	==> app-01: kubernetes/examples/storage/cassandra/java/src/test/java/io/k8s/
	==> app-01: kubernetes/examples/storage/cassandra/java/src/test/java/io/k8s/cassandra/
	==> app-01: kubernetes/examples/storage/cassandra/java/src/test/java/io/k8s/cassandra/KubernetesSeedProviderTest.java
	==> app-01: kubernetes/examples/storage/cassandra/java/README.md
	==> app-01: kubernetes/examples/storage/cassandra/java/.gitignore
	==> app-01: kubernetes/examples/storage/cassandra/java/pom.xml
	==> app-01: kubernetes/examples/storage/rethinkdb/
	==> app-01: kubernetes/examples/storage/rethinkdb/README.md
	==> app-01: kubernetes/examples/storage/rethinkdb/admin-pod.yaml
	==> app-01: kubernetes/examples/storage/rethinkdb/image/
	==> app-01: kubernetes/examples/storage/rethinkdb/image/run.sh
	==> app-01: kubernetes/examples/storage/rethinkdb/image/Dockerfile
	==> app-01: kubernetes/examples/storage/rethinkdb/admin-service.yaml
	==> app-01: kubernetes/examples/storage/rethinkdb/rc.yaml
	==> app-01: kubernetes/examples/storage/rethinkdb/gen-pod.sh
	==> app-01: kubernetes/examples/storage/rethinkdb/driver-service.yaml
	==> app-01: kubernetes/examples/storage/hazelcast/
	==> app-01: kubernetes/examples/storage/hazelcast/hazelcast-controller.yaml
	==> app-01: kubernetes/examples/storage/hazelcast/README.md
	==> app-01: kubernetes/examples/storage/hazelcast/image/
	==> app-01: kubernetes/examples/storage/hazelcast/image/Dockerfile
	==> app-01: kubernetes/examples/storage/hazelcast/hazelcast-service.yaml
	==> app-01: kubernetes/examples/storage/vitess/
	==> app-01: kubernetes/examples/storage/vitess/vitess-up.sh
	==> app-01: kubernetes/examples/storage/vitess/guestbook-down.sh
	==> app-01: kubernetes/examples/storage/vitess/README.md
	==> app-01: kubernetes/examples/storage/vitess/guestbook-service.yaml
	==> app-01: kubernetes/examples/storage/vitess/vtctld-controller-template.yaml
	==> app-01: kubernetes/examples/storage/vitess/vtgate-up.sh
	==> app-01: kubernetes/examples/storage/vitess/etcd-up.sh
	==> app-01: kubernetes/examples/storage/vitess/vtctld-down.sh
	==> app-01: kubernetes/examples/storage/vitess/vtctld-service.yaml
	==> app-01: kubernetes/examples/storage/vitess/vitess-down.sh
	==> app-01: kubernetes/examples/storage/vitess/etcd-controller-template.yaml
	==> app-01: kubernetes/examples/storage/vitess/etcd-down.sh
	==> app-01: kubernetes/examples/storage/vitess/vtctld-up.sh
	==> app-01: kubernetes/examples/storage/vitess/create_test_table.sql
	==> app-01: kubernetes/examples/storage/vitess/configure.sh
	==> app-01: kubernetes/examples/storage/vitess/etcd-service-template.yaml
	==> app-01: kubernetes/examples/storage/vitess/vtgate-service.yaml
	==> app-01: kubernetes/examples/storage/vitess/vttablet-down.sh
	==> app-01: kubernetes/examples/storage/vitess/env.sh
	==> app-01: kubernetes/examples/storage/vitess/vttablet-up.sh
	==> app-01: kubernetes/examples/storage/vitess/guestbook-controller.yaml
	==> app-01: kubernetes/examples/storage/vitess/vtgate-controller-template.yaml
	==> app-01: kubernetes/examples/storage/vitess/guestbook-up.sh
	==> app-01: kubernetes/examples/storage/vitess/vttablet-pod-template.yaml
	==> app-01: kubernetes/examples/storage/vitess/vtgate-down.sh
	==> app-01: kubernetes/examples/guestbook/
	==> app-01: kubernetes/examples/guestbook/redis-slave-deployment.yaml
	==> app-01: kubernetes/examples/guestbook/php-redis/
	==> app-01: kubernetes/examples/guestbook/php-redis/Dockerfile
	==> app-01: kubernetes/examples/guestbook/php-redis/guestbook.php
	==> app-01: kubernetes/examples/guestbook/php-redis/index.html
	==> app-01: kubernetes/examples/guestbook/php-redis/controllers.js
	==> app-01: kubernetes/examples/guestbook/frontend-deployment.yaml
	==> app-01: kubernetes/examples/guestbook/README.md
	==> app-01: kubernetes/examples/guestbook/redis-master-service.yaml
	==> app-01: kubernetes/examples/guestbook/redis-slave/
	==> app-01: kubernetes/examples/guestbook/redis-slave/run.sh
	==> app-01: kubernetes/examples/guestbook/redis-slave/Dockerfile
	==> app-01: kubernetes/examples/guestbook/frontend-service.yaml
	==> app-01: kubernetes/examples/guestbook/redis-master-deployment.yaml
	==> app-01: kubernetes/examples/guestbook/legacy/
	==> app-01: kubernetes/examples/guestbook/legacy/frontend-controller.yaml
	==> app-01: kubernetes/examples/guestbook/legacy/redis-master-controller.yaml
	==> app-01: kubernetes/examples/guestbook/legacy/redis-slave-controller.yaml
	==> app-01: kubernetes/examples/guestbook/redis-slave-service.yaml
	==> app-01: kubernetes/examples/guestbook/all-in-one/
	==> app-01: kubernetes/examples/guestbook/all-in-one/guestbook-all-in-one.yaml
	==> app-01: kubernetes/examples/guestbook/all-in-one/frontend.yaml
	==> app-01: kubernetes/examples/guestbook/all-in-one/redis-slave.yaml
	==> app-01: kubernetes/examples/volumes/
	==> app-01: kubernetes/examples/volumes/iscsi/
	==> app-01: kubernetes/examples/volumes/iscsi/iscsi.yaml
	==> app-01: kubernetes/examples/volumes/iscsi/README.md
	==> app-01: kubernetes/examples/volumes/glusterfs/
	==> app-01: kubernetes/examples/volumes/glusterfs/README.md
	==> app-01: kubernetes/examples/volumes/glusterfs/glusterfs-endpoints.json
	==> app-01: kubernetes/examples/volumes/glusterfs/glusterfs-pod.json
	==> app-01: kubernetes/examples/volumes/glusterfs/glusterfs-service.json
	==> app-01: kubernetes/examples/volumes/cephfs/
	==> app-01: kubernetes/examples/volumes/cephfs/README.md
	==> app-01: kubernetes/examples/volumes/cephfs/secret/
	==> app-01: kubernetes/examples/volumes/cephfs/secret/ceph-secret.yaml
	==> app-01: kubernetes/examples/volumes/cephfs/cephfs-with-secret.yaml
	==> app-01: kubernetes/examples/volumes/cephfs/cephfs.yaml
	==> app-01: kubernetes/examples/volumes/nfs/
	==> app-01: kubernetes/examples/volumes/nfs/nfs-server-service.yaml
	==> app-01: kubernetes/examples/volumes/nfs/nfs-web-rc.yaml
	==> app-01: kubernetes/examples/volumes/nfs/README.md
	==> app-01: kubernetes/examples/volumes/nfs/nfs-data/
	==> app-01: kubernetes/examples/volumes/nfs/nfs-data/README.md
	==> app-01: kubernetes/examples/volumes/nfs/nfs-data/Dockerfile
	==> app-01: kubernetes/examples/volumes/nfs/nfs-data/index.html
	==> app-01: kubernetes/examples/volumes/nfs/nfs-data/run_nfs.sh
	==> app-01: kubernetes/examples/volumes/nfs/nfs-pvc.yaml
	==> app-01: kubernetes/examples/volumes/nfs/nfs-server-rc.yaml
	==> app-01: kubernetes/examples/volumes/nfs/nfs-pv.yaml
	==> app-01: kubernetes/examples/volumes/nfs/nfs-web-service.yaml
	==> app-01: kubernetes/examples/volumes/nfs/provisioner/
	==> app-01: kubernetes/examples/volumes/nfs/provisioner/nfs-server-gce-pv.yaml
	==> app-01: kubernetes/examples/volumes/nfs/nfs-busybox-rc.yaml
	==> app-01: kubernetes/examples/volumes/nfs/nfs-pv.png
	==> app-01: kubernetes/examples/volumes/flocker/
	==> app-01: kubernetes/examples/volumes/flocker/README.md
	==> app-01: kubernetes/examples/volumes/flocker/flocker-pod.yml
	==> app-01: kubernetes/examples/volumes/flocker/flocker-pod-with-rc.yml
	==> app-01: kubernetes/examples/volumes/azure_disk/
	==> app-01: kubernetes/examples/volumes/azure_disk/README.md
	==> app-01: kubernetes/examples/volumes/azure_disk/azure.yaml
	==> app-01: kubernetes/examples/volumes/azure_file/
	==> app-01: kubernetes/examples/volumes/azure_file/README.md
	==> app-01: kubernetes/examples/volumes/azure_file/secret/
	==> app-01: kubernetes/examples/volumes/azure_file/secret/azure-secret.yaml
	==> app-01: kubernetes/examples/volumes/azure_file/azure.yaml
	==> app-01: kubernetes/examples/volumes/flexvolume/
	==> app-01: kubernetes/examples/volumes/flexvolume/README.md
	==> app-01: kubernetes/examples/volumes/flexvolume/lvm
	==> app-01: kubernetes/examples/volumes/flexvolume/nginx.yaml
	==> app-01: kubernetes/examples/volumes/fibre_channel/
	==> app-01: kubernetes/examples/volumes/fibre_channel/README.md
	==> app-01: kubernetes/examples/volumes/fibre_channel/fc.yaml
	==> app-01: kubernetes/examples/volumes/rbd/
	==> app-01: kubernetes/examples/volumes/rbd/rbd-with-secret.json
	==> app-01: kubernetes/examples/volumes/rbd/README.md
	==> app-01: kubernetes/examples/volumes/rbd/secret/
	==> app-01: kubernetes/examples/volumes/rbd/secret/ceph-secret.yaml
	==> app-01: kubernetes/examples/volumes/rbd/rbd.json
	==> app-01: kubernetes/examples/volumes/aws_ebs/
	==> app-01: kubernetes/examples/volumes/aws_ebs/README.md
	==> app-01: kubernetes/examples/volumes/aws_ebs/aws-ebs-web.yaml
	==> app-01: kubernetes/examples/volumes/quobyte/
	==> app-01: kubernetes/examples/volumes/quobyte/quobyte-pod.yaml
	==> app-01: kubernetes/examples/volumes/quobyte/Readme.md
	==> app-01: kubernetes/examples/scheduler-policy-config.json
	==> app-01: kubernetes/examples/spark/
	==> app-01: kubernetes/examples/spark/spark-gluster/
	==> app-01: kubernetes/examples/spark/spark-gluster/README.md
	==> app-01: kubernetes/examples/spark/spark-gluster/glusterfs-endpoints.yaml
	==> app-01: kubernetes/examples/spark/spark-gluster/spark-master-service.yaml
	==> app-01: kubernetes/examples/spark/spark-gluster/spark-worker-controller.yaml
	==> app-01: kubernetes/examples/spark/spark-gluster/spark-master-controller.yaml
	==> app-01: kubernetes/examples/spark/README.md
	==> app-01: kubernetes/examples/spark/spark-master-service.yaml
	==> app-01: kubernetes/examples/spark/spark-worker-controller.yaml
	==> app-01: kubernetes/examples/spark/spark-master-controller.yaml
	==> app-01: kubernetes/examples/spark/zeppelin-controller.yaml
	==> app-01: kubernetes/examples/spark/zeppelin-service.yaml
	==> app-01: kubernetes/examples/spark/namespace-spark-cluster.yaml
	==> app-01: kubernetes/examples/spark/spark-webui.yaml
	==> app-01: kubernetes/examples/pod
	==> app-01: kubernetes/examples/meteor/
	==> app-01: kubernetes/examples/meteor/mongo-pod.json
	==> app-01: kubernetes/examples/meteor/README.md
	==> app-01: kubernetes/examples/meteor/dockerbase/
	==> app-01: kubernetes/examples/meteor/dockerbase/README.md
	==> app-01: kubernetes/examples/meteor/dockerbase/Dockerfile
	==> app-01: kubernetes/examples/meteor/mongo-service.json
	==> app-01: kubernetes/examples/meteor/meteor-controller.json
	==> app-01: kubernetes/examples/meteor/meteor-service.json
	==> app-01: kubernetes/examples/kubectl-container/
	==> app-01: kubernetes/examples/kubectl-container/README.md
	==> app-01: kubernetes/examples/kubectl-container/Dockerfile
	==> app-01: kubernetes/examples/kubectl-container/.gitignore
	==> app-01: kubernetes/examples/kubectl-container/Makefile
	==> app-01: kubernetes/examples/kubectl-container/pod.json
	==> app-01: kubernetes/examples/apiserver/
	==> app-01: kubernetes/examples/apiserver/README.md
	==> app-01: kubernetes/examples/apiserver/server/
	==> app-01: kubernetes/examples/apiserver/server/main.go
	==> app-01: kubernetes/examples/apiserver/rest/
	==> app-01: kubernetes/examples/apiserver/rest/reststorage.go
	==> app-01: kubernetes/examples/apiserver/apiserver.go
	==> app-01: kubernetes/examples/guidelines.md
	==> app-01: kubernetes/platforms/
	==> app-01: kubernetes/platforms/darwin/
	==> app-01: kubernetes/platforms/darwin/amd64/
	==> app-01: kubernetes/platforms/darwin/amd64/kubectl
	==> app-01: kubernetes/platforms/darwin/386/
	==> app-01: kubernetes/platforms/darwin/386/kubectl
	==> app-01: kubernetes/platforms/linux/
	==> app-01: kubernetes/platforms/linux/arm/
	==> app-01: kubernetes/platforms/linux/arm/kubectl
	==> app-01: kubernetes/platforms/linux/amd64/
	==> app-01: kubernetes/platforms/linux/amd64/kubectl
	==> app-01: kubernetes/platforms/linux/arm64/
	==> app-01: kubernetes/platforms/linux/arm64/kubectl
	==> app-01: kubernetes/platforms/linux/386/
	==> app-01: kubernetes/platforms/linux/386/kubectl
	==> app-01: kubernetes/platforms/windows/
	==> app-01: kubernetes/platforms/windows/amd64/
	==> app-01: kubernetes/platforms/windows/amd64/kubectl.exe
	==> app-01: kubernetes/platforms/windows/386/
	==> app-01: kubernetes/platforms/windows/386/kubectl.exe
	==> app-01: + cd /opt/kubernetes-1.5.0/server/
	==> app-01: + tar -zxvf kubernetes-server-linux-amd64.tar.gz
	==> app-01: kubernetes/
	==> app-01: kubernetes/kubernetes-src.tar.gz
	==> app-01: kubernetes/LICENSES
	==> app-01: kubernetes/server/
	==> app-01: kubernetes/server/bin/
	==> app-01: kubernetes/server/bin/kube-apiserver.tar
	==> app-01: kubernetes/server/bin/kube-discovery
	==> app-01: kubernetes/server/bin/kube-proxy.docker_tag
	==> app-01: kubernetes/server/bin/kube-dns
	==> app-01: kubernetes/server/bin/kube-scheduler.tar
	==> app-01: kubernetes/server/bin/kube-scheduler
	==> app-01: kubernetes/server/bin/kubelet
	==> app-01: kubernetes/server/bin/kube-controller-manager.docker_tag
	==> app-01: kubernetes/server/bin/kube-proxy
	==> app-01: kubernetes/server/bin/kubeadm
	==> app-01: kubernetes/server/bin/kube-controller-manager
	==> app-01: kubernetes/server/bin/hyperkube
	==> app-01: kubernetes/server/bin/kube-controller-manager.tar
	==> app-01: kubernetes/server/bin/kube-apiserver
	==> app-01: kubernetes/server/bin/kubectl
	==> app-01: kubernetes/server/bin/kube-apiserver.docker_tag
	==> app-01: kubernetes/server/bin/kube-proxy.tar
	==> app-01: kubernetes/server/bin/kube-scheduler.docker_tag
	==> app-01: kubernetes/addons/
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
	==> app-02: + sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse'
	==> app-02: + sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse'
	==> app-02: + sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse'
	==> app-02: + sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse'
	==> app-02: + sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse'
	==> app-02: + sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse'
	==> app-02: + sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse'
	==> app-02: + sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse'
	==> app-02: + sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse'
	==> app-02: + sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse'
	==> app-02: + sudo apt-get update -y -q
	==> app-02: Ign http://mirrors.aliyun.com trusty InRelease
	==> app-02: Get:1 http://mirrors.aliyun.com trusty-security InRelease [65.9 kB]
	==> app-02: Get:2 http://mirrors.aliyun.com trusty-updates InRelease [65.9 kB]
	==> app-02: Get:3 http://mirrors.aliyun.com trusty-proposed InRelease [65.9 kB]
	==> app-02: Get:4 http://ppa.launchpad.net trusty InRelease [16.0 kB]
	==> app-02: Get:5 http://mirrors.aliyun.com trusty-backports InRelease [65.9 kB]
	==> app-02: Get:6 http://mirrors.aliyun.com trusty Release.gpg [933 B]
	==> app-02: Get:7 http://mirrors.aliyun.com trusty-security/main Sources [120 kB]
	==> app-02: Get:8 http://mirrors.aliyun.com trusty-security/restricted Sources [4,064 B]
	==> app-02: Get:9 http://mirrors.aliyun.com trusty-security/universe Sources [44.7 kB]
	==> app-02: Get:10 http://mirrors.aliyun.com trusty-security/multiverse Sources [3,202 B]
	==> app-02: Get:11 http://mirrors.aliyun.com trusty-security/main amd64 Packages [542 kB]
	==> app-02: Get:12 http://ppa.launchpad.net trusty/main Translation-en [713 B]
	==> app-02: Get:13 http://ppa.launchpad.net trusty/main amd64 Packages [1,706 B]
	==> app-02: Get:14 http://mirrors.aliyun.com trusty-security/restricted amd64 Packages [13.0 kB]
	==> app-02: Get:15 http://mirrors.aliyun.com trusty-security/universe amd64 Packages [141 kB]
	==> app-02: Get:16 http://mirrors.aliyun.com trusty-security/multiverse amd64 Packages [5,199 B]
	==> app-02: Get:17 http://mirrors.aliyun.com trusty-security/main Translation-en [298 kB]
	==> app-02: Get:18 http://mirrors.aliyun.com trusty-security/multiverse Translation-en [2,848 B]
	==> app-02: Get:19 http://mirrors.aliyun.com trusty-security/restricted Translation-en [3,206 B]
	==> app-02: Get:20 http://mirrors.aliyun.com trusty-security/universe Translation-en [84.3 kB]
	==> app-02: Get:21 http://mirrors.aliyun.com trusty-updates/main Sources [383 kB]
	==> app-02: Get:22 http://mirrors.aliyun.com trusty-updates/restricted Sources [5,360 B]
	==> app-02: Get:23 http://mirrors.aliyun.com trusty-updates/universe Sources [169 kB]
	==> app-02: Get:24 http://mirrors.aliyun.com trusty-updates/multiverse Sources [7,531 B]
	==> app-02: Get:25 http://mirrors.aliyun.com trusty-updates/main amd64 Packages [910 kB]
	==> app-02: Get:26 http://mirrors.aliyun.com trusty-updates/restricted amd64 Packages [15.9 kB]
	==> app-02: Get:27 http://mirrors.aliyun.com trusty-updates/universe amd64 Packages [387 kB]
	==> app-02: Get:28 http://mirrors.aliyun.com trusty-updates/multiverse amd64 Packages [15.0 kB]
	==> app-02: Get:29 http://mirrors.aliyun.com trusty-updates/main Translation-en [443 kB]
	==> app-02: Get:30 http://mirrors.aliyun.com trusty-updates/multiverse Translation-en [7,931 B]
	==> app-02: Get:31 http://mirrors.aliyun.com trusty-updates/restricted Translation-en [3,699 B]
	==> app-02: Get:32 http://mirrors.aliyun.com trusty-updates/universe Translation-en [205 kB]
	==> app-02: Get:33 http://mirrors.aliyun.com trusty-proposed/main Sources [116 kB]
	==> app-02: Get:34 http://mirrors.aliyun.com trusty-proposed/restricted Sources [28 B]
	==> app-02: Get:35 http://mirrors.aliyun.com trusty-proposed/universe Sources [16.9 kB]
	==> app-02: Get:36 http://mirrors.aliyun.com trusty-proposed/multiverse Sources [28 B]
	==> app-02: Get:37 http://mirrors.aliyun.com trusty-proposed/main amd64 Packages [99.4 kB]
	==> app-02: Get:38 http://mirrors.aliyun.com trusty-proposed/restricted amd64 Packages [28 B]
	==> app-02: Get:39 http://mirrors.aliyun.com trusty-proposed/universe amd64 Packages [12.1 kB]
	==> app-02: Get:40 http://mirrors.aliyun.com trusty-proposed/multiverse amd64 Packages [28 B]
	==> app-02: Get:41 http://mirrors.aliyun.com trusty-proposed/main Translation-en [34.3 kB]
	==> app-02: Get:42 http://mirrors.aliyun.com trusty-proposed/multiverse Translation-en [28 B]
	==> app-02: Get:43 http://mirrors.aliyun.com trusty-proposed/restricted Translation-en [28 B]
	==> app-02: Get:44 http://mirrors.aliyun.com trusty-proposed/universe Translation-en [10.8 kB]
	==> app-02: Get:45 http://mirrors.aliyun.com trusty-backports/main Sources [9,646 B]
	==> app-02: Get:46 http://mirrors.aliyun.com trusty-backports/restricted Sources [28 B]
	==> app-02: Get:47 http://mirrors.aliyun.com trusty-backports/universe Sources [35.2 kB]
	==> app-02: Get:48 http://mirrors.aliyun.com trusty-backports/multiverse Sources [1,898 B]
	==> app-02: Get:49 http://mirrors.aliyun.com trusty-backports/main amd64 Packages [13.3 kB]
	==> app-02: Get:50 http://mirrors.aliyun.com trusty-backports/restricted amd64 Packages [28 B]
	==> app-02: Get:51 http://mirrors.aliyun.com trusty-backports/universe amd64 Packages [43.2 kB]
	==> app-02: Get:52 http://mirrors.aliyun.com trusty-backports/multiverse amd64 Packages [1,571 B]
	==> app-02: Get:53 http://mirrors.aliyun.com trusty-backports/main Translation-en [7,493 B]
	==> app-02: Get:54 http://mirrors.aliyun.com trusty-backports/multiverse Translation-en [1,215 B]
	==> app-02: Get:55 http://mirrors.aliyun.com trusty-backports/restricted Translation-en [28 B]
	==> app-02: Get:56 http://mirrors.aliyun.com trusty-backports/universe Translation-en [36.8 kB]
	==> app-02: Get:57 http://mirrors.aliyun.com trusty Release [58.5 kB]
	==> app-02: Get:58 http://mirrors.aliyun.com trusty/main Sources [1,064 kB]
	==> app-02: Get:59 http://mirrors.aliyun.com trusty/restricted Sources [5,433 B]
	==> app-02: Get:60 http://mirrors.aliyun.com trusty/universe Sources [6,399 kB]
	==> app-02: Get:61 http://mirrors.aliyun.com trusty/multiverse Sources [174 kB]
	==> app-02: Get:62 http://mirrors.aliyun.com trusty/main amd64 Packages [1,350 kB]
	==> app-02: Get:63 http://mirrors.aliyun.com trusty/restricted amd64 Packages [13.0 kB]
	==> app-02: Get:64 http://mirrors.aliyun.com trusty/universe amd64 Packages [5,859 kB]
	==> app-02: Get:65 http://mirrors.aliyun.com trusty/multiverse amd64 Packages [132 kB]
	==> app-02: Get:66 http://mirrors.aliyun.com trusty/main Translation-en [762 kB]
	==> app-02: Get:67 http://mirrors.aliyun.com trusty/multiverse Translation-en [102 kB]
	==> app-02: Get:68 http://mirrors.aliyun.com trusty/restricted Translation-en [3,457 B]
	==> app-02: Get:69 http://mirrors.aliyun.com trusty/universe Translation-en [4,089 kB]
	==> app-02: Ign http://mirrors.aliyun.com trusty/main Translation-en_US
	==> app-02: Ign http://mirrors.aliyun.com trusty/multiverse Translation-en_US
	==> app-02: Ign http://mirrors.aliyun.com trusty/restricted Translation-en_US
	==> app-02: Ign http://mirrors.aliyun.com trusty/universe Translation-en_US
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
	==> app-02: Get:1 http://mirrors.aliyun.com/ubuntu/ trusty-security/main libnettle4 amd64 2.7.1-1ubuntu0.1 [102 kB]
	==> app-02: Get:2 http://mirrors.aliyun.com/ubuntu/ trusty-security/main libhogweed2 amd64 2.7.1-1ubuntu0.1 [124 kB]
	==> app-02: Get:3 http://ppa.launchpad.net/openconnect/daily/ubuntu/ trusty/main libopenconnect5 amd64 7.06-0~2492~ubuntu14.04.1 [105 kB]
	==> app-02: Get:4 http://mirrors.aliyun.com/ubuntu/ trusty-security/universe libgnutls28 amd64 3.2.11-2ubuntu1.1 [540 kB]
	==> app-02: Get:5 http://mirrors.aliyun.com/ubuntu/ trusty/main libproxy1 amd64 0.4.11-0ubuntu4 [56.2 kB]
	==> app-02: Get:6 http://mirrors.aliyun.com/ubuntu/ trusty/main libtommath0 amd64 0.42.0-1build1 [55.6 kB]
	==> app-02: Get:7 http://mirrors.aliyun.com/ubuntu/ trusty/universe libtomcrypt0 amd64 1.17-5 [272 kB]
	==> app-02: Get:8 http://ppa.launchpad.net/openconnect/daily/ubuntu/ trusty/main openconnect amd64 7.06-0~2492~ubuntu14.04.1 [418 kB]
	==> app-02: Get:9 http://mirrors.aliyun.com/ubuntu/ trusty/universe libstoken1 amd64 0.2-1 [13.0 kB]
	==> app-02: Get:10 http://mirrors.aliyun.com/ubuntu/ trusty-updates/main iproute all 1:3.12.0-2ubuntu1 [2,392 B]
	==> app-02: Get:11 http://mirrors.aliyun.com/ubuntu/ trusty/universe vpnc-scripts all 0.1~git20120602-2 [12.2 kB]
	==> app-02: dpkg-preconfigure: unable to re-open stdin: No such file or directory
	==> app-02: Fetched 1,700 kB in 5s (294 kB/s)
	==> app-02: Selecting previously unselected package libnettle4:amd64.
	==> app-02: (Reading database ... 62997 files and directories currently installed.)
	==> app-02: Preparing to unpack .../libnettle4_2.7.1-1ubuntu0.1_amd64.deb ...
	==> app-02: Unpacking libnettle4:amd64 (2.7.1-1ubuntu0.1) ...
	==> app-02: Selecting previously unselected package libhogweed2:amd64.
	==> app-02: Preparing to unpack .../libhogweed2_2.7.1-1ubuntu0.1_amd64.deb ...
	==> app-02: Unpacking libhogweed2:amd64 (2.7.1-1ubuntu0.1) ...
	==> app-02: Selecting previously unselected package libgnutls28:amd64.
	==> app-02: Preparing to unpack .../libgnutls28_3.2.11-2ubuntu1.1_amd64.deb ...
	==> app-02: Unpacking libgnutls28:amd64 (3.2.11-2ubuntu1.1) ...
	==> app-02: Selecting previously unselected package libproxy1:amd64.
	==> app-02: Preparing to unpack .../libproxy1_0.4.11-0ubuntu4_amd64.deb ...
	==> app-02: Unpacking libproxy1:amd64 (0.4.11-0ubuntu4) ...
	==> app-02: Selecting previously unselected package libtommath0.
	==> app-02: Preparing to unpack .../libtommath0_0.42.0-1build1_amd64.deb ...
	==> app-02: Unpacking libtommath0 (0.42.0-1build1) ...
	==> app-02: Selecting previously unselected package libtomcrypt0:amd64.
	==> app-02: Preparing to unpack .../libtomcrypt0_1.17-5_amd64.deb ...
	==> app-02: Unpacking libtomcrypt0:amd64 (1.17-5) ...
	==> app-02: Selecting previously unselected package libstoken1:amd64.
	==> app-02: Preparing to unpack .../libstoken1_0.2-1_amd64.deb ...
	==> app-02: Unpacking libstoken1:amd64 (0.2-1) ...
	==> app-02: Selecting previously unselected package libopenconnect5:amd64.
	==> app-02: Preparing to unpack .../libopenconnect5_7.06-0~2492~ubuntu14.04.1_amd64.deb ...
	==> app-02: Unpacking libopenconnect5:amd64 (7.06-0~2492~ubuntu14.04.1) ...
	==> app-02: Selecting previously unselected package iproute.
	==> app-02: Preparing to unpack .../iproute_1%3a3.12.0-2ubuntu1_all.deb ...
	==> app-02: Unpacking iproute (1:3.12.0-2ubuntu1) ...
	==> app-02: Selecting previously unselected package vpnc-scripts.
	==> app-02: Preparing to unpack .../vpnc-scripts_0.1~git20120602-2_all.deb ...
	==> app-02: Unpacking vpnc-scripts (0.1~git20120602-2) ...
	==> app-02: Selecting previously unselected package openconnect.
	==> app-02: Preparing to unpack .../openconnect_7.06-0~2492~ubuntu14.04.1_amd64.deb ...
	==> app-02: Unpacking openconnect (7.06-0~2492~ubuntu14.04.1) ...
	==> app-02: Processing triggers for man-db (2.6.7.1-1ubuntu1) ...
	==> app-02: Setting up libnettle4:amd64 (2.7.1-1ubuntu0.1) ...
	==> app-02: Setting up libhogweed2:amd64 (2.7.1-1ubuntu0.1) ...
	==> app-02: Setting up libgnutls28:amd64 (3.2.11-2ubuntu1.1) ...
	==> app-02: Setting up libproxy1:amd64 (0.4.11-0ubuntu4) ...
	==> app-02: Setting up libtommath0 (0.42.0-1build1) ...
	==> app-02: Setting up libtomcrypt0:amd64 (1.17-5) ...
	==> app-02: Setting up libstoken1:amd64 (0.2-1) ...
	==> app-02: Setting up libopenconnect5:amd64 (7.06-0~2492~ubuntu14.04.1) ...
	==> app-02: Setting up iproute (1:3.12.0-2ubuntu1) ...
	==> app-02: Setting up vpnc-scripts (0.1~git20120602-2) ...
	==> app-02: Setting up openconnect (7.06-0~2492~ubuntu14.04.1) ...
	==> app-02: Processing triggers for libc-bin (2.19-0ubuntu6.9) ...
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
	==> app-02: kubernetes/third_party/
	==> app-02: kubernetes/third_party/htpasswd/
	==> app-02: kubernetes/third_party/htpasswd/htpasswd.py
	==> app-02: kubernetes/third_party/htpasswd/COPYING
	==> app-02: kubernetes/README.md
	==> app-02: kubernetes/docs/
	==> app-02: kubernetes/docs/api-reference/
	==> app-02: kubernetes/docs/api-reference/policy/
	==> app-02: kubernetes/docs/api-reference/policy/v1alpha1/
	==> app-02: kubernetes/docs/api-reference/policy/v1alpha1/operations.html
	==> app-02: kubernetes/docs/api-reference/policy/v1alpha1/definitions.html
	==> app-02: kubernetes/docs/api-reference/README.md
	==> app-02: kubernetes/docs/api-reference/v1/
	==> app-02: kubernetes/docs/api-reference/v1/operations.html
	==> app-02: kubernetes/docs/api-reference/v1/definitions.md
	==> app-02: kubernetes/docs/api-reference/v1/operations.md
	==> app-02: kubernetes/docs/api-reference/v1/definitions.html
	==> app-02: kubernetes/docs/api-reference/authorization.k8s.io/
	==> app-02: kubernetes/docs/api-reference/authorization.k8s.io/v1beta1/
	==> app-02: kubernetes/docs/api-reference/authorization.k8s.io/v1beta1/operations.html
	==> app-02: kubernetes/docs/api-reference/authorization.k8s.io/v1beta1/definitions.html
	==> app-02: kubernetes/docs/api-reference/labels-annotations-taints.md
	==> app-02: kubernetes/docs/api-reference/autoscaling/
	==> app-02: kubernetes/docs/api-reference/autoscaling/v1/
	==> app-02: kubernetes/docs/api-reference/autoscaling/v1/operations.html
	==> app-02: kubernetes/docs/api-reference/autoscaling/v1/definitions.html
	==> app-02: kubernetes/docs/api-reference/rbac.authorization.k8s.io/
	==> app-02: kubernetes/docs/api-reference/rbac.authorization.k8s.io/v1alpha1/
	==> app-02: kubernetes/docs/api-reference/rbac.authorization.k8s.io/v1alpha1/operations.html
	==> app-02: kubernetes/docs/api-reference/rbac.authorization.k8s.io/v1alpha1/definitions.html
	==> app-02: kubernetes/docs/api-reference/certificates.k8s.io/
	==> app-02: kubernetes/docs/api-reference/certificates.k8s.io/v1alpha1/
	==> app-02: kubernetes/docs/api-reference/certificates.k8s.io/v1alpha1/operations.html
	==> app-02: kubernetes/docs/api-reference/certificates.k8s.io/v1alpha1/definitions.html
	==> app-02: kubernetes/docs/api-reference/authentication.k8s.io/
	==> app-02: kubernetes/docs/api-reference/authentication.k8s.io/v1beta1/
	==> app-02: kubernetes/docs/api-reference/authentication.k8s.io/v1beta1/operations.html
	==> app-02: kubernetes/docs/api-reference/authentication.k8s.io/v1beta1/definitions.html
	==> app-02: kubernetes/docs/api-reference/apps/
	==> app-02: kubernetes/docs/api-reference/apps/v1alpha1/
	==> app-02: kubernetes/docs/api-reference/apps/v1alpha1/operations.html
	==> app-02: kubernetes/docs/api-reference/apps/v1alpha1/definitions.html
	==> app-02: kubernetes/docs/api-reference/extensions/
	==> app-02: kubernetes/docs/api-reference/extensions/v1beta1/
	==> app-02: kubernetes/docs/api-reference/extensions/v1beta1/operations.html
	==> app-02: kubernetes/docs/api-reference/extensions/v1beta1/definitions.md
	==> app-02: kubernetes/docs/api-reference/extensions/v1beta1/operations.md
	==> app-02: kubernetes/docs/api-reference/extensions/v1beta1/definitions.html
	==> app-02: kubernetes/docs/api-reference/batch/
	==> app-02: kubernetes/docs/api-reference/batch/v1/
	==> app-02: kubernetes/docs/api-reference/batch/v1/operations.html
	==> app-02: kubernetes/docs/api-reference/batch/v1/definitions.html
	==> app-02: kubernetes/docs/api-reference/batch/v2alpha1/
	==> app-02: kubernetes/docs/api-reference/batch/v2alpha1/operations.html
	==> app-02: kubernetes/docs/api-reference/batch/v2alpha1/definitions.html
	==> app-02: kubernetes/docs/api-reference/storage.k8s.io/
	==> app-02: kubernetes/docs/api-reference/storage.k8s.io/v1beta1/
	==> app-02: kubernetes/docs/api-reference/storage.k8s.io/v1beta1/operations.html
	==> app-02: kubernetes/docs/api-reference/storage.k8s.io/v1beta1/definitions.html
	==> app-02: kubernetes/docs/getting-started-guides/
	==> app-02: kubernetes/docs/getting-started-guides/mesos.md
	==> app-02: kubernetes/docs/getting-started-guides/scratch.md
	==> app-02: kubernetes/docs/getting-started-guides/dcos.md
	==> app-02: kubernetes/docs/getting-started-guides/libvirt-coreos.md
	==> app-02: kubernetes/docs/getting-started-guides/README.md
	==> app-02: kubernetes/docs/getting-started-guides/azure.md
	==> app-02: kubernetes/docs/getting-started-guides/ubuntu-calico.md
	==> app-02: kubernetes/docs/getting-started-guides/aws.md
	==> app-02: kubernetes/docs/getting-started-guides/gce.md
	==> app-02: kubernetes/docs/getting-started-guides/coreos/
	==> app-02: kubernetes/docs/getting-started-guides/coreos/coreos_multinode_cluster.md
	==> app-02: kubernetes/docs/getting-started-guides/coreos/bare_metal_offline.md
	==> app-02: kubernetes/docs/getting-started-guides/coreos/bare_metal_calico.md
	==> app-02: kubernetes/docs/getting-started-guides/coreos/azure/
	==> app-02: kubernetes/docs/getting-started-guides/coreos/azure/README.md
	==> app-02: kubernetes/docs/getting-started-guides/centos/
	==> app-02: kubernetes/docs/getting-started-guides/centos/centos_manual_config.md
	==> app-02: kubernetes/docs/getting-started-guides/docker.md
	==> app-02: kubernetes/docs/getting-started-guides/docker-multinode.md
	==> app-02: kubernetes/docs/getting-started-guides/coreos.md
	==> app-02: kubernetes/docs/getting-started-guides/ovirt.md
	==> app-02: kubernetes/docs/getting-started-guides/juju.md
	==> app-02: kubernetes/docs/getting-started-guides/rackspace.md
	==> app-02: kubernetes/docs/getting-started-guides/rkt/
	==> app-02: kubernetes/docs/getting-started-guides/rkt/README.md
	==> app-02: kubernetes/docs/getting-started-guides/rkt/notes.md
	==> app-02: kubernetes/docs/getting-started-guides/ubuntu.md
	==> app-02: kubernetes/docs/getting-started-guides/cloudstack.md
	==> app-02: kubernetes/docs/getting-started-guides/mesos-docker.md
	==> app-02: kubernetes/docs/getting-started-guides/vsphere.md
	==> app-02: kubernetes/docs/getting-started-guides/logging.md
	==> app-02: kubernetes/docs/getting-started-guides/logging-elasticsearch.md
	==> app-02: kubernetes/docs/getting-started-guides/binary_release.md
	==> app-02: kubernetes/docs/getting-started-guides/fedora/
	==> app-02: kubernetes/docs/getting-started-guides/fedora/fedora_ansible_config.md
	==> app-02: kubernetes/docs/getting-started-guides/fedora/fedora_manual_config.md
	==> app-02: kubernetes/docs/getting-started-guides/fedora/flannel_multi_node_cluster.md
	==> app-02: kubernetes/docs/README.md
	==> app-02: kubernetes/docs/design/
	==> app-02: kubernetes/docs/design/admission_control_resource_quota.md
	==> app-02: kubernetes/docs/design/ubernetes-design.png
	==> app-02: kubernetes/docs/design/ubernetes-cluster-state.png
	==> app-02: kubernetes/docs/design/expansion.md
	==> app-02: kubernetes/docs/design/namespaces.md
	==> app-02: kubernetes/docs/design/clustering.md
	==> app-02: kubernetes/docs/design/resource-qos.md
	==> app-02: kubernetes/docs/design/taint-toleration-dedicated.md
	==> app-02: kubernetes/docs/design/indexed-job.md
	==> app-02: kubernetes/docs/design/principles.md
	==> app-02: kubernetes/docs/design/README.md
	==> app-02: kubernetes/docs/design/enhance-pluggable-policy.md
	==> app-02: kubernetes/docs/design/identifiers.md
	==> app-02: kubernetes/docs/design/admission_control_limit_range.md
	==> app-02: kubernetes/docs/design/security.md
	==> app-02: kubernetes/docs/design/simple-rolling-update.md
	==> app-02: kubernetes/docs/design/podaffinity.md
	==> app-02: kubernetes/docs/design/federation-phase-1.md
	==> app-02: kubernetes/docs/design/architecture.dia
	==> app-02: kubernetes/docs/design/versioning.md
	==> app-02: kubernetes/docs/design/resources.md
	==> app-02: kubernetes/docs/design/persistent-storage.md
	==> app-02: kubernetes/docs/design/event_compression.md
	==> app-02: kubernetes/docs/design/ubernetes-scheduling.png
	==> app-02: kubernetes/docs/design/volume-snapshotting.png
	==> app-02: kubernetes/docs/design/daemon.md
	==> app-02: kubernetes/docs/design/extending-api.md
	==> app-02: kubernetes/docs/design/architecture.md
	==> app-02: kubernetes/docs/design/secrets.md
	==> app-02: kubernetes/docs/design/command_execution_port_forwarding.md
	==> app-02: kubernetes/docs/design/networking.md
	==> app-02: kubernetes/docs/design/nodeaffinity.md
	==> app-02: kubernetes/docs/design/downward_api_resources_limits_requests.md
	==> app-02: kubernetes/docs/design/selector-generation.md
	==> app-02: kubernetes/docs/design/horizontal-pod-autoscaler.md
	==> app-02: kubernetes/docs/design/seccomp.md
	==> app-02: kubernetes/docs/design/clustering/
	==> app-02: kubernetes/docs/design/clustering/dynamic.png
	==> app-02: kubernetes/docs/design/clustering/README.md
	==> app-02: kubernetes/docs/design/clustering/dynamic.seqdiag
	==> app-02: kubernetes/docs/design/clustering/Dockerfile
	==> app-02: kubernetes/docs/design/clustering/.gitignore
	==> app-02: kubernetes/docs/design/clustering/static.seqdiag
	==> app-02: kubernetes/docs/design/clustering/static.png
	==> app-02: kubernetes/docs/design/clustering/Makefile
	==> app-02: kubernetes/docs/design/architecture.svg
	==> app-02: kubernetes/docs/design/control-plane-resilience.md
	==> app-02: kubernetes/docs/design/security_context.md
	==> app-02: kubernetes/docs/design/scheduler_extender.md
	==> app-02: kubernetes/docs/design/volume-snapshotting.md
	==> app-02: kubernetes/docs/design/metadata-policy.md
	==> app-02: kubernetes/docs/design/architecture.png
	==> app-02: kubernetes/docs/design/aws_under_the_hood.md
	==> app-02: kubernetes/docs/design/admission_control.md
	==> app-02: kubernetes/docs/design/federated-services.md
	==> app-02: kubernetes/docs/design/service_accounts.md
	==> app-02: kubernetes/docs/design/access.md
	==> app-02: kubernetes/docs/design/selinux.md
	==> app-02: kubernetes/docs/design/configmap.md
	==> app-02: kubernetes/docs/OWNERS
	==> app-02: kubernetes/docs/proposals/
	==> app-02: kubernetes/docs/proposals/kubectl-login.md
	==> app-02: kubernetes/docs/proposals/resource-quota-scoping.md
	==> app-02: kubernetes/docs/proposals/kubelet-systemd.md
	==> app-02: kubernetes/docs/proposals/protobuf.md
	==> app-02: kubernetes/docs/proposals/gpu-support.md
	==> app-02: kubernetes/docs/proposals/kubelet-hypercontainer-runtime.md
	==> app-02: kubernetes/docs/proposals/templates.md
	==> app-02: kubernetes/docs/proposals/multiple-schedulers.md
	==> app-02: kubernetes/docs/proposals/garbage-collection.md
	==> app-02: kubernetes/docs/proposals/runtimeconfig.md
	==> app-02: kubernetes/docs/proposals/controller-ref.md
	==> app-02: kubernetes/docs/proposals/pod-resource-management.md
	==> app-02: kubernetes/docs/proposals/pod-security-context.md
	==> app-02: kubernetes/docs/proposals/high-availability.md
	==> app-02: kubernetes/docs/proposals/volumes.md
	==> app-02: kubernetes/docs/proposals/local-cluster-ux.md
	==> app-02: kubernetes/docs/proposals/volume-selectors.md
	==> app-02: kubernetes/docs/proposals/rescheduling.md
	==> app-02: kubernetes/docs/proposals/scalability-testing.md
	==> app-02: kubernetes/docs/proposals/client-package-structure.md
	==> app-02: kubernetes/docs/proposals/apiserver-watch.md
	==> app-02: kubernetes/docs/proposals/custom-metrics.md
	==> app-02: kubernetes/docs/proposals/runtime-client-server.md
	==> app-02: kubernetes/docs/proposals/federated-api-servers.md
	==> app-02: kubernetes/docs/proposals/release-notes.md
	==> app-02: kubernetes/docs/proposals/service-discovery.md
	==> app-02: kubernetes/docs/proposals/external-lb-source-ip-preservation.md
	==> app-02: kubernetes/docs/proposals/job.md
	==> app-02: kubernetes/docs/proposals/federation-lite.md
	==> app-02: kubernetes/docs/proposals/volume-provisioning.md
	==> app-02: kubernetes/docs/proposals/deployment.md
	==> app-02: kubernetes/docs/proposals/pod-lifecycle-event-generator.md
	==> app-02: kubernetes/docs/proposals/resource-metrics-api.md
	==> app-02: kubernetes/docs/proposals/image-provenance.md
	==> app-02: kubernetes/docs/proposals/kubelet-eviction.md
	==> app-02: kubernetes/docs/proposals/node-allocatable.md
	==> app-02: kubernetes/docs/proposals/secret-configmap-downwarapi-file-mode.md
	==> app-02: kubernetes/docs/proposals/disk-accounting.md
	==> app-02: kubernetes/docs/proposals/rescheduler.md
	==> app-02: kubernetes/docs/proposals/rescheduling-for-critical-pods.md
	==> app-02: kubernetes/docs/proposals/metrics-plumbing.md
	==> app-02: kubernetes/docs/proposals/selinux-enhancements.md
	==> app-02: kubernetes/docs/proposals/initial-resources.md
	==> app-02: kubernetes/docs/proposals/container-runtime-interface-v1.md
	==> app-02: kubernetes/docs/proposals/security-context-constraints.md
	==> app-02: kubernetes/docs/proposals/node-allocatable.png
	==> app-02: kubernetes/docs/proposals/scheduledjob.md
	==> app-02: kubernetes/docs/proposals/performance-related-monitoring.md
	==> app-02: kubernetes/docs/proposals/pod-cache.png
	==> app-02: kubernetes/docs/proposals/network-policy.md
	==> app-02: kubernetes/docs/proposals/multi-platform.md
	==> app-02: kubernetes/docs/proposals/runtime-pod-cache.md
	==> app-02: kubernetes/docs/proposals/kubemark.md
	==> app-02: kubernetes/docs/proposals/flannel-integration.md
	==> app-02: kubernetes/docs/proposals/kubelet-auth.md
	==> app-02: kubernetes/docs/proposals/api-group.md
	==> app-02: kubernetes/docs/proposals/federation-high-level-arch.png
	==> app-02: kubernetes/docs/proposals/dramatically-simplify-cluster-creation.md
	==> app-02: kubernetes/docs/proposals/images/
	==> app-02: kubernetes/docs/proposals/images/.gitignore
	==> app-02: kubernetes/docs/proposals/cluster-deployment.md
	==> app-02: kubernetes/docs/proposals/apparmor.md
	==> app-02: kubernetes/docs/proposals/pleg.png
	==> app-02: kubernetes/docs/proposals/federation.md
	==> app-02: kubernetes/docs/proposals/kubelet-tls-bootstrap.md
	==> app-02: kubernetes/docs/proposals/Kubemark_architecture.png
	==> app-02: kubernetes/docs/proposals/container-init.md
	==> app-02: kubernetes/docs/proposals/service-external-name.md
	==> app-02: kubernetes/docs/proposals/deploy.md
	==> app-02: kubernetes/docs/proposals/volume-ownership-management.md
	==> app-02: kubernetes/docs/proposals/self-hosted-kubelet.md
	==> app-02: kubernetes/docs/user-guide/
	==> app-02: kubernetes/docs/user-guide/security-context.md
	==> app-02: kubernetes/docs/user-guide/namespaces.md
	==> app-02: kubernetes/docs/user-guide/debugging-services.md
	==> app-02: kubernetes/docs/user-guide/connecting-to-applications-port-forward.md
	==> app-02: kubernetes/docs/user-guide/ingress.md
	==> app-02: kubernetes/docs/user-guide/README.md
	==> app-02: kubernetes/docs/user-guide/accessing-the-cluster.md
	==> app-02: kubernetes/docs/user-guide/horizontal-pod-autoscaling/
	==> app-02: kubernetes/docs/user-guide/horizontal-pod-autoscaling/README.md
	==> app-02: kubernetes/docs/user-guide/identifiers.md
	==> app-02: kubernetes/docs/user-guide/simple-nginx.md
	==> app-02: kubernetes/docs/user-guide/images.md
	==> app-02: kubernetes/docs/user-guide/kubectl-overview.md
	==> app-02: kubernetes/docs/user-guide/volumes.md
	==> app-02: kubernetes/docs/user-guide/deployments.md
	==> app-02: kubernetes/docs/user-guide/persistent-volumes.md
	==> app-02: kubernetes/docs/user-guide/deploying-applications.md
	==> app-02: kubernetes/docs/user-guide/jobs.md
	==> app-02: kubernetes/docs/user-guide/node-selection/
	==> app-02: kubernetes/docs/user-guide/node-selection/README.md
	==> app-02: kubernetes/docs/user-guide/downward-api/
	==> app-02: kubernetes/docs/user-guide/downward-api/README.md
	==> app-02: kubernetes/docs/user-guide/downward-api/volume/
	==> app-02: kubernetes/docs/user-guide/downward-api/volume/README.md
	==> app-02: kubernetes/docs/user-guide/application-troubleshooting.md
	==> app-02: kubernetes/docs/user-guide/getting-into-containers.md
	==> app-02: kubernetes/docs/user-guide/config-best-practices.md
	==> app-02: kubernetes/docs/user-guide/kubeconfig-file.md
	==> app-02: kubernetes/docs/user-guide/containers.md
	==> app-02: kubernetes/docs/user-guide/introspection-and-debugging.md
	==> app-02: kubernetes/docs/user-guide/update-demo/
	==> app-02: kubernetes/docs/user-guide/update-demo/README.md
	==> app-02: kubernetes/docs/user-guide/resourcequota/
	==> app-02: kubernetes/docs/user-guide/resourcequota/README.md
	==> app-02: kubernetes/docs/user-guide/configmap/
	==> app-02: kubernetes/docs/user-guide/configmap/README.md
	==> app-02: kubernetes/docs/user-guide/compute-resources.md
	==> app-02: kubernetes/docs/user-guide/ui.md
	==> app-02: kubernetes/docs/user-guide/labels.md
	==> app-02: kubernetes/docs/user-guide/environment-guide/
	==> app-02: kubernetes/docs/user-guide/environment-guide/README.md
	==> app-02: kubernetes/docs/user-guide/environment-guide/containers/
	==> app-02: kubernetes/docs/user-guide/environment-guide/containers/README.md
	==> app-02: kubernetes/docs/user-guide/container-environment.md
	==> app-02: kubernetes/docs/user-guide/production-pods.md
	==> app-02: kubernetes/docs/user-guide/liveness/
	==> app-02: kubernetes/docs/user-guide/liveness/README.md
	==> app-02: kubernetes/docs/user-guide/downward-api.md
	==> app-02: kubernetes/docs/user-guide/services-firewalls.md
	==> app-02: kubernetes/docs/user-guide/sharing-clusters.md
	==> app-02: kubernetes/docs/user-guide/docker-cli-to-kubectl.md
	==> app-02: kubernetes/docs/user-guide/configuring-containers.md
	==> app-02: kubernetes/docs/user-guide/working-with-resources.md
	==> app-02: kubernetes/docs/user-guide/simple-yaml.md
	==> app-02: kubernetes/docs/user-guide/logging-demo/
	==> app-02: kubernetes/docs/user-guide/logging-demo/README.md
	==> app-02: kubernetes/docs/user-guide/connecting-applications.md
	==> app-02: kubernetes/docs/user-guide/jsonpath.md
	==> app-02: kubernetes/docs/user-guide/secrets.md
	==> app-02: kubernetes/docs/user-guide/connecting-to-applications-proxy.md
	==> app-02: kubernetes/docs/user-guide/pods.md
	==> app-02: kubernetes/docs/user-guide/persistent-volumes/
	==> app-02: kubernetes/docs/user-guide/persistent-volumes/README.md
	==> app-02: kubernetes/docs/user-guide/kubectl-cheatsheet.md
	==> app-02: kubernetes/docs/user-guide/replication-controller.md
	==> app-02: kubernetes/docs/user-guide/services.md
	==> app-02: kubernetes/docs/user-guide/managing-deployments.md
	==> app-02: kubernetes/docs/user-guide/horizontal-pod-autoscaler.md
	==> app-02: kubernetes/docs/user-guide/secrets/
	==> app-02: kubernetes/docs/user-guide/secrets/README.md
	==> app-02: kubernetes/docs/user-guide/walkthrough/
	==> app-02: kubernetes/docs/user-guide/walkthrough/README.md
	==> app-02: kubernetes/docs/user-guide/walkthrough/k8s201.md
	==> app-02: kubernetes/docs/user-guide/monitoring.md
	==> app-02: kubernetes/docs/user-guide/logging.md
	==> app-02: kubernetes/docs/user-guide/overview.md
	==> app-02: kubernetes/docs/user-guide/pod-states.md
	==> app-02: kubernetes/docs/user-guide/annotations.md
	==> app-02: kubernetes/docs/user-guide/prereqs.md
	==> app-02: kubernetes/docs/user-guide/kubectl/
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_create_quota.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_version.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_rolling-update.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_exec.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_create_service_nodeport.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_rollout_pause.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_top_pod.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_get.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_config_set-cluster.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_config_unset.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_create_namespace.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_replace.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_create_serviceaccount.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_create_deployment.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_create_secret_docker-registry.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_create_service.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_logs.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_expose.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_config_delete-cluster.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_cordon.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_create_secret_tls.md
	==> app-02: kubernetes/docs/user-guide/kubectl/.files_generated
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_taint.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_rollout_resume.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_delete.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_top-node.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_explain.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_cluster-info_dump.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_rollout_history.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_edit.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_apply.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_run.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_rollout_status.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_annotate.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_set.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_set_image.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_top-pod.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_create_secret.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_config_get-contexts.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_create_configmap.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_create_secret_generic.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_rollout.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_config_set-credentials.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_config_view.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_port-forward.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_config_set-context.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_drain.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_rollout_undo.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_top.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_create_service_clusterip.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_describe.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_attach.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_label.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_cluster-info.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_options.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_config.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_completion.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_create_service_loadbalancer.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_top_node.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_config_get-clusters.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_convert.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_autoscale.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_scale.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_api-versions.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_config_delete-context.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_stop.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_create.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_config_current-context.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_uncordon.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_patch.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_config_use-context.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_config_set.md
	==> app-02: kubernetes/docs/user-guide/kubectl/kubectl_proxy.md
	==> app-02: kubernetes/docs/user-guide/quick-start.md
	==> app-02: kubernetes/docs/user-guide/known-issues.md
	==> app-02: kubernetes/docs/user-guide/pod-templates.md
	==> app-02: kubernetes/docs/user-guide/service-accounts.md
	==> app-02: kubernetes/docs/user-guide/configmap.md
	==> app-02: kubernetes/docs/warning.png
	==> app-02: kubernetes/docs/admin/
	==> app-02: kubernetes/docs/admin/network-plugins.md
	==> app-02: kubernetes/docs/admin/limitrange/
	==> app-02: kubernetes/docs/admin/limitrange/README.md
	==> app-02: kubernetes/docs/admin/dns.md
	==> app-02: kubernetes/docs/admin/federation-controller-manager.md
	==> app-02: kubernetes/docs/admin/kube-scheduler.md
	==> app-02: kubernetes/docs/admin/namespaces.md
	==> app-02: kubernetes/docs/admin/garbage-collection.md
	==> app-02: kubernetes/docs/admin/README.md
	==> app-02: kubernetes/docs/admin/introduction.md
	==> app-02: kubernetes/docs/admin/high-availability.md
	==> app-02: kubernetes/docs/admin/daemons.md
	==> app-02: kubernetes/docs/admin/master-node-communication.md
	==> app-02: kubernetes/docs/admin/kubelet.md
	==> app-02: kubernetes/docs/admin/federation-apiserver.md
	==> app-02: kubernetes/docs/admin/ovs-networking.md
	==> app-02: kubernetes/docs/admin/resourcequota/
	==> app-02: kubernetes/docs/admin/resourcequota/README.md
	==> app-02: kubernetes/docs/admin/cluster-management.md
	==> app-02: kubernetes/docs/admin/etcd.md
	==> app-02: kubernetes/docs/admin/accessing-the-api.md
	==> app-02: kubernetes/docs/admin/salt.md
	==> app-02: kubernetes/docs/admin/authentication.md
	==> app-02: kubernetes/docs/admin/cluster-troubleshooting.md
	==> app-02: kubernetes/docs/admin/static-pods.md
	==> app-02: kubernetes/docs/admin/service-accounts-admin.md
	==> app-02: kubernetes/docs/admin/cluster-components.md
	==> app-02: kubernetes/docs/admin/multi-cluster.md
	==> app-02: kubernetes/docs/admin/cluster-large.md
	==> app-02: kubernetes/docs/admin/admission-controllers.md
	==> app-02: kubernetes/docs/admin/networking.md
	==> app-02: kubernetes/docs/admin/kube-proxy.md
	==> app-02: kubernetes/docs/admin/kube-controller-manager.md
	==> app-02: kubernetes/docs/admin/namespaces/
	==> app-02: kubernetes/docs/admin/namespaces/README.md
	==> app-02: kubernetes/docs/admin/kube-apiserver.md
	==> app-02: kubernetes/docs/admin/node.md
	==> app-02: kubernetes/docs/admin/authorization.md
	==> app-02: kubernetes/docs/admin/resource-quota.md
	==> app-02: kubernetes/docs/reporting-security-issues.md
	==> app-02: kubernetes/docs/whatisk8s.md
	==> app-02: kubernetes/docs/devel/
	==> app-02: kubernetes/docs/devel/development.md
	==> app-02: kubernetes/docs/devel/instrumentation.md
	==> app-02: kubernetes/docs/devel/pr_workflow.png
	==> app-02: kubernetes/docs/devel/local-cluster/
	==> app-02: kubernetes/docs/devel/local-cluster/vagrant.md
	==> app-02: kubernetes/docs/devel/local-cluster/local.md
	==> app-02: kubernetes/docs/devel/local-cluster/docker.md
	==> app-02: kubernetes/docs/devel/local-cluster/k8s-singlenode-docker.png
	==> app-02: kubernetes/docs/devel/coding-conventions.md
	==> app-02: kubernetes/docs/devel/flaky-tests.md
	==> app-02: kubernetes/docs/devel/README.md
	==> app-02: kubernetes/docs/devel/running-locally.md
	==> app-02: kubernetes/docs/devel/testing.md
	==> app-02: kubernetes/docs/devel/owners.md
	==> app-02: kubernetes/docs/devel/writing-good-e2e-tests.md
	==> app-02: kubernetes/docs/devel/community-expectations.md
	==> app-02: kubernetes/docs/devel/adding-an-APIGroup.md
	==> app-02: kubernetes/docs/devel/gubernator-images/
	==> app-02: kubernetes/docs/devel/gubernator-images/testfailures.png
	==> app-02: kubernetes/docs/devel/gubernator-images/filterpage.png
	==> app-02: kubernetes/docs/devel/gubernator-images/skipping2.png
	==> app-02: kubernetes/docs/devel/gubernator-images/filterpage3.png
	==> app-02: kubernetes/docs/devel/gubernator-images/filterpage2.png
	==> app-02: kubernetes/docs/devel/gubernator-images/filterpage1.png
	==> app-02: kubernetes/docs/devel/gubernator-images/skipping1.png
	==> app-02: kubernetes/docs/devel/e2e-node-tests.md
	==> app-02: kubernetes/docs/devel/on-call-rotations.md
	==> app-02: kubernetes/docs/devel/profiling.md
	==> app-02: kubernetes/docs/devel/issues.md
	==> app-02: kubernetes/docs/devel/client-libraries.md
	==> app-02: kubernetes/docs/devel/on-call-user-support.md
	==> app-02: kubernetes/docs/devel/node-performance-testing.md
	==> app-02: kubernetes/docs/devel/automation.md
	==> app-02: kubernetes/docs/devel/developer-guides/
	==> app-02: kubernetes/docs/devel/developer-guides/vagrant.md
	==> app-02: kubernetes/docs/devel/go-code.md
	==> app-02: kubernetes/docs/devel/kubectl-conventions.md
	==> app-02: kubernetes/docs/devel/godep.md
	==> app-02: kubernetes/docs/devel/api-conventions.md
	==> app-02: kubernetes/docs/devel/getting-builds.md
	==> app-02: kubernetes/docs/devel/mesos-style.md
	==> app-02: kubernetes/docs/devel/collab.md
	==> app-02: kubernetes/docs/devel/kubemark-guide.md
	==> app-02: kubernetes/docs/devel/cherry-picks.md
	==> app-02: kubernetes/docs/devel/gubernator.md
	==> app-02: kubernetes/docs/devel/pr_workflow.dia
	==> app-02: kubernetes/docs/devel/faster_reviews.md
	==> app-02: kubernetes/docs/devel/update-release-docs.md
	==> app-02: kubernetes/docs/devel/e2e-tests.md
	==> app-02: kubernetes/docs/devel/api_changes.md
	==> app-02: kubernetes/docs/devel/cli-roadmap.md
	==> app-02: kubernetes/docs/devel/generating-clientset.md
	==> app-02: kubernetes/docs/devel/pull-requests.md
	==> app-02: kubernetes/docs/devel/logging.md
	==> app-02: kubernetes/docs/devel/git_workflow.png
	==> app-02: kubernetes/docs/devel/writing-a-getting-started-guide.md
	==> app-02: kubernetes/docs/devel/scheduler_algorithm.md
	==> app-02: kubernetes/docs/devel/updating-docs-for-feature-changes.md
	==> app-02: kubernetes/docs/devel/on-call-build-cop.md
	==> app-02: kubernetes/docs/devel/scheduler.md
	==> app-02: kubernetes/docs/devel/how-to-doc.md
	==> app-02: kubernetes/docs/images/
	==> app-02: kubernetes/docs/images/newgui.png
	==> app-02: kubernetes/docs/yaml/
	==> app-02: kubernetes/docs/yaml/kubectl/
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_completion.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_scale.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_top-node.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_api-versions.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_taint.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_version.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_apply.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_exec.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_delete.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_autoscale.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_port-forward.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_edit.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_options.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_create.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_top-pod.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_cordon.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_stop.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_attach.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_expose.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_proxy.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_config.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_annotate.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_drain.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_explain.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_describe.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_cluster-info.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_patch.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_logs.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_rolling-update.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_convert.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_run.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_label.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_replace.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_rollout.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_top.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_uncordon.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_set.yaml
	==> app-02: kubernetes/docs/yaml/kubectl/kubectl_get.yaml
	==> app-02: kubernetes/docs/roadmap.md
	==> app-02: kubernetes/docs/man/
	==> app-02: kubernetes/docs/man/man1/
	==> app-02: kubernetes/docs/man/man1/kubectl.1
	==> app-02: kubernetes/docs/man/man1/kubectl-config-view.1
	==> app-02: kubernetes/docs/man/man1/kube-scheduler.1
	==> app-02: kubernetes/docs/man/man1/kubectl-expose.1
	==> app-02: kubernetes/docs/man/man1/kubectl-create-service-nodeport.1
	==> app-02: kubernetes/docs/man/man1/kubectl-edit.1
	==> app-02: kubernetes/docs/man/man1/kubectl-config-get-contexts.1
	==> app-02: kubernetes/docs/man/man1/kubectl-autoscale.1
	==> app-02: kubernetes/docs/man/man1/kubectl-get.1
	==> app-02: kubernetes/docs/man/man1/kubectl-create-service.1
	==> app-02: kubernetes/docs/man/man1/kubectl-create-configmap.1
	==> app-02: kubernetes/docs/man/man1/kubectl-describe.1
	==> app-02: kubernetes/docs/man/man1/kubectl-config.1
	==> app-02: kubernetes/docs/man/man1/kubectl-proxy.1
	==> app-02: kubernetes/docs/man/man1/kube-controller-manager.1
	==> app-02: kubernetes/docs/man/man1/kubectl-config-current-context.1
	==> app-02: kubernetes/docs/man/man1/kubectl-create-service-clusterip.1
	==> app-02: kubernetes/docs/man/man1/kubectl-create-serviceaccount.1
	==> app-02: kubernetes/docs/man/man1/kubectl-uncordon.1
	==> app-02: kubernetes/docs/man/man1/kubectl-rollout-history.1
	==> app-02: kubernetes/docs/man/man1/kubectl-config-set-credentials.1
	==> app-02: kubernetes/docs/man/man1/.files_generated
	==> app-02: kubernetes/docs/man/man1/kubectl-config-set-context.1
	==> app-02: kubernetes/docs/man/man1/kubectl-patch.1
	==> app-02: kubernetes/docs/man/man1/kubectl-create.1
	==> app-02: kubernetes/docs/man/man1/kubectl-exec.1
	==> app-02: kubernetes/docs/man/man1/kubectl-config-use-context.1
	==> app-02: kubernetes/docs/man/man1/kubelet.1
	==> app-02: kubernetes/docs/man/man1/kubectl-label.1
	==> app-02: kubernetes/docs/man/man1/kubectl-scale.1
	==> app-02: kubernetes/docs/man/man1/kubectl-delete.1
	==> app-02: kubernetes/docs/man/man1/kubectl-cluster-info.1
	==> app-02: kubernetes/docs/man/man1/kubectl-options.1
	==> app-02: kubernetes/docs/man/man1/kubectl-set-image.1
	==> app-02: kubernetes/docs/man/man1/kubectl-replace.1
	==> app-02: kubernetes/docs/man/man1/kubectl-create-service-loadbalancer.1
	==> app-02: kubernetes/docs/man/man1/kubectl-rollout-pause.1
	==> app-02: kubernetes/docs/man/man1/kubectl-config-get-clusters.1
	==> app-02: kubernetes/docs/man/man1/kubectl-taint.1
	==> app-02: kubernetes/docs/man/man1/kubectl-config-delete-cluster.1
	==> app-02: kubernetes/docs/man/man1/kubectl-create-secret-generic.1
	==> app-02: kubernetes/docs/man/man1/kubectl-config-set.1
	==> app-02: kubernetes/docs/man/man1/kubectl-version.1
	==> app-02: kubernetes/docs/man/man1/kubectl-explain.1
	==> app-02: kubernetes/docs/man/man1/kubectl-create-secret-docker-registry.1
	==> app-02: kubernetes/docs/man/man1/kubectl-apply.1
	==> app-02: kubernetes/docs/man/man1/kube-proxy.1
	==> app-02: kubernetes/docs/man/man1/kubectl-create-secret-tls.1
	==> app-02: kubernetes/docs/man/man1/kubectl-cluster-info-dump.1
	==> app-02: kubernetes/docs/man/man1/kubectl-api-versions.1
	==> app-02: kubernetes/docs/man/man1/kubectl-stop.1
	==> app-02: kubernetes/docs/man/man1/kubectl-config-unset.1
	==> app-02: kubernetes/docs/man/man1/kubectl-rollout-resume.1
	==> app-02: kubernetes/docs/man/man1/kube-apiserver.1
	==> app-02: kubernetes/docs/man/man1/kubectl-rollout.1
	==> app-02: kubernetes/docs/man/man1/kubectl-rolling-update.1
	==> app-02: kubernetes/docs/man/man1/kubectl-attach.1
	==> app-02: kubernetes/docs/man/man1/kubectl-rollout-status.1
	==> app-02: kubernetes/docs/man/man1/kubectl-cordon.1
	==> app-02: kubernetes/docs/man/man1/kubectl-config-delete-context.1
	==> app-02: kubernetes/docs/man/man1/kubectl-rollout-undo.1
	==> app-02: kubernetes/docs/man/man1/kubectl-create-quota.1
	==> app-02: kubernetes/docs/man/man1/kubectl-run.1
	==> app-02: kubernetes/docs/man/man1/kubectl-annotate.1
	==> app-02: kubernetes/docs/man/man1/kubectl-convert.1
	==> app-02: kubernetes/docs/man/man1/kubectl-top.1
	==> app-02: kubernetes/docs/man/man1/kubectl-logs.1
	==> app-02: kubernetes/docs/man/man1/kubectl-create-namespace.1
	==> app-02: kubernetes/docs/man/man1/kubectl-create-secret.1
	==> app-02: kubernetes/docs/man/man1/kubectl-create-deployment.1
	==> app-02: kubernetes/docs/man/man1/kubectl-set.1
	==> app-02: kubernetes/docs/man/man1/kubectl-completion.1
	==> app-02: kubernetes/docs/man/man1/kubectl-config-set-cluster.1
	==> app-02: kubernetes/docs/man/man1/kubectl-port-forward.1
	==> app-02: kubernetes/docs/man/man1/kubectl-drain.1
	==> app-02: kubernetes/docs/man/man1/kubectl-top-pod.1
	==> app-02: kubernetes/docs/man/man1/kubectl-top-node.1
	==> app-02: kubernetes/docs/api.md
	==> app-02: kubernetes/docs/troubleshooting.md
	==> app-02: kubernetes/cluster/
	==> app-02: kubernetes/cluster/aws/
	==> app-02: kubernetes/cluster/aws/templates/
	==> app-02: kubernetes/cluster/aws/templates/iam/
	==> app-02: kubernetes/cluster/aws/templates/iam/kubernetes-minion-policy.json
	==> app-02: kubernetes/cluster/aws/templates/iam/kubernetes-master-role.json
	==> app-02: kubernetes/cluster/aws/templates/iam/kubernetes-minion-role.json
	==> app-02: kubernetes/cluster/aws/templates/iam/kubernetes-master-policy.json
	==> app-02: kubernetes/cluster/aws/templates/configure-vm-aws.sh
	==> app-02: kubernetes/cluster/aws/templates/format-disks.sh
	==> app-02: kubernetes/cluster/aws/config-default.sh
	==> app-02: kubernetes/cluster/aws/wily/
	==> app-02: kubernetes/cluster/aws/wily/util.sh
	==> app-02: kubernetes/cluster/aws/util.sh
	==> app-02: kubernetes/cluster/aws/config-test.sh
	==> app-02: kubernetes/cluster/aws/common/
	==> app-02: kubernetes/cluster/aws/common/common.sh
	==> app-02: kubernetes/cluster/aws/options.md
	==> app-02: kubernetes/cluster/aws/jessie/
	==> app-02: kubernetes/cluster/aws/jessie/util.sh
	==> app-02: kubernetes/cluster/update-storage-objects.sh
	==> app-02: kubernetes/cluster/vsphere/
	==> app-02: kubernetes/cluster/vsphere/templates/
	==> app-02: kubernetes/cluster/vsphere/templates/salt-master.sh
	==> app-02: kubernetes/cluster/vsphere/templates/hostname.sh
	==> app-02: kubernetes/cluster/vsphere/templates/install-release.sh
	==> app-02: kubernetes/cluster/vsphere/templates/create-dynamic-salt-files.sh
	==> app-02: kubernetes/cluster/vsphere/templates/salt-minion.sh
	==> app-02: kubernetes/cluster/vsphere/config-common.sh
	==> app-02: kubernetes/cluster/vsphere/config-default.sh
	==> app-02: kubernetes/cluster/vsphere/util.sh
	==> app-02: kubernetes/cluster/vsphere/config-test.sh
	==> app-02: kubernetes/cluster/photon-controller/
	==> app-02: kubernetes/cluster/photon-controller/setup-prereq.sh
	==> app-02: kubernetes/cluster/photon-controller/templates/
	==> app-02: kubernetes/cluster/photon-controller/templates/salt-master.sh
	==> app-02: kubernetes/cluster/photon-controller/templates/hostname.sh
	==> app-02: kubernetes/cluster/photon-controller/templates/install-release.sh
	==> app-02: kubernetes/cluster/photon-controller/templates/README
	==> app-02: kubernetes/cluster/photon-controller/templates/create-dynamic-salt-files.sh
	==> app-02: kubernetes/cluster/photon-controller/templates/salt-minion.sh
	==> app-02: kubernetes/cluster/photon-controller/config-common.sh
	==> app-02: kubernetes/cluster/photon-controller/config-default.sh
	==> app-02: kubernetes/cluster/photon-controller/util.sh
	==> app-02: kubernetes/cluster/photon-controller/config-test.sh
	==> app-02: kubernetes/cluster/README.md
	==> app-02: kubernetes/cluster/gke/
	==> app-02: kubernetes/cluster/gke/config-common.sh
	==> app-02: kubernetes/cluster/gke/config-default.sh
	==> app-02: kubernetes/cluster/gke/make-it-stop.sh
	==> app-02: kubernetes/cluster/gke/util.sh
	==> app-02: kubernetes/cluster/gke/config-test.sh
	==> app-02: kubernetes/cluster/validate-cluster.sh
	==> app-02: kubernetes/cluster/get-kube-local.sh
	==> app-02: kubernetes/cluster/kubemark/
	==> app-02: kubernetes/cluster/kubemark/config-default.sh
	==> app-02: kubernetes/cluster/kubemark/util.sh
	==> app-02: kubernetes/cluster/OWNERS
	==> app-02: kubernetes/cluster/log-dump.sh
	==> app-02: kubernetes/cluster/test-network.sh
	==> app-02: kubernetes/cluster/openstack-heat/
	==> app-02: kubernetes/cluster/openstack-heat/config-default.sh
	==> app-02: kubernetes/cluster/openstack-heat/kubernetes-heat/
	==> app-02: kubernetes/cluster/openstack-heat/kubernetes-heat/kubeminion.yaml
	==> app-02: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/
	==> app-02: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/deploy-kube-auth-files-master.yaml
	==> app-02: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/provision-network-master.sh
	==> app-02: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/configure-proxy.sh
	==> app-02: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/write-heat-params.yaml
	==> app-02: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/configure-salt.yaml
	==> app-02: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/hostname-hack.sh
	==> app-02: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/kube-user.yaml
	==> app-02: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/provision-network-node.sh
	==> app-02: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/run-salt.sh
	==> app-02: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/hostname-hack.yaml
	==> app-02: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/deploy-kube-auth-files-node.yaml
	==> app-02: kubernetes/cluster/openstack-heat/kubernetes-heat/kubecluster.yaml
	==> app-02: kubernetes/cluster/openstack-heat/openrc-swift.sh
	==> app-02: kubernetes/cluster/openstack-heat/util.sh
	==> app-02: kubernetes/cluster/openstack-heat/config-test.sh
	==> app-02: kubernetes/cluster/openstack-heat/openrc-default.sh
	==> app-02: kubernetes/cluster/openstack-heat/config-image.sh
	==> app-02: kubernetes/cluster/kubectl.sh
	==> app-02: kubernetes/cluster/lib/
	==> app-02: kubernetes/cluster/lib/util.sh
	==> app-02: kubernetes/cluster/lib/logging.sh
	==> app-02: kubernetes/cluster/rackspace/
	==> app-02: kubernetes/cluster/rackspace/authorization.sh
	==> app-02: kubernetes/cluster/rackspace/cloud-config/
	==> app-02: kubernetes/cluster/rackspace/cloud-config/node-cloud-config.yaml
	==> app-02: kubernetes/cluster/rackspace/cloud-config/master-cloud-config.yaml
	==> app-02: kubernetes/cluster/rackspace/config-default.sh
	==> app-02: kubernetes/cluster/rackspace/util.sh
	==> app-02: kubernetes/cluster/rackspace/kube-up.sh
	==> app-02: kubernetes/cluster/centos/
	==> app-02: kubernetes/cluster/centos/config-build.sh
	==> app-02: kubernetes/cluster/centos/config-default.sh
	==> app-02: kubernetes/cluster/centos/master/
	==> app-02: kubernetes/cluster/centos/master/scripts/
	==> app-02: kubernetes/cluster/centos/master/scripts/scheduler.sh
	==> app-02: kubernetes/cluster/centos/master/scripts/controller-manager.sh
	==> app-02: kubernetes/cluster/centos/master/scripts/apiserver.sh
	==> app-02: kubernetes/cluster/centos/master/scripts/etcd.sh
	==> app-02: kubernetes/cluster/centos/build.sh
	==> app-02: kubernetes/cluster/centos/util.sh
	==> app-02: kubernetes/cluster/centos/node/
	==> app-02: kubernetes/cluster/centos/node/scripts/
	==> app-02: kubernetes/cluster/centos/node/scripts/flannel.sh
	==> app-02: kubernetes/cluster/centos/node/scripts/proxy.sh
	==> app-02: kubernetes/cluster/centos/node/scripts/kubelet.sh
	==> app-02: kubernetes/cluster/centos/node/scripts/docker.sh
	==> app-02: kubernetes/cluster/centos/node/bin/
	==> app-02: kubernetes/cluster/centos/node/bin/remove-docker0.sh
	==> app-02: kubernetes/cluster/centos/node/bin/mk-docker-opts.sh
	==> app-02: kubernetes/cluster/centos/config-test.sh
	==> app-02: kubernetes/cluster/centos/.gitignore
	==> app-02: kubernetes/cluster/libvirt-coreos/
	==> app-02: kubernetes/cluster/libvirt-coreos/README.md
	==> app-02: kubernetes/cluster/libvirt-coreos/config-default.sh
	==> app-02: kubernetes/cluster/libvirt-coreos/util.sh
	==> app-02: kubernetes/cluster/libvirt-coreos/user_data.yml
	==> app-02: kubernetes/cluster/libvirt-coreos/config-test.sh
	==> app-02: kubernetes/cluster/libvirt-coreos/namespace.yaml
	==> app-02: kubernetes/cluster/libvirt-coreos/.gitignore
	==> app-02: kubernetes/cluster/libvirt-coreos/network_kubernetes_pods.xml
	==> app-02: kubernetes/cluster/libvirt-coreos/forShellEval.sed
	==> app-02: kubernetes/cluster/libvirt-coreos/openssl.cnf
	==> app-02: kubernetes/cluster/libvirt-coreos/user_data_master.yml
	==> app-02: kubernetes/cluster/libvirt-coreos/node-openssl.cnf
	==> app-02: kubernetes/cluster/libvirt-coreos/coreos.xml
	==> app-02: kubernetes/cluster/libvirt-coreos/network_kubernetes_global.xml
	==> app-02: kubernetes/cluster/libvirt-coreos/user_data_minion.yml
	==> app-02: kubernetes/cluster/ubuntu/
	==> app-02: kubernetes/cluster/ubuntu/config-default.sh
	==> app-02: kubernetes/cluster/ubuntu/reconfDocker.sh
	==> app-02: kubernetes/cluster/ubuntu/master/
	==> app-02: kubernetes/cluster/ubuntu/master/init_scripts/
	==> app-02: kubernetes/cluster/ubuntu/master/init_scripts/etcd
	==> app-02: kubernetes/cluster/ubuntu/master/init_scripts/kube-scheduler
	==> app-02: kubernetes/cluster/ubuntu/master/init_scripts/kube-controller-manager
	==> app-02: kubernetes/cluster/ubuntu/master/init_scripts/kube-apiserver
	==> app-02: kubernetes/cluster/ubuntu/master/init_conf/
	==> app-02: kubernetes/cluster/ubuntu/master/init_conf/kube-scheduler.conf
	==> app-02: kubernetes/cluster/ubuntu/master/init_conf/kube-controller-manager.conf
	==> app-02: kubernetes/cluster/ubuntu/master/init_conf/kube-apiserver.conf
	==> app-02: kubernetes/cluster/ubuntu/master/init_conf/etcd.conf
	==> app-02: kubernetes/cluster/ubuntu/master-flannel/
	==> app-02: kubernetes/cluster/ubuntu/master-flannel/init_scripts/
	==> app-02: kubernetes/cluster/ubuntu/master-flannel/init_scripts/flanneld
	==> app-02: kubernetes/cluster/ubuntu/master-flannel/init_conf/
	==> app-02: kubernetes/cluster/ubuntu/master-flannel/init_conf/flanneld.conf
	==> app-02: kubernetes/cluster/ubuntu/util.sh
	==> app-02: kubernetes/cluster/ubuntu/config-test.sh
	==> app-02: kubernetes/cluster/ubuntu/namespace.yaml
	==> app-02: kubernetes/cluster/ubuntu/.gitignore
	==> app-02: kubernetes/cluster/ubuntu/minion/
	==> app-02: kubernetes/cluster/ubuntu/minion/init_scripts/
	==> app-02: kubernetes/cluster/ubuntu/minion/init_scripts/kubelet
	==> app-02: kubernetes/cluster/ubuntu/minion/init_scripts/kube-proxy
	==> app-02: kubernetes/cluster/ubuntu/minion/init_conf/
	==> app-02: kubernetes/cluster/ubuntu/minion/init_conf/kubelet.conf
	==> app-02: kubernetes/cluster/ubuntu/minion/init_conf/kube-proxy.conf
	==> app-02: kubernetes/cluster/ubuntu/download-release.sh
	==> app-02: kubernetes/cluster/ubuntu/minion-flannel/
	==> app-02: kubernetes/cluster/ubuntu/minion-flannel/init_scripts/
	==> app-02: kubernetes/cluster/ubuntu/minion-flannel/init_scripts/flanneld
	==> app-02: kubernetes/cluster/ubuntu/minion-flannel/init_conf/
	==> app-02: kubernetes/cluster/ubuntu/minion-flannel/init_conf/flanneld.conf
	==> app-02: kubernetes/cluster/ubuntu/deployAddons.sh
	==> app-02: kubernetes/cluster/local/
	==> app-02: kubernetes/cluster/local/util.sh
	==> app-02: kubernetes/cluster/get-kube-binaries.sh
	==> app-02: kubernetes/cluster/common.sh
	==> app-02: kubernetes/cluster/juju/
	==> app-02: kubernetes/cluster/juju/kube-system-ns.yaml
	==> app-02: kubernetes/cluster/juju/config-default.sh
	==> app-02: kubernetes/cluster/juju/layers/
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/layer.yaml
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/metadata.yaml
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/templates/
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/templates/kubedns-svc.yaml
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/templates/master.json
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/templates/docker-compose.yml
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/templates/kubedns-rc.yaml
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/tests/
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/tests/tests.yaml
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/config.yaml
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/README.md
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/actions.yaml
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/actions/
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/actions/guestbook-example
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/icon.svg
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/reactive/
	==> app-02: kubernetes/cluster/juju/layers/kubernetes/reactive/k8s.py
	==> app-02: kubernetes/cluster/juju/identify-leaders.py
	==> app-02: kubernetes/cluster/juju/util.sh
	==> app-02: kubernetes/cluster/juju/config-test.sh
	==> app-02: kubernetes/cluster/juju/return-node-ips.py
	==> app-02: kubernetes/cluster/juju/bundles/
	==> app-02: kubernetes/cluster/juju/bundles/README.md
	==> app-02: kubernetes/cluster/juju/bundles/local.yaml.base
	==> app-02: kubernetes/cluster/juju/prereqs/
	==> app-02: kubernetes/cluster/juju/prereqs/ubuntu-juju.sh
	==> app-02: kubernetes/cluster/kube-up.sh
	==> app-02: kubernetes/cluster/kube-util.sh
	==> app-02: kubernetes/cluster/options.md
	==> app-02: kubernetes/cluster/mesos/
	==> app-02: kubernetes/cluster/mesos/docker/
	==> app-02: kubernetes/cluster/mesos/docker/static-pod.json
	==> app-02: kubernetes/cluster/mesos/docker/socat/
	==> app-02: kubernetes/cluster/mesos/docker/socat/build.sh
	==> app-02: kubernetes/cluster/mesos/docker/socat/Dockerfile
	==> app-02: kubernetes/cluster/mesos/docker/static-pods-ns.yaml
	==> app-02: kubernetes/cluster/mesos/docker/kube-system-ns.yaml
	==> app-02: kubernetes/cluster/mesos/docker/config-default.sh
	==> app-02: kubernetes/cluster/mesos/docker/OWNERS
	==> app-02: kubernetes/cluster/mesos/docker/util.sh
	==> app-02: kubernetes/cluster/mesos/docker/config-test.sh
	==> app-02: kubernetes/cluster/mesos/docker/.gitignore
	==> app-02: kubernetes/cluster/mesos/docker/common/
	==> app-02: kubernetes/cluster/mesos/docker/common/bin/
	==> app-02: kubernetes/cluster/mesos/docker/common/bin/await-file
	==> app-02: kubernetes/cluster/mesos/docker/common/bin/health-check
	==> app-02: kubernetes/cluster/mesos/docker/common/bin/await-health-check
	==> app-02: kubernetes/cluster/mesos/docker/deploy-dns.sh
	==> app-02: kubernetes/cluster/mesos/docker/docker-compose.yml
	==> app-02: kubernetes/cluster/mesos/docker/test/
	==> app-02: kubernetes/cluster/mesos/docker/test/build.sh
	==> app-02: kubernetes/cluster/mesos/docker/test/Dockerfile
	==> app-02: kubernetes/cluster/mesos/docker/test/bin/
	==> app-02: kubernetes/cluster/mesos/docker/test/bin/install-etcd.sh
	==> app-02: kubernetes/cluster/mesos/docker/deploy-addons.sh
	==> app-02: kubernetes/cluster/mesos/docker/km/
	==> app-02: kubernetes/cluster/mesos/docker/km/build.sh
	==> app-02: kubernetes/cluster/mesos/docker/km/Dockerfile
	==> app-02: kubernetes/cluster/mesos/docker/km/.gitignore
	==> app-02: kubernetes/cluster/mesos/docker/km/opt/
	==> app-02: kubernetes/cluster/mesos/docker/km/opt/mesos-cloud.conf
	==> app-02: kubernetes/cluster/mesos/docker/deploy-ui.sh
	==> app-02: kubernetes/cluster/images/
	==> app-02: kubernetes/cluster/images/kube-discovery/
	==> app-02: kubernetes/cluster/images/kube-discovery/README.md
	==> app-02: kubernetes/cluster/images/kube-discovery/Dockerfile
	==> app-02: kubernetes/cluster/images/kube-discovery/Makefile
	==> app-02: kubernetes/cluster/images/etcd-empty-dir-cleanup/
	==> app-02: kubernetes/cluster/images/etcd-empty-dir-cleanup/Dockerfile
	==> app-02: kubernetes/cluster/images/etcd-empty-dir-cleanup/etcd-empty-dir-cleanup.sh
	==> app-02: kubernetes/cluster/images/etcd-empty-dir-cleanup/Makefile
	==> app-02: kubernetes/cluster/images/etcd/
	==> app-02: kubernetes/cluster/images/etcd/attachlease/
	==> app-02: kubernetes/cluster/images/etcd/attachlease/attachlease.go
	==> app-02: kubernetes/cluster/images/etcd/README.md
	==> app-02: kubernetes/cluster/images/etcd/Dockerfile
	==> app-02: kubernetes/cluster/images/etcd/migrate-if-needed.sh
	==> app-02: kubernetes/cluster/images/etcd/Makefile
	==> app-02: kubernetes/cluster/images/etcd/rollback/
	==> app-02: kubernetes/cluster/images/etcd/rollback/rollback.go
	==> app-02: kubernetes/cluster/images/etcd/rollback/README.md
	==> app-02: kubernetes/cluster/images/kubemark/
	==> app-02: kubernetes/cluster/images/kubemark/kubemark.sh
	==> app-02: kubernetes/cluster/images/kubemark/Dockerfile
	==> app-02: kubernetes/cluster/images/kubemark/Makefile
	==> app-02: kubernetes/cluster/images/kubemark/build-kubemark.sh
	==> app-02: kubernetes/cluster/images/hyperkube/
	==> app-02: kubernetes/cluster/images/hyperkube/README.md
	==> app-02: kubernetes/cluster/images/hyperkube/setup-files.sh
	==> app-02: kubernetes/cluster/images/hyperkube/Dockerfile
	==> app-02: kubernetes/cluster/images/hyperkube/kube-proxy-ds.yaml
	==> app-02: kubernetes/cluster/images/hyperkube/cni-conf/
	==> app-02: kubernetes/cluster/images/hyperkube/cni-conf/10-containernet.conf
	==> app-02: kubernetes/cluster/images/hyperkube/cni-conf/99-loopback.conf
	==> app-02: kubernetes/cluster/images/hyperkube/copy-addons.sh
	==> app-02: kubernetes/cluster/images/hyperkube/static-pods/
	==> app-02: kubernetes/cluster/images/hyperkube/static-pods/kube-proxy.json
	==> app-02: kubernetes/cluster/images/hyperkube/static-pods/master-multi.json
	==> app-02: kubernetes/cluster/images/hyperkube/static-pods/master.json
	==> app-02: kubernetes/cluster/images/hyperkube/static-pods/addon-manager-singlenode.json
	==> app-02: kubernetes/cluster/images/hyperkube/static-pods/etcd.json
	==> app-02: kubernetes/cluster/images/hyperkube/static-pods/addon-manager-multinode.json
	==> app-02: kubernetes/cluster/images/hyperkube/Makefile
	==> app-02: kubernetes/cluster/skeleton/
	==> app-02: kubernetes/cluster/skeleton/util.sh
	==> app-02: kubernetes/cluster/kube-down.sh
	==> app-02: kubernetes/cluster/get-kube.sh
	==> app-02: kubernetes/cluster/test-e2e.sh
	==> app-02: kubernetes/cluster/ovirt/
	==> app-02: kubernetes/cluster/ovirt/ovirt-cloud.conf
	==> app-02: kubernetes/cluster/azure-legacy/
	==> app-02: kubernetes/cluster/azure-legacy/templates/
	==> app-02: kubernetes/cluster/azure-legacy/templates/salt-master.sh
	==> app-02: kubernetes/cluster/azure-legacy/templates/common.sh
	==> app-02: kubernetes/cluster/azure-legacy/templates/download-release.sh
	==> app-02: kubernetes/cluster/azure-legacy/templates/create-dynamic-salt-files.sh
	==> app-02: kubernetes/cluster/azure-legacy/templates/salt-minion.sh
	==> app-02: kubernetes/cluster/azure-legacy/templates/create-kubeconfig.sh
	==> app-02: kubernetes/cluster/azure-legacy/config-default.sh
	==> app-02: kubernetes/cluster/azure-legacy/util.sh
	==> app-02: kubernetes/cluster/azure-legacy/.gitignore
	==> app-02: kubernetes/cluster/vagrant/
	==> app-02: kubernetes/cluster/vagrant/provision-network-master.sh
	==> app-02: kubernetes/cluster/vagrant/config-default.sh
	==> app-02: kubernetes/cluster/vagrant/OWNERS
	==> app-02: kubernetes/cluster/vagrant/util.sh
	==> app-02: kubernetes/cluster/vagrant/pod-ip-test.sh
	==> app-02: kubernetes/cluster/vagrant/config-test.sh
	==> app-02: kubernetes/cluster/vagrant/provision-node.sh
	==> app-02: kubernetes/cluster/vagrant/provision-network-node.sh
	==> app-02: kubernetes/cluster/vagrant/provision-utils.sh
	==> app-02: kubernetes/cluster/vagrant/provision-master.sh
	==> app-02: kubernetes/cluster/gce/
	==> app-02: kubernetes/cluster/gce/config-common.sh
	==> app-02: kubernetes/cluster/gce/config-default.sh
	==> app-02: kubernetes/cluster/gce/trusty/
	==> app-02: kubernetes/cluster/gce/trusty/helper.sh
	==> app-02: kubernetes/cluster/gce/trusty/node-helper.sh
	==> app-02: kubernetes/cluster/gce/trusty/node.yaml
	==> app-02: kubernetes/cluster/gce/trusty/master.yaml
	==> app-02: kubernetes/cluster/gce/trusty/configure.sh
	==> app-02: kubernetes/cluster/gce/trusty/master-helper.sh
	==> app-02: kubernetes/cluster/gce/trusty/configure-helper.sh
	==> app-02: kubernetes/cluster/gce/list-resources.sh
	==> app-02: kubernetes/cluster/gce/delete-stranded-load-balancers.sh
	==> app-02: kubernetes/cluster/gce/util.sh
	==> app-02: kubernetes/cluster/gce/coreos/
	==> app-02: kubernetes/cluster/gce/coreos/master-rkt.yaml
	==> app-02: kubernetes/cluster/gce/coreos/configure-kubelet.sh
	==> app-02: kubernetes/cluster/gce/coreos/node-helper.sh
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/kube-apiserver.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/kube-addon-manager.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/etcd-events.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/kube-system.json
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/kubelet-config.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/kube-controller-manager.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/kubeproxy-config.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/kube-scheduler.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/fluentd-elasticsearch/
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/fluentd-elasticsearch/kibana-controller.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/fluentd-elasticsearch/es-controller.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/fluentd-elasticsearch/es-service.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/fluentd-elasticsearch/kibana-service.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/google/
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/google/heapster-service.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/google/heapster-controller.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/heapster-service.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/influxdb-grafana-controller.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/grafana-service.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/heapster-controller.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/influxdb-service.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/standalone/
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/standalone/heapster-service.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/standalone/heapster-controller.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/googleinfluxdb/
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/googleinfluxdb/heapster-controller-combined.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/namespace.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/registry/
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/registry/registry-rc.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/registry/registry-svc.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/registry/registry-pvc.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/registry/registry-pv.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/node-problem-detector/
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/node-problem-detector/node-problem-detector.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/dashboard/
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/dashboard/dashboard-controller.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/dashboard/dashboard-service.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/dns/
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/dns/skydns-rc.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/dns/skydns-svc.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-loadbalancing/
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-loadbalancing/glbc/
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-loadbalancing/glbc/glbc-controller.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-loadbalancing/glbc/default-svc.yaml
	==> app-02: kubernetes/cluster/gce/coreos/kube-manifests/etcd.yaml
	==> app-02: kubernetes/cluster/gce/coreos/master-docker.yaml
	==> app-02: kubernetes/cluster/gce/coreos/master-helper.sh
	==> app-02: kubernetes/cluster/gce/coreos/node-docker.yaml
	==> app-02: kubernetes/cluster/gce/coreos/configure-node.sh
	==> app-02: kubernetes/cluster/gce/coreos/node-rkt.yaml
	==> app-02: kubernetes/cluster/gce/config-test.sh
	==> app-02: kubernetes/cluster/gce/gci/
	==> app-02: kubernetes/cluster/gce/gci/helper.sh
	==> app-02: kubernetes/cluster/gce/gci/README.md
	==> app-02: kubernetes/cluster/gce/gci/health-monitor.sh
	==> app-02: kubernetes/cluster/gce/gci/node-helper.sh
	==> app-02: kubernetes/cluster/gce/gci/node.yaml
	==> app-02: kubernetes/cluster/gce/gci/master.yaml
	==> app-02: kubernetes/cluster/gce/gci/configure.sh
	==> app-02: kubernetes/cluster/gce/gci/master-helper.sh
	==> app-02: kubernetes/cluster/gce/gci/configure-helper.sh
	==> app-02: kubernetes/cluster/gce/debian/
	==> app-02: kubernetes/cluster/gce/debian/node-helper.sh
	==> app-02: kubernetes/cluster/gce/debian/master-helper.sh
	==> app-02: kubernetes/cluster/gce/configure-vm.sh
	==> app-02: kubernetes/cluster/gce/upgrade.sh
	==> app-02: kubernetes/cluster/addons/
	==> app-02: kubernetes/cluster/addons/podsecuritypolicies/
	==> app-02: kubernetes/cluster/addons/podsecuritypolicies/privileged.yaml
	==> app-02: kubernetes/cluster/addons/fluentd-gcp/
	==> app-02: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/
	==> app-02: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/README.md
	==> app-02: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/google-fluentd-journal.conf
	==> app-02: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/Dockerfile
	==> app-02: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/google-fluentd.conf
	==> app-02: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/Makefile
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-controller.yaml
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/es-controller.yaml
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/es-service.yaml
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/elasticsearch.yml
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/run.sh
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/Dockerfile
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/template-k8s-logstash.json
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/Makefile
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/elasticsearch_logging_discovery.go
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-image/
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-image/run.sh
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-image/Dockerfile
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-image/Makefile
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-service.yaml
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/README.md
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/build.sh
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/Dockerfile
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/td-agent.conf
	==> app-02: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/Makefile
	==> app-02: kubernetes/cluster/addons/etcd-empty-dir-cleanup/
	==> app-02: kubernetes/cluster/addons/etcd-empty-dir-cleanup/etcd-empty-dir-cleanup.yaml
	==> app-02: kubernetes/cluster/addons/README.md
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/README.md
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/google/
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/google/heapster-service.yaml
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/google/heapster-controller.yaml
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/influxdb/
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/influxdb/heapster-service.yaml
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/influxdb/influxdb-grafana-controller.yaml
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/influxdb/grafana-service.yaml
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/influxdb/heapster-controller.yaml
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/influxdb/influxdb-service.yaml
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/standalone/
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/standalone/heapster-service.yaml
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/standalone/heapster-controller.yaml
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/googleinfluxdb/
	==> app-02: kubernetes/cluster/addons/cluster-monitoring/googleinfluxdb/heapster-controller-combined.yaml
	==> app-02: kubernetes/cluster/addons/addon-manager/
	==> app-02: kubernetes/cluster/addons/addon-manager/README.md
	==> app-02: kubernetes/cluster/addons/addon-manager/kube-addons.sh
	==> app-02: kubernetes/cluster/addons/addon-manager/Dockerfile
	==> app-02: kubernetes/cluster/addons/addon-manager/namespace.yaml
	==> app-02: kubernetes/cluster/addons/addon-manager/kube-addon-update.sh
	==> app-02: kubernetes/cluster/addons/addon-manager/Makefile
	==> app-02: kubernetes/cluster/addons/gci/
	==> app-02: kubernetes/cluster/addons/gci/README.md
	==> app-02: kubernetes/cluster/addons/gci/fluentd-gcp.yaml
	==> app-02: kubernetes/cluster/addons/registry/
	==> app-02: kubernetes/cluster/addons/registry/registry-pv.yaml.in
	==> app-02: kubernetes/cluster/addons/registry/README.md
	==> app-02: kubernetes/cluster/addons/registry/gcs/
	==> app-02: kubernetes/cluster/addons/registry/gcs/README.md
	==> app-02: kubernetes/cluster/addons/registry/gcs/registry-gcs-rc.yaml
	==> app-02: kubernetes/cluster/addons/registry/registry-rc.yaml
	==> app-02: kubernetes/cluster/addons/registry/registry-svc.yaml
	==> app-02: kubernetes/cluster/addons/registry/registry-pvc.yaml.in
	==> app-02: kubernetes/cluster/addons/registry/tls/
	==> app-02: kubernetes/cluster/addons/registry/tls/README.md
	==> app-02: kubernetes/cluster/addons/registry/tls/registry-tls-rc.yaml
	==> app-02: kubernetes/cluster/addons/registry/tls/registry-tls-svc.yaml
	==> app-02: kubernetes/cluster/addons/registry/auth/
	==> app-02: kubernetes/cluster/addons/registry/auth/README.md
	==> app-02: kubernetes/cluster/addons/registry/auth/registry-auth-rc.yaml
	==> app-02: kubernetes/cluster/addons/registry/images/
	==> app-02: kubernetes/cluster/addons/registry/images/proxy.conf.in
	==> app-02: kubernetes/cluster/addons/registry/images/Dockerfile
	==> app-02: kubernetes/cluster/addons/registry/images/proxy.conf.insecure.in
	==> app-02: kubernetes/cluster/addons/registry/images/Makefile
	==> app-02: kubernetes/cluster/addons/registry/images/run_proxy.sh
	==> app-02: kubernetes/cluster/addons/node-problem-detector/
	==> app-02: kubernetes/cluster/addons/node-problem-detector/README.md
	==> app-02: kubernetes/cluster/addons/node-problem-detector/MAINTAINERS.md
	==> app-02: kubernetes/cluster/addons/node-problem-detector/node-problem-detector.yaml
	==> app-02: kubernetes/cluster/addons/dashboard/
	==> app-02: kubernetes/cluster/addons/dashboard/dashboard-controller.yaml
	==> app-02: kubernetes/cluster/addons/dashboard/README.md
	==> app-02: kubernetes/cluster/addons/dashboard/MAINTAINERS.md
	==> app-02: kubernetes/cluster/addons/dashboard/dashboard-service.yaml
	==> app-02: kubernetes/cluster/addons/calico-policy-controller/
	==> app-02: kubernetes/cluster/addons/calico-policy-controller/README.md
	==> app-02: kubernetes/cluster/addons/calico-policy-controller/MAINTAINERS.md
	==> app-02: kubernetes/cluster/addons/calico-policy-controller/calico-policy-controller.yaml
	==> app-02: kubernetes/cluster/addons/calico-policy-controller/calico-etcd-service.yaml
	==> app-02: kubernetes/cluster/addons/calico-policy-controller/calico-etcd-petset.yaml
	==> app-02: kubernetes/cluster/addons/python-image/
	==> app-02: kubernetes/cluster/addons/python-image/README.md
	==> app-02: kubernetes/cluster/addons/python-image/Dockerfile
	==> app-02: kubernetes/cluster/addons/python-image/Makefile
	==> app-02: kubernetes/cluster/addons/dns/
	==> app-02: kubernetes/cluster/addons/dns/transforms2salt.sed
	==> app-02: kubernetes/cluster/addons/dns/README.md
	==> app-02: kubernetes/cluster/addons/dns/skydns-svc.yaml.base
	==> app-02: kubernetes/cluster/addons/dns/skydns-svc.yaml.in
	==> app-02: kubernetes/cluster/addons/dns/transforms2sed.sed
	==> app-02: kubernetes/cluster/addons/dns/skydns-svc.yaml.sed
	==> app-02: kubernetes/cluster/addons/dns/skydns-rc.yaml.base
	==> app-02: kubernetes/cluster/addons/dns/skydns-rc.yaml.in
	==> app-02: kubernetes/cluster/addons/dns/skydns-rc.yaml.sed
	==> app-02: kubernetes/cluster/addons/dns/Makefile
	==> app-02: kubernetes/cluster/addons/cluster-loadbalancing/
	==> app-02: kubernetes/cluster/addons/cluster-loadbalancing/MAINTAINERS.md
	==> app-02: kubernetes/cluster/addons/cluster-loadbalancing/glbc/
	==> app-02: kubernetes/cluster/addons/cluster-loadbalancing/glbc/README.md
	==> app-02: kubernetes/cluster/addons/cluster-loadbalancing/glbc/default-svc-controller.yaml
	==> app-02: kubernetes/cluster/addons/cluster-loadbalancing/glbc/default-svc.yaml
	==> app-02: kubernetes/cluster/test-smoke.sh
	==> app-02: kubernetes/cluster/kube-push.sh
	==> app-02: kubernetes/cluster/azure/
	==> app-02: kubernetes/cluster/azure/config-default.sh
	==> app-02: kubernetes/cluster/azure/util.sh
	==> app-02: kubernetes/cluster/azure/.gitignore
	==> app-02: kubernetes/version
	==> app-02: kubernetes/LICENSES
	==> app-02: kubernetes/federation/
	==> app-02: kubernetes/federation/cluster/
	==> app-02: kubernetes/federation/cluster/federation-up.sh
	==> app-02: kubernetes/federation/cluster/common.sh
	==> app-02: kubernetes/federation/cluster/template.go
	==> app-02: kubernetes/federation/cluster/federation-down.sh
	==> app-02: kubernetes/federation/manifests/
	==> app-02: kubernetes/federation/manifests/federation-controller-manager-deployment.yaml
	==> app-02: kubernetes/federation/manifests/federation-etcd-pvc.yaml
	==> app-02: kubernetes/federation/manifests/federation-ns.yaml
	==> app-02: kubernetes/federation/manifests/.gitignore
	==> app-02: kubernetes/federation/manifests/federation-apiserver-deployment.yaml
	==> app-02: kubernetes/federation/manifests/federation-apiserver-lb-service.yaml
	==> app-02: kubernetes/federation/manifests/federation-apiserver-cluster-service.yaml
	==> app-02: kubernetes/federation/manifests/federation-apiserver-nodeport-service.yaml
	==> app-02: kubernetes/federation/manifests/federation-apiserver-secrets.yaml
	==> app-02: kubernetes/federation/deploy/
	==> app-02: kubernetes/federation/deploy/deploy.sh
	==> app-02: kubernetes/federation/deploy/config.json.sample
	==> app-02: kubernetes/server/
	==> app-02: kubernetes/server/kubernetes-salt.tar.gz
	==> app-02: kubernetes/server/kubernetes-manifests.tar.gz
	==> app-02: kubernetes/server/kubernetes-server-linux-arm.tar.gz
	==> app-02: kubernetes/server/kubernetes-server-linux-arm64.tar.gz
	==> app-02: kubernetes/server/kubernetes-server-linux-amd64.tar.gz
	==> app-02: kubernetes/Vagrantfile
	==> app-02: kubernetes/examples/
	==> app-02: kubernetes/examples/doc.go
	==> app-02: kubernetes/examples/README.md
	==> app-02: kubernetes/examples/simple-nginx.md
	==> app-02: kubernetes/examples/runtime-constraints/
	==> app-02: kubernetes/examples/runtime-constraints/README.md
	==> app-02: kubernetes/examples/OWNERS
	==> app-02: kubernetes/examples/phabricator/
	==> app-02: kubernetes/examples/phabricator/php-phabricator/
	==> app-02: kubernetes/examples/phabricator/php-phabricator/run.sh
	==> app-02: kubernetes/examples/phabricator/php-phabricator/Dockerfile
	==> app-02: kubernetes/examples/phabricator/php-phabricator/000-default.conf
	==> app-02: kubernetes/examples/phabricator/README.md
	==> app-02: kubernetes/examples/phabricator/phabricator-controller.json
	==> app-02: kubernetes/examples/phabricator/phabricator-service.json
	==> app-02: kubernetes/examples/phabricator/teardown.sh
	==> app-02: kubernetes/examples/phabricator/setup.sh
	==> app-02: kubernetes/examples/cockroachdb/
	==> app-02: kubernetes/examples/cockroachdb/README.md
	==> app-02: kubernetes/examples/cockroachdb/minikube.sh
	==> app-02: kubernetes/examples/cockroachdb/demo.sh
	==> app-02: kubernetes/examples/cockroachdb/cockroachdb-petset.yaml
	==> app-02: kubernetes/examples/javaweb-tomcat-sidecar/
	==> app-02: kubernetes/examples/javaweb-tomcat-sidecar/README.md
	==> app-02: kubernetes/examples/javaweb-tomcat-sidecar/javaweb.yaml
	==> app-02: kubernetes/examples/javaweb-tomcat-sidecar/javaweb-2.yaml
	==> app-02: kubernetes/examples/javaweb-tomcat-sidecar/workflow.png
	==> app-02: kubernetes/examples/experimental/
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/README.md
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/glusterfs-dp.yaml
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/aws-ebs.yaml
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/glusterfs-provisioning-secret.yaml
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/claim1.json
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/rbd/
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/rbd/ceph-secret-admin.yaml
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/rbd/rbd-storage-class.yaml
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/rbd/ceph-secret-user.yaml
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/rbd/pod.yaml
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/quobyte/
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/quobyte/quobyte-admin-secret.yaml
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/quobyte/example-pod.yaml
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/quobyte/quobyte-storage-class.yaml
	==> app-02: kubernetes/examples/experimental/persistent-volume-provisioning/gce-pd.yaml
	==> app-02: kubernetes/examples/examples_test.go
	==> app-02: kubernetes/examples/nodesjs-mongodb/
	==> app-02: kubernetes/examples/nodesjs-mongodb/README.md
	==> app-02: kubernetes/examples/nodesjs-mongodb/mongo-controller.yaml
	==> app-02: kubernetes/examples/nodesjs-mongodb/web-service.yaml
	==> app-02: kubernetes/examples/nodesjs-mongodb/web-controller.yaml
	==> app-02: kubernetes/examples/nodesjs-mongodb/mongo-service.yaml
	==> app-02: kubernetes/examples/nodesjs-mongodb/web-controller-demo.yaml
	==> app-02: kubernetes/examples/mysql-wordpress-pd/
	==> app-02: kubernetes/examples/mysql-wordpress-pd/README.md
	==> app-02: kubernetes/examples/mysql-wordpress-pd/OWNERS
	==> app-02: kubernetes/examples/mysql-wordpress-pd/WordPress.png
	==> app-02: kubernetes/examples/mysql-wordpress-pd/gce-volumes.yaml
	==> app-02: kubernetes/examples/mysql-wordpress-pd/mysql-deployment.yaml
	==> app-02: kubernetes/examples/mysql-wordpress-pd/wordpress-deployment.yaml
	==> app-02: kubernetes/examples/mysql-wordpress-pd/local-volumes.yaml
	==> app-02: kubernetes/examples/mysql-cinder-pd/
	==> app-02: kubernetes/examples/mysql-cinder-pd/mysql.yaml
	==> app-02: kubernetes/examples/mysql-cinder-pd/README.md
	==> app-02: kubernetes/examples/mysql-cinder-pd/mysql-service.yaml
	==> app-02: kubernetes/examples/openshift-origin/
	==> app-02: kubernetes/examples/openshift-origin/openshift-controller.yaml
	==> app-02: kubernetes/examples/openshift-origin/README.md
	==> app-02: kubernetes/examples/openshift-origin/openshift-origin-namespace.yaml
	==> app-02: kubernetes/examples/openshift-origin/etcd-discovery-service.yaml
	==> app-02: kubernetes/examples/openshift-origin/etcd-service.yaml
	==> app-02: kubernetes/examples/openshift-origin/.gitignore
	==> app-02: kubernetes/examples/openshift-origin/openshift-service.yaml
	==> app-02: kubernetes/examples/openshift-origin/cleanup.sh
	==> app-02: kubernetes/examples/openshift-origin/etcd-discovery-controller.yaml
	==> app-02: kubernetes/examples/openshift-origin/create.sh
	==> app-02: kubernetes/examples/openshift-origin/secret.json
	==> app-02: kubernetes/examples/openshift-origin/etcd-controller.yaml
	==> app-02: kubernetes/examples/javaee/
	==> app-02: kubernetes/examples/javaee/README.md
	==> app-02: kubernetes/examples/javaee/wildfly-rc.yaml
	==> app-02: kubernetes/examples/javaee/mysql-pod.yaml
	==> app-02: kubernetes/examples/javaee/mysql-service.yaml
	==> app-02: kubernetes/examples/newrelic/
	==> app-02: kubernetes/examples/newrelic/newrelic-config.yaml
	==> app-02: kubernetes/examples/newrelic/README.md
	==> app-02: kubernetes/examples/newrelic/nrconfig.env
	==> app-02: kubernetes/examples/newrelic/newrelic-config-template.yaml
	==> app-02: kubernetes/examples/newrelic/config-to-secret.sh
	==> app-02: kubernetes/examples/newrelic/newrelic-daemonset.yaml
	==> app-02: kubernetes/examples/scheduler-policy-config-with-extender.json
	==> app-02: kubernetes/examples/storm/
	==> app-02: kubernetes/examples/storm/README.md
	==> app-02: kubernetes/examples/storm/storm-nimbus-service.json
	==> app-02: kubernetes/examples/storm/zookeeper.json
	==> app-02: kubernetes/examples/storm/zookeeper-service.json
	==> app-02: kubernetes/examples/storm/storm-worker-controller.json
	==> app-02: kubernetes/examples/storm/storm-nimbus.json
	==> app-02: kubernetes/examples/https-nginx/
	==> app-02: kubernetes/examples/https-nginx/README.md
	==> app-02: kubernetes/examples/https-nginx/Dockerfile
	==> app-02: kubernetes/examples/https-nginx/make_secret.go
	==> app-02: kubernetes/examples/https-nginx/nginx-app.yaml
	==> app-02: kubernetes/examples/https-nginx/default.conf
	==> app-02: kubernetes/examples/https-nginx/Makefile
	==> app-02: kubernetes/examples/https-nginx/index2.html
	==> app-02: kubernetes/examples/https-nginx/auto-reload-nginx.sh
	==> app-02: kubernetes/examples/explorer/
	==> app-02: kubernetes/examples/explorer/README.md
	==> app-02: kubernetes/examples/explorer/Dockerfile
	==> app-02: kubernetes/examples/explorer/Makefile
	==> app-02: kubernetes/examples/explorer/pod.yaml
	==> app-02: kubernetes/examples/explorer/explorer.go
	==> app-02: kubernetes/examples/job/
	==> app-02: kubernetes/examples/job/expansions/
	==> app-02: kubernetes/examples/job/expansions/README.md
	==> app-02: kubernetes/examples/job/work-queue-1/
	==> app-02: kubernetes/examples/job/work-queue-1/README.md
	==> app-02: kubernetes/examples/job/work-queue-2/
	==> app-02: kubernetes/examples/job/work-queue-2/README.md
	==> app-02: kubernetes/examples/cluster-dns/
	==> app-02: kubernetes/examples/cluster-dns/namespace-prod.yaml
	==> app-02: kubernetes/examples/cluster-dns/dns-backend-rc.yaml
	==> app-02: kubernetes/examples/cluster-dns/README.md
	==> app-02: kubernetes/examples/cluster-dns/namespace-dev.yaml
	==> app-02: kubernetes/examples/cluster-dns/images/
	==> app-02: kubernetes/examples/cluster-dns/images/frontend/
	==> app-02: kubernetes/examples/cluster-dns/images/frontend/client.py
	==> app-02: kubernetes/examples/cluster-dns/images/frontend/Dockerfile
	==> app-02: kubernetes/examples/cluster-dns/images/frontend/Makefile
	==> app-02: kubernetes/examples/cluster-dns/images/backend/
	==> app-02: kubernetes/examples/cluster-dns/images/backend/Dockerfile
	==> app-02: kubernetes/examples/cluster-dns/images/backend/Makefile
	==> app-02: kubernetes/examples/cluster-dns/images/backend/server.py
	==> app-02: kubernetes/examples/cluster-dns/dns-frontend-pod.yaml
	==> app-02: kubernetes/examples/cluster-dns/dns-backend-service.yaml
	==> app-02: kubernetes/examples/elasticsearch/
	==> app-02: kubernetes/examples/elasticsearch/es-svc.yaml
	==> app-02: kubernetes/examples/elasticsearch/production_cluster/
	==> app-02: kubernetes/examples/elasticsearch/production_cluster/es-svc.yaml
	==> app-02: kubernetes/examples/elasticsearch/production_cluster/service-account.yaml
	==> app-02: kubernetes/examples/elasticsearch/production_cluster/README.md
	==> app-02: kubernetes/examples/elasticsearch/production_cluster/es-discovery-svc.yaml
	==> app-02: kubernetes/examples/elasticsearch/production_cluster/es-master-rc.yaml
	==> app-02: kubernetes/examples/elasticsearch/production_cluster/es-client-rc.yaml
	==> app-02: kubernetes/examples/elasticsearch/production_cluster/es-data-rc.yaml
	==> app-02: kubernetes/examples/elasticsearch/service-account.yaml
	==> app-02: kubernetes/examples/elasticsearch/README.md
	==> app-02: kubernetes/examples/elasticsearch/es-rc.yaml
	==> app-02: kubernetes/examples/sysdig-cloud/
	==> app-02: kubernetes/examples/sysdig-cloud/README.md
	==> app-02: kubernetes/examples/sysdig-cloud/sysdig-rc.yaml
	==> app-02: kubernetes/examples/sysdig-cloud/sysdig-daemonset.yaml
	==> app-02: kubernetes/examples/selenium/
	==> app-02: kubernetes/examples/selenium/README.md
	==> app-02: kubernetes/examples/selenium/selenium-hub-rc.yaml
	==> app-02: kubernetes/examples/selenium/selenium-test.py
	==> app-02: kubernetes/examples/selenium/selenium-node-chrome-rc.yaml
	==> app-02: kubernetes/examples/selenium/selenium-node-firefox-rc.yaml
	==> app-02: kubernetes/examples/selenium/selenium-hub-svc.yaml
	==> app-02: kubernetes/examples/guestbook-go/
	==> app-02: kubernetes/examples/guestbook-go/redis-master-service.json
	==> app-02: kubernetes/examples/guestbook-go/README.md
	==> app-02: kubernetes/examples/guestbook-go/redis-slave-controller.json
	==> app-02: kubernetes/examples/guestbook-go/redis-master-controller.json
	==> app-02: kubernetes/examples/guestbook-go/guestbook-page.png
	==> app-02: kubernetes/examples/guestbook-go/_src/
	==> app-02: kubernetes/examples/guestbook-go/_src/README.md
	==> app-02: kubernetes/examples/guestbook-go/_src/Dockerfile
	==> app-02: kubernetes/examples/guestbook-go/_src/main.go
	==> app-02: kubernetes/examples/guestbook-go/_src/Makefile
	==> app-02: kubernetes/examples/guestbook-go/_src/guestbook/
	==> app-02: kubernetes/examples/guestbook-go/_src/guestbook/Dockerfile
	==> app-02: kubernetes/examples/guestbook-go/_src/public/
	==> app-02: kubernetes/examples/guestbook-go/_src/public/index.html
	==> app-02: kubernetes/examples/guestbook-go/_src/public/script.js
	==> app-02: kubernetes/examples/guestbook-go/_src/public/style.css
	==> app-02: kubernetes/examples/guestbook-go/guestbook-controller.json
	==> app-02: kubernetes/examples/guestbook-go/guestbook-service.json
	==> app-02: kubernetes/examples/guestbook-go/redis-slave-service.json
	==> app-02: kubernetes/examples/sharing-clusters/
	==> app-02: kubernetes/examples/sharing-clusters/README.md
	==> app-02: kubernetes/examples/sharing-clusters/make_secret.go
	==> app-02: kubernetes/examples/k8petstore/
	==> app-02: kubernetes/examples/k8petstore/k8petstore-nodeport.sh
	==> app-02: kubernetes/examples/k8petstore/README.md
	==> app-02: kubernetes/examples/k8petstore/k8petstore-loadbalancer.sh
	==> app-02: kubernetes/examples/k8petstore/k8petstore.sh
	==> app-02: kubernetes/examples/k8petstore/redis-slave/
	==> app-02: kubernetes/examples/k8petstore/redis-slave/etc_redis_redis.conf
	==> app-02: kubernetes/examples/k8petstore/redis-slave/run.sh
	==> app-02: kubernetes/examples/k8petstore/redis-slave/Dockerfile
	==> app-02: kubernetes/examples/k8petstore/redis/
	==> app-02: kubernetes/examples/k8petstore/redis/etc_redis_redis.conf
	==> app-02: kubernetes/examples/k8petstore/redis/Dockerfile
	==> app-02: kubernetes/examples/k8petstore/redis-master/
	==> app-02: kubernetes/examples/k8petstore/redis-master/etc_redis_redis.conf
	==> app-02: kubernetes/examples/k8petstore/redis-master/Dockerfile
	==> app-02: kubernetes/examples/k8petstore/docker-machine-dev.sh
	==> app-02: kubernetes/examples/k8petstore/k8petstore.dot
	==> app-02: kubernetes/examples/k8petstore/bps-data-generator/
	==> app-02: kubernetes/examples/k8petstore/bps-data-generator/README.md
	==> app-02: kubernetes/examples/k8petstore/build-push-containers.sh
	==> app-02: kubernetes/examples/k8petstore/web-server/
	==> app-02: kubernetes/examples/k8petstore/web-server/src/
	==> app-02: kubernetes/examples/k8petstore/web-server/src/main.go
	==> app-02: kubernetes/examples/k8petstore/web-server/test.sh
	==> app-02: kubernetes/examples/k8petstore/web-server/Dockerfile
	==> app-02: kubernetes/examples/k8petstore/web-server/dump.rdb
	==> app-02: kubernetes/examples/k8petstore/web-server/static/
	==> app-02: kubernetes/examples/k8petstore/web-server/static/histogram.js
	==> app-02: kubernetes/examples/k8petstore/web-server/static/index.html
	==> app-02: kubernetes/examples/k8petstore/web-server/static/script.js
	==> app-02: kubernetes/examples/k8petstore/web-server/static/style.css
	==> app-02: kubernetes/examples/storage/
	==> app-02: kubernetes/examples/storage/redis/
	==> app-02: kubernetes/examples/storage/redis/README.md
	==> app-02: kubernetes/examples/storage/redis/image/
	==> app-02: kubernetes/examples/storage/redis/image/run.sh
	==> app-02: kubernetes/examples/storage/redis/image/Dockerfile
	==> app-02: kubernetes/examples/storage/redis/image/redis-slave.conf
	==> app-02: kubernetes/examples/storage/redis/image/redis-master.conf
	==> app-02: kubernetes/examples/storage/redis/redis-controller.yaml
	==> app-02: kubernetes/examples/storage/redis/redis-sentinel-controller.yaml
	==> app-02: kubernetes/examples/storage/redis/redis-proxy.yaml
	==> app-02: kubernetes/examples/storage/redis/redis-sentinel-service.yaml
	==> app-02: kubernetes/examples/storage/redis/redis-master.yaml
	==> app-02: kubernetes/examples/storage/mysql-galera/
	==> app-02: kubernetes/examples/storage/mysql-galera/README.md
	==> app-02: kubernetes/examples/storage/mysql-galera/pxc-node1.yaml
	==> app-02: kubernetes/examples/storage/mysql-galera/image/
	==> app-02: kubernetes/examples/storage/mysql-galera/image/Dockerfile
	==> app-02: kubernetes/examples/storage/mysql-galera/image/docker-entrypoint.sh
	==> app-02: kubernetes/examples/storage/mysql-galera/image/my.cnf
	==> app-02: kubernetes/examples/storage/mysql-galera/image/cluster.cnf
	==> app-02: kubernetes/examples/storage/mysql-galera/pxc-node3.yaml
	==> app-02: kubernetes/examples/storage/mysql-galera/pxc-cluster-service.yaml
	==> app-02: kubernetes/examples/storage/mysql-galera/pxc-node2.yaml
	==> app-02: kubernetes/examples/storage/cassandra/
	==> app-02: kubernetes/examples/storage/cassandra/README.md
	==> app-02: kubernetes/examples/storage/cassandra/cassandra-daemonset.yaml
	==> app-02: kubernetes/examples/storage/cassandra/image/
	==> app-02: kubernetes/examples/storage/cassandra/image/Dockerfile
	==> app-02: kubernetes/examples/storage/cassandra/image/files/
	==> app-02: kubernetes/examples/storage/cassandra/image/files/run.sh
	==> app-02: kubernetes/examples/storage/cassandra/image/files/cassandra.list
	==> app-02: kubernetes/examples/storage/cassandra/image/files/ready-probe.sh
	==> app-02: kubernetes/examples/storage/cassandra/image/files/cassandra.yaml
	==> app-02: kubernetes/examples/storage/cassandra/image/files/kubernetes-cassandra.jar
	==> app-02: kubernetes/examples/storage/cassandra/image/files/logback.xml
	==> app-02: kubernetes/examples/storage/cassandra/image/files/java.list
	==> app-02: kubernetes/examples/storage/cassandra/image/Makefile
	==> app-02: kubernetes/examples/storage/cassandra/cassandra-petset.yaml
	==> app-02: kubernetes/examples/storage/cassandra/cassandra-service.yaml
	==> app-02: kubernetes/examples/storage/cassandra/cassandra-controller.yaml
	==> app-02: kubernetes/examples/storage/cassandra/java/
	==> app-02: kubernetes/examples/storage/cassandra/java/src/
	==> app-02: kubernetes/examples/storage/cassandra/java/src/main/
	==> app-02: kubernetes/examples/storage/cassandra/java/src/main/java/
	==> app-02: kubernetes/examples/storage/cassandra/java/src/main/java/io/
	==> app-02: kubernetes/examples/storage/cassandra/java/src/main/java/io/k8s/
	==> app-02: kubernetes/examples/storage/cassandra/java/src/main/java/io/k8s/cassandra/
	==> app-02: kubernetes/examples/storage/cassandra/java/src/main/java/io/k8s/cassandra/KubernetesSeedProvider.java
	==> app-02: kubernetes/examples/storage/cassandra/java/src/test/
	==> app-02: kubernetes/examples/storage/cassandra/java/src/test/resources/
	==> app-02: kubernetes/examples/storage/cassandra/java/src/test/resources/cassandra.yaml
	==> app-02: kubernetes/examples/storage/cassandra/java/src/test/resources/logback-test.xml
	==> app-02: kubernetes/examples/storage/cassandra/java/src/test/java/
	==> app-02: kubernetes/examples/storage/cassandra/java/src/test/java/io/
	==> app-02: kubernetes/examples/storage/cassandra/java/src/test/java/io/k8s/
	==> app-02: kubernetes/examples/storage/cassandra/java/src/test/java/io/k8s/cassandra/
	==> app-02: kubernetes/examples/storage/cassandra/java/src/test/java/io/k8s/cassandra/KubernetesSeedProviderTest.java
	==> app-02: kubernetes/examples/storage/cassandra/java/README.md
	==> app-02: kubernetes/examples/storage/cassandra/java/.gitignore
	==> app-02: kubernetes/examples/storage/cassandra/java/pom.xml
	==> app-02: kubernetes/examples/storage/rethinkdb/
	==> app-02: kubernetes/examples/storage/rethinkdb/README.md
	==> app-02: kubernetes/examples/storage/rethinkdb/admin-pod.yaml
	==> app-02: kubernetes/examples/storage/rethinkdb/image/
	==> app-02: kubernetes/examples/storage/rethinkdb/image/run.sh
	==> app-02: kubernetes/examples/storage/rethinkdb/image/Dockerfile
	==> app-02: kubernetes/examples/storage/rethinkdb/admin-service.yaml
	==> app-02: kubernetes/examples/storage/rethinkdb/rc.yaml
	==> app-02: kubernetes/examples/storage/rethinkdb/gen-pod.sh
	==> app-02: kubernetes/examples/storage/rethinkdb/driver-service.yaml
	==> app-02: kubernetes/examples/storage/hazelcast/
	==> app-02: kubernetes/examples/storage/hazelcast/hazelcast-controller.yaml
	==> app-02: kubernetes/examples/storage/hazelcast/README.md
	==> app-02: kubernetes/examples/storage/hazelcast/image/
	==> app-02: kubernetes/examples/storage/hazelcast/image/Dockerfile
	==> app-02: kubernetes/examples/storage/hazelcast/hazelcast-service.yaml
	==> app-02: kubernetes/examples/storage/vitess/
	==> app-02: kubernetes/examples/storage/vitess/vitess-up.sh
	==> app-02: kubernetes/examples/storage/vitess/guestbook-down.sh
	==> app-02: kubernetes/examples/storage/vitess/README.md
	==> app-02: kubernetes/examples/storage/vitess/guestbook-service.yaml
	==> app-02: kubernetes/examples/storage/vitess/vtctld-controller-template.yaml
	==> app-02: kubernetes/examples/storage/vitess/vtgate-up.sh
	==> app-02: kubernetes/examples/storage/vitess/etcd-up.sh
	==> app-02: kubernetes/examples/storage/vitess/vtctld-down.sh
	==> app-02: kubernetes/examples/storage/vitess/vtctld-service.yaml
	==> app-02: kubernetes/examples/storage/vitess/vitess-down.sh
	==> app-02: kubernetes/examples/storage/vitess/etcd-controller-template.yaml
	==> app-02: kubernetes/examples/storage/vitess/etcd-down.sh
	==> app-02: kubernetes/examples/storage/vitess/vtctld-up.sh
	==> app-02: kubernetes/examples/storage/vitess/create_test_table.sql
	==> app-02: kubernetes/examples/storage/vitess/configure.sh
	==> app-02: kubernetes/examples/storage/vitess/etcd-service-template.yaml
	==> app-02: kubernetes/examples/storage/vitess/vtgate-service.yaml
	==> app-02: kubernetes/examples/storage/vitess/vttablet-down.sh
	==> app-02: kubernetes/examples/storage/vitess/env.sh
	==> app-02: kubernetes/examples/storage/vitess/vttablet-up.sh
	==> app-02: kubernetes/examples/storage/vitess/guestbook-controller.yaml
	==> app-02: kubernetes/examples/storage/vitess/vtgate-controller-template.yaml
	==> app-02: kubernetes/examples/storage/vitess/guestbook-up.sh
	==> app-02: kubernetes/examples/storage/vitess/vttablet-pod-template.yaml
	==> app-02: kubernetes/examples/storage/vitess/vtgate-down.sh
	==> app-02: kubernetes/examples/guestbook/
	==> app-02: kubernetes/examples/guestbook/redis-slave-deployment.yaml
	==> app-02: kubernetes/examples/guestbook/php-redis/
	==> app-02: kubernetes/examples/guestbook/php-redis/Dockerfile
	==> app-02: kubernetes/examples/guestbook/php-redis/guestbook.php
	==> app-02: kubernetes/examples/guestbook/php-redis/index.html
	==> app-02: kubernetes/examples/guestbook/php-redis/controllers.js
	==> app-02: kubernetes/examples/guestbook/frontend-deployment.yaml
	==> app-02: kubernetes/examples/guestbook/README.md
	==> app-02: kubernetes/examples/guestbook/redis-master-service.yaml
	==> app-02: kubernetes/examples/guestbook/redis-slave/
	==> app-02: kubernetes/examples/guestbook/redis-slave/run.sh
	==> app-02: kubernetes/examples/guestbook/redis-slave/Dockerfile
	==> app-02: kubernetes/examples/guestbook/frontend-service.yaml
	==> app-02: kubernetes/examples/guestbook/redis-master-deployment.yaml
	==> app-02: kubernetes/examples/guestbook/legacy/
	==> app-02: kubernetes/examples/guestbook/legacy/frontend-controller.yaml
	==> app-02: kubernetes/examples/guestbook/legacy/redis-master-controller.yaml
	==> app-02: kubernetes/examples/guestbook/legacy/redis-slave-controller.yaml
	==> app-02: kubernetes/examples/guestbook/redis-slave-service.yaml
	==> app-02: kubernetes/examples/guestbook/all-in-one/
	==> app-02: kubernetes/examples/guestbook/all-in-one/guestbook-all-in-one.yaml
	==> app-02: kubernetes/examples/guestbook/all-in-one/frontend.yaml
	==> app-02: kubernetes/examples/guestbook/all-in-one/redis-slave.yaml
	==> app-02: kubernetes/examples/volumes/
	==> app-02: kubernetes/examples/volumes/iscsi/
	==> app-02: kubernetes/examples/volumes/iscsi/iscsi.yaml
	==> app-02: kubernetes/examples/volumes/iscsi/README.md
	==> app-02: kubernetes/examples/volumes/glusterfs/
	==> app-02: kubernetes/examples/volumes/glusterfs/README.md
	==> app-02: kubernetes/examples/volumes/glusterfs/glusterfs-endpoints.json
	==> app-02: kubernetes/examples/volumes/glusterfs/glusterfs-pod.json
	==> app-02: kubernetes/examples/volumes/glusterfs/glusterfs-service.json
	==> app-02: kubernetes/examples/volumes/cephfs/
	==> app-02: kubernetes/examples/volumes/cephfs/README.md
	==> app-02: kubernetes/examples/volumes/cephfs/secret/
	==> app-02: kubernetes/examples/volumes/cephfs/secret/ceph-secret.yaml
	==> app-02: kubernetes/examples/volumes/cephfs/cephfs-with-secret.yaml
	==> app-02: kubernetes/examples/volumes/cephfs/cephfs.yaml
	==> app-02: kubernetes/examples/volumes/nfs/
	==> app-02: kubernetes/examples/volumes/nfs/nfs-server-service.yaml
	==> app-02: kubernetes/examples/volumes/nfs/nfs-web-rc.yaml
	==> app-02: kubernetes/examples/volumes/nfs/README.md
	==> app-02: kubernetes/examples/volumes/nfs/nfs-data/
	==> app-02: kubernetes/examples/volumes/nfs/nfs-data/README.md
	==> app-02: kubernetes/examples/volumes/nfs/nfs-data/Dockerfile
	==> app-02: kubernetes/examples/volumes/nfs/nfs-data/index.html
	==> app-02: kubernetes/examples/volumes/nfs/nfs-data/run_nfs.sh
	==> app-02: kubernetes/examples/volumes/nfs/nfs-pvc.yaml
	==> app-02: kubernetes/examples/volumes/nfs/nfs-server-rc.yaml
	==> app-02: kubernetes/examples/volumes/nfs/nfs-pv.yaml
	==> app-02: kubernetes/examples/volumes/nfs/nfs-web-service.yaml
	==> app-02: kubernetes/examples/volumes/nfs/provisioner/
	==> app-02: kubernetes/examples/volumes/nfs/provisioner/nfs-server-gce-pv.yaml
	==> app-02: kubernetes/examples/volumes/nfs/nfs-busybox-rc.yaml
	==> app-02: kubernetes/examples/volumes/nfs/nfs-pv.png
	==> app-02: kubernetes/examples/volumes/flocker/
	==> app-02: kubernetes/examples/volumes/flocker/README.md
	==> app-02: kubernetes/examples/volumes/flocker/flocker-pod.yml
	==> app-02: kubernetes/examples/volumes/flocker/flocker-pod-with-rc.yml
	==> app-02: kubernetes/examples/volumes/azure_disk/
	==> app-02: kubernetes/examples/volumes/azure_disk/README.md
	==> app-02: kubernetes/examples/volumes/azure_disk/azure.yaml
	==> app-02: kubernetes/examples/volumes/azure_file/
	==> app-02: kubernetes/examples/volumes/azure_file/README.md
	==> app-02: kubernetes/examples/volumes/azure_file/secret/
	==> app-02: kubernetes/examples/volumes/azure_file/secret/azure-secret.yaml
	==> app-02: kubernetes/examples/volumes/azure_file/azure.yaml
	==> app-02: kubernetes/examples/volumes/flexvolume/
	==> app-02: kubernetes/examples/volumes/flexvolume/README.md
	==> app-02: kubernetes/examples/volumes/flexvolume/lvm
	==> app-02: kubernetes/examples/volumes/flexvolume/nginx.yaml
	==> app-02: kubernetes/examples/volumes/fibre_channel/
	==> app-02: kubernetes/examples/volumes/fibre_channel/README.md
	==> app-02: kubernetes/examples/volumes/fibre_channel/fc.yaml
	==> app-02: kubernetes/examples/volumes/rbd/
	==> app-02: kubernetes/examples/volumes/rbd/rbd-with-secret.json
	==> app-02: kubernetes/examples/volumes/rbd/README.md
	==> app-02: kubernetes/examples/volumes/rbd/secret/
	==> app-02: kubernetes/examples/volumes/rbd/secret/ceph-secret.yaml
	==> app-02: kubernetes/examples/volumes/rbd/rbd.json
	==> app-02: kubernetes/examples/volumes/aws_ebs/
	==> app-02: kubernetes/examples/volumes/aws_ebs/README.md
	==> app-02: kubernetes/examples/volumes/aws_ebs/aws-ebs-web.yaml
	==> app-02: kubernetes/examples/volumes/quobyte/
	==> app-02: kubernetes/examples/volumes/quobyte/quobyte-pod.yaml
	==> app-02: kubernetes/examples/volumes/quobyte/Readme.md
	==> app-02: kubernetes/examples/scheduler-policy-config.json
	==> app-02: kubernetes/examples/spark/
	==> app-02: kubernetes/examples/spark/spark-gluster/
	==> app-02: kubernetes/examples/spark/spark-gluster/README.md
	==> app-02: kubernetes/examples/spark/spark-gluster/glusterfs-endpoints.yaml
	==> app-02: kubernetes/examples/spark/spark-gluster/spark-master-service.yaml
	==> app-02: kubernetes/examples/spark/spark-gluster/spark-worker-controller.yaml
	==> app-02: kubernetes/examples/spark/spark-gluster/spark-master-controller.yaml
	==> app-02: kubernetes/examples/spark/README.md
	==> app-02: kubernetes/examples/spark/spark-master-service.yaml
	==> app-02: kubernetes/examples/spark/spark-worker-controller.yaml
	==> app-02: kubernetes/examples/spark/spark-master-controller.yaml
	==> app-02: kubernetes/examples/spark/zeppelin-controller.yaml
	==> app-02: kubernetes/examples/spark/zeppelin-service.yaml
	==> app-02: kubernetes/examples/spark/namespace-spark-cluster.yaml
	==> app-02: kubernetes/examples/spark/spark-webui.yaml
	==> app-02: kubernetes/examples/pod
	==> app-02: kubernetes/examples/meteor/
	==> app-02: kubernetes/examples/meteor/mongo-pod.json
	==> app-02: kubernetes/examples/meteor/README.md
	==> app-02: kubernetes/examples/meteor/dockerbase/
	==> app-02: kubernetes/examples/meteor/dockerbase/README.md
	==> app-02: kubernetes/examples/meteor/dockerbase/Dockerfile
	==> app-02: kubernetes/examples/meteor/mongo-service.json
	==> app-02: kubernetes/examples/meteor/meteor-controller.json
	==> app-02: kubernetes/examples/meteor/meteor-service.json
	==> app-02: kubernetes/examples/kubectl-container/
	==> app-02: kubernetes/examples/kubectl-container/README.md
	==> app-02: kubernetes/examples/kubectl-container/Dockerfile
	==> app-02: kubernetes/examples/kubectl-container/.gitignore
	==> app-02: kubernetes/examples/kubectl-container/Makefile
	==> app-02: kubernetes/examples/kubectl-container/pod.json
	==> app-02: kubernetes/examples/apiserver/
	==> app-02: kubernetes/examples/apiserver/README.md
	==> app-02: kubernetes/examples/apiserver/server/
	==> app-02: kubernetes/examples/apiserver/server/main.go
	==> app-02: kubernetes/examples/apiserver/rest/
	==> app-02: kubernetes/examples/apiserver/rest/reststorage.go
	==> app-02: kubernetes/examples/apiserver/apiserver.go
	==> app-02: kubernetes/examples/guidelines.md
	==> app-02: kubernetes/platforms/
	==> app-02: kubernetes/platforms/darwin/
	==> app-02: kubernetes/platforms/darwin/amd64/
	==> app-02: kubernetes/platforms/darwin/amd64/kubectl
	==> app-02: kubernetes/platforms/darwin/386/
	==> app-02: kubernetes/platforms/darwin/386/kubectl
	==> app-02: kubernetes/platforms/linux/
	==> app-02: kubernetes/platforms/linux/arm/
	==> app-02: kubernetes/platforms/linux/arm/kubectl
	==> app-02: kubernetes/platforms/linux/amd64/
	==> app-02: kubernetes/platforms/linux/amd64/kubectl
	==> app-02: kubernetes/platforms/linux/arm64/
	==> app-02: kubernetes/platforms/linux/arm64/kubectl
	==> app-02: kubernetes/platforms/linux/386/
	==> app-02: kubernetes/platforms/linux/386/kubectl
	==> app-02: kubernetes/platforms/windows/
	==> app-02: kubernetes/platforms/windows/amd64/
	==> app-02: kubernetes/platforms/windows/amd64/kubectl.exe
	==> app-02: kubernetes/platforms/windows/386/
	==> app-02: kubernetes/platforms/windows/386/kubectl.exe
	==> app-02: + cd /opt/kubernetes-1.5.0/server/
	==> app-02: + tar -zxvf kubernetes-server-linux-amd64.tar.gz
	==> app-02: kubernetes/
	==> app-02: kubernetes/kubernetes-src.tar.gz
	==> app-02: kubernetes/LICENSES
	==> app-02: kubernetes/server/
	==> app-02: kubernetes/server/bin/
	==> app-02: kubernetes/server/bin/kube-apiserver.tar
	==> app-02: kubernetes/server/bin/kube-discovery
	==> app-02: kubernetes/server/bin/kube-proxy.docker_tag
	==> app-02: kubernetes/server/bin/kube-dns
	==> app-02: kubernetes/server/bin/kube-scheduler.tar
	==> app-02: kubernetes/server/bin/kube-scheduler
	==> app-02: kubernetes/server/bin/kubelet
	==> app-02: kubernetes/server/bin/kube-controller-manager.docker_tag
	==> app-02: kubernetes/server/bin/kube-proxy
	==> app-02: kubernetes/server/bin/kubeadm
	==> app-02: kubernetes/server/bin/kube-controller-manager
	==> app-02: kubernetes/server/bin/hyperkube
	==> app-02: kubernetes/server/bin/kube-controller-manager.tar
	==> app-02: kubernetes/server/bin/kube-apiserver
	==> app-02: kubernetes/server/bin/kubectl
	==> app-02: kubernetes/server/bin/kube-apiserver.docker_tag
	==> app-02: kubernetes/server/bin/kube-proxy.tar
	==> app-02: kubernetes/server/bin/kube-scheduler.docker_tag
	==> app-02: kubernetes/addons/
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
	==> app-03: + sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse'
	==> app-03: + sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse'
	==> app-03: + sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse'
	==> app-03: + sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse'
	==> app-03: + sudo echo 'deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse'
	==> app-03: + sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse'
	==> app-03: + sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse'
	==> app-03: + sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse'
	==> app-03: + sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse'
	==> app-03: + sudo echo 'deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse'
	==> app-03: + sudo apt-get update -y -q
	==> app-03: Ign http://mirrors.aliyun.com trusty InRelease
	==> app-03: Get:1 http://mirrors.aliyun.com trusty-security InRelease [65.9 kB]
	==> app-03: Get:2 http://mirrors.aliyun.com trusty-updates InRelease [65.9 kB]
	==> app-03: Get:3 http://mirrors.aliyun.com trusty-proposed InRelease [65.9 kB]
	==> app-03: Get:4 http://mirrors.aliyun.com trusty-backports InRelease [65.9 kB]
	==> app-03: Get:5 http://ppa.launchpad.net trusty InRelease [16.0 kB]
	==> app-03: Get:6 http://mirrors.aliyun.com trusty Release.gpg [933 B]
	==> app-03: Get:7 http://mirrors.aliyun.com trusty-security/main Sources [120 kB]
	==> app-03: Get:8 http://mirrors.aliyun.com trusty-security/restricted Sources [4,064 B]
	==> app-03: Get:9 http://mirrors.aliyun.com trusty-security/universe Sources [44.7 kB]
	==> app-03: Get:10 http://mirrors.aliyun.com trusty-security/multiverse Sources [3,202 B]
	==> app-03: Get:11 http://mirrors.aliyun.com trusty-security/main amd64 Packages [542 kB]
	==> app-03: Get:12 http://ppa.launchpad.net trusty/main Translation-en [713 B]
	==> app-03: Get:13 http://mirrors.aliyun.com trusty-security/restricted amd64 Packages [13.0 kB]
	==> app-03: Get:14 http://mirrors.aliyun.com trusty-security/universe amd64 Packages [141 kB]
	==> app-03: Get:15 http://mirrors.aliyun.com trusty-security/multiverse amd64 Packages [5,199 B]
	==> app-03: Get:16 http://mirrors.aliyun.com trusty-security/main Translation-en [298 kB]
	==> app-03: Get:17 http://mirrors.aliyun.com trusty-security/multiverse Translation-en [2,848 B]
	==> app-03: Get:18 http://mirrors.aliyun.com trusty-security/restricted Translation-en [3,206 B]
	==> app-03: Get:19 http://mirrors.aliyun.com trusty-security/universe Translation-en [84.3 kB]
	==> app-03: Get:20 http://mirrors.aliyun.com trusty-updates/main Sources [383 kB]
	==> app-03: Get:21 http://mirrors.aliyun.com trusty-updates/restricted Sources [5,360 B]
	==> app-03: Get:22 http://mirrors.aliyun.com trusty-updates/universe Sources [169 kB]
	==> app-03: Get:23 http://mirrors.aliyun.com trusty-updates/multiverse Sources [7,531 B]
	==> app-03: Get:24 http://mirrors.aliyun.com trusty-updates/main amd64 Packages [910 kB]
	==> app-03: Get:25 http://mirrors.aliyun.com trusty-updates/restricted amd64 Packages [15.9 kB]
	==> app-03: Get:26 http://mirrors.aliyun.com trusty-updates/universe amd64 Packages [387 kB]
	==> app-03: Get:27 http://mirrors.aliyun.com trusty-updates/multiverse amd64 Packages [15.0 kB]
	==> app-03: Get:28 http://mirrors.aliyun.com trusty-updates/main Translation-en [443 kB]
	==> app-03: Get:29 http://mirrors.aliyun.com trusty-updates/multiverse Translation-en [7,931 B]
	==> app-03: Get:30 http://mirrors.aliyun.com trusty-updates/restricted Translation-en [3,699 B]
	==> app-03: Get:31 http://mirrors.aliyun.com trusty-updates/universe Translation-en [205 kB]
	==> app-03: Get:32 http://mirrors.aliyun.com trusty-proposed/main Sources [116 kB]
	==> app-03: Get:33 http://mirrors.aliyun.com trusty-proposed/restricted Sources [28 B]
	==> app-03: Get:34 http://mirrors.aliyun.com trusty-proposed/universe Sources [16.9 kB]
	==> app-03: Get:35 http://mirrors.aliyun.com trusty-proposed/multiverse Sources [28 B]
	==> app-03: Get:36 http://mirrors.aliyun.com trusty-proposed/main amd64 Packages [99.4 kB]
	==> app-03: Get:37 http://mirrors.aliyun.com trusty-proposed/restricted amd64 Packages [28 B]
	==> app-03: Get:38 http://mirrors.aliyun.com trusty-proposed/universe amd64 Packages [12.1 kB]
	==> app-03: Get:39 http://mirrors.aliyun.com trusty-proposed/multiverse amd64 Packages [28 B]
	==> app-03: Get:40 http://mirrors.aliyun.com trusty-proposed/main Translation-en [34.3 kB]
	==> app-03: Get:41 http://mirrors.aliyun.com trusty-proposed/multiverse Translation-en [28 B]
	==> app-03: Get:42 http://mirrors.aliyun.com trusty-proposed/restricted Translation-en [28 B]
	==> app-03: Get:43 http://mirrors.aliyun.com trusty-proposed/universe Translation-en [10.8 kB]
	==> app-03: Get:44 http://mirrors.aliyun.com trusty-backports/main Sources [9,646 B]
	==> app-03: Get:45 http://mirrors.aliyun.com trusty-backports/restricted Sources [28 B]
	==> app-03: Get:46 http://mirrors.aliyun.com trusty-backports/universe Sources [35.2 kB]
	==> app-03: Get:47 http://mirrors.aliyun.com trusty-backports/multiverse Sources [1,898 B]
	==> app-03: Get:48 http://mirrors.aliyun.com trusty-backports/main amd64 Packages [13.3 kB]
	==> app-03: Get:49 http://mirrors.aliyun.com trusty-backports/restricted amd64 Packages [28 B]
	==> app-03: Get:50 http://mirrors.aliyun.com trusty-backports/universe amd64 Packages [43.2 kB]
	==> app-03: Get:51 http://mirrors.aliyun.com trusty-backports/multiverse amd64 Packages [1,571 B]
	==> app-03: Get:52 http://mirrors.aliyun.com trusty-backports/main Translation-en [7,493 B]
	==> app-03: Get:53 http://mirrors.aliyun.com trusty-backports/multiverse Translation-en [1,215 B]
	==> app-03: Get:54 http://mirrors.aliyun.com trusty-backports/restricted Translation-en [28 B]
	==> app-03: Get:55 http://mirrors.aliyun.com trusty-backports/universe Translation-en [36.8 kB]
	==> app-03: Get:56 http://mirrors.aliyun.com trusty Release [58.5 kB]
	==> app-03: Get:57 http://mirrors.aliyun.com trusty/main Sources [1,064 kB]
	==> app-03: Get:58 http://mirrors.aliyun.com trusty/restricted Sources [5,433 B]
	==> app-03: Get:59 http://mirrors.aliyun.com trusty/universe Sources [6,399 kB]
	==> app-03: Get:60 http://ppa.launchpad.net trusty/main amd64 Packages [1,706 B]
	==> app-03: Get:61 http://mirrors.aliyun.com trusty/multiverse Sources [174 kB]
	==> app-03: Get:62 http://mirrors.aliyun.com trusty/main amd64 Packages [1,350 kB]
	==> app-03: Get:63 http://mirrors.aliyun.com trusty/restricted amd64 Packages [13.0 kB]
	==> app-03: Get:64 http://mirrors.aliyun.com trusty/universe amd64 Packages [5,859 kB]
	==> app-03: Get:65 http://mirrors.aliyun.com trusty/multiverse amd64 Packages [132 kB]
	==> app-03: Get:66 http://mirrors.aliyun.com trusty/main Translation-en [762 kB]
	==> app-03: Get:67 http://mirrors.aliyun.com trusty/multiverse Translation-en [102 kB]
	==> app-03: Get:68 http://mirrors.aliyun.com trusty/restricted Translation-en [3,457 B]
	==> app-03: Get:69 http://mirrors.aliyun.com trusty/universe Translation-en [4,089 kB]
	==> app-03: Ign http://mirrors.aliyun.com trusty/main Translation-en_US
	==> app-03: Ign http://mirrors.aliyun.com trusty/multiverse Translation-en_US
	==> app-03: Ign http://mirrors.aliyun.com trusty/restricted Translation-en_US
	==> app-03: Ign http://mirrors.aliyun.com trusty/universe Translation-en_US
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
	==> app-03: Get:1 http://mirrors.aliyun.com/ubuntu/ trusty-security/main libnettle4 amd64 2.7.1-1ubuntu0.1 [102 kB]
	==> app-03: Get:2 http://mirrors.aliyun.com/ubuntu/ trusty-security/main libhogweed2 amd64 2.7.1-1ubuntu0.1 [124 kB]
	==> app-03: Get:3 http://mirrors.aliyun.com/ubuntu/ trusty-security/universe libgnutls28 amd64 3.2.11-2ubuntu1.1 [540 kB]
	==> app-03: Get:4 http://ppa.launchpad.net/openconnect/daily/ubuntu/ trusty/main libopenconnect5 amd64 7.06-0~2492~ubuntu14.04.1 [105 kB]
	==> app-03: Get:5 http://mirrors.aliyun.com/ubuntu/ trusty/main libproxy1 amd64 0.4.11-0ubuntu4 [56.2 kB]
	==> app-03: Get:6 http://mirrors.aliyun.com/ubuntu/ trusty/main libtommath0 amd64 0.42.0-1build1 [55.6 kB]
	==> app-03: Get:7 http://mirrors.aliyun.com/ubuntu/ trusty/universe libtomcrypt0 amd64 1.17-5 [272 kB]
	==> app-03: Get:8 http://ppa.launchpad.net/openconnect/daily/ubuntu/ trusty/main openconnect amd64 7.06-0~2492~ubuntu14.04.1 [418 kB]
	==> app-03: Get:9 http://mirrors.aliyun.com/ubuntu/ trusty/universe libstoken1 amd64 0.2-1 [13.0 kB]
	==> app-03: Get:10 http://mirrors.aliyun.com/ubuntu/ trusty-updates/main iproute all 1:3.12.0-2ubuntu1 [2,392 B]
	==> app-03: Get:11 http://mirrors.aliyun.com/ubuntu/ trusty/universe vpnc-scripts all 0.1~git20120602-2 [12.2 kB]
	==> app-03: dpkg-preconfigure: unable to re-open stdin: No such file or directory
	==> app-03: Fetched 1,700 kB in 1s (881 kB/s)
	==> app-03: Selecting previously unselected package libnettle4:amd64.
	==> app-03: (Reading database ... 62997 files and directories currently installed.)
	==> app-03: Preparing to unpack .../libnettle4_2.7.1-1ubuntu0.1_amd64.deb ...
	==> app-03: Unpacking libnettle4:amd64 (2.7.1-1ubuntu0.1) ...
	==> app-03: Selecting previously unselected package libhogweed2:amd64.
	==> app-03: Preparing to unpack .../libhogweed2_2.7.1-1ubuntu0.1_amd64.deb ...
	==> app-03: Unpacking libhogweed2:amd64 (2.7.1-1ubuntu0.1) ...
	==> app-03: Selecting previously unselected package libgnutls28:amd64.
	==> app-03: Preparing to unpack .../libgnutls28_3.2.11-2ubuntu1.1_amd64.deb ...
	==> app-03: Unpacking libgnutls28:amd64 (3.2.11-2ubuntu1.1) ...
	==> app-03: Selecting previously unselected package libproxy1:amd64.
	==> app-03: Preparing to unpack .../libproxy1_0.4.11-0ubuntu4_amd64.deb ...
	==> app-03: Unpacking libproxy1:amd64 (0.4.11-0ubuntu4) ...
	==> app-03: Selecting previously unselected package libtommath0.
	==> app-03: Preparing to unpack .../libtommath0_0.42.0-1build1_amd64.deb ...
	==> app-03: Unpacking libtommath0 (0.42.0-1build1) ...
	==> app-03: Selecting previously unselected package libtomcrypt0:amd64.
	==> app-03: Preparing to unpack .../libtomcrypt0_1.17-5_amd64.deb ...
	==> app-03: Unpacking libtomcrypt0:amd64 (1.17-5) ...
	==> app-03: Selecting previously unselected package libstoken1:amd64.
	==> app-03: Preparing to unpack .../libstoken1_0.2-1_amd64.deb ...
	==> app-03: Unpacking libstoken1:amd64 (0.2-1) ...
	==> app-03: Selecting previously unselected package libopenconnect5:amd64.
	==> app-03: Preparing to unpack .../libopenconnect5_7.06-0~2492~ubuntu14.04.1_amd64.deb ...
	==> app-03: Unpacking libopenconnect5:amd64 (7.06-0~2492~ubuntu14.04.1) ...
	==> app-03: Selecting previously unselected package iproute.
	==> app-03: Preparing to unpack .../iproute_1%3a3.12.0-2ubuntu1_all.deb ...
	==> app-03: Unpacking iproute (1:3.12.0-2ubuntu1) ...
	==> app-03: Selecting previously unselected package vpnc-scripts.
	==> app-03: Preparing to unpack .../vpnc-scripts_0.1~git20120602-2_all.deb ...
	==> app-03: Unpacking vpnc-scripts (0.1~git20120602-2) ...
	==> app-03: Selecting previously unselected package openconnect.
	==> app-03: Preparing to unpack .../openconnect_7.06-0~2492~ubuntu14.04.1_amd64.deb ...
	==> app-03: Unpacking openconnect (7.06-0~2492~ubuntu14.04.1) ...
	==> app-03: Processing triggers for man-db (2.6.7.1-1ubuntu1) ...
	==> app-03: Setting up libnettle4:amd64 (2.7.1-1ubuntu0.1) ...
	==> app-03: Setting up libhogweed2:amd64 (2.7.1-1ubuntu0.1) ...
	==> app-03: Setting up libgnutls28:amd64 (3.2.11-2ubuntu1.1) ...
	==> app-03: Setting up libproxy1:amd64 (0.4.11-0ubuntu4) ...
	==> app-03: Setting up libtommath0 (0.42.0-1build1) ...
	==> app-03: Setting up libtomcrypt0:amd64 (1.17-5) ...
	==> app-03: Setting up libstoken1:amd64 (0.2-1) ...
	==> app-03: Setting up libopenconnect5:amd64 (7.06-0~2492~ubuntu14.04.1) ...
	==> app-03: Setting up iproute (1:3.12.0-2ubuntu1) ...
	==> app-03: Setting up vpnc-scripts (0.1~git20120602-2) ...
	==> app-03: Setting up openconnect (7.06-0~2492~ubuntu14.04.1) ...
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
	==> app-03: kubernetes/third_party/
	==> app-03: kubernetes/third_party/htpasswd/
	==> app-03: kubernetes/third_party/htpasswd/htpasswd.py
	==> app-03: kubernetes/third_party/htpasswd/COPYING
	==> app-03: kubernetes/README.md
	==> app-03: kubernetes/docs/
	==> app-03: kubernetes/docs/api-reference/
	==> app-03: kubernetes/docs/api-reference/policy/
	==> app-03: kubernetes/docs/api-reference/policy/v1alpha1/
	==> app-03: kubernetes/docs/api-reference/policy/v1alpha1/operations.html
	==> app-03: kubernetes/docs/api-reference/policy/v1alpha1/definitions.html
	==> app-03: kubernetes/docs/api-reference/README.md
	==> app-03: kubernetes/docs/api-reference/v1/
	==> app-03: kubernetes/docs/api-reference/v1/operations.html
	==> app-03: kubernetes/docs/api-reference/v1/definitions.md
	==> app-03: kubernetes/docs/api-reference/v1/operations.md
	==> app-03: kubernetes/docs/api-reference/v1/definitions.html
	==> app-03: kubernetes/docs/api-reference/authorization.k8s.io/
	==> app-03: kubernetes/docs/api-reference/authorization.k8s.io/v1beta1/
	==> app-03: kubernetes/docs/api-reference/authorization.k8s.io/v1beta1/operations.html
	==> app-03: kubernetes/docs/api-reference/authorization.k8s.io/v1beta1/definitions.html
	==> app-03: kubernetes/docs/api-reference/labels-annotations-taints.md
	==> app-03: kubernetes/docs/api-reference/autoscaling/
	==> app-03: kubernetes/docs/api-reference/autoscaling/v1/
	==> app-03: kubernetes/docs/api-reference/autoscaling/v1/operations.html
	==> app-03: kubernetes/docs/api-reference/autoscaling/v1/definitions.html
	==> app-03: kubernetes/docs/api-reference/rbac.authorization.k8s.io/
	==> app-03: kubernetes/docs/api-reference/rbac.authorization.k8s.io/v1alpha1/
	==> app-03: kubernetes/docs/api-reference/rbac.authorization.k8s.io/v1alpha1/operations.html
	==> app-03: kubernetes/docs/api-reference/rbac.authorization.k8s.io/v1alpha1/definitions.html
	==> app-03: kubernetes/docs/api-reference/certificates.k8s.io/
	==> app-03: kubernetes/docs/api-reference/certificates.k8s.io/v1alpha1/
	==> app-03: kubernetes/docs/api-reference/certificates.k8s.io/v1alpha1/operations.html
	==> app-03: kubernetes/docs/api-reference/certificates.k8s.io/v1alpha1/definitions.html
	==> app-03: kubernetes/docs/api-reference/authentication.k8s.io/
	==> app-03: kubernetes/docs/api-reference/authentication.k8s.io/v1beta1/
	==> app-03: kubernetes/docs/api-reference/authentication.k8s.io/v1beta1/operations.html
	==> app-03: kubernetes/docs/api-reference/authentication.k8s.io/v1beta1/definitions.html
	==> app-03: kubernetes/docs/api-reference/apps/
	==> app-03: kubernetes/docs/api-reference/apps/v1alpha1/
	==> app-03: kubernetes/docs/api-reference/apps/v1alpha1/operations.html
	==> app-03: kubernetes/docs/api-reference/apps/v1alpha1/definitions.html
	==> app-03: kubernetes/docs/api-reference/extensions/
	==> app-03: kubernetes/docs/api-reference/extensions/v1beta1/
	==> app-03: kubernetes/docs/api-reference/extensions/v1beta1/operations.html
	==> app-03: kubernetes/docs/api-reference/extensions/v1beta1/definitions.md
	==> app-03: kubernetes/docs/api-reference/extensions/v1beta1/operations.md
	==> app-03: kubernetes/docs/api-reference/extensions/v1beta1/definitions.html
	==> app-03: kubernetes/docs/api-reference/batch/
	==> app-03: kubernetes/docs/api-reference/batch/v1/
	==> app-03: kubernetes/docs/api-reference/batch/v1/operations.html
	==> app-03: kubernetes/docs/api-reference/batch/v1/definitions.html
	==> app-03: kubernetes/docs/api-reference/batch/v2alpha1/
	==> app-03: kubernetes/docs/api-reference/batch/v2alpha1/operations.html
	==> app-03: kubernetes/docs/api-reference/batch/v2alpha1/definitions.html
	==> app-03: kubernetes/docs/api-reference/storage.k8s.io/
	==> app-03: kubernetes/docs/api-reference/storage.k8s.io/v1beta1/
	==> app-03: kubernetes/docs/api-reference/storage.k8s.io/v1beta1/operations.html
	==> app-03: kubernetes/docs/api-reference/storage.k8s.io/v1beta1/definitions.html
	==> app-03: kubernetes/docs/getting-started-guides/
	==> app-03: kubernetes/docs/getting-started-guides/mesos.md
	==> app-03: kubernetes/docs/getting-started-guides/scratch.md
	==> app-03: kubernetes/docs/getting-started-guides/dcos.md
	==> app-03: kubernetes/docs/getting-started-guides/libvirt-coreos.md
	==> app-03: kubernetes/docs/getting-started-guides/README.md
	==> app-03: kubernetes/docs/getting-started-guides/azure.md
	==> app-03: kubernetes/docs/getting-started-guides/ubuntu-calico.md
	==> app-03: kubernetes/docs/getting-started-guides/aws.md
	==> app-03: kubernetes/docs/getting-started-guides/gce.md
	==> app-03: kubernetes/docs/getting-started-guides/coreos/
	==> app-03: kubernetes/docs/getting-started-guides/coreos/coreos_multinode_cluster.md
	==> app-03: kubernetes/docs/getting-started-guides/coreos/bare_metal_offline.md
	==> app-03: kubernetes/docs/getting-started-guides/coreos/bare_metal_calico.md
	==> app-03: kubernetes/docs/getting-started-guides/coreos/azure/
	==> app-03: kubernetes/docs/getting-started-guides/coreos/azure/README.md
	==> app-03: kubernetes/docs/getting-started-guides/centos/
	==> app-03: kubernetes/docs/getting-started-guides/centos/centos_manual_config.md
	==> app-03: kubernetes/docs/getting-started-guides/docker.md
	==> app-03: kubernetes/docs/getting-started-guides/docker-multinode.md
	==> app-03: kubernetes/docs/getting-started-guides/coreos.md
	==> app-03: kubernetes/docs/getting-started-guides/ovirt.md
	==> app-03: kubernetes/docs/getting-started-guides/juju.md
	==> app-03: kubernetes/docs/getting-started-guides/rackspace.md
	==> app-03: kubernetes/docs/getting-started-guides/rkt/
	==> app-03: kubernetes/docs/getting-started-guides/rkt/README.md
	==> app-03: kubernetes/docs/getting-started-guides/rkt/notes.md
	==> app-03: kubernetes/docs/getting-started-guides/ubuntu.md
	==> app-03: kubernetes/docs/getting-started-guides/cloudstack.md
	==> app-03: kubernetes/docs/getting-started-guides/mesos-docker.md
	==> app-03: kubernetes/docs/getting-started-guides/vsphere.md
	==> app-03: kubernetes/docs/getting-started-guides/logging.md
	==> app-03: kubernetes/docs/getting-started-guides/logging-elasticsearch.md
	==> app-03: kubernetes/docs/getting-started-guides/binary_release.md
	==> app-03: kubernetes/docs/getting-started-guides/fedora/
	==> app-03: kubernetes/docs/getting-started-guides/fedora/fedora_ansible_config.md
	==> app-03: kubernetes/docs/getting-started-guides/fedora/fedora_manual_config.md
	==> app-03: kubernetes/docs/getting-started-guides/fedora/flannel_multi_node_cluster.md
	==> app-03: kubernetes/docs/README.md
	==> app-03: kubernetes/docs/design/
	==> app-03: kubernetes/docs/design/admission_control_resource_quota.md
	==> app-03: kubernetes/docs/design/ubernetes-design.png
	==> app-03: kubernetes/docs/design/ubernetes-cluster-state.png
	==> app-03: kubernetes/docs/design/expansion.md
	==> app-03: kubernetes/docs/design/namespaces.md
	==> app-03: kubernetes/docs/design/clustering.md
	==> app-03: kubernetes/docs/design/resource-qos.md
	==> app-03: kubernetes/docs/design/taint-toleration-dedicated.md
	==> app-03: kubernetes/docs/design/indexed-job.md
	==> app-03: kubernetes/docs/design/principles.md
	==> app-03: kubernetes/docs/design/README.md
	==> app-03: kubernetes/docs/design/enhance-pluggable-policy.md
	==> app-03: kubernetes/docs/design/identifiers.md
	==> app-03: kubernetes/docs/design/admission_control_limit_range.md
	==> app-03: kubernetes/docs/design/security.md
	==> app-03: kubernetes/docs/design/simple-rolling-update.md
	==> app-03: kubernetes/docs/design/podaffinity.md
	==> app-03: kubernetes/docs/design/federation-phase-1.md
	==> app-03: kubernetes/docs/design/architecture.dia
	==> app-03: kubernetes/docs/design/versioning.md
	==> app-03: kubernetes/docs/design/resources.md
	==> app-03: kubernetes/docs/design/persistent-storage.md
	==> app-03: kubernetes/docs/design/event_compression.md
	==> app-03: kubernetes/docs/design/ubernetes-scheduling.png
	==> app-03: kubernetes/docs/design/volume-snapshotting.png
	==> app-03: kubernetes/docs/design/daemon.md
	==> app-03: kubernetes/docs/design/extending-api.md
	==> app-03: kubernetes/docs/design/architecture.md
	==> app-03: kubernetes/docs/design/secrets.md
	==> app-03: kubernetes/docs/design/command_execution_port_forwarding.md
	==> app-03: kubernetes/docs/design/networking.md
	==> app-03: kubernetes/docs/design/nodeaffinity.md
	==> app-03: kubernetes/docs/design/downward_api_resources_limits_requests.md
	==> app-03: kubernetes/docs/design/selector-generation.md
	==> app-03: kubernetes/docs/design/horizontal-pod-autoscaler.md
	==> app-03: kubernetes/docs/design/seccomp.md
	==> app-03: kubernetes/docs/design/clustering/
	==> app-03: kubernetes/docs/design/clustering/dynamic.png
	==> app-03: kubernetes/docs/design/clustering/README.md
	==> app-03: kubernetes/docs/design/clustering/dynamic.seqdiag
	==> app-03: kubernetes/docs/design/clustering/Dockerfile
	==> app-03: kubernetes/docs/design/clustering/.gitignore
	==> app-03: kubernetes/docs/design/clustering/static.seqdiag
	==> app-03: kubernetes/docs/design/clustering/static.png
	==> app-03: kubernetes/docs/design/clustering/Makefile
	==> app-03: kubernetes/docs/design/architecture.svg
	==> app-03: kubernetes/docs/design/control-plane-resilience.md
	==> app-03: kubernetes/docs/design/security_context.md
	==> app-03: kubernetes/docs/design/scheduler_extender.md
	==> app-03: kubernetes/docs/design/volume-snapshotting.md
	==> app-03: kubernetes/docs/design/metadata-policy.md
	==> app-03: kubernetes/docs/design/architecture.png
	==> app-03: kubernetes/docs/design/aws_under_the_hood.md
	==> app-03: kubernetes/docs/design/admission_control.md
	==> app-03: kubernetes/docs/design/federated-services.md
	==> app-03: kubernetes/docs/design/service_accounts.md
	==> app-03: kubernetes/docs/design/access.md
	==> app-03: kubernetes/docs/design/selinux.md
	==> app-03: kubernetes/docs/design/configmap.md
	==> app-03: kubernetes/docs/OWNERS
	==> app-03: kubernetes/docs/proposals/
	==> app-03: kubernetes/docs/proposals/kubectl-login.md
	==> app-03: kubernetes/docs/proposals/resource-quota-scoping.md
	==> app-03: kubernetes/docs/proposals/kubelet-systemd.md
	==> app-03: kubernetes/docs/proposals/protobuf.md
	==> app-03: kubernetes/docs/proposals/gpu-support.md
	==> app-03: kubernetes/docs/proposals/kubelet-hypercontainer-runtime.md
	==> app-03: kubernetes/docs/proposals/templates.md
	==> app-03: kubernetes/docs/proposals/multiple-schedulers.md
	==> app-03: kubernetes/docs/proposals/garbage-collection.md
	==> app-03: kubernetes/docs/proposals/runtimeconfig.md
	==> app-03: kubernetes/docs/proposals/controller-ref.md
	==> app-03: kubernetes/docs/proposals/pod-resource-management.md
	==> app-03: kubernetes/docs/proposals/pod-security-context.md
	==> app-03: kubernetes/docs/proposals/high-availability.md
	==> app-03: kubernetes/docs/proposals/volumes.md
	==> app-03: kubernetes/docs/proposals/local-cluster-ux.md
	==> app-03: kubernetes/docs/proposals/volume-selectors.md
	==> app-03: kubernetes/docs/proposals/rescheduling.md
	==> app-03: kubernetes/docs/proposals/scalability-testing.md
	==> app-03: kubernetes/docs/proposals/client-package-structure.md
	==> app-03: kubernetes/docs/proposals/apiserver-watch.md
	==> app-03: kubernetes/docs/proposals/custom-metrics.md
	==> app-03: kubernetes/docs/proposals/runtime-client-server.md
	==> app-03: kubernetes/docs/proposals/federated-api-servers.md
	==> app-03: kubernetes/docs/proposals/release-notes.md
	==> app-03: kubernetes/docs/proposals/service-discovery.md
	==> app-03: kubernetes/docs/proposals/external-lb-source-ip-preservation.md
	==> app-03: kubernetes/docs/proposals/job.md
	==> app-03: kubernetes/docs/proposals/federation-lite.md
	==> app-03: kubernetes/docs/proposals/volume-provisioning.md
	==> app-03: kubernetes/docs/proposals/deployment.md
	==> app-03: kubernetes/docs/proposals/pod-lifecycle-event-generator.md
	==> app-03: kubernetes/docs/proposals/resource-metrics-api.md
	==> app-03: kubernetes/docs/proposals/image-provenance.md
	==> app-03: kubernetes/docs/proposals/kubelet-eviction.md
	==> app-03: kubernetes/docs/proposals/node-allocatable.md
	==> app-03: kubernetes/docs/proposals/secret-configmap-downwarapi-file-mode.md
	==> app-03: kubernetes/docs/proposals/disk-accounting.md
	==> app-03: kubernetes/docs/proposals/rescheduler.md
	==> app-03: kubernetes/docs/proposals/rescheduling-for-critical-pods.md
	==> app-03: kubernetes/docs/proposals/metrics-plumbing.md
	==> app-03: kubernetes/docs/proposals/selinux-enhancements.md
	==> app-03: kubernetes/docs/proposals/initial-resources.md
	==> app-03: kubernetes/docs/proposals/container-runtime-interface-v1.md
	==> app-03: kubernetes/docs/proposals/security-context-constraints.md
	==> app-03: kubernetes/docs/proposals/node-allocatable.png
	==> app-03: kubernetes/docs/proposals/scheduledjob.md
	==> app-03: kubernetes/docs/proposals/performance-related-monitoring.md
	==> app-03: kubernetes/docs/proposals/pod-cache.png
	==> app-03: kubernetes/docs/proposals/network-policy.md
	==> app-03: kubernetes/docs/proposals/multi-platform.md
	==> app-03: kubernetes/docs/proposals/runtime-pod-cache.md
	==> app-03: kubernetes/docs/proposals/kubemark.md
	==> app-03: kubernetes/docs/proposals/flannel-integration.md
	==> app-03: kubernetes/docs/proposals/kubelet-auth.md
	==> app-03: kubernetes/docs/proposals/api-group.md
	==> app-03: kubernetes/docs/proposals/federation-high-level-arch.png
	==> app-03: kubernetes/docs/proposals/dramatically-simplify-cluster-creation.md
	==> app-03: kubernetes/docs/proposals/images/
	==> app-03: kubernetes/docs/proposals/images/.gitignore
	==> app-03: kubernetes/docs/proposals/cluster-deployment.md
	==> app-03: kubernetes/docs/proposals/apparmor.md
	==> app-03: kubernetes/docs/proposals/pleg.png
	==> app-03: kubernetes/docs/proposals/federation.md
	==> app-03: kubernetes/docs/proposals/kubelet-tls-bootstrap.md
	==> app-03: kubernetes/docs/proposals/Kubemark_architecture.png
	==> app-03: kubernetes/docs/proposals/container-init.md
	==> app-03: kubernetes/docs/proposals/service-external-name.md
	==> app-03: kubernetes/docs/proposals/deploy.md
	==> app-03: kubernetes/docs/proposals/volume-ownership-management.md
	==> app-03: kubernetes/docs/proposals/self-hosted-kubelet.md
	==> app-03: kubernetes/docs/user-guide/
	==> app-03: kubernetes/docs/user-guide/security-context.md
	==> app-03: kubernetes/docs/user-guide/namespaces.md
	==> app-03: kubernetes/docs/user-guide/debugging-services.md
	==> app-03: kubernetes/docs/user-guide/connecting-to-applications-port-forward.md
	==> app-03: kubernetes/docs/user-guide/ingress.md
	==> app-03: kubernetes/docs/user-guide/README.md
	==> app-03: kubernetes/docs/user-guide/accessing-the-cluster.md
	==> app-03: kubernetes/docs/user-guide/horizontal-pod-autoscaling/
	==> app-03: kubernetes/docs/user-guide/horizontal-pod-autoscaling/README.md
	==> app-03: kubernetes/docs/user-guide/identifiers.md
	==> app-03: kubernetes/docs/user-guide/simple-nginx.md
	==> app-03: kubernetes/docs/user-guide/images.md
	==> app-03: kubernetes/docs/user-guide/kubectl-overview.md
	==> app-03: kubernetes/docs/user-guide/volumes.md
	==> app-03: kubernetes/docs/user-guide/deployments.md
	==> app-03: kubernetes/docs/user-guide/persistent-volumes.md
	==> app-03: kubernetes/docs/user-guide/deploying-applications.md
	==> app-03: kubernetes/docs/user-guide/jobs.md
	==> app-03: kubernetes/docs/user-guide/node-selection/
	==> app-03: kubernetes/docs/user-guide/node-selection/README.md
	==> app-03: kubernetes/docs/user-guide/downward-api/
	==> app-03: kubernetes/docs/user-guide/downward-api/README.md
	==> app-03: kubernetes/docs/user-guide/downward-api/volume/
	==> app-03: kubernetes/docs/user-guide/downward-api/volume/README.md
	==> app-03: kubernetes/docs/user-guide/application-troubleshooting.md
	==> app-03: kubernetes/docs/user-guide/getting-into-containers.md
	==> app-03: kubernetes/docs/user-guide/config-best-practices.md
	==> app-03: kubernetes/docs/user-guide/kubeconfig-file.md
	==> app-03: kubernetes/docs/user-guide/containers.md
	==> app-03: kubernetes/docs/user-guide/introspection-and-debugging.md
	==> app-03: kubernetes/docs/user-guide/update-demo/
	==> app-03: kubernetes/docs/user-guide/update-demo/README.md
	==> app-03: kubernetes/docs/user-guide/resourcequota/
	==> app-03: kubernetes/docs/user-guide/resourcequota/README.md
	==> app-03: kubernetes/docs/user-guide/configmap/
	==> app-03: kubernetes/docs/user-guide/configmap/README.md
	==> app-03: kubernetes/docs/user-guide/compute-resources.md
	==> app-03: kubernetes/docs/user-guide/ui.md
	==> app-03: kubernetes/docs/user-guide/labels.md
	==> app-03: kubernetes/docs/user-guide/environment-guide/
	==> app-03: kubernetes/docs/user-guide/environment-guide/README.md
	==> app-03: kubernetes/docs/user-guide/environment-guide/containers/
	==> app-03: kubernetes/docs/user-guide/environment-guide/containers/README.md
	==> app-03: kubernetes/docs/user-guide/container-environment.md
	==> app-03: kubernetes/docs/user-guide/production-pods.md
	==> app-03: kubernetes/docs/user-guide/liveness/
	==> app-03: kubernetes/docs/user-guide/liveness/README.md
	==> app-03: kubernetes/docs/user-guide/downward-api.md
	==> app-03: kubernetes/docs/user-guide/services-firewalls.md
	==> app-03: kubernetes/docs/user-guide/sharing-clusters.md
	==> app-03: kubernetes/docs/user-guide/docker-cli-to-kubectl.md
	==> app-03: kubernetes/docs/user-guide/configuring-containers.md
	==> app-03: kubernetes/docs/user-guide/working-with-resources.md
	==> app-03: kubernetes/docs/user-guide/simple-yaml.md
	==> app-03: kubernetes/docs/user-guide/logging-demo/
	==> app-03: kubernetes/docs/user-guide/logging-demo/README.md
	==> app-03: kubernetes/docs/user-guide/connecting-applications.md
	==> app-03: kubernetes/docs/user-guide/jsonpath.md
	==> app-03: kubernetes/docs/user-guide/secrets.md
	==> app-03: kubernetes/docs/user-guide/connecting-to-applications-proxy.md
	==> app-03: kubernetes/docs/user-guide/pods.md
	==> app-03: kubernetes/docs/user-guide/persistent-volumes/
	==> app-03: kubernetes/docs/user-guide/persistent-volumes/README.md
	==> app-03: kubernetes/docs/user-guide/kubectl-cheatsheet.md
	==> app-03: kubernetes/docs/user-guide/replication-controller.md
	==> app-03: kubernetes/docs/user-guide/services.md
	==> app-03: kubernetes/docs/user-guide/managing-deployments.md
	==> app-03: kubernetes/docs/user-guide/horizontal-pod-autoscaler.md
	==> app-03: kubernetes/docs/user-guide/secrets/
	==> app-03: kubernetes/docs/user-guide/secrets/README.md
	==> app-03: kubernetes/docs/user-guide/walkthrough/
	==> app-03: kubernetes/docs/user-guide/walkthrough/README.md
	==> app-03: kubernetes/docs/user-guide/walkthrough/k8s201.md
	==> app-03: kubernetes/docs/user-guide/monitoring.md
	==> app-03: kubernetes/docs/user-guide/logging.md
	==> app-03: kubernetes/docs/user-guide/overview.md
	==> app-03: kubernetes/docs/user-guide/pod-states.md
	==> app-03: kubernetes/docs/user-guide/annotations.md
	==> app-03: kubernetes/docs/user-guide/prereqs.md
	==> app-03: kubernetes/docs/user-guide/kubectl/
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_create_quota.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_version.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_rolling-update.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_exec.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_create_service_nodeport.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_rollout_pause.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_top_pod.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_get.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_config_set-cluster.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_config_unset.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_create_namespace.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_replace.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_create_serviceaccount.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_create_deployment.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_create_secret_docker-registry.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_create_service.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_logs.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_expose.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_config_delete-cluster.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_cordon.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_create_secret_tls.md
	==> app-03: kubernetes/docs/user-guide/kubectl/.files_generated
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_taint.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_rollout_resume.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_delete.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_top-node.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_explain.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_cluster-info_dump.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_rollout_history.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_edit.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_apply.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_run.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_rollout_status.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_annotate.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_set.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_set_image.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_top-pod.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_create_secret.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_config_get-contexts.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_create_configmap.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_create_secret_generic.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_rollout.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_config_set-credentials.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_config_view.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_port-forward.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_config_set-context.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_drain.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_rollout_undo.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_top.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_create_service_clusterip.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_describe.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_attach.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_label.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_cluster-info.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_options.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_config.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_completion.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_create_service_loadbalancer.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_top_node.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_config_get-clusters.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_convert.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_autoscale.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_scale.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_api-versions.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_config_delete-context.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_stop.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_create.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_config_current-context.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_uncordon.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_patch.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_config_use-context.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_config_set.md
	==> app-03: kubernetes/docs/user-guide/kubectl/kubectl_proxy.md
	==> app-03: kubernetes/docs/user-guide/quick-start.md
	==> app-03: kubernetes/docs/user-guide/known-issues.md
	==> app-03: kubernetes/docs/user-guide/pod-templates.md
	==> app-03: kubernetes/docs/user-guide/service-accounts.md
	==> app-03: kubernetes/docs/user-guide/configmap.md
	==> app-03: kubernetes/docs/warning.png
	==> app-03: kubernetes/docs/admin/
	==> app-03: kubernetes/docs/admin/network-plugins.md
	==> app-03: kubernetes/docs/admin/limitrange/
	==> app-03: kubernetes/docs/admin/limitrange/README.md
	==> app-03: kubernetes/docs/admin/dns.md
	==> app-03: kubernetes/docs/admin/federation-controller-manager.md
	==> app-03: kubernetes/docs/admin/kube-scheduler.md
	==> app-03: kubernetes/docs/admin/namespaces.md
	==> app-03: kubernetes/docs/admin/garbage-collection.md
	==> app-03: kubernetes/docs/admin/README.md
	==> app-03: kubernetes/docs/admin/introduction.md
	==> app-03: kubernetes/docs/admin/high-availability.md
	==> app-03: kubernetes/docs/admin/daemons.md
	==> app-03: kubernetes/docs/admin/master-node-communication.md
	==> app-03: kubernetes/docs/admin/kubelet.md
	==> app-03: kubernetes/docs/admin/federation-apiserver.md
	==> app-03: kubernetes/docs/admin/ovs-networking.md
	==> app-03: kubernetes/docs/admin/resourcequota/
	==> app-03: kubernetes/docs/admin/resourcequota/README.md
	==> app-03: kubernetes/docs/admin/cluster-management.md
	==> app-03: kubernetes/docs/admin/etcd.md
	==> app-03: kubernetes/docs/admin/accessing-the-api.md
	==> app-03: kubernetes/docs/admin/salt.md
	==> app-03: kubernetes/docs/admin/authentication.md
	==> app-03: kubernetes/docs/admin/cluster-troubleshooting.md
	==> app-03: kubernetes/docs/admin/static-pods.md
	==> app-03: kubernetes/docs/admin/service-accounts-admin.md
	==> app-03: kubernetes/docs/admin/cluster-components.md
	==> app-03: kubernetes/docs/admin/multi-cluster.md
	==> app-03: kubernetes/docs/admin/cluster-large.md
	==> app-03: kubernetes/docs/admin/admission-controllers.md
	==> app-03: kubernetes/docs/admin/networking.md
	==> app-03: kubernetes/docs/admin/kube-proxy.md
	==> app-03: kubernetes/docs/admin/kube-controller-manager.md
	==> app-03: kubernetes/docs/admin/namespaces/
	==> app-03: kubernetes/docs/admin/namespaces/README.md
	==> app-03: kubernetes/docs/admin/kube-apiserver.md
	==> app-03: kubernetes/docs/admin/node.md
	==> app-03: kubernetes/docs/admin/authorization.md
	==> app-03: kubernetes/docs/admin/resource-quota.md
	==> app-03: kubernetes/docs/reporting-security-issues.md
	==> app-03: kubernetes/docs/whatisk8s.md
	==> app-03: kubernetes/docs/devel/
	==> app-03: kubernetes/docs/devel/development.md
	==> app-03: kubernetes/docs/devel/instrumentation.md
	==> app-03: kubernetes/docs/devel/pr_workflow.png
	==> app-03: kubernetes/docs/devel/local-cluster/
	==> app-03: kubernetes/docs/devel/local-cluster/vagrant.md
	==> app-03: kubernetes/docs/devel/local-cluster/local.md
	==> app-03: kubernetes/docs/devel/local-cluster/docker.md
	==> app-03: kubernetes/docs/devel/local-cluster/k8s-singlenode-docker.png
	==> app-03: kubernetes/docs/devel/coding-conventions.md
	==> app-03: kubernetes/docs/devel/flaky-tests.md
	==> app-03: kubernetes/docs/devel/README.md
	==> app-03: kubernetes/docs/devel/running-locally.md
	==> app-03: kubernetes/docs/devel/testing.md
	==> app-03: kubernetes/docs/devel/owners.md
	==> app-03: kubernetes/docs/devel/writing-good-e2e-tests.md
	==> app-03: kubernetes/docs/devel/community-expectations.md
	==> app-03: kubernetes/docs/devel/adding-an-APIGroup.md
	==> app-03: kubernetes/docs/devel/gubernator-images/
	==> app-03: kubernetes/docs/devel/gubernator-images/testfailures.png
	==> app-03: kubernetes/docs/devel/gubernator-images/filterpage.png
	==> app-03: kubernetes/docs/devel/gubernator-images/skipping2.png
	==> app-03: kubernetes/docs/devel/gubernator-images/filterpage3.png
	==> app-03: kubernetes/docs/devel/gubernator-images/filterpage2.png
	==> app-03: kubernetes/docs/devel/gubernator-images/filterpage1.png
	==> app-03: kubernetes/docs/devel/gubernator-images/skipping1.png
	==> app-03: kubernetes/docs/devel/e2e-node-tests.md
	==> app-03: kubernetes/docs/devel/on-call-rotations.md
	==> app-03: kubernetes/docs/devel/profiling.md
	==> app-03: kubernetes/docs/devel/issues.md
	==> app-03: kubernetes/docs/devel/client-libraries.md
	==> app-03: kubernetes/docs/devel/on-call-user-support.md
	==> app-03: kubernetes/docs/devel/node-performance-testing.md
	==> app-03: kubernetes/docs/devel/automation.md
	==> app-03: kubernetes/docs/devel/developer-guides/
	==> app-03: kubernetes/docs/devel/developer-guides/vagrant.md
	==> app-03: kubernetes/docs/devel/go-code.md
	==> app-03: kubernetes/docs/devel/kubectl-conventions.md
	==> app-03: kubernetes/docs/devel/godep.md
	==> app-03: kubernetes/docs/devel/api-conventions.md
	==> app-03: kubernetes/docs/devel/getting-builds.md
	==> app-03: kubernetes/docs/devel/mesos-style.md
	==> app-03: kubernetes/docs/devel/collab.md
	==> app-03: kubernetes/docs/devel/kubemark-guide.md
	==> app-03: kubernetes/docs/devel/cherry-picks.md
	==> app-03: kubernetes/docs/devel/gubernator.md
	==> app-03: kubernetes/docs/devel/pr_workflow.dia
	==> app-03: kubernetes/docs/devel/faster_reviews.md
	==> app-03: kubernetes/docs/devel/update-release-docs.md
	==> app-03: kubernetes/docs/devel/e2e-tests.md
	==> app-03: kubernetes/docs/devel/api_changes.md
	==> app-03: kubernetes/docs/devel/cli-roadmap.md
	==> app-03: kubernetes/docs/devel/generating-clientset.md
	==> app-03: kubernetes/docs/devel/pull-requests.md
	==> app-03: kubernetes/docs/devel/logging.md
	==> app-03: kubernetes/docs/devel/git_workflow.png
	==> app-03: kubernetes/docs/devel/writing-a-getting-started-guide.md
	==> app-03: kubernetes/docs/devel/scheduler_algorithm.md
	==> app-03: kubernetes/docs/devel/updating-docs-for-feature-changes.md
	==> app-03: kubernetes/docs/devel/on-call-build-cop.md
	==> app-03: kubernetes/docs/devel/scheduler.md
	==> app-03: kubernetes/docs/devel/how-to-doc.md
	==> app-03: kubernetes/docs/images/
	==> app-03: kubernetes/docs/images/newgui.png
	==> app-03: kubernetes/docs/yaml/
	==> app-03: kubernetes/docs/yaml/kubectl/
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_completion.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_scale.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_top-node.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_api-versions.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_taint.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_version.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_apply.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_exec.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_delete.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_autoscale.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_port-forward.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_edit.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_options.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_create.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_top-pod.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_cordon.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_stop.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_attach.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_expose.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_proxy.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_config.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_annotate.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_drain.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_explain.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_describe.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_cluster-info.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_patch.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_logs.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_rolling-update.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_convert.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_run.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_label.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_replace.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_rollout.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_top.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_uncordon.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_set.yaml
	==> app-03: kubernetes/docs/yaml/kubectl/kubectl_get.yaml
	==> app-03: kubernetes/docs/roadmap.md
	==> app-03: kubernetes/docs/man/
	==> app-03: kubernetes/docs/man/man1/
	==> app-03: kubernetes/docs/man/man1/kubectl.1
	==> app-03: kubernetes/docs/man/man1/kubectl-config-view.1
	==> app-03: kubernetes/docs/man/man1/kube-scheduler.1
	==> app-03: kubernetes/docs/man/man1/kubectl-expose.1
	==> app-03: kubernetes/docs/man/man1/kubectl-create-service-nodeport.1
	==> app-03: kubernetes/docs/man/man1/kubectl-edit.1
	==> app-03: kubernetes/docs/man/man1/kubectl-config-get-contexts.1
	==> app-03: kubernetes/docs/man/man1/kubectl-autoscale.1
	==> app-03: kubernetes/docs/man/man1/kubectl-get.1
	==> app-03: kubernetes/docs/man/man1/kubectl-create-service.1
	==> app-03: kubernetes/docs/man/man1/kubectl-create-configmap.1
	==> app-03: kubernetes/docs/man/man1/kubectl-describe.1
	==> app-03: kubernetes/docs/man/man1/kubectl-config.1
	==> app-03: kubernetes/docs/man/man1/kubectl-proxy.1
	==> app-03: kubernetes/docs/man/man1/kube-controller-manager.1
	==> app-03: kubernetes/docs/man/man1/kubectl-config-current-context.1
	==> app-03: kubernetes/docs/man/man1/kubectl-create-service-clusterip.1
	==> app-03: kubernetes/docs/man/man1/kubectl-create-serviceaccount.1
	==> app-03: kubernetes/docs/man/man1/kubectl-uncordon.1
	==> app-03: kubernetes/docs/man/man1/kubectl-rollout-history.1
	==> app-03: kubernetes/docs/man/man1/kubectl-config-set-credentials.1
	==> app-03: kubernetes/docs/man/man1/.files_generated
	==> app-03: kubernetes/docs/man/man1/kubectl-config-set-context.1
	==> app-03: kubernetes/docs/man/man1/kubectl-patch.1
	==> app-03: kubernetes/docs/man/man1/kubectl-create.1
	==> app-03: kubernetes/docs/man/man1/kubectl-exec.1
	==> app-03: kubernetes/docs/man/man1/kubectl-config-use-context.1
	==> app-03: kubernetes/docs/man/man1/kubelet.1
	==> app-03: kubernetes/docs/man/man1/kubectl-label.1
	==> app-03: kubernetes/docs/man/man1/kubectl-scale.1
	==> app-03: kubernetes/docs/man/man1/kubectl-delete.1
	==> app-03: kubernetes/docs/man/man1/kubectl-cluster-info.1
	==> app-03: kubernetes/docs/man/man1/kubectl-options.1
	==> app-03: kubernetes/docs/man/man1/kubectl-set-image.1
	==> app-03: kubernetes/docs/man/man1/kubectl-replace.1
	==> app-03: kubernetes/docs/man/man1/kubectl-create-service-loadbalancer.1
	==> app-03: kubernetes/docs/man/man1/kubectl-rollout-pause.1
	==> app-03: kubernetes/docs/man/man1/kubectl-config-get-clusters.1
	==> app-03: kubernetes/docs/man/man1/kubectl-taint.1
	==> app-03: kubernetes/docs/man/man1/kubectl-config-delete-cluster.1
	==> app-03: kubernetes/docs/man/man1/kubectl-create-secret-generic.1
	==> app-03: kubernetes/docs/man/man1/kubectl-config-set.1
	==> app-03: kubernetes/docs/man/man1/kubectl-version.1
	==> app-03: kubernetes/docs/man/man1/kubectl-explain.1
	==> app-03: kubernetes/docs/man/man1/kubectl-create-secret-docker-registry.1
	==> app-03: kubernetes/docs/man/man1/kubectl-apply.1
	==> app-03: kubernetes/docs/man/man1/kube-proxy.1
	==> app-03: kubernetes/docs/man/man1/kubectl-create-secret-tls.1
	==> app-03: kubernetes/docs/man/man1/kubectl-cluster-info-dump.1
	==> app-03: kubernetes/docs/man/man1/kubectl-api-versions.1
	==> app-03: kubernetes/docs/man/man1/kubectl-stop.1
	==> app-03: kubernetes/docs/man/man1/kubectl-config-unset.1
	==> app-03: kubernetes/docs/man/man1/kubectl-rollout-resume.1
	==> app-03: kubernetes/docs/man/man1/kube-apiserver.1
	==> app-03: kubernetes/docs/man/man1/kubectl-rollout.1
	==> app-03: kubernetes/docs/man/man1/kubectl-rolling-update.1
	==> app-03: kubernetes/docs/man/man1/kubectl-attach.1
	==> app-03: kubernetes/docs/man/man1/kubectl-rollout-status.1
	==> app-03: kubernetes/docs/man/man1/kubectl-cordon.1
	==> app-03: kubernetes/docs/man/man1/kubectl-config-delete-context.1
	==> app-03: kubernetes/docs/man/man1/kubectl-rollout-undo.1
	==> app-03: kubernetes/docs/man/man1/kubectl-create-quota.1
	==> app-03: kubernetes/docs/man/man1/kubectl-run.1
	==> app-03: kubernetes/docs/man/man1/kubectl-annotate.1
	==> app-03: kubernetes/docs/man/man1/kubectl-convert.1
	==> app-03: kubernetes/docs/man/man1/kubectl-top.1
	==> app-03: kubernetes/docs/man/man1/kubectl-logs.1
	==> app-03: kubernetes/docs/man/man1/kubectl-create-namespace.1
	==> app-03: kubernetes/docs/man/man1/kubectl-create-secret.1
	==> app-03: kubernetes/docs/man/man1/kubectl-create-deployment.1
	==> app-03: kubernetes/docs/man/man1/kubectl-set.1
	==> app-03: kubernetes/docs/man/man1/kubectl-completion.1
	==> app-03: kubernetes/docs/man/man1/kubectl-config-set-cluster.1
	==> app-03: kubernetes/docs/man/man1/kubectl-port-forward.1
	==> app-03: kubernetes/docs/man/man1/kubectl-drain.1
	==> app-03: kubernetes/docs/man/man1/kubectl-top-pod.1
	==> app-03: kubernetes/docs/man/man1/kubectl-top-node.1
	==> app-03: kubernetes/docs/api.md
	==> app-03: kubernetes/docs/troubleshooting.md
	==> app-03: kubernetes/cluster/
	==> app-03: kubernetes/cluster/aws/
	==> app-03: kubernetes/cluster/aws/templates/
	==> app-03: kubernetes/cluster/aws/templates/iam/
	==> app-03: kubernetes/cluster/aws/templates/iam/kubernetes-minion-policy.json
	==> app-03: kubernetes/cluster/aws/templates/iam/kubernetes-master-role.json
	==> app-03: kubernetes/cluster/aws/templates/iam/kubernetes-minion-role.json
	==> app-03: kubernetes/cluster/aws/templates/iam/kubernetes-master-policy.json
	==> app-03: kubernetes/cluster/aws/templates/configure-vm-aws.sh
	==> app-03: kubernetes/cluster/aws/templates/format-disks.sh
	==> app-03: kubernetes/cluster/aws/config-default.sh
	==> app-03: kubernetes/cluster/aws/wily/
	==> app-03: kubernetes/cluster/aws/wily/util.sh
	==> app-03: kubernetes/cluster/aws/util.sh
	==> app-03: kubernetes/cluster/aws/config-test.sh
	==> app-03: kubernetes/cluster/aws/common/
	==> app-03: kubernetes/cluster/aws/common/common.sh
	==> app-03: kubernetes/cluster/aws/options.md
	==> app-03: kubernetes/cluster/aws/jessie/
	==> app-03: kubernetes/cluster/aws/jessie/util.sh
	==> app-03: kubernetes/cluster/update-storage-objects.sh
	==> app-03: kubernetes/cluster/vsphere/
	==> app-03: kubernetes/cluster/vsphere/templates/
	==> app-03: kubernetes/cluster/vsphere/templates/salt-master.sh
	==> app-03: kubernetes/cluster/vsphere/templates/hostname.sh
	==> app-03: kubernetes/cluster/vsphere/templates/install-release.sh
	==> app-03: kubernetes/cluster/vsphere/templates/create-dynamic-salt-files.sh
	==> app-03: kubernetes/cluster/vsphere/templates/salt-minion.sh
	==> app-03: kubernetes/cluster/vsphere/config-common.sh
	==> app-03: kubernetes/cluster/vsphere/config-default.sh
	==> app-03: kubernetes/cluster/vsphere/util.sh
	==> app-03: kubernetes/cluster/vsphere/config-test.sh
	==> app-03: kubernetes/cluster/photon-controller/
	==> app-03: kubernetes/cluster/photon-controller/setup-prereq.sh
	==> app-03: kubernetes/cluster/photon-controller/templates/
	==> app-03: kubernetes/cluster/photon-controller/templates/salt-master.sh
	==> app-03: kubernetes/cluster/photon-controller/templates/hostname.sh
	==> app-03: kubernetes/cluster/photon-controller/templates/install-release.sh
	==> app-03: kubernetes/cluster/photon-controller/templates/README
	==> app-03: kubernetes/cluster/photon-controller/templates/create-dynamic-salt-files.sh
	==> app-03: kubernetes/cluster/photon-controller/templates/salt-minion.sh
	==> app-03: kubernetes/cluster/photon-controller/config-common.sh
	==> app-03: kubernetes/cluster/photon-controller/config-default.sh
	==> app-03: kubernetes/cluster/photon-controller/util.sh
	==> app-03: kubernetes/cluster/photon-controller/config-test.sh
	==> app-03: kubernetes/cluster/README.md
	==> app-03: kubernetes/cluster/gke/
	==> app-03: kubernetes/cluster/gke/config-common.sh
	==> app-03: kubernetes/cluster/gke/config-default.sh
	==> app-03: kubernetes/cluster/gke/make-it-stop.sh
	==> app-03: kubernetes/cluster/gke/util.sh
	==> app-03: kubernetes/cluster/gke/config-test.sh
	==> app-03: kubernetes/cluster/validate-cluster.sh
	==> app-03: kubernetes/cluster/get-kube-local.sh
	==> app-03: kubernetes/cluster/kubemark/
	==> app-03: kubernetes/cluster/kubemark/config-default.sh
	==> app-03: kubernetes/cluster/kubemark/util.sh
	==> app-03: kubernetes/cluster/OWNERS
	==> app-03: kubernetes/cluster/log-dump.sh
	==> app-03: kubernetes/cluster/test-network.sh
	==> app-03: kubernetes/cluster/openstack-heat/
	==> app-03: kubernetes/cluster/openstack-heat/config-default.sh
	==> app-03: kubernetes/cluster/openstack-heat/kubernetes-heat/
	==> app-03: kubernetes/cluster/openstack-heat/kubernetes-heat/kubeminion.yaml
	==> app-03: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/
	==> app-03: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/deploy-kube-auth-files-master.yaml
	==> app-03: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/provision-network-master.sh
	==> app-03: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/configure-proxy.sh
	==> app-03: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/write-heat-params.yaml
	==> app-03: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/configure-salt.yaml
	==> app-03: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/hostname-hack.sh
	==> app-03: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/kube-user.yaml
	==> app-03: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/provision-network-node.sh
	==> app-03: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/run-salt.sh
	==> app-03: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/hostname-hack.yaml
	==> app-03: kubernetes/cluster/openstack-heat/kubernetes-heat/fragments/deploy-kube-auth-files-node.yaml
	==> app-03: kubernetes/cluster/openstack-heat/kubernetes-heat/kubecluster.yaml
	==> app-03: kubernetes/cluster/openstack-heat/openrc-swift.sh
	==> app-03: kubernetes/cluster/openstack-heat/util.sh
	==> app-03: kubernetes/cluster/openstack-heat/config-test.sh
	==> app-03: kubernetes/cluster/openstack-heat/openrc-default.sh
	==> app-03: kubernetes/cluster/openstack-heat/config-image.sh
	==> app-03: kubernetes/cluster/kubectl.sh
	==> app-03: kubernetes/cluster/lib/
	==> app-03: kubernetes/cluster/lib/util.sh
	==> app-03: kubernetes/cluster/lib/logging.sh
	==> app-03: kubernetes/cluster/rackspace/
	==> app-03: kubernetes/cluster/rackspace/authorization.sh
	==> app-03: kubernetes/cluster/rackspace/cloud-config/
	==> app-03: kubernetes/cluster/rackspace/cloud-config/node-cloud-config.yaml
	==> app-03: kubernetes/cluster/rackspace/cloud-config/master-cloud-config.yaml
	==> app-03: kubernetes/cluster/rackspace/config-default.sh
	==> app-03: kubernetes/cluster/rackspace/util.sh
	==> app-03: kubernetes/cluster/rackspace/kube-up.sh
	==> app-03: kubernetes/cluster/centos/
	==> app-03: kubernetes/cluster/centos/config-build.sh
	==> app-03: kubernetes/cluster/centos/config-default.sh
	==> app-03: kubernetes/cluster/centos/master/
	==> app-03: kubernetes/cluster/centos/master/scripts/
	==> app-03: kubernetes/cluster/centos/master/scripts/scheduler.sh
	==> app-03: kubernetes/cluster/centos/master/scripts/controller-manager.sh
	==> app-03: kubernetes/cluster/centos/master/scripts/apiserver.sh
	==> app-03: kubernetes/cluster/centos/master/scripts/etcd.sh
	==> app-03: kubernetes/cluster/centos/build.sh
	==> app-03: kubernetes/cluster/centos/util.sh
	==> app-03: kubernetes/cluster/centos/node/
	==> app-03: kubernetes/cluster/centos/node/scripts/
	==> app-03: kubernetes/cluster/centos/node/scripts/flannel.sh
	==> app-03: kubernetes/cluster/centos/node/scripts/proxy.sh
	==> app-03: kubernetes/cluster/centos/node/scripts/kubelet.sh
	==> app-03: kubernetes/cluster/centos/node/scripts/docker.sh
	==> app-03: kubernetes/cluster/centos/node/bin/
	==> app-03: kubernetes/cluster/centos/node/bin/remove-docker0.sh
	==> app-03: kubernetes/cluster/centos/node/bin/mk-docker-opts.sh
	==> app-03: kubernetes/cluster/centos/config-test.sh
	==> app-03: kubernetes/cluster/centos/.gitignore
	==> app-03: kubernetes/cluster/libvirt-coreos/
	==> app-03: kubernetes/cluster/libvirt-coreos/README.md
	==> app-03: kubernetes/cluster/libvirt-coreos/config-default.sh
	==> app-03: kubernetes/cluster/libvirt-coreos/util.sh
	==> app-03: kubernetes/cluster/libvirt-coreos/user_data.yml
	==> app-03: kubernetes/cluster/libvirt-coreos/config-test.sh
	==> app-03: kubernetes/cluster/libvirt-coreos/namespace.yaml
	==> app-03: kubernetes/cluster/libvirt-coreos/.gitignore
	==> app-03: kubernetes/cluster/libvirt-coreos/network_kubernetes_pods.xml
	==> app-03: kubernetes/cluster/libvirt-coreos/forShellEval.sed
	==> app-03: kubernetes/cluster/libvirt-coreos/openssl.cnf
	==> app-03: kubernetes/cluster/libvirt-coreos/user_data_master.yml
	==> app-03: kubernetes/cluster/libvirt-coreos/node-openssl.cnf
	==> app-03: kubernetes/cluster/libvirt-coreos/coreos.xml
	==> app-03: kubernetes/cluster/libvirt-coreos/network_kubernetes_global.xml
	==> app-03: kubernetes/cluster/libvirt-coreos/user_data_minion.yml
	==> app-03: kubernetes/cluster/ubuntu/
	==> app-03: kubernetes/cluster/ubuntu/config-default.sh
	==> app-03: kubernetes/cluster/ubuntu/reconfDocker.sh
	==> app-03: kubernetes/cluster/ubuntu/master/
	==> app-03: kubernetes/cluster/ubuntu/master/init_scripts/
	==> app-03: kubernetes/cluster/ubuntu/master/init_scripts/etcd
	==> app-03: kubernetes/cluster/ubuntu/master/init_scripts/kube-scheduler
	==> app-03: kubernetes/cluster/ubuntu/master/init_scripts/kube-controller-manager
	==> app-03: kubernetes/cluster/ubuntu/master/init_scripts/kube-apiserver
	==> app-03: kubernetes/cluster/ubuntu/master/init_conf/
	==> app-03: kubernetes/cluster/ubuntu/master/init_conf/kube-scheduler.conf
	==> app-03: kubernetes/cluster/ubuntu/master/init_conf/kube-controller-manager.conf
	==> app-03: kubernetes/cluster/ubuntu/master/init_conf/kube-apiserver.conf
	==> app-03: kubernetes/cluster/ubuntu/master/init_conf/etcd.conf
	==> app-03: kubernetes/cluster/ubuntu/master-flannel/
	==> app-03: kubernetes/cluster/ubuntu/master-flannel/init_scripts/
	==> app-03: kubernetes/cluster/ubuntu/master-flannel/init_scripts/flanneld
	==> app-03: kubernetes/cluster/ubuntu/master-flannel/init_conf/
	==> app-03: kubernetes/cluster/ubuntu/master-flannel/init_conf/flanneld.conf
	==> app-03: kubernetes/cluster/ubuntu/util.sh
	==> app-03: kubernetes/cluster/ubuntu/config-test.sh
	==> app-03: kubernetes/cluster/ubuntu/namespace.yaml
	==> app-03: kubernetes/cluster/ubuntu/.gitignore
	==> app-03: kubernetes/cluster/ubuntu/minion/
	==> app-03: kubernetes/cluster/ubuntu/minion/init_scripts/
	==> app-03: kubernetes/cluster/ubuntu/minion/init_scripts/kubelet
	==> app-03: kubernetes/cluster/ubuntu/minion/init_scripts/kube-proxy
	==> app-03: kubernetes/cluster/ubuntu/minion/init_conf/
	==> app-03: kubernetes/cluster/ubuntu/minion/init_conf/kubelet.conf
	==> app-03: kubernetes/cluster/ubuntu/minion/init_conf/kube-proxy.conf
	==> app-03: kubernetes/cluster/ubuntu/download-release.sh
	==> app-03: kubernetes/cluster/ubuntu/minion-flannel/
	==> app-03: kubernetes/cluster/ubuntu/minion-flannel/init_scripts/
	==> app-03: kubernetes/cluster/ubuntu/minion-flannel/init_scripts/flanneld
	==> app-03: kubernetes/cluster/ubuntu/minion-flannel/init_conf/
	==> app-03: kubernetes/cluster/ubuntu/minion-flannel/init_conf/flanneld.conf
	==> app-03: kubernetes/cluster/ubuntu/deployAddons.sh
	==> app-03: kubernetes/cluster/local/
	==> app-03: kubernetes/cluster/local/util.sh
	==> app-03: kubernetes/cluster/get-kube-binaries.sh
	==> app-03: kubernetes/cluster/common.sh
	==> app-03: kubernetes/cluster/juju/
	==> app-03: kubernetes/cluster/juju/kube-system-ns.yaml
	==> app-03: kubernetes/cluster/juju/config-default.sh
	==> app-03: kubernetes/cluster/juju/layers/
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/layer.yaml
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/metadata.yaml
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/templates/
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/templates/kubedns-svc.yaml
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/templates/master.json
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/templates/docker-compose.yml
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/templates/kubedns-rc.yaml
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/tests/
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/tests/tests.yaml
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/config.yaml
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/README.md
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/actions.yaml
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/actions/
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/actions/guestbook-example
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/icon.svg
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/reactive/
	==> app-03: kubernetes/cluster/juju/layers/kubernetes/reactive/k8s.py
	==> app-03: kubernetes/cluster/juju/identify-leaders.py
	==> app-03: kubernetes/cluster/juju/util.sh
	==> app-03: kubernetes/cluster/juju/config-test.sh
	==> app-03: kubernetes/cluster/juju/return-node-ips.py
	==> app-03: kubernetes/cluster/juju/bundles/
	==> app-03: kubernetes/cluster/juju/bundles/README.md
	==> app-03: kubernetes/cluster/juju/bundles/local.yaml.base
	==> app-03: kubernetes/cluster/juju/prereqs/
	==> app-03: kubernetes/cluster/juju/prereqs/ubuntu-juju.sh
	==> app-03: kubernetes/cluster/kube-up.sh
	==> app-03: kubernetes/cluster/kube-util.sh
	==> app-03: kubernetes/cluster/options.md
	==> app-03: kubernetes/cluster/mesos/
	==> app-03: kubernetes/cluster/mesos/docker/
	==> app-03: kubernetes/cluster/mesos/docker/static-pod.json
	==> app-03: kubernetes/cluster/mesos/docker/socat/
	==> app-03: kubernetes/cluster/mesos/docker/socat/build.sh
	==> app-03: kubernetes/cluster/mesos/docker/socat/Dockerfile
	==> app-03: kubernetes/cluster/mesos/docker/static-pods-ns.yaml
	==> app-03: kubernetes/cluster/mesos/docker/kube-system-ns.yaml
	==> app-03: kubernetes/cluster/mesos/docker/config-default.sh
	==> app-03: kubernetes/cluster/mesos/docker/OWNERS
	==> app-03: kubernetes/cluster/mesos/docker/util.sh
	==> app-03: kubernetes/cluster/mesos/docker/config-test.sh
	==> app-03: kubernetes/cluster/mesos/docker/.gitignore
	==> app-03: kubernetes/cluster/mesos/docker/common/
	==> app-03: kubernetes/cluster/mesos/docker/common/bin/
	==> app-03: kubernetes/cluster/mesos/docker/common/bin/await-file
	==> app-03: kubernetes/cluster/mesos/docker/common/bin/health-check
	==> app-03: kubernetes/cluster/mesos/docker/common/bin/await-health-check
	==> app-03: kubernetes/cluster/mesos/docker/deploy-dns.sh
	==> app-03: kubernetes/cluster/mesos/docker/docker-compose.yml
	==> app-03: kubernetes/cluster/mesos/docker/test/
	==> app-03: kubernetes/cluster/mesos/docker/test/build.sh
	==> app-03: kubernetes/cluster/mesos/docker/test/Dockerfile
	==> app-03: kubernetes/cluster/mesos/docker/test/bin/
	==> app-03: kubernetes/cluster/mesos/docker/test/bin/install-etcd.sh
	==> app-03: kubernetes/cluster/mesos/docker/deploy-addons.sh
	==> app-03: kubernetes/cluster/mesos/docker/km/
	==> app-03: kubernetes/cluster/mesos/docker/km/build.sh
	==> app-03: kubernetes/cluster/mesos/docker/km/Dockerfile
	==> app-03: kubernetes/cluster/mesos/docker/km/.gitignore
	==> app-03: kubernetes/cluster/mesos/docker/km/opt/
	==> app-03: kubernetes/cluster/mesos/docker/km/opt/mesos-cloud.conf
	==> app-03: kubernetes/cluster/mesos/docker/deploy-ui.sh
	==> app-03: kubernetes/cluster/images/
	==> app-03: kubernetes/cluster/images/kube-discovery/
	==> app-03: kubernetes/cluster/images/kube-discovery/README.md
	==> app-03: kubernetes/cluster/images/kube-discovery/Dockerfile
	==> app-03: kubernetes/cluster/images/kube-discovery/Makefile
	==> app-03: kubernetes/cluster/images/etcd-empty-dir-cleanup/
	==> app-03: kubernetes/cluster/images/etcd-empty-dir-cleanup/Dockerfile
	==> app-03: kubernetes/cluster/images/etcd-empty-dir-cleanup/etcd-empty-dir-cleanup.sh
	==> app-03: kubernetes/cluster/images/etcd-empty-dir-cleanup/Makefile
	==> app-03: kubernetes/cluster/images/etcd/
	==> app-03: kubernetes/cluster/images/etcd/attachlease/
	==> app-03: kubernetes/cluster/images/etcd/attachlease/attachlease.go
	==> app-03: kubernetes/cluster/images/etcd/README.md
	==> app-03: kubernetes/cluster/images/etcd/Dockerfile
	==> app-03: kubernetes/cluster/images/etcd/migrate-if-needed.sh
	==> app-03: kubernetes/cluster/images/etcd/Makefile
	==> app-03: kubernetes/cluster/images/etcd/rollback/
	==> app-03: kubernetes/cluster/images/etcd/rollback/rollback.go
	==> app-03: kubernetes/cluster/images/etcd/rollback/README.md
	==> app-03: kubernetes/cluster/images/kubemark/
	==> app-03: kubernetes/cluster/images/kubemark/kubemark.sh
	==> app-03: kubernetes/cluster/images/kubemark/Dockerfile
	==> app-03: kubernetes/cluster/images/kubemark/Makefile
	==> app-03: kubernetes/cluster/images/kubemark/build-kubemark.sh
	==> app-03: kubernetes/cluster/images/hyperkube/
	==> app-03: kubernetes/cluster/images/hyperkube/README.md
	==> app-03: kubernetes/cluster/images/hyperkube/setup-files.sh
	==> app-03: kubernetes/cluster/images/hyperkube/Dockerfile
	==> app-03: kubernetes/cluster/images/hyperkube/kube-proxy-ds.yaml
	==> app-03: kubernetes/cluster/images/hyperkube/cni-conf/
	==> app-03: kubernetes/cluster/images/hyperkube/cni-conf/10-containernet.conf
	==> app-03: kubernetes/cluster/images/hyperkube/cni-conf/99-loopback.conf
	==> app-03: kubernetes/cluster/images/hyperkube/copy-addons.sh
	==> app-03: kubernetes/cluster/images/hyperkube/static-pods/
	==> app-03: kubernetes/cluster/images/hyperkube/static-pods/kube-proxy.json
	==> app-03: kubernetes/cluster/images/hyperkube/static-pods/master-multi.json
	==> app-03: kubernetes/cluster/images/hyperkube/static-pods/master.json
	==> app-03: kubernetes/cluster/images/hyperkube/static-pods/addon-manager-singlenode.json
	==> app-03: kubernetes/cluster/images/hyperkube/static-pods/etcd.json
	==> app-03: kubernetes/cluster/images/hyperkube/static-pods/addon-manager-multinode.json
	==> app-03: kubernetes/cluster/images/hyperkube/Makefile
	==> app-03: kubernetes/cluster/skeleton/
	==> app-03: kubernetes/cluster/skeleton/util.sh
	==> app-03: kubernetes/cluster/kube-down.sh
	==> app-03: kubernetes/cluster/get-kube.sh
	==> app-03: kubernetes/cluster/test-e2e.sh
	==> app-03: kubernetes/cluster/ovirt/
	==> app-03: kubernetes/cluster/ovirt/ovirt-cloud.conf
	==> app-03: kubernetes/cluster/azure-legacy/
	==> app-03: kubernetes/cluster/azure-legacy/templates/
	==> app-03: kubernetes/cluster/azure-legacy/templates/salt-master.sh
	==> app-03: kubernetes/cluster/azure-legacy/templates/common.sh
	==> app-03: kubernetes/cluster/azure-legacy/templates/download-release.sh
	==> app-03: kubernetes/cluster/azure-legacy/templates/create-dynamic-salt-files.sh
	==> app-03: kubernetes/cluster/azure-legacy/templates/salt-minion.sh
	==> app-03: kubernetes/cluster/azure-legacy/templates/create-kubeconfig.sh
	==> app-03: kubernetes/cluster/azure-legacy/config-default.sh
	==> app-03: kubernetes/cluster/azure-legacy/util.sh
	==> app-03: kubernetes/cluster/azure-legacy/.gitignore
	==> app-03: kubernetes/cluster/vagrant/
	==> app-03: kubernetes/cluster/vagrant/provision-network-master.sh
	==> app-03: kubernetes/cluster/vagrant/config-default.sh
	==> app-03: kubernetes/cluster/vagrant/OWNERS
	==> app-03: kubernetes/cluster/vagrant/util.sh
	==> app-03: kubernetes/cluster/vagrant/pod-ip-test.sh
	==> app-03: kubernetes/cluster/vagrant/config-test.sh
	==> app-03: kubernetes/cluster/vagrant/provision-node.sh
	==> app-03: kubernetes/cluster/vagrant/provision-network-node.sh
	==> app-03: kubernetes/cluster/vagrant/provision-utils.sh
	==> app-03: kubernetes/cluster/vagrant/provision-master.sh
	==> app-03: kubernetes/cluster/gce/
	==> app-03: kubernetes/cluster/gce/config-common.sh
	==> app-03: kubernetes/cluster/gce/config-default.sh
	==> app-03: kubernetes/cluster/gce/trusty/
	==> app-03: kubernetes/cluster/gce/trusty/helper.sh
	==> app-03: kubernetes/cluster/gce/trusty/node-helper.sh
	==> app-03: kubernetes/cluster/gce/trusty/node.yaml
	==> app-03: kubernetes/cluster/gce/trusty/master.yaml
	==> app-03: kubernetes/cluster/gce/trusty/configure.sh
	==> app-03: kubernetes/cluster/gce/trusty/master-helper.sh
	==> app-03: kubernetes/cluster/gce/trusty/configure-helper.sh
	==> app-03: kubernetes/cluster/gce/list-resources.sh
	==> app-03: kubernetes/cluster/gce/delete-stranded-load-balancers.sh
	==> app-03: kubernetes/cluster/gce/util.sh
	==> app-03: kubernetes/cluster/gce/coreos/
	==> app-03: kubernetes/cluster/gce/coreos/master-rkt.yaml
	==> app-03: kubernetes/cluster/gce/coreos/configure-kubelet.sh
	==> app-03: kubernetes/cluster/gce/coreos/node-helper.sh
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/kube-apiserver.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/kube-addon-manager.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/etcd-events.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/kube-system.json
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/kubelet-config.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/kube-controller-manager.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/kubeproxy-config.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/kube-scheduler.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/fluentd-elasticsearch/
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/fluentd-elasticsearch/kibana-controller.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/fluentd-elasticsearch/es-controller.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/fluentd-elasticsearch/es-service.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/fluentd-elasticsearch/kibana-service.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/google/
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/google/heapster-service.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/google/heapster-controller.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/heapster-service.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/influxdb-grafana-controller.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/grafana-service.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/heapster-controller.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/influxdb/influxdb-service.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/standalone/
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/standalone/heapster-service.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/standalone/heapster-controller.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/googleinfluxdb/
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-monitoring/googleinfluxdb/heapster-controller-combined.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/namespace.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/registry/
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/registry/registry-rc.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/registry/registry-svc.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/registry/registry-pvc.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/registry/registry-pv.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/node-problem-detector/
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/node-problem-detector/node-problem-detector.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/dashboard/
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/dashboard/dashboard-controller.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/dashboard/dashboard-service.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/dns/
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/dns/skydns-rc.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/dns/skydns-svc.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-loadbalancing/
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-loadbalancing/glbc/
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-loadbalancing/glbc/glbc-controller.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/addons/cluster-loadbalancing/glbc/default-svc.yaml
	==> app-03: kubernetes/cluster/gce/coreos/kube-manifests/etcd.yaml
	==> app-03: kubernetes/cluster/gce/coreos/master-docker.yaml
	==> app-03: kubernetes/cluster/gce/coreos/master-helper.sh
	==> app-03: kubernetes/cluster/gce/coreos/node-docker.yaml
	==> app-03: kubernetes/cluster/gce/coreos/configure-node.sh
	==> app-03: kubernetes/cluster/gce/coreos/node-rkt.yaml
	==> app-03: kubernetes/cluster/gce/config-test.sh
	==> app-03: kubernetes/cluster/gce/gci/
	==> app-03: kubernetes/cluster/gce/gci/helper.sh
	==> app-03: kubernetes/cluster/gce/gci/README.md
	==> app-03: kubernetes/cluster/gce/gci/health-monitor.sh
	==> app-03: kubernetes/cluster/gce/gci/node-helper.sh
	==> app-03: kubernetes/cluster/gce/gci/node.yaml
	==> app-03: kubernetes/cluster/gce/gci/master.yaml
	==> app-03: kubernetes/cluster/gce/gci/configure.sh
	==> app-03: kubernetes/cluster/gce/gci/master-helper.sh
	==> app-03: kubernetes/cluster/gce/gci/configure-helper.sh
	==> app-03: kubernetes/cluster/gce/debian/
	==> app-03: kubernetes/cluster/gce/debian/node-helper.sh
	==> app-03: kubernetes/cluster/gce/debian/master-helper.sh
	==> app-03: kubernetes/cluster/gce/configure-vm.sh
	==> app-03: kubernetes/cluster/gce/upgrade.sh
	==> app-03: kubernetes/cluster/addons/
	==> app-03: kubernetes/cluster/addons/podsecuritypolicies/
	==> app-03: kubernetes/cluster/addons/podsecuritypolicies/privileged.yaml
	==> app-03: kubernetes/cluster/addons/fluentd-gcp/
	==> app-03: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/
	==> app-03: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/README.md
	==> app-03: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/google-fluentd-journal.conf
	==> app-03: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/Dockerfile
	==> app-03: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/google-fluentd.conf
	==> app-03: kubernetes/cluster/addons/fluentd-gcp/fluentd-gcp-image/Makefile
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-controller.yaml
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/es-controller.yaml
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/es-service.yaml
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/elasticsearch.yml
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/run.sh
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/Dockerfile
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/template-k8s-logstash.json
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/Makefile
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/es-image/elasticsearch_logging_discovery.go
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-image/
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-image/run.sh
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-image/Dockerfile
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-image/Makefile
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/kibana-service.yaml
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/README.md
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/build.sh
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/Dockerfile
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/td-agent.conf
	==> app-03: kubernetes/cluster/addons/fluentd-elasticsearch/fluentd-es-image/Makefile
	==> app-03: kubernetes/cluster/addons/etcd-empty-dir-cleanup/
	==> app-03: kubernetes/cluster/addons/etcd-empty-dir-cleanup/etcd-empty-dir-cleanup.yaml
	==> app-03: kubernetes/cluster/addons/README.md
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/README.md
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/google/
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/google/heapster-service.yaml
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/google/heapster-controller.yaml
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/influxdb/
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/influxdb/heapster-service.yaml
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/influxdb/influxdb-grafana-controller.yaml
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/influxdb/grafana-service.yaml
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/influxdb/heapster-controller.yaml
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/influxdb/influxdb-service.yaml
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/standalone/
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/standalone/heapster-service.yaml
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/standalone/heapster-controller.yaml
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/googleinfluxdb/
	==> app-03: kubernetes/cluster/addons/cluster-monitoring/googleinfluxdb/heapster-controller-combined.yaml
	==> app-03: kubernetes/cluster/addons/addon-manager/
	==> app-03: kubernetes/cluster/addons/addon-manager/README.md
	==> app-03: kubernetes/cluster/addons/addon-manager/kube-addons.sh
	==> app-03: kubernetes/cluster/addons/addon-manager/Dockerfile
	==> app-03: kubernetes/cluster/addons/addon-manager/namespace.yaml
	==> app-03: kubernetes/cluster/addons/addon-manager/kube-addon-update.sh
	==> app-03: kubernetes/cluster/addons/addon-manager/Makefile
	==> app-03: kubernetes/cluster/addons/gci/
	==> app-03: kubernetes/cluster/addons/gci/README.md
	==> app-03: kubernetes/cluster/addons/gci/fluentd-gcp.yaml
	==> app-03: kubernetes/cluster/addons/registry/
	==> app-03: kubernetes/cluster/addons/registry/registry-pv.yaml.in
	==> app-03: kubernetes/cluster/addons/registry/README.md
	==> app-03: kubernetes/cluster/addons/registry/gcs/
	==> app-03: kubernetes/cluster/addons/registry/gcs/README.md
	==> app-03: kubernetes/cluster/addons/registry/gcs/registry-gcs-rc.yaml
	==> app-03: kubernetes/cluster/addons/registry/registry-rc.yaml
	==> app-03: kubernetes/cluster/addons/registry/registry-svc.yaml
	==> app-03: kubernetes/cluster/addons/registry/registry-pvc.yaml.in
	==> app-03: kubernetes/cluster/addons/registry/tls/
	==> app-03: kubernetes/cluster/addons/registry/tls/README.md
	==> app-03: kubernetes/cluster/addons/registry/tls/registry-tls-rc.yaml
	==> app-03: kubernetes/cluster/addons/registry/tls/registry-tls-svc.yaml
	==> app-03: kubernetes/cluster/addons/registry/auth/
	==> app-03: kubernetes/cluster/addons/registry/auth/README.md
	==> app-03: kubernetes/cluster/addons/registry/auth/registry-auth-rc.yaml
	==> app-03: kubernetes/cluster/addons/registry/images/
	==> app-03: kubernetes/cluster/addons/registry/images/proxy.conf.in
	==> app-03: kubernetes/cluster/addons/registry/images/Dockerfile
	==> app-03: kubernetes/cluster/addons/registry/images/proxy.conf.insecure.in
	==> app-03: kubernetes/cluster/addons/registry/images/Makefile
	==> app-03: kubernetes/cluster/addons/registry/images/run_proxy.sh
	==> app-03: kubernetes/cluster/addons/node-problem-detector/
	==> app-03: kubernetes/cluster/addons/node-problem-detector/README.md
	==> app-03: kubernetes/cluster/addons/node-problem-detector/MAINTAINERS.md
	==> app-03: kubernetes/cluster/addons/node-problem-detector/node-problem-detector.yaml
	==> app-03: kubernetes/cluster/addons/dashboard/
	==> app-03: kubernetes/cluster/addons/dashboard/dashboard-controller.yaml
	==> app-03: kubernetes/cluster/addons/dashboard/README.md
	==> app-03: kubernetes/cluster/addons/dashboard/MAINTAINERS.md
	==> app-03: kubernetes/cluster/addons/dashboard/dashboard-service.yaml
	==> app-03: kubernetes/cluster/addons/calico-policy-controller/
	==> app-03: kubernetes/cluster/addons/calico-policy-controller/README.md
	==> app-03: kubernetes/cluster/addons/calico-policy-controller/MAINTAINERS.md
	==> app-03: kubernetes/cluster/addons/calico-policy-controller/calico-policy-controller.yaml
	==> app-03: kubernetes/cluster/addons/calico-policy-controller/calico-etcd-service.yaml
	==> app-03: kubernetes/cluster/addons/calico-policy-controller/calico-etcd-petset.yaml
	==> app-03: kubernetes/cluster/addons/python-image/
	==> app-03: kubernetes/cluster/addons/python-image/README.md
	==> app-03: kubernetes/cluster/addons/python-image/Dockerfile
	==> app-03: kubernetes/cluster/addons/python-image/Makefile
	==> app-03: kubernetes/cluster/addons/dns/
	==> app-03: kubernetes/cluster/addons/dns/transforms2salt.sed
	==> app-03: kubernetes/cluster/addons/dns/README.md
	==> app-03: kubernetes/cluster/addons/dns/skydns-svc.yaml.base
	==> app-03: kubernetes/cluster/addons/dns/skydns-svc.yaml.in
	==> app-03: kubernetes/cluster/addons/dns/transforms2sed.sed
	==> app-03: kubernetes/cluster/addons/dns/skydns-svc.yaml.sed
	==> app-03: kubernetes/cluster/addons/dns/skydns-rc.yaml.base
	==> app-03: kubernetes/cluster/addons/dns/skydns-rc.yaml.in
	==> app-03: kubernetes/cluster/addons/dns/skydns-rc.yaml.sed
	==> app-03: kubernetes/cluster/addons/dns/Makefile
	==> app-03: kubernetes/cluster/addons/cluster-loadbalancing/
	==> app-03: kubernetes/cluster/addons/cluster-loadbalancing/MAINTAINERS.md
	==> app-03: kubernetes/cluster/addons/cluster-loadbalancing/glbc/
	==> app-03: kubernetes/cluster/addons/cluster-loadbalancing/glbc/README.md
	==> app-03: kubernetes/cluster/addons/cluster-loadbalancing/glbc/default-svc-controller.yaml
	==> app-03: kubernetes/cluster/addons/cluster-loadbalancing/glbc/default-svc.yaml
	==> app-03: kubernetes/cluster/test-smoke.sh
	==> app-03: kubernetes/cluster/kube-push.sh
	==> app-03: kubernetes/cluster/azure/
	==> app-03: kubernetes/cluster/azure/config-default.sh
	==> app-03: kubernetes/cluster/azure/util.sh
	==> app-03: kubernetes/cluster/azure/.gitignore
	==> app-03: kubernetes/version
	==> app-03: kubernetes/LICENSES
	==> app-03: kubernetes/federation/
	==> app-03: kubernetes/federation/cluster/
	==> app-03: kubernetes/federation/cluster/federation-up.sh
	==> app-03: kubernetes/federation/cluster/common.sh
	==> app-03: kubernetes/federation/cluster/template.go
	==> app-03: kubernetes/federation/cluster/federation-down.sh
	==> app-03: kubernetes/federation/manifests/
	==> app-03: kubernetes/federation/manifests/federation-controller-manager-deployment.yaml
	==> app-03: kubernetes/federation/manifests/federation-etcd-pvc.yaml
	==> app-03: kubernetes/federation/manifests/federation-ns.yaml
	==> app-03: kubernetes/federation/manifests/.gitignore
	==> app-03: kubernetes/federation/manifests/federation-apiserver-deployment.yaml
	==> app-03: kubernetes/federation/manifests/federation-apiserver-lb-service.yaml
	==> app-03: kubernetes/federation/manifests/federation-apiserver-cluster-service.yaml
	==> app-03: kubernetes/federation/manifests/federation-apiserver-nodeport-service.yaml
	==> app-03: kubernetes/federation/manifests/federation-apiserver-secrets.yaml
	==> app-03: kubernetes/federation/deploy/
	==> app-03: kubernetes/federation/deploy/deploy.sh
	==> app-03: kubernetes/federation/deploy/config.json.sample
	==> app-03: kubernetes/server/
	==> app-03: kubernetes/server/kubernetes-salt.tar.gz
	==> app-03: kubernetes/server/kubernetes-manifests.tar.gz
	==> app-03: kubernetes/server/kubernetes-server-linux-arm.tar.gz
	==> app-03: kubernetes/server/kubernetes-server-linux-arm64.tar.gz
	==> app-03: kubernetes/server/kubernetes-server-linux-amd64.tar.gz
	==> app-03: kubernetes/Vagrantfile
	==> app-03: kubernetes/examples/
	==> app-03: kubernetes/examples/doc.go
	==> app-03: kubernetes/examples/README.md
	==> app-03: kubernetes/examples/simple-nginx.md
	==> app-03: kubernetes/examples/runtime-constraints/
	==> app-03: kubernetes/examples/runtime-constraints/README.md
	==> app-03: kubernetes/examples/OWNERS
	==> app-03: kubernetes/examples/phabricator/
	==> app-03: kubernetes/examples/phabricator/php-phabricator/
	==> app-03: kubernetes/examples/phabricator/php-phabricator/run.sh
	==> app-03: kubernetes/examples/phabricator/php-phabricator/Dockerfile
	==> app-03: kubernetes/examples/phabricator/php-phabricator/000-default.conf
	==> app-03: kubernetes/examples/phabricator/README.md
	==> app-03: kubernetes/examples/phabricator/phabricator-controller.json
	==> app-03: kubernetes/examples/phabricator/phabricator-service.json
	==> app-03: kubernetes/examples/phabricator/teardown.sh
	==> app-03: kubernetes/examples/phabricator/setup.sh
	==> app-03: kubernetes/examples/cockroachdb/
	==> app-03: kubernetes/examples/cockroachdb/README.md
	==> app-03: kubernetes/examples/cockroachdb/minikube.sh
	==> app-03: kubernetes/examples/cockroachdb/demo.sh
	==> app-03: kubernetes/examples/cockroachdb/cockroachdb-petset.yaml
	==> app-03: kubernetes/examples/javaweb-tomcat-sidecar/
	==> app-03: kubernetes/examples/javaweb-tomcat-sidecar/README.md
	==> app-03: kubernetes/examples/javaweb-tomcat-sidecar/javaweb.yaml
	==> app-03: kubernetes/examples/javaweb-tomcat-sidecar/javaweb-2.yaml
	==> app-03: kubernetes/examples/javaweb-tomcat-sidecar/workflow.png
	==> app-03: kubernetes/examples/experimental/
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/README.md
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/glusterfs-dp.yaml
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/aws-ebs.yaml
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/glusterfs-provisioning-secret.yaml
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/claim1.json
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/rbd/
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/rbd/ceph-secret-admin.yaml
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/rbd/rbd-storage-class.yaml
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/rbd/ceph-secret-user.yaml
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/rbd/pod.yaml
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/quobyte/
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/quobyte/quobyte-admin-secret.yaml
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/quobyte/example-pod.yaml
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/quobyte/quobyte-storage-class.yaml
	==> app-03: kubernetes/examples/experimental/persistent-volume-provisioning/gce-pd.yaml
	==> app-03: kubernetes/examples/examples_test.go
	==> app-03: kubernetes/examples/nodesjs-mongodb/
	==> app-03: kubernetes/examples/nodesjs-mongodb/README.md
	==> app-03: kubernetes/examples/nodesjs-mongodb/mongo-controller.yaml
	==> app-03: kubernetes/examples/nodesjs-mongodb/web-service.yaml
	==> app-03: kubernetes/examples/nodesjs-mongodb/web-controller.yaml
	==> app-03: kubernetes/examples/nodesjs-mongodb/mongo-service.yaml
	==> app-03: kubernetes/examples/nodesjs-mongodb/web-controller-demo.yaml
	==> app-03: kubernetes/examples/mysql-wordpress-pd/
	==> app-03: kubernetes/examples/mysql-wordpress-pd/README.md
	==> app-03: kubernetes/examples/mysql-wordpress-pd/OWNERS
	==> app-03: kubernetes/examples/mysql-wordpress-pd/WordPress.png
	==> app-03: kubernetes/examples/mysql-wordpress-pd/gce-volumes.yaml
	==> app-03: kubernetes/examples/mysql-wordpress-pd/mysql-deployment.yaml
	==> app-03: kubernetes/examples/mysql-wordpress-pd/wordpress-deployment.yaml
	==> app-03: kubernetes/examples/mysql-wordpress-pd/local-volumes.yaml
	==> app-03: kubernetes/examples/mysql-cinder-pd/
	==> app-03: kubernetes/examples/mysql-cinder-pd/mysql.yaml
	==> app-03: kubernetes/examples/mysql-cinder-pd/README.md
	==> app-03: kubernetes/examples/mysql-cinder-pd/mysql-service.yaml
	==> app-03: kubernetes/examples/openshift-origin/
	==> app-03: kubernetes/examples/openshift-origin/openshift-controller.yaml
	==> app-03: kubernetes/examples/openshift-origin/README.md
	==> app-03: kubernetes/examples/openshift-origin/openshift-origin-namespace.yaml
	==> app-03: kubernetes/examples/openshift-origin/etcd-discovery-service.yaml
	==> app-03: kubernetes/examples/openshift-origin/etcd-service.yaml
	==> app-03: kubernetes/examples/openshift-origin/.gitignore
	==> app-03: kubernetes/examples/openshift-origin/openshift-service.yaml
	==> app-03: kubernetes/examples/openshift-origin/cleanup.sh
	==> app-03: kubernetes/examples/openshift-origin/etcd-discovery-controller.yaml
	==> app-03: kubernetes/examples/openshift-origin/create.sh
	==> app-03: kubernetes/examples/openshift-origin/secret.json
	==> app-03: kubernetes/examples/openshift-origin/etcd-controller.yaml
	==> app-03: kubernetes/examples/javaee/
	==> app-03: kubernetes/examples/javaee/README.md
	==> app-03: kubernetes/examples/javaee/wildfly-rc.yaml
	==> app-03: kubernetes/examples/javaee/mysql-pod.yaml
	==> app-03: kubernetes/examples/javaee/mysql-service.yaml
	==> app-03: kubernetes/examples/newrelic/
	==> app-03: kubernetes/examples/newrelic/newrelic-config.yaml
	==> app-03: kubernetes/examples/newrelic/README.md
	==> app-03: kubernetes/examples/newrelic/nrconfig.env
	==> app-03: kubernetes/examples/newrelic/newrelic-config-template.yaml
	==> app-03: kubernetes/examples/newrelic/config-to-secret.sh
	==> app-03: kubernetes/examples/newrelic/newrelic-daemonset.yaml
	==> app-03: kubernetes/examples/scheduler-policy-config-with-extender.json
	==> app-03: kubernetes/examples/storm/
	==> app-03: kubernetes/examples/storm/README.md
	==> app-03: kubernetes/examples/storm/storm-nimbus-service.json
	==> app-03: kubernetes/examples/storm/zookeeper.json
	==> app-03: kubernetes/examples/storm/zookeeper-service.json
	==> app-03: kubernetes/examples/storm/storm-worker-controller.json
	==> app-03: kubernetes/examples/storm/storm-nimbus.json
	==> app-03: kubernetes/examples/https-nginx/
	==> app-03: kubernetes/examples/https-nginx/README.md
	==> app-03: kubernetes/examples/https-nginx/Dockerfile
	==> app-03: kubernetes/examples/https-nginx/make_secret.go
	==> app-03: kubernetes/examples/https-nginx/nginx-app.yaml
	==> app-03: kubernetes/examples/https-nginx/default.conf
	==> app-03: kubernetes/examples/https-nginx/Makefile
	==> app-03: kubernetes/examples/https-nginx/index2.html
	==> app-03: kubernetes/examples/https-nginx/auto-reload-nginx.sh
	==> app-03: kubernetes/examples/explorer/
	==> app-03: kubernetes/examples/explorer/README.md
	==> app-03: kubernetes/examples/explorer/Dockerfile
	==> app-03: kubernetes/examples/explorer/Makefile
	==> app-03: kubernetes/examples/explorer/pod.yaml
	==> app-03: kubernetes/examples/explorer/explorer.go
	==> app-03: kubernetes/examples/job/
	==> app-03: kubernetes/examples/job/expansions/
	==> app-03: kubernetes/examples/job/expansions/README.md
	==> app-03: kubernetes/examples/job/work-queue-1/
	==> app-03: kubernetes/examples/job/work-queue-1/README.md
	==> app-03: kubernetes/examples/job/work-queue-2/
	==> app-03: kubernetes/examples/job/work-queue-2/README.md
	==> app-03: kubernetes/examples/cluster-dns/
	==> app-03: kubernetes/examples/cluster-dns/namespace-prod.yaml
	==> app-03: kubernetes/examples/cluster-dns/dns-backend-rc.yaml
	==> app-03: kubernetes/examples/cluster-dns/README.md
	==> app-03: kubernetes/examples/cluster-dns/namespace-dev.yaml
	==> app-03: kubernetes/examples/cluster-dns/images/
	==> app-03: kubernetes/examples/cluster-dns/images/frontend/
	==> app-03: kubernetes/examples/cluster-dns/images/frontend/client.py
	==> app-03: kubernetes/examples/cluster-dns/images/frontend/Dockerfile
	==> app-03: kubernetes/examples/cluster-dns/images/frontend/Makefile
	==> app-03: kubernetes/examples/cluster-dns/images/backend/
	==> app-03: kubernetes/examples/cluster-dns/images/backend/Dockerfile
	==> app-03: kubernetes/examples/cluster-dns/images/backend/Makefile
	==> app-03: kubernetes/examples/cluster-dns/images/backend/server.py
	==> app-03: kubernetes/examples/cluster-dns/dns-frontend-pod.yaml
	==> app-03: kubernetes/examples/cluster-dns/dns-backend-service.yaml
	==> app-03: kubernetes/examples/elasticsearch/
	==> app-03: kubernetes/examples/elasticsearch/es-svc.yaml
	==> app-03: kubernetes/examples/elasticsearch/production_cluster/
	==> app-03: kubernetes/examples/elasticsearch/production_cluster/es-svc.yaml
	==> app-03: kubernetes/examples/elasticsearch/production_cluster/service-account.yaml
	==> app-03: kubernetes/examples/elasticsearch/production_cluster/README.md
	==> app-03: kubernetes/examples/elasticsearch/production_cluster/es-discovery-svc.yaml
	==> app-03: kubernetes/examples/elasticsearch/production_cluster/es-master-rc.yaml
	==> app-03: kubernetes/examples/elasticsearch/production_cluster/es-client-rc.yaml
	==> app-03: kubernetes/examples/elasticsearch/production_cluster/es-data-rc.yaml
	==> app-03: kubernetes/examples/elasticsearch/service-account.yaml
	==> app-03: kubernetes/examples/elasticsearch/README.md
	==> app-03: kubernetes/examples/elasticsearch/es-rc.yaml
	==> app-03: kubernetes/examples/sysdig-cloud/
	==> app-03: kubernetes/examples/sysdig-cloud/README.md
	==> app-03: kubernetes/examples/sysdig-cloud/sysdig-rc.yaml
	==> app-03: kubernetes/examples/sysdig-cloud/sysdig-daemonset.yaml
	==> app-03: kubernetes/examples/selenium/
	==> app-03: kubernetes/examples/selenium/README.md
	==> app-03: kubernetes/examples/selenium/selenium-hub-rc.yaml
	==> app-03: kubernetes/examples/selenium/selenium-test.py
	==> app-03: kubernetes/examples/selenium/selenium-node-chrome-rc.yaml
	==> app-03: kubernetes/examples/selenium/selenium-node-firefox-rc.yaml
	==> app-03: kubernetes/examples/selenium/selenium-hub-svc.yaml
	==> app-03: kubernetes/examples/guestbook-go/
	==> app-03: kubernetes/examples/guestbook-go/redis-master-service.json
	==> app-03: kubernetes/examples/guestbook-go/README.md
	==> app-03: kubernetes/examples/guestbook-go/redis-slave-controller.json
	==> app-03: kubernetes/examples/guestbook-go/redis-master-controller.json
	==> app-03: kubernetes/examples/guestbook-go/guestbook-page.png
	==> app-03: kubernetes/examples/guestbook-go/_src/
	==> app-03: kubernetes/examples/guestbook-go/_src/README.md
	==> app-03: kubernetes/examples/guestbook-go/_src/Dockerfile
	==> app-03: kubernetes/examples/guestbook-go/_src/main.go
	==> app-03: kubernetes/examples/guestbook-go/_src/Makefile
	==> app-03: kubernetes/examples/guestbook-go/_src/guestbook/
	==> app-03: kubernetes/examples/guestbook-go/_src/guestbook/Dockerfile
	==> app-03: kubernetes/examples/guestbook-go/_src/public/
	==> app-03: kubernetes/examples/guestbook-go/_src/public/index.html
	==> app-03: kubernetes/examples/guestbook-go/_src/public/script.js
	==> app-03: kubernetes/examples/guestbook-go/_src/public/style.css
	==> app-03: kubernetes/examples/guestbook-go/guestbook-controller.json
	==> app-03: kubernetes/examples/guestbook-go/guestbook-service.json
	==> app-03: kubernetes/examples/guestbook-go/redis-slave-service.json
	==> app-03: kubernetes/examples/sharing-clusters/
	==> app-03: kubernetes/examples/sharing-clusters/README.md
	==> app-03: kubernetes/examples/sharing-clusters/make_secret.go
	==> app-03: kubernetes/examples/k8petstore/
	==> app-03: kubernetes/examples/k8petstore/k8petstore-nodeport.sh
	==> app-03: kubernetes/examples/k8petstore/README.md
	==> app-03: kubernetes/examples/k8petstore/k8petstore-loadbalancer.sh
	==> app-03: kubernetes/examples/k8petstore/k8petstore.sh
	==> app-03: kubernetes/examples/k8petstore/redis-slave/
	==> app-03: kubernetes/examples/k8petstore/redis-slave/etc_redis_redis.conf
	==> app-03: kubernetes/examples/k8petstore/redis-slave/run.sh
	==> app-03: kubernetes/examples/k8petstore/redis-slave/Dockerfile
	==> app-03: kubernetes/examples/k8petstore/redis/
	==> app-03: kubernetes/examples/k8petstore/redis/etc_redis_redis.conf
	==> app-03: kubernetes/examples/k8petstore/redis/Dockerfile
	==> app-03: kubernetes/examples/k8petstore/redis-master/
	==> app-03: kubernetes/examples/k8petstore/redis-master/etc_redis_redis.conf
	==> app-03: kubernetes/examples/k8petstore/redis-master/Dockerfile
	==> app-03: kubernetes/examples/k8petstore/docker-machine-dev.sh
	==> app-03: kubernetes/examples/k8petstore/k8petstore.dot
	==> app-03: kubernetes/examples/k8petstore/bps-data-generator/
	==> app-03: kubernetes/examples/k8petstore/bps-data-generator/README.md
	==> app-03: kubernetes/examples/k8petstore/build-push-containers.sh
	==> app-03: kubernetes/examples/k8petstore/web-server/
	==> app-03: kubernetes/examples/k8petstore/web-server/src/
	==> app-03: kubernetes/examples/k8petstore/web-server/src/main.go
	==> app-03: kubernetes/examples/k8petstore/web-server/test.sh
	==> app-03: kubernetes/examples/k8petstore/web-server/Dockerfile
	==> app-03: kubernetes/examples/k8petstore/web-server/dump.rdb
	==> app-03: kubernetes/examples/k8petstore/web-server/static/
	==> app-03: kubernetes/examples/k8petstore/web-server/static/histogram.js
	==> app-03: kubernetes/examples/k8petstore/web-server/static/index.html
	==> app-03: kubernetes/examples/k8petstore/web-server/static/script.js
	==> app-03: kubernetes/examples/k8petstore/web-server/static/style.css
	==> app-03: kubernetes/examples/storage/
	==> app-03: kubernetes/examples/storage/redis/
	==> app-03: kubernetes/examples/storage/redis/README.md
	==> app-03: kubernetes/examples/storage/redis/image/
	==> app-03: kubernetes/examples/storage/redis/image/run.sh
	==> app-03: kubernetes/examples/storage/redis/image/Dockerfile
	==> app-03: kubernetes/examples/storage/redis/image/redis-slave.conf
	==> app-03: kubernetes/examples/storage/redis/image/redis-master.conf
	==> app-03: kubernetes/examples/storage/redis/redis-controller.yaml
	==> app-03: kubernetes/examples/storage/redis/redis-sentinel-controller.yaml
	==> app-03: kubernetes/examples/storage/redis/redis-proxy.yaml
	==> app-03: kubernetes/examples/storage/redis/redis-sentinel-service.yaml
	==> app-03: kubernetes/examples/storage/redis/redis-master.yaml
	==> app-03: kubernetes/examples/storage/mysql-galera/
	==> app-03: kubernetes/examples/storage/mysql-galera/README.md
	==> app-03: kubernetes/examples/storage/mysql-galera/pxc-node1.yaml
	==> app-03: kubernetes/examples/storage/mysql-galera/image/
	==> app-03: kubernetes/examples/storage/mysql-galera/image/Dockerfile
	==> app-03: kubernetes/examples/storage/mysql-galera/image/docker-entrypoint.sh
	==> app-03: kubernetes/examples/storage/mysql-galera/image/my.cnf
	==> app-03: kubernetes/examples/storage/mysql-galera/image/cluster.cnf
	==> app-03: kubernetes/examples/storage/mysql-galera/pxc-node3.yaml
	==> app-03: kubernetes/examples/storage/mysql-galera/pxc-cluster-service.yaml
	==> app-03: kubernetes/examples/storage/mysql-galera/pxc-node2.yaml
	==> app-03: kubernetes/examples/storage/cassandra/
	==> app-03: kubernetes/examples/storage/cassandra/README.md
	==> app-03: kubernetes/examples/storage/cassandra/cassandra-daemonset.yaml
	==> app-03: kubernetes/examples/storage/cassandra/image/
	==> app-03: kubernetes/examples/storage/cassandra/image/Dockerfile
	==> app-03: kubernetes/examples/storage/cassandra/image/files/
	==> app-03: kubernetes/examples/storage/cassandra/image/files/run.sh
	==> app-03: kubernetes/examples/storage/cassandra/image/files/cassandra.list
	==> app-03: kubernetes/examples/storage/cassandra/image/files/ready-probe.sh
	==> app-03: kubernetes/examples/storage/cassandra/image/files/cassandra.yaml
	==> app-03: kubernetes/examples/storage/cassandra/image/files/kubernetes-cassandra.jar
	==> app-03: kubernetes/examples/storage/cassandra/image/files/logback.xml
	==> app-03: kubernetes/examples/storage/cassandra/image/files/java.list
	==> app-03: kubernetes/examples/storage/cassandra/image/Makefile
	==> app-03: kubernetes/examples/storage/cassandra/cassandra-petset.yaml
	==> app-03: kubernetes/examples/storage/cassandra/cassandra-service.yaml
	==> app-03: kubernetes/examples/storage/cassandra/cassandra-controller.yaml
	==> app-03: kubernetes/examples/storage/cassandra/java/
	==> app-03: kubernetes/examples/storage/cassandra/java/src/
	==> app-03: kubernetes/examples/storage/cassandra/java/src/main/
	==> app-03: kubernetes/examples/storage/cassandra/java/src/main/java/
	==> app-03: kubernetes/examples/storage/cassandra/java/src/main/java/io/
	==> app-03: kubernetes/examples/storage/cassandra/java/src/main/java/io/k8s/
	==> app-03: kubernetes/examples/storage/cassandra/java/src/main/java/io/k8s/cassandra/
	==> app-03: kubernetes/examples/storage/cassandra/java/src/main/java/io/k8s/cassandra/KubernetesSeedProvider.java
	==> app-03: kubernetes/examples/storage/cassandra/java/src/test/
	==> app-03: kubernetes/examples/storage/cassandra/java/src/test/resources/
	==> app-03: kubernetes/examples/storage/cassandra/java/src/test/resources/cassandra.yaml
	==> app-03: kubernetes/examples/storage/cassandra/java/src/test/resources/logback-test.xml
	==> app-03: kubernetes/examples/storage/cassandra/java/src/test/java/
	==> app-03: kubernetes/examples/storage/cassandra/java/src/test/java/io/
	==> app-03: kubernetes/examples/storage/cassandra/java/src/test/java/io/k8s/
	==> app-03: kubernetes/examples/storage/cassandra/java/src/test/java/io/k8s/cassandra/
	==> app-03: kubernetes/examples/storage/cassandra/java/src/test/java/io/k8s/cassandra/KubernetesSeedProviderTest.java
	==> app-03: kubernetes/examples/storage/cassandra/java/README.md
	==> app-03: kubernetes/examples/storage/cassandra/java/.gitignore
	==> app-03: kubernetes/examples/storage/cassandra/java/pom.xml
	==> app-03: kubernetes/examples/storage/rethinkdb/
	==> app-03: kubernetes/examples/storage/rethinkdb/README.md
	==> app-03: kubernetes/examples/storage/rethinkdb/admin-pod.yaml
	==> app-03: kubernetes/examples/storage/rethinkdb/image/
	==> app-03: kubernetes/examples/storage/rethinkdb/image/run.sh
	==> app-03: kubernetes/examples/storage/rethinkdb/image/Dockerfile
	==> app-03: kubernetes/examples/storage/rethinkdb/admin-service.yaml
	==> app-03: kubernetes/examples/storage/rethinkdb/rc.yaml
	==> app-03: kubernetes/examples/storage/rethinkdb/gen-pod.sh
	==> app-03: kubernetes/examples/storage/rethinkdb/driver-service.yaml
	==> app-03: kubernetes/examples/storage/hazelcast/
	==> app-03: kubernetes/examples/storage/hazelcast/hazelcast-controller.yaml
	==> app-03: kubernetes/examples/storage/hazelcast/README.md
	==> app-03: kubernetes/examples/storage/hazelcast/image/
	==> app-03: kubernetes/examples/storage/hazelcast/image/Dockerfile
	==> app-03: kubernetes/examples/storage/hazelcast/hazelcast-service.yaml
	==> app-03: kubernetes/examples/storage/vitess/
	==> app-03: kubernetes/examples/storage/vitess/vitess-up.sh
	==> app-03: kubernetes/examples/storage/vitess/guestbook-down.sh
	==> app-03: kubernetes/examples/storage/vitess/README.md
	==> app-03: kubernetes/examples/storage/vitess/guestbook-service.yaml
	==> app-03: kubernetes/examples/storage/vitess/vtctld-controller-template.yaml
	==> app-03: kubernetes/examples/storage/vitess/vtgate-up.sh
	==> app-03: kubernetes/examples/storage/vitess/etcd-up.sh
	==> app-03: kubernetes/examples/storage/vitess/vtctld-down.sh
	==> app-03: kubernetes/examples/storage/vitess/vtctld-service.yaml
	==> app-03: kubernetes/examples/storage/vitess/vitess-down.sh
	==> app-03: kubernetes/examples/storage/vitess/etcd-controller-template.yaml
	==> app-03: kubernetes/examples/storage/vitess/etcd-down.sh
	==> app-03: kubernetes/examples/storage/vitess/vtctld-up.sh
	==> app-03: kubernetes/examples/storage/vitess/create_test_table.sql
	==> app-03: kubernetes/examples/storage/vitess/configure.sh
	==> app-03: kubernetes/examples/storage/vitess/etcd-service-template.yaml
	==> app-03: kubernetes/examples/storage/vitess/vtgate-service.yaml
	==> app-03: kubernetes/examples/storage/vitess/vttablet-down.sh
	==> app-03: kubernetes/examples/storage/vitess/env.sh
	==> app-03: kubernetes/examples/storage/vitess/vttablet-up.sh
	==> app-03: kubernetes/examples/storage/vitess/guestbook-controller.yaml
	==> app-03: kubernetes/examples/storage/vitess/vtgate-controller-template.yaml
	==> app-03: kubernetes/examples/storage/vitess/guestbook-up.sh
	==> app-03: kubernetes/examples/storage/vitess/vttablet-pod-template.yaml
	==> app-03: kubernetes/examples/storage/vitess/vtgate-down.sh
	==> app-03: kubernetes/examples/guestbook/
	==> app-03: kubernetes/examples/guestbook/redis-slave-deployment.yaml
	==> app-03: kubernetes/examples/guestbook/php-redis/
	==> app-03: kubernetes/examples/guestbook/php-redis/Dockerfile
	==> app-03: kubernetes/examples/guestbook/php-redis/guestbook.php
	==> app-03: kubernetes/examples/guestbook/php-redis/index.html
	==> app-03: kubernetes/examples/guestbook/php-redis/controllers.js
	==> app-03: kubernetes/examples/guestbook/frontend-deployment.yaml
	==> app-03: kubernetes/examples/guestbook/README.md
	==> app-03: kubernetes/examples/guestbook/redis-master-service.yaml
	==> app-03: kubernetes/examples/guestbook/redis-slave/
	==> app-03: kubernetes/examples/guestbook/redis-slave/run.sh
	==> app-03: kubernetes/examples/guestbook/redis-slave/Dockerfile
	==> app-03: kubernetes/examples/guestbook/frontend-service.yaml
	==> app-03: kubernetes/examples/guestbook/redis-master-deployment.yaml
	==> app-03: kubernetes/examples/guestbook/legacy/
	==> app-03: kubernetes/examples/guestbook/legacy/frontend-controller.yaml
	==> app-03: kubernetes/examples/guestbook/legacy/redis-master-controller.yaml
	==> app-03: kubernetes/examples/guestbook/legacy/redis-slave-controller.yaml
	==> app-03: kubernetes/examples/guestbook/redis-slave-service.yaml
	==> app-03: kubernetes/examples/guestbook/all-in-one/
	==> app-03: kubernetes/examples/guestbook/all-in-one/guestbook-all-in-one.yaml
	==> app-03: kubernetes/examples/guestbook/all-in-one/frontend.yaml
	==> app-03: kubernetes/examples/guestbook/all-in-one/redis-slave.yaml
	==> app-03: kubernetes/examples/volumes/
	==> app-03: kubernetes/examples/volumes/iscsi/
	==> app-03: kubernetes/examples/volumes/iscsi/iscsi.yaml
	==> app-03: kubernetes/examples/volumes/iscsi/README.md
	==> app-03: kubernetes/examples/volumes/glusterfs/
	==> app-03: kubernetes/examples/volumes/glusterfs/README.md
	==> app-03: kubernetes/examples/volumes/glusterfs/glusterfs-endpoints.json
	==> app-03: kubernetes/examples/volumes/glusterfs/glusterfs-pod.json
	==> app-03: kubernetes/examples/volumes/glusterfs/glusterfs-service.json
	==> app-03: kubernetes/examples/volumes/cephfs/
	==> app-03: kubernetes/examples/volumes/cephfs/README.md
	==> app-03: kubernetes/examples/volumes/cephfs/secret/
	==> app-03: kubernetes/examples/volumes/cephfs/secret/ceph-secret.yaml
	==> app-03: kubernetes/examples/volumes/cephfs/cephfs-with-secret.yaml
	==> app-03: kubernetes/examples/volumes/cephfs/cephfs.yaml
	==> app-03: kubernetes/examples/volumes/nfs/
	==> app-03: kubernetes/examples/volumes/nfs/nfs-server-service.yaml
	==> app-03: kubernetes/examples/volumes/nfs/nfs-web-rc.yaml
	==> app-03: kubernetes/examples/volumes/nfs/README.md
	==> app-03: kubernetes/examples/volumes/nfs/nfs-data/
	==> app-03: kubernetes/examples/volumes/nfs/nfs-data/README.md
	==> app-03: kubernetes/examples/volumes/nfs/nfs-data/Dockerfile
	==> app-03: kubernetes/examples/volumes/nfs/nfs-data/index.html
	==> app-03: kubernetes/examples/volumes/nfs/nfs-data/run_nfs.sh
	==> app-03: kubernetes/examples/volumes/nfs/nfs-pvc.yaml
	==> app-03: kubernetes/examples/volumes/nfs/nfs-server-rc.yaml
	==> app-03: kubernetes/examples/volumes/nfs/nfs-pv.yaml
	==> app-03: kubernetes/examples/volumes/nfs/nfs-web-service.yaml
	==> app-03: kubernetes/examples/volumes/nfs/provisioner/
	==> app-03: kubernetes/examples/volumes/nfs/provisioner/nfs-server-gce-pv.yaml
	==> app-03: kubernetes/examples/volumes/nfs/nfs-busybox-rc.yaml
	==> app-03: kubernetes/examples/volumes/nfs/nfs-pv.png
	==> app-03: kubernetes/examples/volumes/flocker/
	==> app-03: kubernetes/examples/volumes/flocker/README.md
	==> app-03: kubernetes/examples/volumes/flocker/flocker-pod.yml
	==> app-03: kubernetes/examples/volumes/flocker/flocker-pod-with-rc.yml
	==> app-03: kubernetes/examples/volumes/azure_disk/
	==> app-03: kubernetes/examples/volumes/azure_disk/README.md
	==> app-03: kubernetes/examples/volumes/azure_disk/azure.yaml
	==> app-03: kubernetes/examples/volumes/azure_file/
	==> app-03: kubernetes/examples/volumes/azure_file/README.md
	==> app-03: kubernetes/examples/volumes/azure_file/secret/
	==> app-03: kubernetes/examples/volumes/azure_file/secret/azure-secret.yaml
	==> app-03: kubernetes/examples/volumes/azure_file/azure.yaml
	==> app-03: kubernetes/examples/volumes/flexvolume/
	==> app-03: kubernetes/examples/volumes/flexvolume/README.md
	==> app-03: kubernetes/examples/volumes/flexvolume/lvm
	==> app-03: kubernetes/examples/volumes/flexvolume/nginx.yaml
	==> app-03: kubernetes/examples/volumes/fibre_channel/
	==> app-03: kubernetes/examples/volumes/fibre_channel/README.md
	==> app-03: kubernetes/examples/volumes/fibre_channel/fc.yaml
	==> app-03: kubernetes/examples/volumes/rbd/
	==> app-03: kubernetes/examples/volumes/rbd/rbd-with-secret.json
	==> app-03: kubernetes/examples/volumes/rbd/README.md
	==> app-03: kubernetes/examples/volumes/rbd/secret/
	==> app-03: kubernetes/examples/volumes/rbd/secret/ceph-secret.yaml
	==> app-03: kubernetes/examples/volumes/rbd/rbd.json
	==> app-03: kubernetes/examples/volumes/aws_ebs/
	==> app-03: kubernetes/examples/volumes/aws_ebs/README.md
	==> app-03: kubernetes/examples/volumes/aws_ebs/aws-ebs-web.yaml
	==> app-03: kubernetes/examples/volumes/quobyte/
	==> app-03: kubernetes/examples/volumes/quobyte/quobyte-pod.yaml
	==> app-03: kubernetes/examples/volumes/quobyte/Readme.md
	==> app-03: kubernetes/examples/scheduler-policy-config.json
	==> app-03: kubernetes/examples/spark/
	==> app-03: kubernetes/examples/spark/spark-gluster/
	==> app-03: kubernetes/examples/spark/spark-gluster/README.md
	==> app-03: kubernetes/examples/spark/spark-gluster/glusterfs-endpoints.yaml
	==> app-03: kubernetes/examples/spark/spark-gluster/spark-master-service.yaml
	==> app-03: kubernetes/examples/spark/spark-gluster/spark-worker-controller.yaml
	==> app-03: kubernetes/examples/spark/spark-gluster/spark-master-controller.yaml
	==> app-03: kubernetes/examples/spark/README.md
	==> app-03: kubernetes/examples/spark/spark-master-service.yaml
	==> app-03: kubernetes/examples/spark/spark-worker-controller.yaml
	==> app-03: kubernetes/examples/spark/spark-master-controller.yaml
	==> app-03: kubernetes/examples/spark/zeppelin-controller.yaml
	==> app-03: kubernetes/examples/spark/zeppelin-service.yaml
	==> app-03: kubernetes/examples/spark/namespace-spark-cluster.yaml
	==> app-03: kubernetes/examples/spark/spark-webui.yaml
	==> app-03: kubernetes/examples/pod
	==> app-03: kubernetes/examples/meteor/
	==> app-03: kubernetes/examples/meteor/mongo-pod.json
	==> app-03: kubernetes/examples/meteor/README.md
	==> app-03: kubernetes/examples/meteor/dockerbase/
	==> app-03: kubernetes/examples/meteor/dockerbase/README.md
	==> app-03: kubernetes/examples/meteor/dockerbase/Dockerfile
	==> app-03: kubernetes/examples/meteor/mongo-service.json
	==> app-03: kubernetes/examples/meteor/meteor-controller.json
	==> app-03: kubernetes/examples/meteor/meteor-service.json
	==> app-03: kubernetes/examples/kubectl-container/
	==> app-03: kubernetes/examples/kubectl-container/README.md
	==> app-03: kubernetes/examples/kubectl-container/Dockerfile
	==> app-03: kubernetes/examples/kubectl-container/.gitignore
	==> app-03: kubernetes/examples/kubectl-container/Makefile
	==> app-03: kubernetes/examples/kubectl-container/pod.json
	==> app-03: kubernetes/examples/apiserver/
	==> app-03: kubernetes/examples/apiserver/README.md
	==> app-03: kubernetes/examples/apiserver/server/
	==> app-03: kubernetes/examples/apiserver/server/main.go
	==> app-03: kubernetes/examples/apiserver/rest/
	==> app-03: kubernetes/examples/apiserver/rest/reststorage.go
	==> app-03: kubernetes/examples/apiserver/apiserver.go
	==> app-03: kubernetes/examples/guidelines.md
	==> app-03: kubernetes/platforms/
	==> app-03: kubernetes/platforms/darwin/
	==> app-03: kubernetes/platforms/darwin/amd64/
	==> app-03: kubernetes/platforms/darwin/amd64/kubectl
	==> app-03: kubernetes/platforms/darwin/386/
	==> app-03: kubernetes/platforms/darwin/386/kubectl
	==> app-03: kubernetes/platforms/linux/
	==> app-03: kubernetes/platforms/linux/arm/
	==> app-03: kubernetes/platforms/linux/arm/kubectl
	==> app-03: kubernetes/platforms/linux/amd64/
	==> app-03: kubernetes/platforms/linux/amd64/kubectl
	==> app-03: kubernetes/platforms/linux/arm64/
	==> app-03: kubernetes/platforms/linux/arm64/kubectl
	==> app-03: kubernetes/platforms/linux/386/
	==> app-03: kubernetes/platforms/linux/386/kubectl
	==> app-03: kubernetes/platforms/windows/
	==> app-03: kubernetes/platforms/windows/amd64/
	==> app-03: kubernetes/platforms/windows/amd64/kubectl.exe
	==> app-03: kubernetes/platforms/windows/386/
	==> app-03: kubernetes/platforms/windows/386/kubectl.exe
	==> app-03: + cd /opt/kubernetes-1.5.0/server/
	==> app-03: + tar -zxvf kubernetes-server-linux-amd64.tar.gz
	==> app-03: kubernetes/
	==> app-03: kubernetes/kubernetes-src.tar.gz
	==> app-03: kubernetes/LICENSES
	==> app-03: kubernetes/server/
	==> app-03: kubernetes/server/bin/
	==> app-03: kubernetes/server/bin/kube-apiserver.tar
	==> app-03: kubernetes/server/bin/kube-discovery
	==> app-03: kubernetes/server/bin/kube-proxy.docker_tag
	==> app-03: kubernetes/server/bin/kube-dns
	==> app-03: kubernetes/server/bin/kube-scheduler.tar
	==> app-03: kubernetes/server/bin/kube-scheduler
	==> app-03: kubernetes/server/bin/kubelet
	==> app-03: kubernetes/server/bin/kube-controller-manager.docker_tag
	==> app-03: kubernetes/server/bin/kube-proxy
	==> app-03: kubernetes/server/bin/kubeadm
	==> app-03: kubernetes/server/bin/kube-controller-manager
	==> app-03: kubernetes/server/bin/hyperkube
	==> app-03: kubernetes/server/bin/kube-controller-manager.tar
	==> app-03: kubernetes/server/bin/kube-apiserver
	==> app-03: kubernetes/server/bin/kubectl
	==> app-03: kubernetes/server/bin/kube-apiserver.docker_tag
	==> app-03: kubernetes/server/bin/kube-proxy.tar
	==> app-03: kubernetes/server/bin/kube-scheduler.docker_tag
	==> app-03: kubernetes/addons/
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
	
## 验证
1. 进程

	pp-03:~$ ps -e -o pid,cmd | grep --color -E 'etcd|flannel|docker|kube' 
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

		vagrant@app-03:~$ kubectl -s 44.0.0.103:8888 get no 
		NAME         STATUS    AGE
		44.0.0.101   Ready     1h
		44.0.0.102   Ready     1h
		44.0.0.103   Ready     1h
		vagrant@app-03:~$ kubectl -s 44.0.0.103:8888 get ns
		NAME          STATUS    AGE
		default       Active    1h
		kube-system   Active    1h
