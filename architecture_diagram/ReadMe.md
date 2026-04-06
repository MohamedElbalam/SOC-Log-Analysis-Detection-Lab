
# SOC Lab Architecture

This document describes the architecture of the SOC Log Analysis & Detection Lab — a fully isolated virtual environment designed for security testing, detection engineering, and incident investigation training.

## Architecture Diagram

The SVG below illustrates the complete network topology, including the attacker network, victim network, firewall placement, and Security Onion monitoring position.

![Lab Architecture Diagram](Detection_lab.drawio(5).svg)

> If the SVG does not render inline, open the file directly: `architecture_diagram/Detection_lab.drawio(5).svg`

For an ASCII representation and annotated data flow, see [ARCHITECTURE_EXPLAINED.md](ARCHITECTURE_EXPLAINED.md).

---

## Architecture Overview

The lab is built on a **three-tier network model** hosted entirely inside Proxmox VE:

| Tier | Network Bridge | Segment Purpose |
|------|---------------|-----------------|
| WAN / Management | `vmbr0` | External internet access, pfSense WAN interface |
| Attacker Network | `vmbr1` | Offensive machines — Kali Linux, Parrot OS |
| Victim Network | `vmbr2` | Target endpoints — Windows, Kioptrix |

**Design principles:**
- **Network segmentation** — attackers and victims are on separate bridges; they cannot communicate directly without passing through pfSense
- **Monitoring coverage** — Security Onion has interfaces on both `vmbr1` and `vmbr2` to capture east-west and north-south traffic
- **Separation of concerns** — each VM has a single, well-defined role (attacker, target, firewall, or monitor)
- **Snapshot-friendly** — all VMs are snapshotted before each scenario so the environment can be reset cleanly

---

## Detailed Component Descriptions

### 1. Proxmox VE (Virtualization Platform)

**Role:** Hypervisor that hosts all virtual machines and manages network bridges.

- **Hardware requirements:** 32 GB RAM, 8-core CPU with VT-x/AMD-V, 500 GB SSD
- **Network bridges:**
  - `vmbr0` — WAN/management (connects to physical NIC / router)
  - `vmbr1` — Attacker network (internal, isolated)
  - `vmbr2` — Victim network (internal, isolated)
- **Storage:** Each VM uses a dedicated virtual disk; snapshots are stored on local storage
- **VM management:** Proxmox web UI at `https://<proxmox-ip>:8006`

---

### 2. pfSense Firewall

**Role:** Gateway and traffic controller between all network segments.

- **Placement:** Connected to `vmbr0` (WAN), `vmbr1` (attacker LAN), and `vmbr2` (victim LAN)
- **Traffic control:** Firewall rules define which traffic is allowed between segments
- **NAT:** Provides outbound internet access to attacker VMs for downloading payloads and C2 communication
- **VLAN management:** Can be extended with VLAN tagging for further segmentation
- **Logging:** All allowed and denied connections are logged; logs are optionally forwarded to Security Onion
- **IDS/IPS integration:** pfSense Suricata or Snort package can be enabled for inline inspection at the firewall level

---

### 3. Security Onion (SIEM / IDS / NSM)

**Role:** Central monitoring platform that collects, correlates, and alerts on suspicious activity.

- **Tools included:**
  - **Suricata** — signature-based IDS; generates alerts on known attack patterns
  - **Zeek** — network protocol analyser; produces structured logs (conn, dns, http, ssl, files, etc.)
  - **Wazuh** — host-based intrusion detection and log management; receives Sysmon and Windows Event logs
- **Network monitoring strategy:** Security Onion has a dedicated monitoring NIC in promiscuous mode on `vmbr1` and `vmbr2` to see all traffic on both segments
- **Alert generation:** Suricata rules fire on malicious traffic; Wazuh rules fire on suspicious host events
- **Log analysis:** All logs are indexed and searchable in the Kibana/Security Onion dashboards
- **Dashboards:** Pre-built dashboards for alert triage, connection analysis, DNS, and HTTP activity

---

### 4. Attacker Network (vmbr1)

**Role:** Isolated segment for offensive operations.

- **Machines:**
  - **Kali Linux** — primary pentesting platform (Metasploit, Nmap, Impacket, CrackMapExec, etc.)
  - **Parrot OS** — secondary offensive machine with additional tooling
- **Network isolation:** Can only reach the victim network through pfSense; firewall rules control what is allowed
- **Internet access:** Outbound internet is available through pfSense NAT for payload downloads and C2 setup
- **Attack tools available:** Full Kali toolset — exploitation frameworks, credential dumping, network scanning, wireless, web application testing

---

### 5. Victim Network (vmbr2)

**Role:** Target endpoints that simulate a real enterprise environment.

- **Windows 10** — modern workstation endpoint
- **Windows 11** — latest Windows endpoint
- **Windows Server 2022** — Active Directory, DNS, and file server workloads
- **Kioptrix** — intentionally vulnerable Linux machine for CTF-style exploitation
- **Logging agents installed on Windows machines:**
  - **Sysmon** — detailed process, network, file, and registry event logging
  - **Windows Event Forwarding (WEF)** — forwards events to Wazuh / Security Onion
- **Snapshot discipline:** All victims are snapshotted before each scenario for clean resets

---

### 6. Internet / WAN

**Role:** Simulated external connectivity for realistic attack scenarios.

- **Outbound access:** pfSense provides NAT so attacker VMs can reach the internet for:
  - Downloading payloads and tools
  - C2 (Command and Control) communication simulation
  - OSINT and reconnaissance against external targets
- **Inbound access:** Blocked by default; can be opened selectively through pfSense rules

---

## Network Architecture

### IP Addressing Scheme

| Segment | Bridge | Subnet | Example IPs |
|---------|--------|--------|-------------|
| WAN | vmbr0 | DHCP from router | — |
| Attacker | vmbr1 | 192.168.1.0/24 | Kali: .10, Parrot: .11 |
| Victim | vmbr2 | 192.168.2.0/24 | Win10: .20, WinSrv: .21, Kioptrix: .30 |
| pfSense LAN1 | vmbr1 | 192.168.1.1 | Gateway for attackers |
| pfSense LAN2 | vmbr2 | 192.168.2.1 | Gateway for victims |
| Security Onion | vmbr1+vmbr2 | Monitoring only (no IP on span ports) | — |

> **Note:** Adjust IP ranges to match your Proxmox network configuration.

### Network Isolation

- **Attacker → Victim:** Traffic must pass through pfSense; firewall rules define what is permitted
- **Victim → Attacker:** Blocked by default to prevent reverse connections unless explicitly opened
- **Security Onion → Both segments:** Passive monitoring only (promiscuous mode); Security Onion does not route traffic
- **pfSense → Internet:** NAT allows outbound connections; inbound blocked by default

### Monitoring Points

| Location | Tool | What Is Captured |
|----------|------|-----------------|
| vmbr1 span port | Zeek + Suricata | All attacker-side traffic |
| vmbr2 span port | Zeek + Suricata | All victim-side traffic |
| Victim Windows VMs | Sysmon + Wazuh | Process, network, registry, file events |
| pfSense | pfSense logs | Firewall allow/deny events |

---

## Data Flow

### 1. Attack Initiation
```
Attacker VM (Kali/Parrot) → vmbr1 → pfSense → vmbr2 → Victim VM
```

### 2. Log Generation on Victim
```
Victim VM (Windows) → Sysmon → Windows Event Log → Wazuh Agent → Security Onion
```

### 3. Network Detection (IDS)
```
Traffic on vmbr1/vmbr2 → Suricata (signature matching) → Alert in Security Onion
```

### 4. Network Protocol Analysis (NSM)
```
Traffic on vmbr1/vmbr2 → Zeek → Structured logs (conn, dns, http, ssl) → Security Onion index
```

### 5. Alert and Investigation Workflow
```
Alert generated → Analyst opens Security Onion dashboard → Pivots to raw logs →
Reconstructs timeline → Documents findings → Writes incident report
```

---

## Security Controls

| Control | Implementation |
|---------|---------------|
| Network segmentation | Separate bridges (vmbr1/vmbr2) with pfSense between them |
| Firewall rules | pfSense — default deny, explicit allow per scenario |
| Host logging | Sysmon on all Windows VMs |
| Network monitoring | Zeek + Suricata on both segments |
| Log aggregation | Wazuh + Security Onion |
| Environment isolation | All VMs are internal; no direct internet exposure to victims |
| Snapshot / reset | Proxmox snapshots taken before every attack scenario |

---

## How to Set Up the Lab

### Step 1 — Prerequisites

- Bare-metal server or workstation with VT-x/AMD-V enabled
- 32 GB+ RAM, 8+ CPU cores, 500 GB+ SSD
- Proxmox VE ISO downloaded from [proxmox.com](https://www.proxmox.com/en/downloads)
- ISOs for: pfSense, Security Onion, Kali Linux, Parrot OS, Windows 10/11, Windows Server 2022, Kioptrix

### Step 2 — Install Proxmox VE

1. Boot from Proxmox ISO and install on bare metal
2. Access the web UI at `https://<proxmox-ip>:8006`
3. Upload all VM ISOs to Proxmox local storage

### Step 3 — Configure Network Bridges

In Proxmox → Network, create:
- `vmbr0` — bridge to physical NIC (WAN)
- `vmbr1` — internal bridge, no physical port (Attacker network)
- `vmbr2` — internal bridge, no physical port (Victim network)

### Step 4 — Deploy pfSense

1. Create VM: 1 vCPU, 1 GB RAM, 8 GB disk
2. Attach NICs: `vmbr0` (WAN), `vmbr1` (LAN1), `vmbr2` (LAN2)
3. Install pfSense and assign interfaces
4. Configure firewall rules and NAT

See [`lab-setup/pfsense/readme.md`](../lab-setup/pfsense/readme.md) for detailed steps.

### Step 5 — Deploy Security Onion

1. Create VM: 4 vCPU, 16 GB RAM, 200 GB disk
2. Attach NICs: management NIC on `vmbr0`, monitoring NICs on `vmbr1` and `vmbr2`
3. Install Security Onion in standalone mode
4. Configure monitoring interfaces in promiscuous mode
5. Set up Wazuh to receive agent logs

See [`lab-setup/security-onion-os/README.md`](../lab-setup/security-onion-os/README.md) for detailed steps.

### Step 6 — Set Up Attacker Machines

1. Create Kali Linux VM: 2 vCPU, 4 GB RAM, 80 GB disk, NIC on `vmbr1`
2. Install Kali Linux and update tools
3. Optionally create Parrot OS VM with same specs

See [`lab-setup/kali-linux-main/READ.md`](../lab-setup/kali-linux-main/READ.md).

### Step 7 — Set Up Victim Machines

1. Create Windows VMs: 2 vCPU, 4 GB RAM each, NICs on `vmbr2`
2. Install Windows 10, Windows 11, Windows Server 2022
3. Create Kioptrix VM on `vmbr2`
4. Take initial snapshots of all victim VMs

See [`lab-setup/Ubuntu-main/readME.md`](../lab-setup/Ubuntu-main/readME.md).

### Step 8 — Install Logging Agents on Windows VMs

1. Download and install **Sysmon** with a recommended config (e.g., SwiftOnSecurity config)
   ```powershell
   sysmon64.exe -accepteula -i sysmonconfig.xml
   ```
2. Install **Wazuh agent** and point it to the Security Onion Wazuh manager IP
3. Verify events appear in Security Onion dashboards

### Step 9 — Configure Log Forwarding

1. On each Windows VM, configure Wazuh agent (`ossec.conf`) with the Security Onion manager IP
2. Restart the Wazuh agent service
3. In Security Onion, verify the agent is connected and events are being indexed

### Step 10 — Verification

1. From Kali Linux, run `nmap -sV <victim-ip>` against a victim VM
2. Open Security Onion dashboards — you should see:
   - Suricata alert for the port scan
   - Zeek conn logs showing the connections
3. On the victim Windows VM, open Event Viewer — Sysmon events should be present
4. Verify Wazuh in Security Onion shows the host as connected

---

## Troubleshooting

| Issue | Possible Cause | Solution |
|-------|---------------|----------|
| VMs cannot ping each other | Bridge not assigned correctly | Check Proxmox NIC settings; ensure correct vmbr assigned |
| pfSense not routing traffic | Firewall rules blocking | Review pfSense firewall rules; check interface assignment |
| Security Onion not seeing traffic | NIC not in promiscuous mode | Set monitoring NICs to promiscuous in Proxmox; restart SO |
| Wazuh agent not connecting | Firewall or wrong manager IP | Check pfSense rules allow port 1514; verify manager IP in ossec.conf |
| No alerts in Security Onion | Suricata rules not loaded | Run `sudo so-rule-update` on Security Onion |
| VM performance issues | Insufficient resources | Reduce concurrent VMs; increase RAM/vCPU allocation |
| Log forwarding gaps | Wazuh agent not running | Check agent status: `sudo systemctl status wazuh-agent` |

---

## Architecture Benefits

| Benefit | Description |
|---------|-------------|
| Isolated testing | Attacks stay inside the lab — no risk to production systems |
| Realistic simulation | Mirrors real enterprise SOC architecture |
| Comprehensive monitoring | Both network and host-based detection |
| Safe experimentation | Snapshots allow fast environment resets |
| Portfolio-ready | Demonstrates real-world SOC skills to employers |

---

## References

- [Proxmox VE Documentation](https://pve.proxmox.com/wiki/Main_Page)
- [pfSense Documentation](https://docs.netgate.com/pfsense/en/latest/)
- [Security Onion Documentation](https://docs.securityonion.net/)
- [Wazuh Documentation](https://documentation.wazuh.com/)
- [Zeek Documentation](https://docs.zeek.org/)
- [Suricata Documentation](https://suricata.readthedocs.io/)
- [Sysmon (Sysinternals)](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon)
- [SwiftOnSecurity Sysmon Config](https://github.com/SwiftOnSecurity/sysmon-config)

---

*Back to main lab: [README.md](../README.md)*
