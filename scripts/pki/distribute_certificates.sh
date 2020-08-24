#!/bin/bash

set -ex

echo "Distribute the CA and client certificates to the worker nodes"
num_workers=2
for i in $(seq 1 $num_workers); do
  hostname="worker-$i.lab.net"

  ssh -F ./vms/ssh.config ${hostname} "mkdir -p ~/pki"
  scp -F ./vms/ssh.config \
    ./pki/ca.pem \
    ./pki/${hostname}*.pem \
    steven@${hostname}:~/pki
  
  ssh -F ./vms/ssh.config ${hostname} "chmod -R 640 ~/pki/*.pem"
  ssh -F ./vms/ssh.config ${hostname} "ls -la ~/pki"

done

echo "Distribute the CA and apiserver certificates to the master nodes"
num_masters=2
for i in $(seq 1 $num_masters); do
  hostname="master-$i.lab.net"
  ssh -F ./vms/ssh.config ${hostname} "mkdir -p ~/pki"
  scp -F ./vms/ssh.config \
    ./pki/ca*.pem \
    ./pki/kubernetes*.pem \
    ./pki/service-account*.pem \
    steven@${hostname}:~/pki
    
  ssh -F ./vms/ssh.config ${hostname} "chmod -R 640 ~/pki/*.pem"
  ssh -F ./vms/ssh.config ${hostname} "ls -la ~/pki"
done

