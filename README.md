# kube-scratch-lab
## 问题及其解决
1. vagrant内嵌docker provisioning时网速极慢，所以在虚拟机中连接VPN；但手工docker provision时，发生vagrant不能加入docker组问题。
2. app-03 etcd不能加入etcd集群。app-03 etcd起动时失败，导致etcd service起动不成功；app-01 etcd leader报错：无法连接app-03 etcd。
3. etcd v3.1.0-rc版本报错：无法在0.0.0.0:2379找到etcd leader。

## 要点
1. ubuntu service upstart配置：*.conf, *.override, *.conf中接受环境变量
2. ruby编程编写Vagrantfile
3. vagrant shell provisioning过程中，shell脚本接受Vagrantfile传入的环境变量
4. flanneld使用etcd存储子网信息，作为etcd的客户端，访问etcd的127.0.0.1:2379。
