#!/bin/bash

set -ex

K8S_VERSION=v1.18.6

rm -rf /tmp/k8s && mkdir -p /tmp/k8s

DOWNLOAD_URL=https://storage.googleapis.com/kubernetes-release/release/

for COMPONENT in kube-apiserver kube-controller-manager kube-scheduler kubectl; do
    curl -L ${DOWNLOAD_URL}${K8S_VERSION}/bin/linux/amd64/${COMPONENT} -o /tmp/k8s/${COMPONENT}
    chmod +x /tmp/k8s/${COMPONENT}
done

num_masters=2
for i in $(seq 1 $num_masters); do
  hostname="master-$i.lab.net"
  echo "Distribute k8s binaries to ${hostname}"

  ssh -F ./vms/ssh.config ${hostname} "mkdir -p /tmp/k8s/"
  
  scp -F ./vms/ssh.config \
    /tmp/k8s/* \
    ${hostname}:/tmp/k8s

  ssh -F ./vms/ssh.config ${hostname} "sudo mv /tmp/k8s/* /usr/local/bin/"
done
