# Network Topology and Configuration

## Network Segments

### Management Network (vmbr0)
- **Purpose**: Proxmox management and VM administration
- **Network**: 192.168.1.0/24
- **Gateway**: 192.168.1.1
- **DNS**: 8.8.8.8, 8.8.4.4
- **Hosts**:
  - Proxmox Host: 192.168.1.10
  - pfSense WAN: 192.168.1.50
  - Analyst Workstation: 192.168.1.100

### Attacker Network (vmbr1)
- **Purpose**: Attack simulation and offensive operations
- **Network**: 10.10.10.0/24
- **Gateway**: 10.10.10.1 (pfSense LAN)
- **VLAN**: 100
- **Hosts**:
  - Kali Linux: 10.10.10.50
  - Parrot OS: 10.10.10.51
  - Security Onion (listening interface): 10.10.10.100

### Victim Network (vmbr2)
- **Purpose**: Target systems for attacks and monitoring
- **Network**: 10.20.20.0/24
- **Gateway**: 10.20.20.1 (pfSense LAN)
- **VLAN**: 200
- **Hosts**:
  - Windows 10: 10.20.20.10
  - Windows 11: 10.20.20.11
  - Windows Server 2022: 10.20.20.20
  - Kioptrix (Linux): 10.20.20.30
  - Security Onion (listening interface): 10.20.20.100

## Firewall Rules

### pfSense Rules

| Rule | Source | Destination | Action | Purpose |
|------|--------|-------------|--------|---------|
| 1 | Attacker (10.10.10.0/24) | Victim (10.20.20.0/24) | ALLOW | Simulate attacks |
| 2 | Victim (10.20.20.0/24) | Attacker (10.10.10.0/24) | DENY | Prevent reverse attacks |
| 3 | Victim (10.20.20.0/24) | WAN (Internet) | DENY | Isolated victim network |
| 4 | Attacker (10.10.10.0/24) | WAN (Internet) | ALLOW | Reconnaissance and payloads |
| 5 | Management (192.168.1.0/24) | All | ALLOW | Administration access |

## Network Flows

### Attack Flow
```
Attacker (10.10.10.50)
  → pfSense Firewall (10.10.10.1 / 10.20.20.1)
  → Victim (10.20.20.x)
```

### Log Collection Flow
```
Victim Machines (10.20.20.x)
  → WinLogBeat / Rsyslog Forwarder
  → Security Onion (10.20.20.100)
  → Wazuh Manager → Elasticsearch
```

### Analysis Flow
```
Analyst Workstation (192.168.1.100)
  → Security Onion Web UI (https://10.20.20.100)
  → Kibana / Investigation Dashboard
```

## VLAN Configuration

| Bridge | VLAN ID | Segment | Description |
|--------|---------|---------|-------------|
| vmbr0 | None | Management | Proxmox host management, no VLAN tagging |
| vmbr1 | 100 | Attackers | Isolated attacker machines |
| vmbr2 | 200 | Victims | Isolated victim machines |

## Network Segmentation Benefits

- **Isolated testing environment** — victim traffic cannot reach the internet
- **Realistic network segmentation** — mirrors real enterprise LAN/DMZ separation
- **Clear traffic boundaries** — easy to identify suspicious inter-segment flows
- **Monitoring clarity** — Security Onion listens on both attacker and victim segments simultaneously
- **Safe attack simulation** — attacker machines are contained within VLAN 100

## Security Onion Placement

Security Onion is connected to **both vmbr1 and vmbr2** using dedicated monitoring interfaces in **promiscuous mode**. This allows Suricata and Zeek to capture all traffic on both network segments passively without affecting network performance.

```
vmbr1 (attacker) ──→ Security Onion eth1 (passive/promiscuous)
vmbr2 (victim)   ──→ Security Onion eth2 (passive/promiscuous)
vmbr2 (victim)   ──→ Security Onion eth0 (management, 10.20.20.100)
```

## Related Documentation

- [LOGGING_ARCHITECTURE.md](./LOGGING_ARCHITECTURE.md) — how logs flow through the lab
- [DATA_FLOW.md](./DATA_FLOW.md) — data flow diagrams and traffic patterns
- [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) — step-by-step setup instructions
