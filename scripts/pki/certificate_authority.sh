#!/bin/bash

# A Certificate Authority can validate the authenticity of any certificate issued by it.

set -ex

cd ./pki/

echo "Generate the Certificate Authority"
{
cat > ca-config.json << EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
EOF


# A certificate signing request for the CA Certificate
cat > ca-csr.json << EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "O": "Kubernetes",
      "OU": "CA",
      "L": "St Louis",
      "ST": "Missouri",
      "C": "US"
    }
  ]
}
EOF

# Generate the CA Certificate using the CSR and CA config
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
}

chmod -R 640 *.pem *.csr
