#!/bin/bash

set -ex

# Download ETCD Binary
ETCD_VER=v3.4.10

# choose either URL
DOWNLOAD_URL=https://github.com/etcd-io/etcd/releases/download

rm -rf /tmp/etcd && mkdir -p /tmp/etcd

curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd --strip-components=1
rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz

/tmp/etcd/etcd --version
/tmp/etcd/etcdctl version

num_masters=2
for i in $(seq 1 $num_masters); do
  hostname="master-$i.lab.net"
  echo "Distribute etcd binary to ${hostname}"
  
  scp -F ./vms/ssh.config \
    /tmp/etcd/etcd \
    /tmp/etcd/etcdctl \
    ${hostname}:/tmp/

  ssh -F ./vms/ssh.config ${hostname} "sudo mv /tmp/etcd /usr/local/bin"
  ssh -F ./vms/ssh.config ${hostname} "sudo mv /tmp/etcdctl /usr/local/bin"
  ssh -F ./vms/ssh.config ${hostname} "etcd --version"
  ssh -F ./vms/ssh.config ${hostname} "etcdctl version"
done
