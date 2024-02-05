variable "pve_node" {
  type    = string
  default = "pve1-hw"
}
variable "pve_ip" {
  type    = string
  default = "10.0.1.1"
}
variable "pve_pool" {
  type    = string
  default = "vms"
}
variable "pve_template" {
  type    = string
  default = "debian-12-amd64-cloudinit-template"
}

variable "dns_servers" {
  type    = list(any)
  default = ["10.0.100.1", "1.1.1.1"]
}
variable "dns_search" {
  type    = list(any)
  default = ["pve.sonic", "hw.sonic", "sonic"]
}

variable "dhcp" {
  type    = string
  default = "false"
}

variable "hosts" {
  type = map(object({
    hostname = string
    cpu      = number
    ram      = number
    hdd      = string
    template = string
    macaddr  = string
    ip       = string
    bridge   = string
  }))
}
