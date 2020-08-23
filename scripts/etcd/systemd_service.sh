#!/bin/bash

set -ex

num_masters=2

# Build a list of the master nodes to use in etcd initial cluster setting
# --initial-cluster hostname1=address1,hostname2=address2...

etcd_hosts=()
for i in $(seq 1 $num_masters); do
  hostname="master-$i.lab.net"
  ip=$(dig +short $hostname | tail -n1)
  etcd_hosts+=("${hostname}=https://${ip}:2380")
done

etcd_hosts=$(IFS=,;printf "%s" "${etcd_hosts[*]}")
echo $etcd_hosts


for i in $(seq 1 $num_masters); do
  hostname="master-$i.lab.net"
  ip=$(dig +short $hostname | tail -n1)

  echo "Create etcd systemd service for ${hostname}"

  cat << EOF | tee ./etcd/${hostname}_etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/etcd-io/

[Service]
ExecStart=/usr/local/bin/etcd \
  --name ${hostname} \
  --cert-file=/etc/etcd/kubernetes.pem \
  --key-file=/etc/etcd/kubernetes-key.pem \
  --peer-cert-file=/etc/etcd/kubernetes.pem \
  --peer-key-file=/etc/etcd/kubernetes-key.pem \
  --trusted-ca-file=/etc/etcd/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ca.pem \
  --peer-client-cert-auth \
  --client-cert-auth \
  --initial-advertise-peer-urls https://${ip}:2380 \
  --listen-peer-urls https://${ip}:2380 \
  --listen-client-urls https://${ip}:2379,https://127.0.0.1:2379 \
  --advertise-client-urls https://${ip}:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster ${etcd_hosts} \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  ssh -F ./vms/ssh.config ${hostname} "sudo mkdir -p /etc/etcd /var/lib/etcd"
  ssh -F ./vms/ssh.config ${hostname} "sudo chmod -R 700 /var/lib/etcd"

  scp -F ./vms/ssh.config \
    ./etcd/${hostname}_etcd.service \
    ${hostname}:/tmp/etcd.service
    
  ssh -F ./vms/ssh.config ${hostname} "sudo mv /tmp/etcd.service /etc/systemd/system/etcd.service"
  ssh -F ./vms/ssh.config ${hostname} "sudo systemctl daemon-reload"
  ssh -F ./vms/ssh.config ${hostname} "sudo systemctl enable etcd"
  ssh -F ./vms/ssh.config ${hostname} "sudo systemctl start etcd"
  ssh -F ./vms/ssh.config ${hostname} "sudo systemctl status etcd"
done
