#!/bin/bash

set -ex
num_masters=2
for i in $(seq 1 $num_masters); do
  hostname="master-$i.lab.net"
  ssh -F ./vms/ssh.config ${hostname} "sudo systemctl daemon-reload"
  ssh -F ./vms/ssh.config ${hostname} "sudo systemctl enable kube-apiserver kube-controller-manager kube-scheduler"
  ssh -F ./vms/ssh.config ${hostname} "sudo systemctl restart kube-apiserver kube-controller-manager kube-scheduler"
done
