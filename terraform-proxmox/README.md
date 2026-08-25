# terraform-proxmox

Terraform configuration for provisioning VMs on Proxmox VE by cloning a Cloud-Init template. State is stored remotely in MinIO (S3-compatible backend), so `terraform apply` runs from CI rather than a local machine.

- `main.tf` — provider config and the `proxmox_virtual_environment_vm` resource (clone, CPU/memory, network, Cloud-Init user/SSH key)
- `backend.tf` — remote state backend (MinIO)
- `deploy` — CI pipeline that installs Terraform and Ansible, applies the Terraform config, then runs the Ansible playbook against the new VM
- `copy_my_proxmox.yml` / `proxmox_clone_copy.yaml` — dynamic Proxmox inventory and follow-up Ansible provisioning for the VM Terraform creates

Credentials (`proxmox_api_token`, `ci_password`) are passed as Terraform variables from CI secrets — never hardcoded.
