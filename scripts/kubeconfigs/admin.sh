#!/bin/bash

set -ex

cluster_name=$1
cluster_proxy=$2 

# Localhost is used instead of $cluster_proxy, since this config will be used
# from the controller nodes

kubectl config set-cluster ${cluster_name} \
  --certificate-authority=./pki/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=./kubeconfigs/admin.yaml

kubectl config set-credentials admin \
  --client-certificate=./pki/admin.pem \
  --client-key=./pki/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=./kubeconfigs/admin.yaml

kubectl config set-context default \
  --cluster=${cluster_name}\
  --user=admin \
  --kubeconfig=./kubeconfigs/admin.yaml

kubectl config use-context default --kubeconfig=./kubeconfigs/admin.yaml

chmod -R 640 ./kubeconfigs/*.yaml
