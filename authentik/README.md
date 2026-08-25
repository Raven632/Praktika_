# authentik

Deploys [authentik](https://goauthentik.io/) as the cluster's central identity provider (SSO/OIDC), so other services authenticate against one endpoint instead of separate local accounts.

- `main.tf` / `backend.tf` — Terraform provisioning of the VM that hosts authentik (remote state in MinIO)
- `proxmox_clone_copy.yaml` — installs Docker, downloads the official authentik `compose.yml`, generates the `.env` secrets (Postgres password, `AUTHENTIK_SECRET_KEY`) at deploy time, and starts the stack
- `copy_my_proxmox.yml` — dynamic Proxmox inventory
- `.forgejo/workflows/deploy.yml` — CI pipeline tying the above together

Secrets are generated on the target host at deploy time (`openssl rand ...`), not committed.
