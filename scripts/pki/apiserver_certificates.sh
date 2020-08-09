#!/bin/bash

# This is the TLS certificate for the Kubernetes API.

set -ex

cd ./pki/


echo "Generate certificates for API server"

function get_master_host_info() {
  num_masters=2
  for i in $(seq 1 $num_masters); do
    hostname="master-$i.lab.net"
    ip=$(dig +short $hostname | tail -n1)
    printf "$ip,$hostname,"
  done
}

function get_proxy_host_info() {
  hostname="dns.lab.net"
  ip=$(dig +short $hostname | tail -n1)
  printf "$ip,$hostname"
}


host_list=10.32.0.1,$(get_master_host_info)$(get_proxy_host_info),127.0.0.1,localhost,kubernetes.default

{
cat > kubernetes-csr.json << EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "O": "Kubernetes",
      "OU": "Kubernetes: The Hard Way",
      "L": "St Louis",
      "ST": "Missouri",
      "C": "US"
    }
  ]
}
EOF

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname=${host_list} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
}

chmod -R 640 *.pem *.csr
