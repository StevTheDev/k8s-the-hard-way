#!/bin/bash

set -ex

# Kubeconfigs can be generated using kubectl:
# - kubectl config set-cluster
# - kubectl config set-credentials
# - kubectl config set-context
# - kubectl config use-context

# Kubeconfig for:
# - the admin user
# - the kube-controller-manager
# - the kube-scheduler
# - the kube-proxy
# - the worker Kubelets

cluster_name="k8s-lab"
cluster_proxy="dns.lab.net"

./scripts/kubeconfigs/admin.sh $cluster_name $cluster_proxy
./scripts/kubeconfigs/kube_controller_manager.sh $cluster_name $cluster_proxy
./scripts/kubeconfigs/kube_scheduler.sh $cluster_name $cluster_proxy
./scripts/kubeconfigs/kube_proxy.sh $cluster_name $cluster_proxy
./scripts/kubeconfigs/worker_nodes.sh $cluster_name $cluster_proxy

./scripts/kubeconfigs/distribute_kubeconfigs.sh