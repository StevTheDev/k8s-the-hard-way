#!/bin/bash

set -ex

cluster_name=$1
cluster_proxy=$2

num_workers=2
for i in $(seq 1 $num_workers); do
  hostname="worker-$i.lab.net"
  kubectl config set-cluster ${cluster_name} \
    --certificate-authority=./pki/ca.pem \
    --embed-certs=true \
    --server=https://${cluster_proxy}:6443 \
    --kubeconfig=./kubeconfigs/${hostname}.yaml

  kubectl config set-credentials system:node:${hostname} \
    --client-certificate=./pki/${hostname}.pem \
    --client-key=./pki/${hostname}-key.pem \
    --embed-certs=true \
    --kubeconfig=./kubeconfigs/${hostname}.yaml

  kubectl config set-context default \
    --cluster=${cluster_name}\
    --user=system:node:${hostname} \
    --kubeconfig=./kubeconfigs/${hostname}.yaml

  kubectl config use-context default --kubeconfig=./kubeconfigs/${hostname}.yaml
done

chmod -R 640 ./kubeconfigs/*.yaml
