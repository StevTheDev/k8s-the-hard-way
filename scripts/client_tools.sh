#!/bin/bash


# Download cloudflare ssl (cfssl) and cfssljson
# https://github.com/cloudflare/cfssl/releases/

wget -q --show-progress --https-only --timestamping \
    https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssl_1.4.1_linux_amd64 \
    https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssljson_1.4.1_linux_amd64

chmod +x cfssl_1.4.1_linux_amd64
sudo mv cfssl_1.4.1_linux_amd64 /usr/local/bin/cfssl

chmod +x cfssljson_1.4.1_linux_amd6
sudo mv cfssljson_1.4.1_linux_amd64 /usr/local/bin/cfssljson

cfssl version


# Download kubectl binary
# https://kubernetes.io/docs/tasks/tools/install-kubectl/

curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x ./kubectl

sudo mv ./kubectl /usr/local/bin/kubectl

kubectl version --client
