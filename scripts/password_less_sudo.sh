#!/bin/bash

set -ex

echo "Set up passwordless sudo on the worker nodes"
num_workers=2
for i in $(seq 1 $num_workers); do
  hostname="worker-$i.lab.net"
  ssh -tF ./vms/ssh.config ${hostname} "sudo touch /etc/sudoers.d/steven"
  ssh -tF ./vms/ssh.config ${hostname} "echo 'steven ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/steven"
  ssh -tF ./vms/ssh.config ${hostname} "sudo chmod 440 /etc/sudoers.d/steven"
done

echo "Set up passwordless sudo on the master nodes"
num_masters=2
for i in $(seq 1 $num_masters); do
  hostname="master-$i.lab.net"
  ssh -tF ./vms/ssh.config ${hostname} "sudo touch /etc/sudoers.d/steven"
  ssh -tF ./vms/ssh.config ${hostname} "echo 'steven ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/steven"
  ssh -tF ./vms/ssh.config ${hostname} "sudo chmod 440 /etc/sudoers.d/steven"
done
