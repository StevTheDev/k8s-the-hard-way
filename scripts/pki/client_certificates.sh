#!/bin/bash

# These certificates provide client authentication for various users: 
# - admin
# - kube-controller-manager
# - kube-proxy
# - kube-scheduler
# and the kubelet client on each worker node.

# These certificates allow the client to authenticate with the kubernetes api
# and with other clients.

set -ex

cd ./pki/

echo "Generate a certificate for admin user authentication"
{
cat > admin-csr.json << EOF
{
  "CN": "admin",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "O": "system:admins",
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
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin
}


echo "Generate a certificate for the controller-manager"
{
cat > kube-controller-manager-csr.json << EOF
{
  "CN": "system:kube-controller-manager",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "O": "system:kube-controller-manager",
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
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager
}

echo "Generate a certificate for the kube-proxy"
{
cat > kube-proxy-csr.json << EOF
{
  "CN": "system:kube-proxy",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "O": "system:node-proxier",
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
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy
}

echo "Kube Scheduler Client Certificate"
{
cat > kube-scheduler-csr.json << EOF
{
  "CN": "system:kube-scheduler",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "O": "system:kube-scheduler",
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
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler
}


echo "Generate client certificates for Kubelet on the worker nodes"
num_workers=2
for i in $(seq 1 $num_workers); do

hostname="worker-$i.lab.net"
ip=$(dig +short $hostname | tail -n1)

  {
    cat > ${hostname}-csr.json << EOF
{
  "CN": "system:node:${hostname}",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "O": "system:nodes",
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
      -hostname=${ip},${hostname} \
      -profile=kubernetes \
      ${hostname}-csr.json | cfssljson -bare ${hostname}
  }
done

chmod -R 640 *.pem *.csr
