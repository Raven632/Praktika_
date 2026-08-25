# coreos

Provisions a Fedora CoreOS VM on Proxmox via Terraform. CoreOS is configured declaratively through a Butane manifest, compiled to Ignition at `terraform apply` time, and passed to the VM directly (no cloud-init).

- `config.bu` — Butane config: user/SSH key, static network connection
- `main.tf` — Terraform: reads `config.bu`, converts it to Ignition via the `ct` provider, uploads it to Proxmox as a snippet, and creates the VM with it wired in via `kvm_arguments`
