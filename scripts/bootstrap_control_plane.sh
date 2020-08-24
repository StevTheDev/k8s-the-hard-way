#!/bin/bash

set -ex

./scripts/control-plane/download_binaries.sh
./scripts/control-plane/setup_apiserver.sh
./scripts/control-plane/setup_controller_manager.sh
./scripts/control-plane/setup_scheduler.sh

./scripts/control-plane/start_services.sh

./scripts/control-plane/health_check_responder.sh
