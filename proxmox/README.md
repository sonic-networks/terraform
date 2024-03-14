## First Guidance

This module uses variables defined in variables for creating VMs.
In this case the best practice is to defined a `*.auto.tfvars` file that will include all settings using `hosts` map object. Default values for that var are defined in `variables.tf` . Example tfvars file look like this

```
hosts = {
  "srv-app-xx" = {
    hostname = "srv-app-xx"
    macaddr  = "00:1E:67:01:10:01"
    ip       = "10.xx.xx.xx"
    cpu      = x
    hdd      = "xxG"
    ram      = x
    template = "debian11-generic"
  }
```

Above values can be different. It's up to you what `template`, `ip` `macaddr` or `hostname` you choose to use. 
## Second Guidance

This script uses `agent` in `connection {}` blocks

```hcl
...
  connection {
    type  = "ssh"
    host  = var.pve_ip
    agent = true
  }
...
```
which means when you look at terraform docs it describes its using keys from ssh-agent directly to connect to server. So if you not familiar what it is I encourage to know with it. 

Conclusion from above config is that without authorization against you proxmox server using private key this script will end up with `Still creating...` Why? Because SSH connections is used to put cloudinit snippets on proxmox server. So literally terraform lanunched from your computer will connect to proxmox specified in `var.pve_ip` and put prepared snippets from template into `/var/lib/vz/snippets` locations. 

## Third Guidance

In `cloud-init` directory modify the `user_data.cfg` and `network-config.cfg` according to your needs. 


## Attention 
This script works with Proxmox 7.x and Proxmox 8.x. But with the latest Proxmox version (8.x) you need to use `Telmate` provider for proxmox compiled manually not from RC version `3.0.1-rc1` as its not working with `cicustom` and removes cloudinit drive that fails the whole provisioning process.
More details can be found here at Telmate github issues [#956](https://github.com/Telmate/terraform-provider-proxmox/issues/956) and the bottom there is refference to solution [#959](https://github.com/Telmate/terraform-provider-proxmox/issues/959)

That solution requires manuall compiliation of the provider from `master` branch (not `3.0.1-rc1`). That fixed the issue with cloudinit drive that dissapear when using `cicustom`

The current provider setup is using manual compilation of the provider. If you wanna have RC version change the provider according to latest terraform [documentation](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)

```hcl
terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}
```
and use `terraform init` to download the provider.
