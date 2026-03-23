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
| Managed switch | Internal switching, VLANs |

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
    │     ┌─────┼───────────────────────┐
    │     │                             │
    │  [ Proxmox Host ]       [ Workstation ]
    │  Xeon E5-2690 v3          Ryzen 7800X3D
    │  64GB RAM                 RX 7900 XTX
    │  Arc A380 (passthrough)
    │     │
    │  ┌──┴──────────────────────────────────────────────┐
    │  │  VMs                                             │
    │  │  ├─ 100 haos14.0    Home Assistant OS           │
    │  │  ├─ 102 UbuntuServer  Docker host (Portainer)   │
    │  │  ├─ 103 truenas      NAS + TrueNAS apps         │
    │  │  │                   └─ Arc A380 (GPU passthru) │
    │  │  ├─ 105 serverNET    Pi-hole + USB printer      │
    │  │  ├─ 106 pfSense      Router / Firewall          │
    │  │  ├─ 108 wazuh        SIEM / Security            │
    │  │  └─ 101 Zabbix       LXC — Monitoring           │
    │  └─────────────────────────────────────────────────┘
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

### 🏠 Smart Home — Home Assistant OS (VM 100)

**Platform:** [Home Assistant OS](https://www.home-assistant.io/)

#### Integrations

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

#### Key Automations

- 🌬️ **Air purifier control** — PM2.5-triggered fan speed for two Blueair P30 Silk 2.0 units. Stale sensor guard, sleep mode logic, and ionizer/UV re-enable after speed changes.
- 🏠 **Presence detection** — Multi-source: phone GPS, PC session state (`sensor.gamingpc_sessionstate`), device trackers. Per-room `input_boolean` guards prevent false triggers.
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
| **Cloudflared** | Cloudflare Tunnel on UbuntuServer — selective external exposure via Nginx Proxy Manager |

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

## 👾 About Me

Network & Telecom Engineer by day, homelabber by night. This repo documents my self-hosted setup — built to learn, experiment, and break things in a controlled way.

- 🔧 **Day job:** Network operations (RAN + fixed broadband infrastructure)
- 📚 **Currently studying:** Cisco CCNA → CCNP → CCIE switching track
- 🛠️ **Interests:** Networking, self-hosting, smart home, local AI inference, electronics (SMD soldering, GPU repair)

---

*Living document — updated as the lab evolves.*
