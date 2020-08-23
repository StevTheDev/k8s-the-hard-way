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

`manage.py` can be used to quickly start or stop all virtual machines in the directory.

> **Note:** The VM folders and .vmx files must share the same names

``` shell
python manage.py status
python manage.py start # [all, vm_name] (default=all)
python manage.py stop  # [all, vm_name] (default=all)
```
