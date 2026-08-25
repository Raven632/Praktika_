# ansible-proxmox

Provisions and configures a Proxmox VM entirely through Ansible, as a comparison to the Terraform-based flow in [`terraform-proxmox`](../terraform-proxmox) — same end result (a running VM with Docker/Nginx), different tool.

- `proxmox_clone_copy.yaml` — clones a VM from a Cloud-Init template, waits for boot, then deploys a Docker Nginx container on it
- `copy_my_proxmox.yml` — dynamic Proxmox inventory plugin config
- `inventory.yml` — static inventory used by the base playbooks
- `autoupdate.yaml` / `docker_nginx.yaml` — base configuration playbooks (package updates, Docker/Nginx)
- `deploy` — CI pipeline that runs the playbooks against Proxmox

Proxmox credentials are read from environment variables (`PROXMOX_HOST`/`PROXMOX_USER`/`PROXMOX_PASSWORD`), injected from CI secrets — never hardcoded.
