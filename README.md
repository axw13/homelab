# 🏠 Homelab — Infrastructure as Code, Zero-Trust Network, Self-Hosted Everything

> A production-style homelab built to practice and demonstrate real infrastructure engineering: Infrastructure as Code, centralized secrets management, single sign-on, network segmentation, SIEM/security monitoring, and tested disaster recovery — not just "a pile of Docker containers."

The Terraform/Ansible source for this lab is kept in a private repository (it contains real network topology and is not for public sharing) — this README documents the architecture, design decisions, and the engineering practices behind it.

---

## 🧰 Skills & Technologies

**IaC / Automation:** Terraform · Ansible · Git · CI/CD
**Virtualization:** Proxmox VE · LXC · KVM/VM management
**Networking:** VLAN segmentation · Firewall/ACL design · VPN (WireGuard) · DNS · Internal PKI/ACME
**Security:** Secrets management (Vault) · SSO/OIDC · SIEM/XDR (Wazuh) · Zero-trust network design
**Observability:** Prometheus · Grafana · Loki · Alerting design · Hardware health monitoring
**Systems:** Linux administration · Time sync/NTP · DHCP/IPAM · Reverse proxying
**Other:** Backup/disaster-recovery engineering · Home automation (Home Assistant, ESPHome) · AI-assisted operations

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
- [AI-Assisted Fleet Maintenance](#-ai-assisted-fleet-maintenance)
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
   ├── Clients VLAN        — personal devices, workstations
   ├── IoT VLAN            — smart home devices, isolated from every other segment except a narrow DNS exception
   ├── VPN VLAN            — WireGuard gateway + Tailscale subnet router for remote access
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

**Authentik** provides SSO across nearly the entire service catalog, via two mechanisms depending on what each app actually supports:

- **Native OIDC** for the handful of apps that implement it themselves (git hosting, dashboards, monitoring, wiki, secrets manager UI, IPAM). Getting this working consistently surfaced real integration quirks — mismatched scope requests, apps that silently drop non-explicit `grant_types`, GraphQL mutations that delete-and-recreate config instead of patching it — all captured as reusable Ansible task patterns rather than one-off hacks.
- **Forward-auth at the reverse proxy** for everything else (media stack, automation tools, dashboards, monitoring UIs with no OIDC of their own) — the reverse proxy checks with Authentik's outpost before forwarding any request, so an app never needs to support SSO itself to get gated by it. A couple of services are deliberately left out of this (anything needing simple local-network trusted access, or already authenticating through another already-SSO'd service) rather than applying it blindly everywhere.

---

## 🌐 Network Segmentation

Nine purpose-built VLANs (management, infrastructure, applications, media, security, clients, IoT, VPN, DMZ), enforced by explicit firewall rules rather than a flat "trusted LAN." Default posture is deny-by-default between segments, with narrow, documented exceptions (e.g., the monitoring segment is allowed to scrape metrics from other segments on exactly the ports it needs, nothing else).

Key design decisions:
- The secrets manager and SSO provider live on the most restricted segment — reachable by almost nothing except what explicitly needs them.
- A dedicated VPN gateway (WireGuard) provides remote access without exposing anything else directly to the internet, alongside a second, independent VPN path (a Tailscale subnet router) for reaching the management/infrastructure segments both remotely and from a local workstation that's normally firewalled away from them.
- The one thing that *is* internet-facing (a tunnel endpoint for selective external access) sits alone in its own DMZ segment.

---

## 🔏 Internal PKI & Reverse Proxy

A private internal CA (step-ca) issues real, trusted TLS certificates to every internal service via ACME — every internal hostname gets automatic HTTPS with no self-signed-cert browser warnings, because every host in the fleet trusts the internal root CA. **Caddy** handles reverse proxying and automatic cert renewal for the whole service catalog from one place.

---

## 📊 Monitoring, Logging & SIEM

- **Prometheus + Grafana** — full-fleet metrics, including the hypervisor itself, with a single "fleet overview" dashboard and per-host drill-down.
- **Loki** — centralized log aggregation.
- **Wazuh** — SIEM/XDR with an agent on every single host in the fleet (management host included), giving full security-event visibility and vulnerability tracking across the whole environment, not just the "important" servers.
- **Hardware health, not just service health** — SMART data from the hypervisor's physical disks and pool/array health from the NAS (which has no shell access at all — pulled via its management API instead) both feed the same Grafana instance, with multi-stage alert rules (raw metric → reduced value → threshold) so a slowly-degrading disk pages someone the same way a crashed container would.

---

## 🤖 AI-Assisted Fleet Maintenance

Three headless AI agents run on a schedule against the live monitoring stack (metrics, logs, uptime checks, SIEM) with real but tightly bounded authority — no human approves each individual action, but a strict tiered policy defines exactly what "safely fixable" means:

- **Auto-fixable** (restart a crashed service, clear known-safe disk space) — just done, verified, logged.
- **Reversible-with-care** (a config change) — snapshot first, apply, verify, roll back automatically if verification fails.
- **Detect-only, never act** — an explicit, non-negotiable list (the secrets manager, any firewall change, storage-pool mutations, anything destructive) that always gets reported to a human instead of touched.

A fast, narrow daytime pass (metrics/uptime/SIEM/smart-home device health only) runs a couple of times a day; a deeper nightly pass has the full toolset and a longer window. A third agent handles patching on its own dedicated nights — it refuses to touch anything until it's confirmed the fleet is actually healthy first, applies a capped, prioritized batch rather than everything at once, and queues the rest for its next scheduled run instead of rushing. The two "check fleet health" agents and the "apply updates" agent are mutually exclusive by design — patch nights are handled deterministically, not by racing for a lock, so it's always predictable which one runs when. All of them report a single, clear summary over chat when done — not a wall of green checkmarks, and never silent about something still unresolved from a prior run.

Unresolved findings are tracked as real issues in the self-hosted Git server rather than only ever existing as chat scrollback — each agent has its own dedicated account (so authorship is real, not a shared generic identity), searches for an existing issue before opening a duplicate, and follows a deliberate closing rule: an apparent fix gets flagged and watched for a few days before the issue is actually closed, not closed the moment it first looks resolved (a fix that regresses a day later resets the clock rather than silently reopening something already marked done). Agents can also hand an issue to a different agent when its schedule or capabilities fit the follow-up better, and — when an agent hits a genuine decision only a human should make — it opens a self-assigned question and waits for a reply in that same thread, rather than blocking silently or guessing.

---

## 💾 Backup & Disaster Recovery

The backup strategy deliberately does **not** back up everything — infrastructure that Terraform/Ansible can faithfully recreate isn't backed up at all; only genuine, non-recreatable *data* is (secrets manager contents, internal CA keys, application databases, git repositories, workflow/automation state, smart-home configuration).

- **restic**, encrypting client-side before anything leaves the network, deduplicating across runs, with a daily/weekly/monthly retention policy.
- A second, independent encryption layer (age) on top of the single highest-value bundle (secrets manager + CA keys) — so a compromised backup-tool password alone still isn't enough to read the most sensitive material.
- Offsite target, reached via `rclone`, kept separate from on-site NAS backups.
- A **fully written, dry-run-tested disaster recovery runbook** — not just "we have backups," but a step-by-step procedure that assumes the reader has zero prior context, was actually exercised (including catching and documenting a couple of genuine gotchas around stale locks and orphaned backup data along the way).
- A second, complementary **local snapshot backup** (VM/container disk images, not just data) direct to on-site NAS storage — fast local recovery for the common case, kept separate from and secondary to the offsite pipeline above, deliberately excluding workloads that already source their data from the same NAS to avoid a pointless backup-to-itself loop.

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
| **Productivity** | Workflow automation, home inventory tracker, unified service dashboard, recipe manager, Discord bot integrations |

---

## 🏡 Smart Home

Home Assistant integrates a mix of local-only (ESPHome, Zigbee2MQTT, WLED) and cloud-dependent (a couple of manufacturer ecosystems that don't offer a local API) devices. Automations include presence-based lighting, TV-power-synced ambient lighting, air-quality-triggered purifier control, and a DIY ESPHome-based motorized blind controller with full position calibration and power-loss recovery (see `esphome/blinds-bedroom` in this repo).

---

## 💡 Engineering Highlights / War Stories

A few real incidents this lab has actually hit and resolved — the parts that don't show up in a features list but are the actual substance of running real infrastructure:

- **Diagnosed and recovered from a multi-day, multi-drive NAS pool failure cascade** — several genuinely bad drives, one case of a failing drive's bus noise disrupting its healthy neighbor on a shared expander channel (which looked exactly like a second failure until isolated by pulling the actual bad drive and confirming the neighbor's symptoms cleared), and a final severe pool suspend that corrupted several VM/container disk images simultaneously and spiked hypervisor load into the triple digits (every process wedged in uninterruptible I/O wait on the suspended storage mount). Rebuilt the pool from scratch with a deliberate size-for-reliability tradeoff rather than reconstructing the original higher-capacity layout, and migrated the highest-I/O workloads off shared NAS storage entirely onto local SSD instead — removing the failure mode rather than just patching around it.
- **Recovered from a real management-network outage** caused by a switch VLAN reassignment mid-migration, diagnosed methodically (bond state → physical link state → full ARP-table cross-reference across every VLAN) rather than assuming and reflashing/rebooting things.
- **Root-caused a cascading "everything is offline" incident** after a power outage down to a single root cause (most local-network integrations store a static IP and never notice a DHCP lease changed) that had silently broken a dozen unrelated integrations at once, then fixed the actual cause once instead of patching each symptom individually.
- **Wrote and dry-run tested a full disaster recovery procedure**, catching real gotchas (a stale process lock, orphaned backup data left by an interrupted run) that only show up when you actually try the restore instead of trusting the backup exists.
- **Chased a "fleet-wide NTP config" change that silently did nothing** — every container reported the change applied successfully, but nothing was actually happening under the hood. Root cause: unprivileged Linux containers share their host's kernel clock and cannot run their own time-sync client at all (the service refuses to even start in a container, and the container has no permission to adjust a clock regardless). The actual fix was pointing the *hypervisor's* own clock at the new internal time server — every container inherits it for free. A good reminder that "the task reported success" and "the task did something real" are two different claims, especially for anything kernel-level.
- **Designed the automated patching workflow to respect IaC as the actual source of truth**, not just the running fleet. Most services here don't pin a specific version in their Ansible config, so patching them live and re-running the role later produces the same result either way — no drift. But a few do pin an exact version tag; patching *those* live without also updating the pinned value in code (and committing it) would create silent infrastructure drift — a future rebuild would quietly redeploy the old version, undoing the patch. The automation checks which case applies before deciding how to apply an update, rather than treating "patch everything the same way" as good enough.
- **Rolled out forward-auth to over a dozen services and hit a silently-wrong API filter along the way** — one endpoint accepted a filter parameter that looked identical to one on a sibling endpoint, but silently ignored it and returned the whole unfiltered list instead of erroring. The first service provisioned fine; every service after it then "found" that first one's config and quietly reused it instead of creating its own — surfacing only as a confusing, unrelated-looking conflict error several steps later. Fixed by switching to the parameter that actually filters, and by treating the earlier vague error as a symptom to trace back, not something to just retry past.
- **Found and fixed a masked automation bug**: a role that writes a generated credential into the secrets manager was missing a "run this from the controller, not the target host" directive that every equivalent role elsewhere had — invisible on first glance because an earlier, unrelated check step in the same role had a permissive error-tolerance flag that silently absorbed the same underlying connectivity failure and reported success. The real failure only surfaced later, on a step without that tolerance. A reminder that a deliberately lenient error handler on one step can mask a real problem that only shows up downstream.
- **Diagnosed a third-party Docker image with a broken dependency tree** (two conflicting versions of the same internal library installed simultaneously) that caused a clean-looking startup — successful login, successful registration with its upstream API — followed by a crash loop on an internal null-reference error. Verified the root cause with a targeted debug patch rather than guessing, confirmed it wasn't a permissions issue via a raw API call bypassing the client library entirely, then built a corrected image from source with the dependency tree pinned to a single consistent version.
- **Migrated the entire smart-home device fleet onto its own dedicated IoT VLAN**, off the general clients segment — a dozen-plus devices across five different local/cloud protocols (WLED, ESPHome, local Tuya, cloud Tuya, a manufacturer camera app), each with a different migration path. The trickiest recurring gotcha: several local-protocol devices issued a **new authentication key** from the vendor's cloud the moment they rejoined the new network — the same physical device, same account, same everything, but the previously-stored local credential silently stopped authenticating anyway. Traced one particularly stubborn case (a locked-down cloud account with no in-app way to view the device's key) through a chain of dead ends — a developer cloud API blocked by an unexplained subscription-entitlement error on two separately created projects, a MITM-based extraction approach blocked by the same network segmentation this migration was implementing — before finding that the vendor's own web console had a session-authenticated API explorer that bypassed the entitlement gate entirely, since it doesn't rely on the same developer-credential path.
- **Chased an intermittent "invalid auth" on a freshly-migrated camera integration** that turned out to have nothing to do with credentials at all — a device-level "third-party API compatibility" toggle had been silently reset to off during the same network rejoin, a separate setting from the account/device password entirely. A reminder that "authentication failed" doesn't always mean the credentials are wrong.
- **Stood up a WireGuard remote-access peer and hit a networking gap that had never been exercised**: the gateway's outbound NAT rule for tunnel-peer traffic didn't exist at all — traffic left the tunnel fine, but the router had no route back to an individual peer's tunnel address (only the gateway host's own address was a known route on that segment), so every reply silently vanished, DNS included. Root-caused with a live packet capture on the gateway's own interface during a real connection attempt, which conclusively separated "traffic never arrives" (a port-forward/NAT problem upstream) from "traffic arrives but routes nowhere" (this bug) — two failure modes that look identical from the client side but need completely different fixes.
- **Added a second, independent VPN path (a subnet router) for reaching the management/infrastructure segments**, both remotely and from a local workstation that's normally firewalled away from them — deliberately alongside the existing gateway rather than replacing it. Assumed it would need the identical manual NAT fix as the WireGuard case above and checked before adding it: this tool manages its own return-routing automatically the moment subnet routing is enabled, no manual rule required — a good reminder that two conceptually similar VPN tools can differ completely in what they handle for you versus what you have to do by hand, and that's worth verifying rather than assuming from precedent. Confirmed the whole thing actually worked with a real differential test rather than a superficial one: an unrelated segment already had a broad "allow everything else" rule that made a naive reachability test pass regardless of whether the VPN was even connected, so the real proof came from testing against a *different* segment with an explicit, narrow block rule instead — same request, failed with the VPN off, succeeded immediately with it on.

---

## 🗺️ Roadmap

- [ ] Second offsite backup destination for extra redundancy
- [ ] Expand SSO coverage to the last few services still using local auth
- [ ] Formal quarterly disaster-recovery re-test

---

## 👾 About Me

Network & Telecom Engineer by day, homelabber by night. This lab exists to practice the same engineering discipline in a home environment that I'd want to see in a production one — infrastructure as code, least-privilege network design, centralized secrets, and backups that are actually tested, not just assumed to work.

---

*Living document — updated as the lab evolves.*
