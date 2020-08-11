#!/bin/bash

set -ex

# Generate certificate files
./scripts/pki/certificate_authority.sh
./scripts/pki/apiserver_certificates.sh
./scripts/pki/service_account_certificates.sh
./scripts/pki/client_certificates.sh

echo "Generated Keys:"
ls -la ./pki

# Distribute certificate files to VMs
./scripts/pki/distribute_certificates.sh

# Generate and Distribute the Data Encryption key
./scripts/pki/data_encryption_key.sh
