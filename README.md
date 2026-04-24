# 🏠 AlexM's Homelab

> Self-hosted infrastructure built and maintained as a personal learning platform alongside a career in network & telecom engineering.

---

## 📋 Table of Contents

- [Hardware](#-hardware)
- [Network Topology](#-network-topology)
- [Virtualisation Stack](#-virtualisation-stack)
- [Services](#-services)
- [Smart Home](#-smart-home)
- [Zigbee Network](#-zigbee-network)
- [VPN & Remote Access](#-vpn--remote-access)
- [Monitoring & Security](#-monitoring--security)
- [Backup Strategy](#-backup-strategy)
- [Roadmap](#-roadmap)
- [About Me](#-about-me)

---

## 🖥️ Hardware

### Workstation / Daily Driver
| Component | Spec |
|-----------|------|
| **CPU** | AMD Ryzen 7 7800X3D |
| **GPU** | AMD Radeon RX 7900 XTX (24GB VRAM) |
| **Cooling** | NZXT Kraken AIO |
| **OS** | Ubuntu 24.04 LTS |
| **Use** | Daily driver, gaming, local AI (Ollama) |

### Proxmox Server
| Component | Spec |
|-----------|------|
| **CPU** | Intel Xeon E5-2690 v3 @ 2.60GHz (24 cores) |
| **RAM** | 64 GB |
| **GPU** | Intel Arc A380 6GB — passed through to TrueNAS for Jellyfin HW transcoding |
| **NIC** | 2× 10GbE + 1× 2.5GbE |
| **Hypervisor** | Proxmox VE 8.4 |
| **Storage** | Local ZFS + TrueNAS SCALE VM (ZFS pool) |

### Network
| Device | Role |
|--------|------|
| **pfSense (VM 106)** | Router, firewall, DHCP, DNS forwarder |
| Managed switch | Internal switching |

---

## 🗺️ Network Topology

```
Internet
    │
    ▼
[ pfSense (VM 106) — Router / Firewall ]
    │
    ├──── [ Managed Switch ] ──── 10GbE / 2.5GbE uplinks
    │           │
    │     ┌─────┴───────────────────────┐
    │     │                             │
    │  [ Proxmox Host ]       [ Workstation ]
    │  Xeon E5-2690 v3          Ryzen 7800X3D
    │  64GB RAM                 RX 7900 XTX
    │  Arc A380 (passthrough)
    │     │
    │     ├── KVM Virtual Machines (see table below)
    │     └── LXC Containers (Zabbix only)
    │
    └──── [ WireGuard + Tailscale ] ◄── Remote access
```

---

## 🧱 Virtualisation Stack

**Hypervisor:** [Proxmox VE](https://www.proxmox.com/) 8.4

| VM ID | Name | Type | Role |
|-------|------|------|------|
| 100 | `haos14.0` | KVM VM | Home Assistant OS |
| 102 | `UbuntuServer` | KVM VM | Docker host — all Portainer containers |
| 103 | `truenas` | KVM VM | NAS + ZFS + TrueNAS app platform |
| 105 | `serverNET` | KVM VM | Pi-hole DNS + USB printer passthrough |
| 106 | `pfSense` | KVM VM | Router / firewall |
| 108 | `wazuh` | KVM VM | SIEM / security |
| 101 | `Zabbix` | **LXC** | Monitoring (only LXC on the host) |

---

## 🛠️ Services

### 🎬 Media Stack — TrueNAS SCALE (VM 103)

> Intel Arc A380 passed through to TrueNAS for hardware-accelerated Jellyfin transcoding.

| App | Purpose |
|-----|---------|
| **Jellyfin** | Primary media server — hardware transcoding via Arc A380 |
| **Plex** | Secondary media server |
| **Overseerr** | Media request management |
| **Sonarr** | TV show automation |
| **Radarr** | Movie automation |
| **Lidarr** | Music automation |
| **Bazarr** | Subtitle automation |
| **Prowlarr** | Indexer aggregator for *arr stack |
| **qBittorrent** | Download client |
| **Kavita** | E-book / manga library server |

### 🤖 AI Stack — TrueNAS SCALE (VM 103)

| App | Purpose |
|-----|---------|
| **Ollama** | Local LLM inference engine |
| **Open WebUI** | Chat UI frontend for Ollama |

### 🛠️ Infrastructure — TrueNAS SCALE (VM 103)

| App | Purpose |
|-----|---------|
| **Collabora** | Online document editing (Nextcloud Office) |
| **Nextcloud** | Self-hosted cloud storage & file sync |
| **MariaDB** | Database backend |
| **Netbootxyz** | Network boot / PXE server |
| **Lingarr** | Subtitle translation |
| **Qui** | Queue management UI |

---

### 🐳 Docker Containers — UbuntuServer (VM 102) via Portainer

#### 💰 Finance & Productivity
| Container | Purpose |
|-----------|---------|
| **Actual Budget** | Local-first personal finance / budgeting |
| **Homebox** | Home inventory management |
| **Gramps Web** | Genealogy / family tree |

#### 🤖 AI & Automation
| Container | Purpose |
|-----------|---------|
| **n8n** | Workflow automation (self-hosted Zapier alternative) |
| **Self-hosted AI Starter Kit** | AI pipeline stack (n8n + Qdrant + Postgres) |
| **Qdrant** | Vector database for AI/RAG workloads |
| **SearXNG** | Privacy-respecting metasearch engine |

#### 🌐 Network & Proxy
| Container | Purpose |
|-----------|---------|
| **Nginx Proxy Manager** | Reverse proxy + SSL termination |
| **Cloudflared** | Cloudflare Tunnel — secure external access |
| **nl-outage** | Netherlands outage monitoring / alerting |
| **Portainer** | Docker container management UI |

---

## 🏡 Smart Home

**Platform:** [Home Assistant OS](https://www.home-assistant.io/) — VM 100 (`haos14.0`)

### Integrations

| Integration | Purpose |
|-------------|---------|
| **Zigbee2MQTT** | Zigbee device bridge |
| **LocalTuya** | Tuya Wi-Fi devices — fully local, no cloud |
| **ESPHome** | Custom ESP-based devices |
| **WLED** | LED strip controllers |
| **LG ThinQ** | LG C1 OLED TV |
| **Roborock** | Robot vacuum |
| **Blueair** | Air purifiers (PM2.5 automation) |
| **iPhone / Android** | Presence detection |

### Key Automations

- 🌬️ **Air purifier control** — PM2.5-triggered fan speed for two Blueair P30 Silk 2.0 units. Stale sensor guard, sleep mode logic, and ionizer/UV re-enable after speed changes.
- 🏠 **Presence detection** — Multi-source: phone GPS, PC session state (`sensor.gamingpc_sessionstate`), and device trackers. Per-room `input_boolean` guards prevent false triggers.
- 🪟 **Motorized blinds** — ESPHome NodeMCU controlling a bedroom blind motor.
- 🤖 **Roborock vacuum** — Room-segment cleaning by presence and schedule.
- 💡 **Plex pause lighting** — LG C1 adjusts automatically when Plex is paused.
- 📷 **Camera & plug** — Tapo camera and plug toggle on phone presence.

---

## 📡 Zigbee Network

**Coordinator:** Sonoff ZBDongle-E (EFR32MG21 — EZSP firmware)
**Bridge:** Zigbee2MQTT

> USB autosuspend disabled via `/etc/modprobe.d/` to prevent known EZSP coordinator freezes under Linux.

| Friendly Name | Type | Location |
|---------------|------|----------|
| `LvSocket` | Smart plug | Living room |
| `AudioSystem` | Smart plug | Audio rack |
| `BedroomSocket` | Smart plug | Bedroom |
| `LvSensor` | Temp/humidity sensor | Living room |
| `KitchenSocket` | Smart plug | Kitchen |
| `KitchenSensor` | Temp/humidity sensor | Kitchen |
| `BathroomSensor` | Temp/humidity sensor | Bathroom |
| `GamingDesk` | Smart plug | Gaming desk |
| `3Dprinter` | Smart plug | 3D printer |
| `NetworkSocket` | Smart plug | Network rack |

> ⚠️ `BedroomSocket` shows persistently low LQI — suspected 2.4GHz interference.

---

## 🔐 VPN & Remote Access

| Service | How it's used |
|---------|--------------|
| **WireGuard** | Full-tunnel VPN — pfSense handles port forwarding and firewall rules |
| **Tailscale** | Zero-config mesh overlay — quick SSH and internal service access |
| **Cloudflared** | Cloudflare Tunnel — selective external exposure via Nginx Proxy Manager |

---

## 📊 Monitoring & Security

### Zabbix — VM 101 (LXC)
- Monitors all VMs and the Proxmox host
- Tracks CPU, RAM, disk I/O, and network throughput
- Alerting for service downtime and threshold breaches

### Wazuh — VM 108
- SIEM platform for log aggregation and correlation
- Vulnerability tracking across all hosts
- Security event alerting

---

## 💾 Backup Strategy

Backups are handled by **Proxmox Backup Server**, with jobs running every **Monday at 01:00**. Backup files are stored on TrueNAS via an NFS share (`backupnas`), with a separate local job for TrueNAS itself.

| Job | VMs Covered | Storage | Retention | Compression |
|-----|-------------|---------|-----------|-------------|
| **Main backup** | 100 (haos), 102 (UbuntuServer), 105 (serverNET), 108 (wazuh) | `backupnas` → TrueNAS NFS | keep-last=2 | ZSTD |
| **TrueNAS backup** | 103 (truenas) | `local` (Proxmox) | keep-last=2 | ZSTD |

**Notes:**
- All backups use **snapshot mode** — no downtime required
- pfSense (106) is excluded — configuration is exported separately via pfSense's own backup
- TrueNAS is backed up to local Proxmox storage to avoid a circular dependency (can't back up the NFS server to itself)

---

## 🗺️ Roadmap

Things I'm planning to build, break, or improve:

- [ ] **VLAN segmentation** — separate IoT, management, and trusted device networks on pfSense
- [ ] **Offsite backup** — replicate critical VM backups to a cloud target or remote location
- [ ] **CCNA home lab** — dedicated GNS3 / EVE-NG VM for Cisco switching and routing practice
- [ ] **Expand Zigbee mesh** — add more Zigbee routers to fix `BedroomSocket` LQI issues
- [ ] **Automate more with n8n** — connect Home Assistant events to n8n workflows
- [ ] **Upgrade to PBS dedicated node** — move Proxmox Backup Server to its own machine

---

## 👾 About Me

Network & Telecom Engineer by day, homelabber by night. This repo documents my self-hosted setup — built to learn, experiment, and break things in a controlled way.

---

*Living document — updated as the lab evolves.*
