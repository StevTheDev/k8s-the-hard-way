#!/bin/bash

set -ex

echo "Create systemd service for kube-controller-manager"
cat << EOF | tee ./control-plane/kube-controller-manager.service
[Unit]
Description=Kubernetes Controller Manager
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-controller-manager \\
  --bind-address=0.0.0.0 \\
  --cluster-cidr=10.200.0.0/16 \\
  --cluster-name=kubernetes \\
  --cluster-signing-cert-file=/var/lib/kubernetes/ca.pem \\
  --cluster-signing-key-file=/var/lib/kubernetes/ca-key.pem \\
  --kubeconfig=/var/lib/kubernetes/kube-controller-manager.yaml \\
  --leader-elect=true \\
  --root-ca-file=/var/lib/kubernetes/ca.pem \\
  --service-account-private-key-file=/var/lib/kubernetes/service-account-key.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --use-service-account-credentials=true \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

num_masters=2
for i in $(seq 1 $num_masters); do
  hostname="master-$i.lab.net"

  scp -F ./vms/ssh.config \
    ./control-plane/kube-controller-manager.service \
    ${hostname}:~

  ssh -F ./vms/ssh.config ${hostname} "sudo cp ~/kubeconfigs/kube-controller-manager.yaml /var/lib/kubernetes"
  ssh -F ./vms/ssh.config ${hostname} "sudo mv ~/kube-controller-manager.service /etc/systemd/system/kube-controller-manager.service"
done
