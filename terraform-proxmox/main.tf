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

variable "vm_count" {
  type = number
  description = "How much vm?"
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
  count       = var.vm_count
  name        = "docker-node02-test${count.index + 1}"
  description = "Склонировано через Terraform с Cloud-Init"
  
  node_name = "node02" 
  vm_id     = 201 + count.index

  clone {
    vm_id     = 100
    node_name = "node01" 
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr0"
  }

  initialization {
    # Здесь мы исправили ошибку с local-lvm
    datastore_id = "nvme-e1"

    ip_config {
      ipv4 {
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
    value       = proxmox_virtual_environment_vm.my_first_tf_vm[*].ipv4_addresses
}

