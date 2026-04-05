# Environment Setup Guide

This guide walks through the complete setup of the SOC Detection Lab from bare metal to a fully operational environment.

---

## Table of Contents

1. [Hardware Requirements](#1-hardware-requirements)
2. [Proxmox VE Installation](#2-proxmox-ve-installation)
3. [Network Design](#3-network-design)
4. [pfSense Firewall Setup](#4-pfsense-firewall-setup)
5. [Security Onion Deployment](#5-security-onion-deployment)
6. [Attacker VMs (Kali Linux)](#6-attacker-vms-kali-linux)
7. [Victim VMs (Windows)](#7-victim-vms-windows)
8. [Sysmon Deployment](#8-sysmon-deployment)
9. [Remote Access (Tailscale)](#9-remote-access-tailscale)
10. [Verification Checklist](#10-verification-checklist)

---

## 1. Hardware Requirements

| Component | Minimum | Recommended |
|---|---|---|
| CPU | 4 cores (VT-x/AMD-V + AES-NI) | 8+ cores |
| RAM | 32 GB | 64 GB |
| Storage | 500 GB SSD | 1 TB NVMe |
| Network | 1 NIC | 2+ NICs |

**Verify AES-NI before starting:**
```bash
grep -o 'aes' /proc/cpuinfo | head -1
# Should output: aes
```

---

## 2. Proxmox VE Installation

1. Download [Proxmox VE ISO](https://www.proxmox.com/en/downloads)
2. Flash to USB: `dd if=proxmox-ve.iso of=/dev/sdX bs=4M status=progress`
3. Boot from USB and follow the installation wizard
4. Set a static IP for the management interface
5. After boot, access the web UI at `https://<proxmox-ip>:8006`

**Post-install tasks:**
```bash
# Update package lists
apt update && apt dist-upgrade -y

# Enable IOMMU for PCI passthrough (Intel)
sed -i 's/quiet/quiet intel_iommu=on iommu=pt/' /etc/default/grub
update-grub

# Verify QEMU agent package is available
apt install -y qemu-guest-agent
```

**Create Linux bridges in Proxmox:**

| Bridge | Purpose | VLAN/Subnet |
|---|---|---|
| vmbr0 | Management / WAN uplink | Your home network |
| vmbr1 | Attacker network | 10.10.10.0/24 |
| vmbr2 | Victim network | 192.168.100.0/24 |

---

## 3. Network Design

```
[Home Router] ── vmbr0 ── [pfSense WAN]
                          [pfSense LAN] ── vmbr1 ── [Kali Linux]
                                                     [Parrot OS]
                          [pfSense OPT1] ── vmbr2 ── [Windows 10]
                                                      [Windows 11]
                                                      [Win Server 2022]
                                                      [Kioptrix]

[Security Onion] ── (promiscuous on vmbr1 + vmbr2)
```

---

## 4. pfSense Firewall Setup

1. Create a new VM in Proxmox with:
   - 2 vCPUs, 2 GB RAM, 20 GB disk
   - Network interfaces on vmbr0 (WAN) and vmbr1 (LAN)
2. Boot the pfSense ISO and follow the installer
3. After install, configure interfaces via the console menu
4. Access the web UI at `https://192.168.1.1` (default)

**Install QEMU guest agent inside pfSense:**
```bash
# In pfSense shell (Diagnostics → Command Prompt or console option 8)
pkg install -y qemu-guest-agent
echo 'qemu_guest_agent_enable="YES"' >> /etc/rc.conf.local
echo 'virtio_console_load="YES"' >> /boot/loader.conf.local
service qemu-guest-agent start
```

**Firewall rules to configure:**
- WAN: Block all inbound (default)
- LAN (vmbr1): Allow attacker VMs to reach victim network and internet
- OPT1 (vmbr2): Allow victim VMs to reach internet; block attacker-initiated connections

See [`lab-setup/pfsense/readme.md`](../lab-setup/pfsense/readme.md) for detailed notes.

---

## 5. Security Onion Deployment

Security Onion consolidates IDS, NSM, and SIEM capabilities.

**VM Specifications (Eval/Standalone mode):**
- 4 vCPUs
- 12–16 GB RAM
- 200 GB storage
- 2 NICs: one for management, one for monitoring (promiscuous)

**Installation steps:**
1. Download the [Security Onion ISO](https://securityonionsolutions.com/software)
2. Create VM in Proxmox (see specs above)
3. Boot ISO and select **Eval** (standalone) mode
4. Follow the setup wizard; set the monitoring NIC to promiscuous mode in Proxmox

**Post-install — enable MAC address spoofing on the monitoring bridge:**
```
Proxmox → Network → vmbr1 → Enable MAC address learning (promiscuous)
```

**Access Security Onion dashboards:**
- Web UI: `https://<security-onion-ip>`
- Tools available: Kibana, Dashboards, Hunt, Alerts, PCAP

See [`lab-setup/security-onion-os/README.md`](../lab-setup/security-onion-os/README.md) for detailed notes.

---

## 6. Attacker VMs (Kali Linux)

1. Download [Kali Linux ISO](https://www.kali.org/get-kali/)
2. Create VM with: 4 vCPUs, 8 GB RAM, 80 GB disk, on vmbr1
3. Install Kali; update after install:
   ```bash
   sudo apt update && sudo apt full-upgrade -y
   ```
4. Install useful tools:
   ```bash
   sudo apt install -y metasploit-framework impacket-scripts bloodhound
   ```

---

## 7. Victim VMs (Windows)

**For each Windows VM:**
1. Create VM with: 2 vCPUs, 4 GB RAM, 60 GB disk, on vmbr2
2. Install Windows from ISO
3. Install QEMU guest agent from Proxmox VirtIO drivers ISO
4. Disable Windows Defender (for lab purposes only):
   ```powershell
   Set-MpPreference -DisableRealtimeMonitoring $true
   ```
5. Install Sysmon (see next section)

---

## 8. Sysmon Deployment

Sysmon provides detailed Windows endpoint telemetry.

**Download and install:**
```powershell
# Download Sysmon
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile "Sysmon.zip"
Expand-Archive Sysmon.zip -DestinationPath C:\Sysmon

# Download SwiftOnSecurity config (recommended)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile "C:\Sysmon\sysmonconfig.xml"

# Install
C:\Sysmon\Sysmon64.exe -accepteula -i C:\Sysmon\sysmonconfig.xml
```

**Verify Sysmon is running:**
```powershell
Get-Service Sysmon64
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 5
```

See [`configs/sysmon-config.xml`](../configs/sysmon-config.xml) for the configuration used in this lab.

---

## 9. Remote Access (Tailscale)

Tailscale provides secure, MFA-protected remote access to the lab.

**Install on Proxmox host:**
```bash
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --advertise-routes=192.168.100.0/24,10.10.10.0/24
```

**Enable subnet routing** in the Tailscale admin console to route traffic to lab subnets.

See [`lab-setup/remote-access/readme.md`](../lab-setup/remote-access/readme.md) for full details.

---

## 10. Verification Checklist

After completing setup, verify:

- [ ] Proxmox web UI accessible
- [ ] pfSense web UI accessible (via management network)
- [ ] Kali Linux can ping victim VMs (through pfSense)
- [ ] Victim VMs have internet access via pfSense NAT
- [ ] Security Onion receives traffic from monitoring interface
- [ ] Security Onion dashboards show live alerts
- [ ] Sysmon is running on all Windows VMs
- [ ] Windows event logs appear in Security Onion
- [ ] Remote access via Tailscale works
- [ ] VM snapshots taken of all VMs at clean baseline

---

*For architecture details, see [`docs/ARCHITECTURE.md`](./ARCHITECTURE.md).*
