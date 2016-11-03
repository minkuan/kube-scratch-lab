#!/bin/bash

set -x;

echo "environments: $IP, $CLUSTER_STATE, $CLUSTER"

# etcd

cd /opt/

# Download the release
# curl -L https://github.com/coreos/etcd/releases/download/etcd-v3.0.1/etcd-etcd-v3.0.1-linux-amd64.tar.gz -o etcd-v3.0.1.tar.gz

# Create the directory the binaries will live in
mkdir /opt/etcd-v3.0.1

# Extract the contents of the release
cp /vagrant/etcd-v3.0.1-linux-amd64.tar.gz /opt/
tar -zxf etcd-v3.0.1-linux-amd64.tar.gz  -C etcd-v3.0.1 --strip-components=1

# Make symlinks so we can access the binaries
ln -s /opt/etcd-v3.0.1/etcd /usr/local/bin/etcd
ln -s /opt/etcd-v3.0.1/etcdctl /usr/local/bin/etcdctl

# Copy our Upstart script
cp /vagrant/etcd.conf /etc/init/etcd.conf

# Update our Upstart override files, and copy it into place
# if [ $CLUSTER_STATE = "new" ]
# then
  sed -e "s/MY_IP/$IP/g" -e "s/MY_CLUSTER_STATE/$CLUSTER_STATE/g" -e "s/MY_CLUSTER/$CLUSTER/g" </vagrant/etcd.override >/etc/init/etcd.override
# else
#   sed -e "s/MY_IP/$IP/g" -e "s/MY_CLUSTER_STATE/$CLUSTER_STATE/g" -e "s/MY_CLUSTER/$CLUSTER/g" </vagrant/etcd.override >/etc/init/etcd.override
# fi
# Create etcd's data director
mkdir /var/lib/etcd
chown vagrant:vagrant /var/lib/etcd

# Create etcd's logging directory
mkdir /var/log/etcd
chown vagrant:vagrant /var/log/etcd

# Start the service
start etcd
