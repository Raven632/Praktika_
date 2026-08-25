terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.108.0"
    }
  }
}

variable "proxmox_api_token" {
  type        = string
  sensitive   = true
  description = "API token"
}

variable "ci_password" {
  type        = string
  sensitive   = true
  description = "Cloud-init user password"
}

provider "proxmox" {
  endpoint  = "https://192.0.2.10:8006/"
  api_token = var.proxmox_api_token
  insecure  = true 
}

resource "proxmox_virtual_environment_vm" "my_first_tf_vm" {
  name        = "Authentik"
  description = "Склонировано через Terraform с Cloud-Init"
  
  node_name = "node03" 
  vm_id     = 300

  clone {
    vm_id     = 100
    node_name = "node01" 
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "nvme-e1" # Указываем твое хранилище
    interface    = "scsi0"   # Обязательно указываем интерфейс (в 99% cloud-init шаблонов это scsi0)
    size         = 20        # Желаемый размер в гигабайтах
  }

  initialization {
    # Здесь мы исправили ошибку с local-lvm
    datastore_id = "nvme-e1"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
      ipv6 {
        address = "dhcp"
      }
    }

    user_account {
      username = "root"
      password = var.ci_password
      keys     = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG2RKn22zxdVaBENrVZTFtC1CYOMWZKQmQ4r6TJBtPzq khalil@Mac-mini-von-Khalil.local"
      ]
    }
  }
  
  started = true
}

output "vm_ip_addresses" {
    description = "IP-адреса созданной виртуальной машины"
    value       = proxmox_virtual_environment_vm.my_first_tf_vm.ipv4_addresses
}

