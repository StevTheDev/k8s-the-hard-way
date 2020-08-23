# Put VMs in this directory

``` shell
vms
├── machines.md
├── manage.py
├── master-1
│   ├── master-1.vmx
│   └── ...
├── worker-1
│   ├── worker-1.vmx
│   └── ...
└── ...
```

## `manage.py` can be used to quickly start or stop all virtual machines in the directory.

> **Note:** The VM folders and .vmx files must share the same names

``` shell
python manage.py status
python manage.py start # [all, vm_name] (default=all)
python manage.py stop  # [all, vm_name] (default=all)
```

## Setup DNS for the lab environment

`./vms/dns` contains bind9 configuration files for hosts on the 10.0.0.0/24 subnet.

Configure as needed and place in `/etc/bind/` on the host system. Manage bind via systemd service `named`.

## Netplan documents for lab machines

`netplan` contains netplan configuration files for the host and lab machines.

Configure as needed and place in `/etc/netplan`. Apply with

```
sudo netplan apply
sudo systemctl daemon-reload
```
