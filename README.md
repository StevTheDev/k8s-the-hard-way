# Files for Kubernetes: The Hard Way

This repo contains configuration files and utility script for completing
[Kubernetes: the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)

`vms` contains files for configuring the lab environment.

`scripts` contains scripts for:

- Installing cfssl and kubectl ("client tools")
- Generating a CA and Cluster Certificates
- Generating Kubeconfigs
- Installing etcd on the Controller nodes

The other directories are used to organize the various generated config files. Most of their contents are in the .gitignore
