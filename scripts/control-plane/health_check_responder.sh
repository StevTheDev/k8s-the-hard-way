#!/bin/bash

cat > ./control-plane/kubernetes.default.svc.cluster.local <<EOF
server {
  listen      80;
  server_name kubernetes.default.svc.cluster.local;

  location /healthz {
     proxy_pass                    https://127.0.0.1:6443/healthz;
     proxy_ssl_trusted_certificate /var/lib/kubernetes/ca.pem;
  }
}
EOF

set -ex
num_masters=2
for i in $(seq 1 $num_masters); do
  hostname="master-$i.lab.net"
  ssh -F ./vms/ssh.config ${hostname} "sudo apt update && sudo apt install -y nginx"
  scp -F ./vms/ssh.config \
    ./control-plane/kubernetes.default.svc.cluster.local \
    ${hostname}:~
  ssh -F ./vms/ssh.config ${hostname} "sudo mv ~/kubernetes.default.svc.cluster.local /etc/nginx/sites-available/kubernetes.default.svc.cluster.local"
  ssh -F ./vms/ssh.config ${hostname} "sudo ln -s /etc/nginx/sites-available/kubernetes.default.svc.cluster.local /etc/nginx/sites-enabled/"

  ssh -F ./vms/ssh.config ${hostname} "sudo systemctl restart nginx"
  ssh -F ./vms/ssh.config ${hostname} "sudo systemctl enable nginx"
done
