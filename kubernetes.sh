#!/bin/bash

set -x;


# Kubernetes

cd /opt/

# Download the release
# curl -L https://github.com/kubernetes/kubernetes/releases/download/v1.3.0/kubernetes.tar.gz -o kubernetes-1.5.0.tar.gz

# Create the directory the binaries will live in
mkdir /opt/kubernetes-1.5.0

# Extract the contents of the release
tar -zxf /vagrant/kubernetes.tar.gz -C kubernetes-1.5.0 --strip-components=1

# Extract the contents of the contents of the release (where the binaries actually reside)
cd /opt/kubernetes-1.5.0/server/
tar -zxf kubernetes-server-linux-amd64.tar.gz

# Make symlink for kubectl binary to interact with cluster
ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kubectl /usr/local/bin/kubectl
echo "alias kubectl='kubectl --server=44.0.0.103:8888'" | tee -a ~/.bashrc && source ~/.bashrc

# Create etcd's logging directory
mkdir /var/log/kubernetes
chown vagrant:vagrant /var/log/kubernetes
chown -R vagrant:vagrant /opt/kubernetes-1.5.0
