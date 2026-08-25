# praktika — Proxmox VE Cluster & GitOps Lab

Infrastructure-as-Code setup built during my DevOps internship at **partimus GmbH** (Limburg, Germany), May–June 2026.

A 3-node Proxmox VE cluster with Ceph storage and SDN, fully provisioned through Terraform and Ansible. Every change goes through Git: a commit to the self-hosted Forgejo instance triggers a CI/CD pipeline that applies the infrastructure. Terraform state is kept remotely in MinIO (S3-compatible), and authentication is centralised through authentik.

---

## Architecture

```
                     ┌──────────────────────────┐
   git commit  ────► │  Forgejo (self-hosted)   │
                     │  CI/CD pipeline          │
                     └────────────┬─────────────┘
                                  │
                    ┌─────────────┴──────────────┐
                    ▼                            ▼
            ┌───────────────┐            ┌───────────────┐
            │   Terraform   │            │    Ansible    │
            │  (provision)  │            │  (configure)  │
            └───────┬───────┘            └───────┬───────┘
                    │                            │
                    │  state ──► MinIO (S3)      │
                    │                            │
                    ▼                            ▼
      ┌──────────────────────────────────────────────────┐
      │        Proxmox VE — 3-node HA cluster            │
      │        Ceph storage  ·  SDN  ·  PegaProx         │
      ├──────────────────────────────────────────────────┤
      │  VMs / CTs  ·  Fedora CoreOS  ·  Kubernetes      │
      │  authentik (SSO / OIDC)                          │
      └──────────────────────────────────────────────────┘
```

---

## Stack

| Layer | Tooling |
|---|---|
| Virtualisation | Proxmox VE (3-node HA cluster), Ceph, SDN, PegaProx |
| Provisioning | Terraform (Proxmox provider), Cloud-Init |
| Configuration | Ansible |
| CI/CD | Forgejo / Gitea pipelines |
| State backend | MinIO (S3-compatible), remote + versioned |
| Identity | authentik (SSO, OIDC) |
| Container hosts | Fedora CoreOS |
| Orchestration | Kubernetes — manual cluster build (Kubernetes The Hard Way) |

---

## Repository layout

| Directory | What's inside |
|---|---|
| `terraform-proxmox/` | Terraform configuration for VM and template provisioning on Proxmox, remote state in MinIO |
| `ansible-proxmox/` | The same VM provisioning done via Ansible instead of Terraform, as a hands-on comparison of the two approaches |
| `authentik/` | authentik deployment and OIDC configuration used as central identity provider |
| `coreos/` | Fedora CoreOS Ignition configs for container-optimised hosts |
| `kthw/` | Kubernetes The Hard Way — manual cluster build: etcd, kube-apiserver, kubelet, TLS certificates, CNI |
| `k8squest/` | Solutions and notes from the K8sQuest troubleshooting challenges |

---

## What I built and learned

**Cluster and storage.** Set up a 3-node Proxmox VE cluster — three nodes being the minimum for a working Ceph quorum and real HA behaviour. Configured Ceph as distributed storage and SDN for network segmentation.

**Provisioning as code.** Moved VM and template creation out of the web UI and into Terraform, with Cloud-Init handling first-boot configuration. Ansible takes over afterwards for packages, users and service configuration.

**Remote state.** Terraform state lives in MinIO rather than on a local disk — versioned, shared, and safe against the "state file only exists on my laptop" failure mode.

**GitOps workflow.** No manual `terraform apply` from a workstation. A commit to Forgejo triggers the pipeline, the pipeline applies the change, and Git history becomes the record of what the infrastructure looks like and why.

**Identity.** Deployed authentik as a central identity provider so services authenticate through one OIDC endpoint instead of separate local accounts.

**Kubernetes from scratch.** Built a cluster manually following *Kubernetes The Hard Way* — no managed distro, no bootstrapper — to understand what a Kubernetes installer normally hides: certificate chains, control plane components, and pod networking.

---

## Notes

This is a learning repository documenting internship work, not a production-ready module.
Secrets, host names and internal addresses have been removed or replaced with placeholders.

## Author

Khalil Velinov — [github.com/Raven632](https://github.com/Raven632)
