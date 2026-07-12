# 🏠 Homelab — Infrastructure as Code, Zero-Trust Network, Self-Hosted Everything

> A production-style homelab built to practice and demonstrate real infrastructure engineering: Infrastructure as Code, centralized secrets management, single sign-on, network segmentation, SIEM/security monitoring, and tested disaster recovery — not just "a pile of Docker containers."

The Terraform/Ansible source for this lab is kept in a private repository (it contains real network topology and is not for public sharing) — this README documents the architecture, design decisions, and the engineering practices behind it.

---

## 📋 Table of Contents

- [Philosophy](#-philosophy)
- [Architecture Overview](#-architecture-overview)
- [Infrastructure as Code](#-infrastructure-as-code)
- [Secrets Management](#-secrets-management)
- [Single Sign-On](#-single-sign-on)
- [Network Segmentation](#-network-segmentation)
- [Internal PKI & Reverse Proxy](#-internal-pki--reverse-proxy)
- [Monitoring, Logging & SIEM](#-monitoring-logging--siem)
- [Backup & Disaster Recovery](#-backup--disaster-recovery)
- [Services Catalog](#-services-catalog)
- [Smart Home](#-smart-home)
- [Engineering Highlights / War Stories](#-engineering-highlights--war-stories)
- [Roadmap](#-roadmap)
- [About Me](#-about-me)

---

## 🎯 Philosophy

Every service here is deployed the same, repeatable way — nothing is hand-clicked into existence. The goals driving every design decision:

- **Everything is code.** New services get a Terraform LXC definition + an Ansible role, not a manual container spin-up.
- **Nothing is a shared secret sitting in a config file.** Every credential is generated on first deploy and lives in a central secrets manager, never hardcoded, never committed.
- **One identity, everywhere.** A single SSO login federates into every service that supports it, instead of a different password per app.
- **The network enforces the trust model, not just the apps.** VLANs + firewall rules mean a compromised IoT device physically cannot reach the secrets manager, even if every app-level auth check somehow failed.
- **If it can't be restored from nothing, it's not actually backed up.** The disaster recovery procedure has been written and dry-run tested end-to-end, not just assumed to work.

---

## 🗺️ Architecture Overview

```
Internet
   │
   ▼
[ Firewall / Router — VLAN-aware, stateful rules per segment ]
   │
   ├── Management VLAN     — bastion host, IaC tooling, admin access only
   ├── Infrastructure VLAN — reverse proxy, DNS, internal CA, CI/CD, databases
   ├── Application VLAN    — automation, dashboards, home inventory, smart home
   ├── Media VLAN          — media server + media automation stack
   ├── Security VLAN       — secrets manager, SSO, SIEM (most tightly firewalled segment)
   ├── Clients VLAN        — personal devices, workstations, IoT (until its own VLAN is finished)
   ├── VPN VLAN            — dedicated WireGuard gateway for remote access
   └── DMZ VLAN            — the one thing exposed toward the internet (tunnel endpoint)

Cross-VLAN traffic is default-deny; every exception is an explicit, documented pass rule.
```

**Hypervisor:** Proxmox VE, single physical host, LXC-first (containers for every Linux service; a couple of true VMs only where required — router/firewall, smart-home OS, NAS).

**Storage:** A dedicated NAS VM running ZFS in RAIDZ2, serving both media storage and NFS-backed storage for some containers' root disks.

---

## 🧱 Infrastructure as Code

- **Terraform** (`bpg/proxmox` provider) drives every LXC's existence — a single JSON file defines each container's VLAN, IP, resources, and storage backend; a `for_each` loop turns that into real infrastructure. Adding a new service is: add one JSON entry, write one Ansible role, `terraform apply`.
- **Terraform state** is stored in Postgres (not local files), so infrastructure changes are safe even with the tooling itself running from a container that could be rebuilt.
- **Ansible** owns everything past "the container exists" — package installs, service config, reverse-proxy site blocks, DNS records, and the secrets-generation dance described below. Roles follow a strict idempotent pattern: check if a secret exists first, generate only if missing, never regenerate and break an existing integration.

---

## 🔑 Secrets Management

**HashiCorp Vault** is the single source of truth for every credential in the lab. The pattern used everywhere:

1. Ansible checks Vault for an existing secret at a known path.
2. If found, reuse it (idempotent — re-running a playbook never rotates a working credential out from under a live integration).
3. If not found, generate a fresh random one, write it to Vault, and use it.

This means: no password is ever typed into a YAML file, no API key lives in `docker-compose.yml`, and a full credential audit is one `vault kv list` away.

Vault itself is backed up via its integrated Raft snapshot mechanism — restoring it correctly (and understanding *why* the original unseal keys, not new ones, are required after a restore) is documented as its own disaster-recovery runbook.

---

## 🔐 Single Sign-On

**Authentik** provides OIDC-based SSO across the services that support it (git hosting, dashboards, monitoring, wiki, secrets manager UI, IPAM, and more). Getting this working consistently across a dozen different apps' OIDC implementations surfaced a lot of real integration quirks — mismatched scope requests, apps that silently drop non-explicit `grant_types`, GraphQL mutations that delete-and-recreate config instead of patching it — all captured as reusable Ansible task patterns rather than one-off hacks.

---

## 🌐 Network Segmentation

Nine purpose-built VLANs (management, infrastructure, applications, media, security, clients, IoT, VPN, DMZ), enforced by explicit firewall rules rather than a flat "trusted LAN." Default posture is deny-by-default between segments, with narrow, documented exceptions (e.g., the monitoring segment is allowed to scrape metrics from other segments on exactly the ports it needs, nothing else).

Key design decisions:
- The secrets manager and SSO provider live on the most restricted segment — reachable by almost nothing except what explicitly needs them.
- A dedicated VPN gateway (WireGuard) provides remote access without exposing anything else directly to the internet.
- The one thing that *is* internet-facing (a tunnel endpoint for selective external access) sits alone in its own DMZ segment.

---

## 🔏 Internal PKI & Reverse Proxy

A private internal CA (step-ca) issues real, trusted TLS certificates to every internal service via ACME — every internal hostname gets automatic HTTPS with no self-signed-cert browser warnings, because every host in the fleet trusts the internal root CA. **Caddy** handles reverse proxying and automatic cert renewal for the whole service catalog from one place.

---

## 📊 Monitoring, Logging & SIEM

- **Prometheus + Grafana** — full-fleet metrics, including the hypervisor itself, with a single "fleet overview" dashboard and per-host drill-down.
- **Loki** — centralized log aggregation.
- **Wazuh** — SIEM/XDR with an agent on every single host in the fleet (management host included), giving full security-event visibility and vulnerability tracking across the whole environment, not just the "important" servers.

---

## 💾 Backup & Disaster Recovery

The backup strategy deliberately does **not** back up everything — infrastructure that Terraform/Ansible can faithfully recreate isn't backed up at all; only genuine, non-recreatable *data* is (secrets manager contents, internal CA keys, application databases, git repositories, workflow/automation state, smart-home configuration).

- **restic**, encrypting client-side before anything leaves the network, deduplicating across runs, with a daily/weekly/monthly retention policy.
- A second, independent encryption layer (age) on top of the single highest-value bundle (secrets manager + CA keys) — so a compromised backup-tool password alone still isn't enough to read the most sensitive material.
- Offsite target, reached via `rclone`, kept separate from on-site NAS backups.
- A **fully written, dry-run-tested disaster recovery runbook** — not just "we have backups," but a step-by-step procedure that assumes the reader has zero prior context, was actually exercised (including catching and documenting a couple of genuine gotchas around stale locks and orphaned backup data along the way).

---

## 🛠️ Services Catalog

| Category | Services |
|---|---|
| **Identity & Secrets** | Vault, Authentik |
| **Networking** | Internal CA (step-ca), reverse proxy (Caddy), DNS/ad-blocking (Pi-hole), WireGuard VPN |
| **CI/CD & Source Control** | Self-hosted Git, CI server |
| **Observability** | Prometheus, Grafana, Loki, Wazuh SIEM |
| **IPAM/DCIM** | NetBox |
| **Documentation** | Self-hosted wiki |
| **Media** | Media server (hardware-accelerated transcoding), automated media management/acquisition stack, subtitle automation with multi-provider + multi-language support |
| **Home Automation** | Home Assistant, WLED, ESPHome, Zigbee2MQTT, various local + cloud device integrations |
| **Productivity** | Workflow automation, home inventory tracker, unified service dashboard, recipe manager |

---

## 🏡 Smart Home

Home Assistant integrates a mix of local-only (ESPHome, Zigbee2MQTT, WLED) and cloud-dependent (a couple of manufacturer ecosystems that don't offer a local API) devices. Automations include presence-based lighting, TV-power-synced ambient lighting, air-quality-triggered purifier control, and a DIY ESPHome-based motorized blind controller with full position calibration and power-loss recovery (see `esphome/blinds-bedroom` in this repo).

---

## 💡 Engineering Highlights / War Stories

A few real incidents this lab has actually hit and resolved — the parts that don't show up in a features list but are the actual substance of running real infrastructure:

- **Diagnosed a NAS pool going into a suspended state** during a live incident, correctly distinguishing a genuine failing-drive problem from an HBA/cable-level fault by cross-referencing kernel SAS-port-flap logs against the pool's own fault reporting — rather than guessing and replacing hardware blindly.
- **Recovered from a real management-network outage** caused by a switch VLAN reassignment mid-migration, diagnosed methodically (bond state → physical link state → full ARP-table cross-reference across every VLAN) rather than assuming and reflashing/rebooting things.
- **Root-caused a cascading "everything is offline" incident** after a power outage down to a single root cause (most local-network integrations store a static IP and never notice a DHCP lease changed) that had silently broken a dozen unrelated integrations at once, then fixed the actual cause once instead of patching each symptom individually.
- **Wrote and dry-run tested a full disaster recovery procedure**, catching real gotchas (a stale process lock, orphaned backup data left by an interrupted run) that only show up when you actually try the restore instead of trusting the backup exists.

---

## 🗺️ Roadmap

- [ ] Finish dedicated IoT VLAN (currently IoT devices share the general clients segment as an interim measure)
- [ ] Second offsite backup destination for extra redundancy
- [ ] Expand SSO coverage to the last few services still using local auth
- [ ] Formal quarterly disaster-recovery re-test

---

## 👾 About Me

Network & Telecom Engineer by day, homelabber by night. This lab exists to practice the same engineering discipline in a home environment that I'd want to see in a production one — infrastructure as code, least-privilege network design, centralized secrets, and backups that are actually tested, not just assumed to work.

---

*Living document — updated as the lab evolves.*
