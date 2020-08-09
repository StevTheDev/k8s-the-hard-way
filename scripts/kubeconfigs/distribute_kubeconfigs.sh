#!/bin/bash

set -ex

echo "Distribute kubeconfigs to the worker nodes"
num_workers=2
for i in $(seq 1 $num_workers); do
  hostname="worker-$i.lab.net"

  ssh -F ./vms/ssh.config ${hostname} "mkdir -p ~/kubeconfigs"

  scp -F ./vms/ssh.config \
    ./kubeconfigs/${hostname}.kubeconfig \
    ./kubeconfigs/kube-proxy.kubeconfig \
    ${hostname}:~/kubeconfigs
  
  ssh -F ./vms/ssh.config ${hostname} "chmod -R 640 ~/kubeconfigs/*.kubeconfig"
  ssh -F ./vms/ssh.config ${hostname} "ls -la ~/kubeconfigs/"
done

echo "Distribute kubeconfigs to the master nodes"
num_masters=2
for i in $(seq 1 $num_masters); do
  hostname="master-$i.lab.net"

  ssh -F ./vms/ssh.config ${hostname} "mkdir -p ~/kubeconfigs"
  
  scp -F ./vms/ssh.config \
    ./kubeconfigs/admin.kubeconfig \
    ./kubeconfigs/kube-controller-manager.kubeconfig \
    ./kubeconfigs/kube-scheduler.kubeconfig \
    ${hostname}:~/kubeconfigs
    
  ssh -F ./vms/ssh.config ${hostname} "chmod -R 640 ~/kubeconfigs/*.kubeconfig"
  ssh -F ./vms/ssh.config ${hostname} "ls -la ~/kubeconfigs/"
done
