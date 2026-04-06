# Deployment Guide

This document provides complete deployment instructions for the SOC Detection Lab — from hardware procurement through final validation.

---

## 1. Hardware Requirements

### Minimum Specifications
| Component | Minimum | Recommended |
|---|---|---|
| CPU | 8 cores (Intel/AMD with VT-x/AMD-V) | 16+ cores |
| RAM | 32 GB DDR4 | 64 GB DDR4 |
| Storage | 500 GB SSD | 1 TB NVMe SSD + 2 TB HDD |
| Network | 1× Gigabit NIC | 2× Gigabit NIC (dedicated management) |

> **Note:** Security Onion alone requires 16 GB RAM minimum. More RAM allows more VMs to run simultaneously.

---

## 2. Software Versions

| Software | Version | Download |
|---|---|---|
| Proxmox VE | 8.x | https://www.proxmox.com/downloads |
| pfSense CE | 2.7.x | https://www.pfsense.org/download/ |
| Security Onion | 2.4.x | https://github.com/Security-Onion-Solutions/securityonion/releases |
| Kali Linux | 2024.x | https://www.kali.org/get-kali/ |
| Parrot OS Security | 6.x | https://parrotsec.org/download/ |
| Windows 10 | 22H2 | Microsoft Evaluation Center |
| Windows 11 | 23H2 | Microsoft Evaluation Center |
| Windows Server 2022 | Latest | Microsoft Evaluation Center |
| Kioptrix | Level 1 | https://www.vulnhub.com/entry/kioptrix-level-1-1,22/ |
| Sysmon | 15.x | https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon |
| WinLogBeat | 8.x | https://www.elastic.co/beats/winlogbeat |

---

## 3. VM Specifications Table

| VM | OS | vCPUs | RAM | Disk | Network |
|---|---|---|---|---|---|
| pfSense | FreeBSD | 2 | 2 GB | 20 GB | vmbr0 (WAN), vmbr1 (LAN1), vmbr2 (LAN2) |
| Security Onion | Ubuntu 22.04 | 4 | 16 GB | 200 GB | vmbr0 (mgmt), vmbr1 (monitor), vmbr2 (monitor) |
| Kali Linux | Debian | 4 | 4 GB | 80 GB | vmbr1 |
| Parrot OS | Debian | 2 | 4 GB | 60 GB | vmbr1 |
| Windows 10 | Windows | 2 | 4 GB | 60 GB | vmbr2 |
| Windows 11 | Windows | 2 | 4 GB | 60 GB | vmbr2 |
| Windows Server 2022 | Windows | 2 | 4 GB | 80 GB | vmbr2 |
| Kioptrix | Linux | 1 | 512 MB | 8 GB | vmbr2 |

**Total RAM required**: ~38.5 GB (allow 4–6 GB for Proxmox host overhead → 64 GB recommended)

---

## 4. Step-by-Step Deployment

### Step 1 — Proxmox VE Installation

1. Download Proxmox VE ISO from https://www.proxmox.com/downloads
2. Create bootable USB with Rufus or Balena Etcher
3. Boot from USB and follow the installation wizard:
   - Select target disk (SSD recommended for VMs)
   - Set management IP: `192.168.1.10/24`, gateway: `192.168.1.1`
   - Set root password and admin email
4. After install, access Proxmox Web UI: `https://192.168.1.10:8006`

### Step 2 — Network Bridge Creation

In Proxmox Web UI → Node → Network → Create Linux Bridge:

```
vmbr0 — Management
  Bridge ports: (physical NIC, e.g. eth0)
  IP:           192.168.1.10/24
  Comment:      Management Network

vmbr1 — Attacker Network
  Bridge ports: (none — internal only)
  IP:           (none — pfSense manages DHCP)
  Comment:      Attacker Network VLAN 100

vmbr2 — Victim Network
  Bridge ports: (none — internal only)
  IP:           (none — pfSense manages DHCP)
  Comment:      Victim Network VLAN 200
```

After creating bridges, apply network configuration and reboot if prompted.

### Step 3 — pfSense Setup

1. Create pfSense VM in Proxmox:
   - Upload pfSense ISO to Proxmox local storage
   - Create VM: 2 vCPUs, 2 GB RAM, 20 GB disk
   - Add network interfaces: vmbr0 (WAN), vmbr1 (LAN1), vmbr2 (LAN2)

2. Boot pfSense and follow console setup:
   - WAN: DHCP or static from 192.168.1.x range → assign `192.168.1.50`
   - LAN1 (vmbr1): `10.10.10.1/24`
   - LAN2 (vmbr2): `10.20.20.1/24`

3. Configure firewall rules via pfSense Web UI (`https://192.168.1.50`):
   ```
   LAN1 (Attacker) rules:
     Allow: LAN1 → LAN2 (attacker can reach victims)
     Allow: LAN1 → WAN (internet access)

   LAN2 (Victim) rules:
     Deny:  LAN2 → LAN1 (victims cannot reach attackers)
     Deny:  LAN2 → 192.168.1.0/24 (no management access)
     Allow: LAN2 → WAN (internet for updates only)
   ```

4. Enable DHCP server on LAN1 and LAN2 (or use static IPs as listed in the network table)

### Step 4 — Security Onion Deployment

1. Create Security Onion VM:
   - Upload Security Onion ISO
   - VM config: 4 vCPUs, 16 GB RAM, 200 GB disk
   - Network interfaces: vmbr0 (management), vmbr1 (monitoring), vmbr2 (monitoring)

2. Boot and run Security Onion setup:
   ```bash
   sudo sosetup
   ```
   - Choose: **Standalone** (all-in-one for lab use)
   - Management interface: eth0 (vmbr0) → IP: `10.20.20.100` or `192.168.1.100`
   - Monitor interfaces: eth1 (vmbr1), eth2 (vmbr2)
   - Enable: Suricata, Zeek, Wazuh, Elasticsearch, Kibana

3. Set admin credentials when prompted

4. After setup, access Security Onion Web UI:
   ```
   https://192.168.1.100 (from analyst workstation)
   ```

### Step 5 — Victim Machine Setup

For each victim VM (Windows 10, 11, Server 2022):

1. Create VM in Proxmox:
   - Upload Windows ISO to local storage
   - Attach to vmbr2 only
   - Complete Windows installation

2. Set static IP:
   - Windows 10: `10.20.20.10`, Gateway: `10.20.20.1`, DNS: `10.20.20.1`
   - Windows 11: `10.20.20.11`, same gateway/DNS
   - Windows Server: `10.20.20.20`, same gateway/DNS

3. Disable Windows Firewall for lab testing (optional — for unrestricted attack simulation):
   ```powershell
   Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
   ```

For Kioptrix Linux:
1. Import Kioptrix OVA into Proxmox
2. Attach to vmbr2
3. Static IP: `10.20.20.30` (or configure after boot)

### Step 6 — Logging Agent Installation

#### Sysmon (on each Windows victim)

```powershell
# Create temp directory if it doesn't exist
New-Item -ItemType Directory -Path C:\Temp -Force

# Download Sysmon
Invoke-WebRequest -Uri https://download.sysinternals.com/files/Sysmon.zip -OutFile C:\Temp\Sysmon.zip
Expand-Archive C:\Temp\Sysmon.zip -DestinationPath C:\Temp\Sysmon

# Download SwiftOnSecurity Sysmon config (comprehensive rule set)
Invoke-WebRequest -Uri https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml -OutFile C:\Temp\sysmonconfig.xml

# Install Sysmon
C:\Temp\Sysmon\Sysmon64.exe -accepteula -i C:\Temp\sysmonconfig.xml

# Verify Sysmon is running
Get-Service Sysmon64
```

#### WinLogBeat (on each Windows victim)

```powershell
# Download WinLogBeat
Invoke-WebRequest -Uri https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-8.x.x-windows-x86_64.zip -OutFile C:\Temp\winlogbeat.zip
Expand-Archive C:\Temp\winlogbeat.zip -DestinationPath "C:\Program Files\WinLogBeat"

# Edit winlogbeat.yml — set output to Security Onion
# output.logstash:
#   hosts: ["10.20.20.100:5044"]

# Install and start WinLogBeat service
cd "C:\Program Files\WinLogBeat\winlogbeat-8.x.x-windows-x86_64"
.\install-service-winlogbeat.ps1
Start-Service winlogbeat
```

#### Rsyslog on Kioptrix (Linux log forwarding)

```bash
# Add to /etc/rsyslog.conf
echo "*.* @10.20.20.100:514" >> /etc/rsyslog.conf

# Restart rsyslog
systemctl restart rsyslog
```

### Step 7 — SIEM Configuration

1. **Verify WinLogBeat connectivity**:
   - Check Security Onion Kibana → Management → Index Patterns
   - Confirm `winlogbeat-*` index exists and has data

2. **Verify Suricata and Zeek**:
   ```bash
   # On Security Onion
   so-status
   # All services should show as running (green)
   ```

3. **Import Kibana dashboards**:
   - Security Onion includes default dashboards
   - Access: Kibana → Dashboard → Search "Security Onion"

4. **Configure Wazuh agent on victim VMs** (optional — for advanced host IDS):
   ```powershell
   # Download and install Wazuh agent
   Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.x.x-1.msi -OutFile wazuh-agent.msi
   msiexec /i wazuh-agent.msi WAZUH_MANAGER=10.20.20.100 /q
   Start-Service WazuhSvc
   ```

### Step 8 — Attacker VM Setup

1. Create Kali Linux VM:
   - Attach to vmbr1
   - Static IP: `10.10.10.50`, Gateway: `10.10.10.1`, DNS: `10.10.10.1`

2. Create Parrot OS VM:
   - Attach to vmbr1
   - Static IP: `10.10.10.51`

3. Update tools:
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo apt install -y nmap metasploit-framework impacket-scripts
   ```

### Step 9 — Testing and Validation

```bash
# Test 1: Connectivity from attacker to victim
ping 10.20.20.10       # should succeed (allow rule)
ping 10.20.20.100      # should succeed

# Test 2: Verify victim cannot reach attacker
# On Windows 10: ping 10.10.10.50 → should timeout (deny rule)

# Test 3: Trigger a Suricata alert
nmap -sV 10.20.20.0/24   # Suricata should alert on port scan

# Test 4: Verify logs appear in Kibana
# Open https://192.168.1.100 → Kibana → Discover
# Search: src_ip: 10.10.10.50 → nmap scan events should appear

# Test 5: Verify Sysmon logs
# On Windows 10: open Event Viewer → Applications and Services Logs
# → Microsoft → Windows → Sysmon → Operational
# Events should appear when running processes
```

---

## 5. Troubleshooting Guide

| Symptom | Likely Cause | Solution |
|---|---|---|
| WinLogBeat not sending logs | Firewall blocking port 5044 | Ensure pfSense allows LAN2→Security Onion:5044; check Windows Firewall |
| Kibana shows no data | Index pattern not created | Kibana → Stack Management → Index Patterns → Create `winlogbeat-*` |
| Suricata not alerting on attacks | Interface not in promiscuous mode | Check SO interfaces: `ip link show` → set promisc mode |
| pfSense blocking legit traffic | Firewall rule order wrong | pfSense rules evaluated top-to-bottom; move allow rules above deny |
| Security Onion services stopped | Insufficient RAM | Increase SO VM RAM; check `so-status` for failed services |
| Cannot access Security Onion UI | Network routing issue | Ensure analyst workstation can route to Security Onion management IP |
| Wazuh agent not connecting | Port 1514 blocked | Open UDP 1514 between victim VMs and Security Onion |
| Victim VMs have no internet | pfSense NAT not configured | Enable outbound NAT on pfSense for LAN2 → WAN |
| Logs missing in Elasticsearch | Logstash pipeline failed | Check `so-status` and Logstash logs: `/var/log/logstash/logstash-plain.log` |
| Sysmon not logging events | Config not loaded | Re-run: `Sysmon64.exe -c sysmonconfig.xml` to reload config |

---

## 6. Quick Reference — Key IPs and Ports

| Service | IP | Port | Protocol |
|---|---|---|---|
| Proxmox Web UI | 192.168.1.10 | 8006 | HTTPS |
| pfSense Web UI | 192.168.1.50 | 443 | HTTPS |
| Security Onion Web UI | 192.168.1.100 | 443 | HTTPS |
| WinLogBeat → Logstash | 10.20.20.100 | 5044 | TCP (Beats) |
| Wazuh Agent → Manager | 10.20.20.100 | 1514 | UDP |
| Rsyslog → Security Onion | 10.20.20.100 | 514 | UDP |
| Kibana | 192.168.1.100 | 5601 | HTTPS |
| Elasticsearch | localhost | 9200 | HTTP (internal) |
