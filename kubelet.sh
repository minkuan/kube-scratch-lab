#!/bin/bash

set -x;

# Make symlinks so we can access the binaries
ln -s /opt/kubernetes-1.5.0/server/kubernetes/server/bin/kubelet /usr/local/bin/kubelet

mkdir /var/lib/kubelet
cp /vagrant/.kubeconfig /var/lib/kubelet/kubeconfig

# Copy the Upstart script into the machine
cp /vagrant/kubelet.conf /etc/init/kubelet.conf

env MY_IP=$IP

start kubelet
