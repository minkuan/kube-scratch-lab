# kube-scratch-lab

## 目标

基于vagrant(1.8.1) ubuntu(Ubuntu 14.04.5 LTS, vagrant ubuntu/trusty64)虚拟机，从0到1建立kubernetes 1.5集群

1. 以flannel作为kubernetes网络管理组件，管理kubernetes集群子网，overlay网络数据
2. 以etcd kv-store存储flannel的子网配置
3. kubernetes与etcd的交互
4. ubuntu/linux service机制: etcd/flannel/docker/kubernetes(kubelet/kube-proxy/kube-apiserver/kube-controller-manager/kube-scheduler) kube-dashboard? kube-dns?

	- /etc/init/下的*.conf和*.override
	- service接受环境变量

## 问题及其解决
1. vagrant内嵌docker provisioning时网速极慢，所以在虚拟机中连接VPN；但手工docker provision时，发生vagrant不能加入docker组问题。
2. app-03 etcd不能加入etcd集群。app-03 etcd起动时失败，导致etcd service起动不成功；app-01 etcd leader报错：无法连接app-03 etcd。重起etcd leader才能解决；显然，重起etcd leader在工程实践中应当是不可接受的。
3. etcd v3.1.0-rc版本报错：无法在0.0.0.0:2379找到etcd leader。

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
