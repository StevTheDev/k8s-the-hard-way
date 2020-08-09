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
  --kubeconfig=./kubeconfigs/kube-controller-manager.kubeconfig

kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=./pki/kube-controller-manager.pem \
  --client-key=./pki/kube-controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=./kubeconfigs/kube-controller-manager.kubeconfig

kubectl config set-context default \
  --cluster=${cluster_name}\
  --user=system:kube-controller-manager \
  --kubeconfig=./kubeconfigs/kube-controller-manager.kubeconfig

kubectl config use-context default --kubeconfig=./kubeconfigs/kube-controller-manager.kubeconfig

chmod -R 640 ./kubeconfigs/*.kubeconfig
