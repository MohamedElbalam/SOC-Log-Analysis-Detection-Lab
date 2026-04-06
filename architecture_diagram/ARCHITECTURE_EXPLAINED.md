# Lab Architecture Explained

This document provides a detailed breakdown of the SOC home lab topology, data flows, and the role of each component.

---

## ASCII Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                     PROXMOX VE (Hypervisor Host)                    │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  WAN (vmbr0) — Internet access / NAT                        │   │
│  └──────────────────────────┬───────────────────────────────────┘   │
│                             │                                       │
│                    ┌────────▼────────┐                              │
│                    │   pfSense       │                              │
│                    │   Firewall      │                              │
│                    │   (Router/NAT)  │                              │
│                    └────┬───────┬───┘                              │
│                         │       │                                   │
│         ┌───────────────▼─┐   ┌─▼────────────────┐                │
│         │  Attacker Net   │   │   Victim Net      │                │
│         │  (vmbr1)        │   │   (vmbr2)         │                │
│         │                 │   │                   │                │
│         │  ┌───────────┐  │   │  ┌─────────────┐ │                │
│         │  │ Kali Linux│  │   │  │ Windows 10  │ │                │
│         │  └───────────┘  │   │  └─────────────┘ │                │
│         │  ┌───────────┐  │   │  ┌─────────────┐ │                │
│         │  │ Parrot OS │  │   │  │ Windows 11  │ │                │
│         │  └───────────┘  │   │  └─────────────┘ │                │
│         └───────┬─────────┘   │  ┌─────────────┐ │                │
│                 │             │  │ Win Server  │ │                │
│                 │             │  │    2022     │ │                │
│                 │             │  └─────────────┘ │                │
│                 │             │  ┌─────────────┐ │                │
│                 │             │  │  Kioptrix   │ │                │
│                 │             │  └─────────────┘ │                │
│                 │             └────────┬──────────┘                │
│                 │                      │                            │
│                 └──────────┬───────────┘                            │
│                            │ (span/mirror port)                    │
│                   ┌────────▼────────┐                              │
│                   │  Security Onion │                              │
│                   │  ─────────────  │                              │
│                   │  Suricata (IDS) │                              │
│                   │  Zeek (NSM)     │                              │
│                   │  Kibana (UI)    │                              │
│                   │  Elasticsearch  │                              │
│                   └─────────────────┘                              │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Network Segments

| Bridge | Role | Subnet |
|--------|------|--------|
| `vmbr0` | WAN — uplink to physical network / internet | DHCP from ISP/router |
| `vmbr1` | Attacker Network — isolated from victim | 192.168.10.0/24 |
| `vmbr2` | Victim Network — target machines | 192.168.20.0/24 |

---

## Component Details

### Proxmox VE
- **Role:** Hypervisor host that runs all VMs
- **Why:** Free, enterprise-grade type-1 hypervisor with web UI; allows snapshot/rollback for repeatable attack scenarios
- **Key config:** AES-NI enabled in BIOS; three Linux bridges (vmbr0/1/2); QEMU guest agent on each VM

### pfSense Firewall
- **Role:** Network gateway, NAT, inter-segment routing, and access control
- **Why:** Production-grade open-source firewall; mirrors real enterprise environments
- **Key config:**
  - WAN on `vmbr0` (internet)
  - LAN on `vmbr2` (victim network)
  - OPT1 on `vmbr1` (attacker network)
  - Firewall rules restrict attacker → victim traffic (simulates east-west controls)
  - QEMU guest agent installed via `pkg install -y qemu-guest-agent`

### Security Onion (EVAL mode)
- **Role:** Network Security Monitoring (NSM) + IDS + log aggregation
- **Components:** Suricata, Zeek, Kibana, Elasticsearch, Strelka
- **Why:** All-in-one SOC platform; EVAL mode consolidates all roles onto one VM
- **Key config:**
  - Two NICs: management NIC (for admin access) + monitor NIC (promiscuous mode on vmbr1/vmbr2)
  - MAC spoofing enabled on monitor interface so it can see all traffic
  - 200 GB storage, 12 GB RAM minimum for EVAL
- **Known issue:** Cannot fetch OS URL during setup → download ISO manually and mount

### Kali Linux (Attacker)
- **Role:** Primary attack platform
- **Tools:** Metasploit, Mimikatz, Nmap, Impacket, CrackMapExec
- **Network:** vmbr1 (attacker segment)

### Parrot OS (Attacker)
- **Role:** Secondary attack platform / alternative toolset
- **Network:** vmbr1 (attacker segment)

### Windows 10 / 11 (Victims)
- **Role:** Desktop workstation targets
- **Monitoring:** Sysmon installed with SwiftOnSecurity config; logs forwarded to SIEM
- **Network:** vmbr2 (victim segment)

### Windows Server 2022 (Victim)
- **Role:** Domain controller / file server target
- **Network:** vmbr2 (victim segment)

### Kioptrix (Victim)
- **Role:** Intentionally vulnerable Linux VM for CTF-style exercises
- **Network:** vmbr2 (victim segment)

---

## Data Flow

```
Attack Traffic
 Kali/Parrot ──► pfSense ──► Windows/Linux Victims
                    │
                    ▼
              Security Onion (mirror)
                    │
          ┌─────────┼─────────┐
          ▼         ▼         ▼
       Zeek       Suricata  Elasticsearch
    (conn logs)  (alerts)   (storage)
          │         │         │
          └─────────┴────►  Kibana
                              │
                          SOC Analyst
                         (investigation)
```

### Host Telemetry Flow

```
Windows Victim
  └─► Sysmon
        └─► Windows Event Log
              └─► Winlogbeat / Wazuh Agent
                    └─► Elasticsearch / Splunk
                              └─► SOC Analyst
```

---

## Remote Access

- **Tailscale** is installed on the Proxmox host, enabling secure MFA-protected remote access to all lab VMs without exposing ports to the internet.
- A **Cloudflare Tunnel** is optionally used for web-based access to the Proxmox UI.

See [`../lab-setup/remote-access/README.md`](../lab-setup/remote-access/README.md) for setup details.
