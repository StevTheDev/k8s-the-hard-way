#!/bin/bash

# This is the certificate used to sign service account tokens.

set -ex

cd ./pki/

echo "Generate certificate for service accounts"
{
cat > service-account-csr.json << EOF
{
  "CN": "service-accounts",
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
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account
}

chmod -R 640 *.pem *.csr
