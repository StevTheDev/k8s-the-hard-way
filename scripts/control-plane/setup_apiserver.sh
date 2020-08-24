#!/bin/bash

num_masters=2

etcd_hosts=()
for i in $(seq 1 $num_masters); do
  hostname="master-$i.lab.net"
  ip=$(dig +short $hostname | tail -n1)
  etcd_hosts+=("https://${ip}:2379")
done

etcd_hosts=$(IFS=,;printf "%s" "${etcd_hosts[*]}")

set -ex
echo $etcd_hosts

for i in $(seq 1 $num_masters); do
  hostname="master-$i.lab.net"
  ip=$(dig +short $hostname | tail -n1)

  echo "Generate systemd service for the apiserver"
  cat << EOF | tee ./control-plane/${hostname}-apiserver.service
[Unit]
Description=Kubernetes API Server
Documentation=https://github.com/kubernetes/kubernetes

[Service]
ExecStart=/usr/local/bin/kube-apiserver \\
  --advertise-address=${ip} \\
  --allow-privileged=true \\
  --apiserver-count=2 \\
  --audit-log-maxage=30 \\
  --audit-log-maxbackup=3 \\
  --audit-log-maxsize=100 \\
  --audit-log-path=/var/log/audit.log \\
  --authorization-mode=Node,RBAC \\
  --bind-address=0.0.0.0 \\
  --client-ca-file=/var/lib/kubernetes/ca.pem \\
  --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \\
  --etcd-cafile=/var/lib/kubernetes/ca.pem \\
  --etcd-certfile=/var/lib/kubernetes/kubernetes.pem \\
  --etcd-keyfile=/var/lib/kubernetes/kubernetes-key.pem \\
  --etcd-servers=${etcd_hosts} \\
  --event-ttl=1h \\
  --encryption-provider-config=/var/lib/kubernetes/data_encryption_config.yaml \\
  --kubelet-certificate-authority=/var/lib/kubernetes/ca.pem \\
  --kubelet-client-certificate=/var/lib/kubernetes/kubernetes.pem \\
  --kubelet-client-key=/var/lib/kubernetes/kubernetes-key.pem \\
  --kubelet-https=true \\
  --runtime-config='api/all=true' \\
  --service-account-key-file=/var/lib/kubernetes/service-account.pem \\
  --service-cluster-ip-range=10.32.0.0/24 \\
  --service-node-port-range=30000-32767 \\
  --tls-cert-file=/var/lib/kubernetes/kubernetes.pem \\
  --tls-private-key-file=/var/lib/kubernetes/kubernetes-key.pem \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  scp -F ./vms/ssh.config \
    ./control-plane/${hostname}-apiserver.service \
    ${hostname}:~

  ssh -F ./vms/ssh.config ${hostname} "sudo mkdir -p /var/lib/kubernetes"
  ssh -F ./vms/ssh.config ${hostname} "sudo cp ~/pki/ca* /var/lib/kubernetes"
  ssh -F ./vms/ssh.config ${hostname} "sudo cp ~/pki/kubernetes* /var/lib/kubernetes"
  ssh -F ./vms/ssh.config ${hostname} "sudo cp ~/pki/service-account* /var/lib/kubernetes"
  ssh -F ./vms/ssh.config ${hostname} "sudo cp ~/pki/data_encryption_config.yaml /var/lib/kubernetes"
  ssh -F ./vms/ssh.config ${hostname} "sudo mv ~/${hostname}-apiserver.service /etc/systemd/system/kube-apiserver.service"
done
