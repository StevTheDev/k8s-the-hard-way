import subprocess
from pathlib import Path

import fire

class Manager(object):
    """Use vmrun to start, stop and list unning VMs
    
    Options:
      --base-dir (string) The base directory for VMs (default=~/k8s-the-hard-way/vms)
      --gui (boolean) Start VMs with GUI Enabled (default=False)

    python manage.py status
    python manage.py start [all, vm_name] (default=all)
    python manage.py stop  [all, vm_name] (default=all)
    """
    def __init__(self, base_dir=Path.home()/"k8s-the-hard-way"/"vms", gui=False):
        self.directory = base_dir
        self.gui = gui

    def _find_vms(self, vm):
        def resolve_path(vm):
            location = self.directory/f"{vm}"
            if location.is_dir():
                file = location/f"{vm}.vmx"
                if file.is_file():
                    return file
                else:
                    print(f"{vm} vmx ({file}) not found")
                    return False
            else:
                print(f"{vm} directory ({location}) not found")
                return False

        if vm == "all":
            return [resolve_path(i.name) for i in self.directory.iterdir() if i.is_dir()]
        else:
            return [resolve_path(vm)]
        
    def _call_vmrun(self, action, vm="", gui=""):
        command = f"vmrun {action} {vm} {gui}".split(" ")
        subprocess.run(command)

    def status(self):
        """List running VMs"""
        self._call_vmrun("list")

    def start(self, vm="all"):
        """Start a VM or directory of VMs"""
        
        gui = "nogui" if not self.gui else ""
        for machine in self._find_vms(vm):
            if machine:
                print(f"starting {machine} {gui}")
                self._call_vmrun("start", machine, gui)

    def stop(self, vm="all"):
        """Stop a VM or directory of VMs"""
        for machine in self._find_vms(vm):
            if machine:
                print(f"stopping {machine}")
                self._call_vmrun("stop", machine)       


if __name__ == '__main__':
    fire.Fire(Manager)




