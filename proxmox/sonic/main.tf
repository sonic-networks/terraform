resource "proxmox_vm_qemu" "cloudinit" {
  depends_on  = [null_resource.cloud_init_config_files]
  for_each    = var.hosts
  target_node = var.pve_node
  name        = each.value.hostname
  clone       = each.value.template
  memory      = each.value.ram * 1024
  cores       = each.value.cpu
  os_type     = "cloud-init"
  sockets     = 1
  scsihw      = "virtio-scsi-pci"
  agent       = 1
  disks {
    scsi {
      scsi0 {
        disk {
          size       = each.value.hdd
          storage    = var.pve_pool
          emulatessd = true
        }
      }
    }
  }
  network {
    macaddr = each.value.macaddr
    model   = "virtio"
    bridge  = each.value.bridge
  }
  # ipconfig0 = "ip=${each.value.ip}/24,gw=${join(".", slice(split(".", each.value.ip), 0, 3))}.254"
  # nameserver              = "10.0.1.30 1.1.1.1"
  # searchdomain            = "${var.pve_node}.sonic hw.sonic"
  cicustom                = "user=local:snippets/user-data_vm-${each.key}.yaml,network=local:snippets/network-config_vm-${each.key}.yaml"
  cloudinit_cdrom_storage = "local"
}

data "template_file" "user_data" {
  for_each = var.hosts
  template = file("${path.module}/../cloud-init/user_data.cfg")
  vars = {
    hostname = each.value.hostname
    fqdn     = "${each.value.hostname}.sonic.net.pl"
  }
}

data "template_file" "network-config" {
  for_each = var.hosts
  template = file("${path.module}/../cloud-init/network-config.cfg")
  vars = {
    dns_search  = jsonencode(var.dns_search)
    dns_servers = jsonencode(var.dns_servers)
    dhcp        = var.dhcp
    ip_address  = "${each.value.ip}/24"
    gateway     = "${join(".", slice(split(".", each.value.ip), 0, 3))}.254"
    hostname    = each.value.hostname
  }
}
locals {
  vm_user_data      = values(data.template_file.user_data)
  vm_network-config = values(data.template_file.network-config)
  hosts             = values(var.hosts)
}

resource "local_file" "cloud_init_user_data_file" {
  count    = length(local.vm_user_data)
  content  = local.vm_user_data[count.index].rendered
  filename = "${path.module}/../cloud-init/user_data_${local.hosts[count.index].hostname}.cfg"
}

resource "local_file" "cloud_init_network-config_file" {
  count    = length(local.vm_network-config)
  content  = local.vm_network-config[count.index].rendered
  filename = "${path.module}/../cloud-init/network-config_${local.hosts[count.index].hostname}.cfg"
}
resource "null_resource" "cloud_init_config_files" {
  count = length(local_file.cloud_init_user_data_file)
  connection {
    type  = "ssh"
    host  = var.pve_ip
    agent = true
  }
  provisioner "file" {
    source      = local_file.cloud_init_user_data_file[count.index].filename
    destination = "/var/lib/vz/snippets/user-data_vm-${local.hosts[count.index].hostname}.yaml"
  }
}
resource "null_resource" "cloud_init_network-config_files" {
  count = length(local_file.cloud_init_network-config_file)
  connection {
    type  = "ssh"
    host  = var.pve_ip
    agent = true
  }
  provisioner "file" {
    source      = local_file.cloud_init_network-config_file[count.index].filename
    destination = "/var/lib/vz/snippets/network-config_vm-${local.hosts[count.index].hostname}.yaml"
  }
}
# output "debug" {
# value = data.template_file.user_data
# value = local_file.cloud_init_user_data_file
# value = local.vm_user_data
# value = local.vm_user_data2
# value = local.vm_hostname
# value = null_resource.cloud_init_config_files
# value = proxmox_vm_qemu.cloudinit
# }
