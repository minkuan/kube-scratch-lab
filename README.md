# kube-scratch-lab
# docker provisioning
1. 网速极慢，所以在虚拟机中连接VPN

## app-03 etcd不能加入etcd集群
app-03 etcd起动时失败，导致etcd service起动不成功；app-01 etcd leader报错：无法连接app-03 etcd。
## etcd v3.1.0-rc版本报错：无法在0.0.0.0:2379找到etcd leader。
