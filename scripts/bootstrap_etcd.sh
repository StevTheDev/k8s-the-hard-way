#!/bin/bash

set -ex

./scripts/etcd/download_binary.sh
./scripts/etcd/systemd_service.sh
