# Network Topology

This document describes the complete network configuration of the SOC Detection Lab — including IP addressing, VLANs, subnets, firewall rules, traffic flows, and monitoring points.

---

## 1. Network Overview

```
                          ┌────────────────────────────────────────────────────┐
                          │              PROXMOX VE HYPERVISOR                 │
                          │                 192.168.1.10                       │
                          │                                                    │
  Internet ───────────────┤  vmbr0 (Management) 192.168.1.0/24                │
                          │  ┌─────────────────────────────────────────────┐  │
                          │  │ pfSense WAN: 192.168.1.50                   │  │
                          │  │ Analyst WS:  192.168.1.100                  │  │
                          │  └─────────────────────────────────────────────┘  │
                          │                                                    │
                          │  vmbr1 (Attacker) 10.10.10.0/24  [VLAN 100]      │
                          │  ┌─────────────────────────────────────────────┐  │
                          │  │ Kali Linux:          10.10.10.50             │  │
                          │  │ Parrot OS:           10.10.10.51             │  │
                          │  │ Security Onion (tap): 10.10.10.100           │  │
                          │  └─────────────────────────────────────────────┘  │
                          │              ↕ pfSense enforces rules              │
                          │  vmbr2 (Victim)  10.20.20.0/24  [VLAN 200]       │
                          │  ┌─────────────────────────────────────────────┐  │
                          │  │ Windows 10:          10.20.20.10             │  │
                          │  │ Windows 11:          10.20.20.11             │  │
                          │  │ Windows Server 2022: 10.20.20.20             │  │
                          │  │ Kioptrix Linux:      10.20.20.30             │  │
                          │  │ Security Onion (tap): 10.20.20.100           │  │
                          │  └─────────────────────────────────────────────┘  │
                          └────────────────────────────────────────────────────┘
```

---

## 2. IP Addressing Table

### Management Network — vmbr0 (192.168.1.0/24)
| Host | IP Address | Role |
|---|---|---|
| Proxmox VE Host | 192.168.1.10 | Hypervisor management |
| pfSense (WAN) | 192.168.1.50 | Firewall / router WAN interface |
| Analyst Workstation | 192.168.1.100 | SOC analyst access to Security Onion UI |

### Attacker Network — vmbr1 (10.10.10.0/24, VLAN 100)
| Host | IP Address | Role |
|---|---|---|
| Kali Linux | 10.10.10.50 | Primary attacker VM |
| Parrot OS | 10.10.10.51 | Secondary attacker VM |
| Security Onion (monitor) | 10.10.10.100 | Passive IDS/NSM sensor on attacker segment |
| pfSense (LAN1 gateway) | 10.10.10.1 | Default gateway for attacker VMs |

### Victim Network — vmbr2 (10.20.20.0/24, VLAN 200)
| Host | IP Address | Role |
|---|---|---|
| Windows 10 | 10.20.20.10 | Windows victim (Sysmon + WinLogBeat) |
| Windows 11 | 10.20.20.11 | Windows victim (Sysmon + WinLogBeat) |
| Windows Server 2022 | 10.20.20.20 | Domain controller / file server target |
| Kioptrix Linux | 10.20.20.30 | Vulnerable Linux CTF machine |
| Security Onion (monitor) | 10.20.20.100 | Passive IDS/NSM sensor on victim segment |
| pfSense (LAN2 gateway) | 10.20.20.1 | Default gateway for victim VMs |

---

## 3. VLAN Configuration

| VLAN ID | Name | Bridge | Subnet |
|---|---|---|---|
| — | Management | vmbr0 | 192.168.1.0/24 |
| 100 | Attacker | vmbr1 | 10.10.10.0/24 |
| 200 | Victim | vmbr2 | 10.20.20.0/24 |

VLANs enforce layer-2 isolation between network segments. Proxmox Linux bridges act as virtual switches connecting VMs within each segment.

---

## 4. Firewall Rules (pfSense)

### vmbr1 (Attacker) → vmbr2 (Victim)
| Rule | Source | Destination | Action | Purpose |
|---|---|---|---|---|
| 1 | 10.10.10.0/24 | 10.20.20.0/24 | **ALLOW** | Attacker can reach victim network |
| 2 | 10.10.10.0/24 | any | **ALLOW** | Outbound internet access for attackers |

### vmbr2 (Victim) → vmbr1 (Attacker)
| Rule | Source | Destination | Action | Purpose |
|---|---|---|---|---|
| 1 | 10.20.20.0/24 | 10.10.10.0/24 | **DENY** | Victims cannot initiate connections to attackers |
| 2 | 10.20.20.0/24 | 192.168.1.0/24 | **DENY** | Victims isolated from management network |
| 3 | 10.20.20.0/24 | any | **ALLOW** | Victims can access the internet (for updates) |

### Management (vmbr0) Access
| Rule | Source | Destination | Action | Purpose |
|---|---|---|---|---|
| 1 | 192.168.1.100 | 10.20.20.100 | **ALLOW** | Analyst accesses Security Onion UI |
| 2 | 192.168.1.100 | 192.168.1.10 | **ALLOW** | Analyst accesses Proxmox UI |
| 3 | 192.168.1.0/24 | 10.10.10.0/24 | **DENY** | Management network cannot reach attacker VMs |

---

## 5. Network Flows

### 5.1 Attack Flow
```
Kali Linux (10.10.10.50)
    │
    │  [Attack traffic — e.g., exploit, brute force]
    ▼
pfSense (10.10.10.1 → 10.20.20.1)
    │
    │  [Forwarded — attacker→victim rule ALLOWS]
    ▼
Windows 10 (10.20.20.10)
```

### 5.2 Log Collection Flow
```
Windows 10 (10.20.20.10)
    │
    │  [WinLogBeat → port 5044]
    ▼
Security Onion Wazuh Manager (10.20.20.100)
    │
    │  [Logstash pipeline]
    ▼
Elasticsearch (local on Security Onion)
    │
    │  [Kibana query]
    ▼
Analyst Workstation (192.168.1.100)
```

### 5.3 Network Monitoring Flow
```
Traffic on vmbr1 or vmbr2
    │
    │  [Promiscuous mode / port mirror]
    ▼
Security Onion monitoring interface (10.10.10.100 / 10.20.20.100)
    │
    ├──▶ Suricata (IDS rules — alert on malicious signatures)
    └──▶ Zeek (NSM — parse and log protocol metadata)
             │
             ▼
        Elasticsearch (indexed for analysis)
```

### 5.4 Analysis Flow
```
Elasticsearch (Security Onion)
    │
    │  [HTTPS — port 443]
    ▼
Kibana Web UI
    │
    │  [Analyst reviews dashboards, runs queries]
    ▼
Analyst Workstation (192.168.1.100 browser)
```

---

## 6. Traffic Monitoring Points

| Monitoring Point | Sensor | What It Sees |
|---|---|---|
| vmbr1 (Attacker segment) | Security Onion Suricata + Zeek | All attacker-generated traffic (recon, exploits, C2) |
| vmbr2 (Victim segment) | Security Onion Suricata + Zeek | All victim traffic (lateral movement, exfiltration) |
| Windows endpoints | Sysmon | Process creation, network connections, file events |
| Linux endpoint | Rsyslog | Auth events, system logs |
| pfSense | Firewall logs | Inter-VLAN routing decisions, blocked connections |

---

## 7. DNS Configuration

| Zone | Nameserver | Resolution |
|---|---|---|
| Lab internal | pfSense DNS Resolver | Resolves hostnames within each VLAN |
| External (Internet) | pfSense DNS Forwarder → 8.8.8.8 | Public DNS for internet access |

Victim VMs use 10.20.20.1 (pfSense LAN2) as their DNS server.  
Attacker VMs use 10.10.10.1 (pfSense LAN1) as their DNS server.

---

## 8. Network Segmentation Security Summary

| Control | Implementation |
|---|---|
| VLAN isolation | Separate Proxmox bridges prevent unintended cross-segment traffic |
| Firewall enforcement | pfSense rules explicitly allow/deny inter-segment flows |
| Monitoring coverage | Security Onion sensors on both vmbr1 and vmbr2 ensure full visibility |
| Management access | Analyst workstation on separate management VLAN (no attacker exposure) |
| No victim→attacker routing | pfSense deny rules prevent victims from pivoting back to attacker network |
