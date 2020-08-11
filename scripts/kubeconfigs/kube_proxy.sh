#!/bin/bash

set -ex

cluster_name=$1
cluster_proxy=$2

kubectl config set-cluster ${cluster_name} \
  --certificate-authority=./pki/ca.pem \
  --embed-certs=true \
  --server=https://${cluster_proxy}:6443 \
  --kubeconfig=./kubeconfigs/kube-proxy.yaml

kubectl config set-credentials system:kube-proxy \
  --client-certificate=./pki/kube-proxy.pem \
  --client-key=./pki/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=./kubeconfigs/kube-proxy.yaml

kubectl config set-context default \
  --cluster=${cluster_name}\
  --user=system:kube-proxy \
  --kubeconfig=./kubeconfigs/kube-proxy.yaml

kubectl config use-context default --kubeconfig=./kubeconfigs/kube-proxy.yaml
chmod -R 640 ./kubeconfigs/*.yaml
