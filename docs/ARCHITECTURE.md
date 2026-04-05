# Lab Architecture

This document describes the network design and infrastructure of the SOC Detection Lab.

---

## Overview

The lab is built on a **Proxmox VE** bare-metal hypervisor running on a physical server (Lenovo ThinkPad T430). All virtual machines are isolated into separate virtual networks managed by pfSense.

---

## Network Diagram

```
                        ┌──────────────────────────────────────┐
                        │         Proxmox VE Host              │
                        │                                      │
  [Home Router/WAN]─────┤ vmbr0 (Management/WAN)              │
                        │     │                                │
                        │  ┌──▼────────────────┐              │
                        │  │     pfSense        │              │
                        │  │  Firewall/Router   │              │
                        │  └──┬────────────┬───┘              │
                        │     │            │                   │
                        │  vmbr1        vmbr2                  │
                        │  (Attacker)   (Victim)               │
                        │     │            │                   │
                        │  ┌──▼──┐      ┌──▼──────────────┐   │
                        │  │Kali │      │  Windows 10     │   │
                        │  │Linux│      │  Windows 11     │   │
                        │  ├─────┤      │  Win Server 2022│   │
                        │  │Parr-│      │  Kioptrix       │   │
                        │  │ot OS│      └─────────────────┘   │
                        │  └─────┘                            │
                        │                                      │
                        │  ┌─────────────────────────────┐    │
                        │  │      Security Onion          │    │
                        │  │  (promiscuous on vmbr1+vmbr2)│   │
                        │  │  Suricata IDS + Zeek NSM     │    │
                        │  └─────────────────────────────┘    │
                        └──────────────────────────────────────┘
```

---

## Components

### Proxmox VE (Virtualization Host)

| Property | Value |
|---|---|
| Role | Bare-metal hypervisor |
| Hardware | Lenovo ThinkPad T430 |
| Network bridges | vmbr0, vmbr1, vmbr2 |
| Remote access | Tailscale |

Proxmox manages all VMs and provides network bridging between virtual networks. The QEMU guest agent is installed on all VMs for improved integration.

---

### pfSense Firewall

| Property | Value |
|---|---|
| Role | Firewall, router, NAT gateway |
| WAN interface | vmbr0 (home network) |
| LAN interface | vmbr1 (attacker network: 10.10.10.0/24) |
| OPT1 interface | vmbr2 (victim network: 192.168.100.0/24) |
| RAM | 2 GB |
| Storage | 20 GB |

pfSense controls all traffic between the attacker network, victim network, and the internet. It enforces firewall rules to prevent lab traffic from leaking to the home network.

---

### Security Onion (SIEM / NSM)

| Property | Value |
|---|---|
| Role | IDS, NSM, SIEM, packet capture |
| Mode | Standalone (Eval) |
| RAM | 12–16 GB |
| Storage | 200 GB |
| Monitoring | vmbr1 (attacker) + vmbr2 (victim) via promiscuous NIC |

Security Onion provides:
- **Suricata** — signature-based IDS/IPS
- **Zeek** — network metadata and protocol analysis
- **Kibana / SOC Dashboards** — log visualization and hunting
- **PCAP** — full packet capture and replay

---

### Attacker Network (vmbr1 — 10.10.10.0/24)

| VM | OS | Purpose |
|---|---|---|
| Kali Linux | Kali Linux 2024.x | Primary attack platform |
| Parrot OS | Parrot Security | Secondary attack platform |

These VMs simulate the adversary. They have internet access via pfSense for downloading payloads and C2 tooling (controlled and time-limited).

---

### Victim Network (vmbr2 — 192.168.100.0/24)

| VM | OS | Purpose |
|---|---|---|
| Windows 10 | Windows 10 Pro | Workstation target |
| Windows 11 | Windows 11 Pro | Workstation target |
| Windows Server 2022 | Windows Server 2022 | Domain controller / server target |
| Kioptrix | Kioptrix Level 1 | Vulnerable Linux target (CTF-style) |

All Windows VMs have **Sysmon** installed with the SwiftOnSecurity configuration. Windows event logs are forwarded to Security Onion.

---

## Traffic Flow

### Attack Simulation Flow

```
Kali Linux (vmbr1)
    │
    ▼  [pfSense allows attacker → victim]
Windows 10 (vmbr2)
    │
    ▼  [Sysmon captures endpoint events]
Security Onion
    │
    ▼  [Suricata/Zeek analyze network traffic]
SOC Dashboards / Alerts
```

### Log Collection Flow

```
Windows VMs
  └── Sysmon → Windows Event Log
                   └── WinLogBeat / Elastic Agent → Security Onion

Network Traffic
  └── Security Onion NIC (promiscuous)
        ├── Zeek → Connection logs, DNS, HTTP, SSL metadata
        └── Suricata → Signature-based alerts
```

---

## IP Addressing

| Subnet | Range | Gateway |
|---|---|---|
| Management (vmbr0) | DHCP from home router | Home router |
| Attacker (vmbr1) | 10.10.10.0/24 | 10.10.10.1 (pfSense) |
| Victim (vmbr2) | 192.168.100.0/24 | 192.168.100.1 (pfSense) |

| Host | IP Address |
|---|---|
| pfSense (LAN) | 10.10.10.1 |
| pfSense (OPT1) | 192.168.100.1 |
| Security Onion | 192.168.100.10 |
| Kali Linux | 10.10.10.100 (DHCP) |
| Windows 10 | 192.168.100.20 (DHCP) |
| Windows 11 | 192.168.100.21 (DHCP) |
| Windows Server 2022 | 192.168.100.22 (static) |

---

## Security Controls

| Control | Implementation |
|---|---|
| Network segmentation | pfSense VLANs / separate bridges |
| Firewall rules | pfSense blocks cross-network traffic by default |
| IDS/IPS | Suricata on Security Onion |
| Endpoint logging | Sysmon on all Windows VMs |
| Remote access | Tailscale with MFA (not a direct VPN into the lab) |
| VM isolation | Snapshots before every lab exercise |

---

*For setup instructions, see [`docs/SETUP.md`](./SETUP.md).*
*For the visual diagram, see [`architecture_diagram/`](../architecture_diagram/).*
