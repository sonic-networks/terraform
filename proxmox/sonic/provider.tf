terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}

variable "TF_PROXMOX_API_ID" {}
variable "TF_PROXMOX_API_SECRET" {}
variable "PROXMOX_URL" {
  type    = string
  default = "https://10.0.1.1:8006/api2/json"
}

provider "proxmox" {
  pm_api_token_id     = var.TF_PROXMOX_API_ID
  pm_api_token_secret = var.TF_PROXMOX_API_SECRET
  pm_api_url          = var.PROXMOX_URL
  pm_tls_insecure     = "true"
  # pm_log_enable       = true
  # pm_log_file         = "terraform-plugin-proxmox.log"
  # pm_debug            = true
  # pm_log_levels = {
  #   _default    = "debug"
  #   _capturelog = ""
  # }
}
