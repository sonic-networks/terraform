## Guidance

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
