#!/bin/bash

set -ex

cat << EOF | tee ./control-plane/kube-scheduler.yaml
apiVersion: kubescheduler.config.k8s.io/v1alpha1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/var/lib/kubernetes/kube-scheduler.yaml"
leaderElection:
  leaderElect: true
EOF

cat << EOF | tee ./control-plane/kube-scheduler.service
[Unit]
Description=Kubernetes Scheduler
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-scheduler \\
  --config=/etc/kubernetes/config/kube-scheduler.yaml \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF


num_masters=2
for i in $(seq 1 $num_masters); do
  hostname="master-$i.lab.net"

  ssh -F ./vms/ssh.config ${hostname} "sudo mkdir -p /etc/kubernetes/config"

  scp -F ./vms/ssh.config \
    ./control-plane/kube-scheduler.yaml \
    ./control-plane/kube-scheduler.service \
    ${hostname}:~

  ssh -F ./vms/ssh.config ${hostname} "sudo cp ~/kubeconfigs/kube-scheduler.yaml /var/lib/kubernetes"
  ssh -F ./vms/ssh.config ${hostname} "sudo mv ~/kube-scheduler.yaml /etc/kubernetes/config/kube-scheduler.yaml"
  ssh -F ./vms/ssh.config ${hostname} "sudo mv ~/kube-scheduler.service /etc/systemd/system/kube-scheduler.service"
done
