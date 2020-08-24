#!/bin/bash

set -e

ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)

cat > ./pki/data_encryption_config.yaml << EOF
kind: EncryptionConfig
apiVersion: v1
resources:
- resources:
  - secrets
  providers:
  - aescbc:
      keys:
        - name: key1
          secret: ${ENCRYPTION_KEY}
  - identity: {}
EOF

chmod 640 ./pki/data_encryption_config.yaml


echo "Distribute the Data Encryption Key to the master nodes"
set -x
num_masters=2
for i in $(seq 1 $num_masters); do
  hostname="master-$i.lab.net"
  ssh -F ./vms/ssh.config ${hostname} "mkdir -p ~/pki"
  scp -F ./vms/ssh.config \
    ./pki/data_encryption_config.yaml \
    ${hostname}:~/pki
    
  ssh -F ./vms/ssh.config ${hostname} "chmod -R 640 ~/pki/data_encryption_config.yaml"
  ssh -F ./vms/ssh.config ${hostname} "ls -la ~/pki"
done
