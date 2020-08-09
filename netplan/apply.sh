#!/bin/bash

# Apply netplan
sudo netplan apply
sudo systemctl daemon-reload
