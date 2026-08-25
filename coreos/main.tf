terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.108.0"
    }
    ct = {
      source  = "poseidon/ct"
      version = "0.14.0"
    }
  }
}

variable "proxmox_password" {
  type        = string
  sensitive   = true
  description = "Пароль от root@pam"
}

variable "vm_count" {
  default = 1
}

variable "ssh_private_key" {
  type        = string
  sensitive   = true
  description = "SSH ключ для загрузки файлов"
}

# Читаем Butane конфиг и конвертируем его в Ignition "на лету"
data "ct_config" "ignition" {
  content      = file("${path.module}/config.bu")
  strict       = true
  pretty_print = false
}

provider "proxmox" {
  endpoint  = "https://192.0.2.10:8006/"
  username  = "root@pam"
  password  = var.proxmox_password
  insecure  = true 

  ssh {
    agent       = false
    username    = "root"
    private_key = var.ssh_private_key
    
    node {
      name    = "node01"
      address = "192.0.2.10"
    }
    node {
      name    = "node02"
      address = "192.0.2.11" 
    }
    node {
      name    = "node03"
      address = "192.0.2.12"
    }
  }
}

# Загружаем распакованный .qcow2 из CI-раннера напрямую в хранилище
resource "proxmox_virtual_environment_file" "ignition_file" {
  content_type = "snippets"
  datastore_id = "cephfs"
  node_name    = "node01"

  source_raw {
    # Передаем сгенерированный Ignition-конфиг
    data      = data.ct_config.ignition.rendered
    file_name = "ignition-config.ign"
  }
}

# 3. Создаем саму виртуалку
resource "proxmox_virtual_environment_vm" "my_first_tf_vm" {
  count       = var.vm_count
  name        = "CoreOS-test-${count.index + 1}"
  description = "Copy from Terraform CoreOS"
  
  node_name   = "node02" 
  vm_id       = 501 + count.index

  bios = "ovmf"

  efi_disk {
    datastore_id = "nvme-e1"
    file_format  = "raw"
    type         = "4m"
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048
  }

  

  disk {
    datastore_id = "nvme-e1"
    interface    = "virtio0"
    size         = 20
    # Просто убедись, что тут используется динамическая ссылка:
    file_id      = "cephfs:iso/fcos2.img"
    file_format  = "raw"
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  agent {
    enabled = false
  }


  # Передаем Ignition через fw_cfg (теперь сработает, так как образ дисковый)
  kvm_arguments = "-fw_cfg name=opt/com.coreos/config,file=/mnt/pve/cephfs/snippets/ignition-config.ign"

  depends_on = [
    proxmox_virtual_environment_file.ignition_file
  ]

  started = true
}