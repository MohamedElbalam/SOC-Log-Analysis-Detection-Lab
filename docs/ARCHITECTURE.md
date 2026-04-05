# Lab Architecture

This document describes the network topology and component relationships of the SOC Detection Lab.

---

## Network Topology

```
                          ┌─────────────────────────────────────────────────────┐
                          │              Proxmox VE Host (Bare Metal)           │
                          │                                                     │
  Internet (WAN) ─────── │  vmbr0 (Management / WAN)                          │
                          │       │                                             │
                          │  ┌────┴────────────────────┐                       │
                          │  │        pfSense           │                       │
                          │  │  WAN: vmbr0 (NAT)        │                       │
                          │  │  LAN: vmbr1 (10.10.1.1)  │                       │
                          │  │  OPT1: vmbr2 (10.10.2.1) │                       │
                          │  └────┬──────────────┬──────┘                       │
                          │       │              │                              │
                          │  vmbr1 (Attacker)  vmbr2 (Victim)                  │
                          │       │              │                              │
                          │  ┌────┴───┐    ┌────┴──────────────────────────┐   │
                          │  │ Kali   │    │   Windows 10/11               │   │
                          │  │ Linux  │    │   Windows Server 2022         │   │
                          │  │Parrot  │    │   Kioptrix (Linux)            │   │
                          │  │  OS    │    │   (Sysmon + Wazuh agent)      │   │
                          │  └────────┘    └───────────────────────────────┘   │
                          │                              │                      │
                          │                    ┌─────────┴──────────┐          │
                          │                    │  Security Onion     │          │
                          │                    │  (EVAL mode)        │          │
                          │                    │  mgmt: vmbr0        │          │
                          │                    │  monitor: vmbr1+2   │          │
                          │                    │  Suricata + Zeek    │          │
                          │                    │  Kibana + Elastic   │          │
                          │                    └────────────────────┘          │
                          └─────────────────────────────────────────────────────┘
```

---

## Components

### Proxmox VE (Hypervisor)
- **Role**: Virtualization host managing all VMs
- **Bridges**: vmbr0 (management/WAN), vmbr1 (attacker), vmbr2 (victim)
- **Why**: Open-source, enterprise-grade hypervisor with snapshot support and QEMU agent integration
- **Key settings**: AES-NI enabled in BIOS, dedicated admin user, QEMU guest agent on all VMs

### pfSense (Firewall / Router)
- **Role**: Controls traffic between attacker network, victim network, and the internet
- **Interfaces**: WAN (vmbr0), LAN/attacker (vmbr1), OPT1/victim (vmbr2)
- **Why**: BSD-based open-source firewall with stateful inspection, NAT, and fine-grained ACLs
- **Key config**: NAT for outbound internet, firewall rules toggle attacker↔victim access per exercise

### Security Onion (IDS / NSM)
- **Role**: Network traffic monitoring, IDS alerting, flow analysis
- **Mode**: EVAL (single-node — combines manager, search, and sensor roles)
- **Tools inside**: Suricata (signature IDS), Zeek (network protocol analysis), Kibana (dashboards), Elasticsearch (log storage)
- **Interfaces**: Management (vmbr0), Monitoring (mirrors vmbr1 and/or vmbr2 traffic)
- **Hardware**: 12 GB RAM, 200 GB storage, 2 NICs
- **Notes**: Virtual switches must allow MAC spoofing for the monitoring NIC to capture in promiscuous mode

### Attacker VMs
| VM | Network | Purpose |
|----|---------|---------|
| Kali Linux | vmbr1 (10.10.1.0/24) | Primary attack platform — Metasploit, Nmap, Impacket |
| Parrot OS | vmbr1 (10.10.1.0/24) | Secondary attacker / OSINT |

### Victim VMs
| VM | Network | Purpose |
|----|---------|---------|
| Windows 10 | vmbr2 (10.10.2.0/24) | Primary target — Sysmon + Wazuh agent |
| Windows 11 | vmbr2 (10.10.2.0/24) | Secondary target |
| Windows Server 2022 | vmbr2 (10.10.2.0/24) | AD / domain controller target |
| Kioptrix | vmbr2 (10.10.2.0/24) | Vulnerable Linux target (CTF-style) |

### SIEM / Log Analysis
| Tool | Role |
|------|------|
| Splunk (Free) | Windows event log search, dashboards, custom detection queries |
| Wazuh | Agent-based log collection, host-based IDS, custom rule alerting |
| Security Onion / Kibana | Network-level event visualization |

### Remote Access
| Tool | Purpose |
|------|---------|
| Tailscale | MFA-protected VPN with subnet routing for all lab networks |
| Cloudflare Tunnel | Web UI access to Proxmox without exposing ports (optional) |

---

## Traffic Flow Summary

| Scenario | Source | Destination | Path |
|----------|--------|-------------|------|
| Attack simulation | Kali (vmbr1) | Windows VM (vmbr2) | pfSense (firewall rule enabled) |
| Log forwarding | Windows VM (vmbr2) | Splunk/Wazuh (vmbr0 or vmbr2) | Direct or pfSense OPT1 |
| IDS monitoring | Security Onion | vmbr1 + vmbr2 | Promiscuous capture on monitoring NIC |
| Internet access | Any lab VM | WAN | pfSense NAT via vmbr0 |
| Remote admin | Tailscale client | Proxmox (vmbr0) | Encrypted Tailscale tunnel |

---

## Architecture Diagram

See the SVG network diagram in [`architecture_diagram/`](../architecture_diagram/).
