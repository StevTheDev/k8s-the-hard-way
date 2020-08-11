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
  --kubeconfig=./kubeconfigs/kube-scheduler.yaml

kubectl config set-credentials system:kube-scheduler \
  --client-certificate=./pki/kube-scheduler.pem \
  --client-key=./pki/kube-scheduler-key.pem \
  --embed-certs=true \
  --kubeconfig=./kubeconfigs/kube-scheduler.yaml

kubectl config set-context default \
  --cluster=${cluster_name}\
  --user=system:kube-scheduler \
  --kubeconfig=./kubeconfigs/kube-scheduler.yaml

kubectl config use-context default --kubeconfig=./kubeconfigs/kube-scheduler.yaml

chmod -R 640 ./kubeconfigs/*.yaml
