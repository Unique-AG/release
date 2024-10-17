## Troubleshoot

### `az cli not found`
The cloud-init scripts failed to provision the necessary tooling!

#### Pre-requisites
An administrator must assign you via PIM a temporary `Virtual Machine Administrator Login` on the affected VM itself (lowest scope possible). After that, restart the VM and connect via SSH.

#### Logfiles

Debugging this is needs elevated permissions on the VM as one needs to look at the cloud-init logs. The logs are located at `/var/log/cloud-init-output.log` and `/var/log/cloud-init.log`.

```
sudo apt-get -o DPkg::Lock::Timeout=300 install -y kubectl azure-cli helm

    No VM guests are running outdated hypervisor (qemu) binaries on this host.
    deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /
      % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                    Dload  Upload   Total   Spent    Left  Speed
    100  1699  100  1699    0     0  10264      0 --:--:-- --:--:-- --:--:-- 10296
    Reading package lists...
    E: Could not get lock /var/lib/apt/lists/lock. It is held by process 4047 (apt-get)
    E: Unable to lock directory /var/lib/apt/lists/
    Reading package lists...
    ...
```
One can try to run each init step manually to see what fails.
From here, a detailed guide can not be given… find what failed in the logs and try to fix it in the init scripts (if needed you need to create a new iteration of them).

#### Reprovision the VM
One possible option is to reprovision the VM. The easiest way to do so is to first taint it and then let terraform recreate it.

```bash
terraform taint "module.jumpbox.module.virtual-machine.azurerm_linux_virtual_machine.vm_linux[0]"
terraform apply
```

With less privileges and more automation, one can also delete the VM in the portal and let the automation recreate it as it will be detected as missing.