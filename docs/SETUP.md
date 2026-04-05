# Environment Setup Guide

This guide walks through setting up the full SOC Detection Lab from scratch on a bare-metal host running Proxmox VE.

---

## Table of Contents
1. [Hardware Requirements](#hardware-requirements)
2. [Proxmox Installation](#proxmox-installation)
3. [Network Configuration](#network-configuration)
4. [pfSense Firewall Setup](#pfsense-firewall-setup)
5. [Security Onion Setup](#security-onion-setup)
6. [Victim VM Setup (Windows)](#victim-vm-setup-windows)
7. [Sysmon Deployment](#sysmon-deployment)
8. [Attacker VM Setup (Kali Linux)](#attacker-vm-setup-kali-linux)
9. [SIEM Setup (Splunk / Wazuh)](#siem-setup)
10. [Remote Access (Tailscale)](#remote-access-tailscale)

---

## Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 4 cores, AES-NI support | 8+ cores |
| RAM | 16 GB | 32+ GB |
| Storage | 500 GB SSD | 1+ TB NVMe SSD |
| Network | 1 NIC | 2 NICs (1 management, 1 lab) |

**Verify AES-NI is enabled** in your BIOS before installing Proxmox — required for efficient VM encryption and performance.

---

## Proxmox Installation

1. Download Proxmox VE ISO from [proxmox.com](https://www.proxmox.com/en/downloads).
2. Flash to USB with Balena Etcher or Rufus and boot from it.
3. Follow the installer — set a strong root password and a static IP for the management interface.
4. After reboot, access the web UI at `https://<proxmox-ip>:8006`.

**Post-install:**
```bash
# Add community repo (no subscription required)
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" \
  > /etc/apt/sources.list.d/pve-no-subscription.list

# Disable enterprise repo
sed -i 's/^deb/# deb/' /etc/apt/sources.list.d/pve-enterprise.list

apt update && apt full-upgrade -y

# Install QEMU guest agent support
apt install -y qemu-guest-agent
```

5. Create a dedicated admin user in **Datacenter → Users** — do not use root for daily operations.
6. Enable AES-NI check: **Node → Summary** should show hardware acceleration.

---

## Network Configuration

Create three Linux bridges in **Node → Network**:

| Bridge | Purpose | IP / Subnet |
|--------|---------|-------------|
| `vmbr0` | WAN / host management | Your host IP (e.g. 192.168.1.x/24) |
| `vmbr1` | Attacker network | No IP on host (internal only) |
| `vmbr2` | Victim network | No IP on host (internal only) |

- `vmbr1` and `vmbr2` should have **no gateway** on the Proxmox host — pfSense controls routing.
- Enable **MAC spoofing** on `vmbr1` and `vmbr2` (required for Security Onion IDS sensors):  
  In the bridge settings, set "Bridge VLAN aware" off and leave the security tab defaults.

---

## pfSense Firewall Setup

1. Download pfSense CE ISO from [netgate.com](https://www.pfsense.org/download/).
2. Create a VM in Proxmox:
   - **OS**: Other (FreeBSD 64-bit)
   - **NICs**: 3 (vmbr0=WAN, vmbr1=attacker LAN, vmbr2=victim LAN)
   - **Storage**: 20 GB
   - **RAM**: 2 GB
3. Install pfSense and configure interfaces:
   - WAN → vmbr0 (DHCP from home router or static)
   - LAN (attacker) → vmbr1 (e.g. 10.10.1.1/24)
   - OPT1 (victim) → vmbr2 (e.g. 10.10.2.1/24)

**Install QEMU guest agent** (run inside pfSense shell):
```bash
pkg install -y qemu-guest-agent
echo 'qemu_guest_agent_enable="YES"' >> /etc/rc.conf.local
echo 'virtio_console_load="YES"' >> /boot/loader.conf.local
service qemu-guest-agent start
```

**Key firewall rules to configure:**
- Allow attacker → victim for simulations (can toggle on/off per exercise)
- Allow victim → Security Onion for log forwarding
- Block all inbound from WAN to lab networks
- Allow outbound NAT from both lab networks through WAN

---

## Security Onion Setup

1. Download Security Onion ISO from [securityonionsolutions.com](https://securityonionsolutions.com/).
2. Create a VM in Proxmox:
   - **RAM**: 12 GB
   - **Storage**: 200 GB
   - **NICs**: 2 (management on vmbr0, monitoring on vmbr1 or vmbr2)
3. Boot the ISO and select **EVAL** installation mode (consolidates manager/search/sensor roles).
4. Assign the management interface a static IP accessible from your Proxmox host.
5. Set the monitoring interface to the network you want to capture (e.g. vmbr2 for victim traffic).

**Notes:**
- EVAL mode is suitable for single-node lab environments.
- Cannot fetch OS URL during install? Download the ISO directly instead of using the online installer.
- Virtual switches must allow MAC spoofing for the IDS/sensor interface to capture promiscuously.

---

## Victim VM Setup (Windows)

1. Create Windows 10/11 or Windows Server 2022 VMs on vmbr2.
   - Recommended: 4 GB RAM, 60 GB storage per VM
2. Install the **QEMU guest agent**: download from Proxmox VirtIO driver ISO.
3. Set static IPs in the 10.10.2.0/24 range with gateway pointing to pfSense OPT1 (10.10.2.1).
4. Take a **baseline snapshot** before installing any additional tools.

---

## Sysmon Deployment

Sysmon provides detailed Windows event logging for process creation, network connections, file changes, and more.

```powershell
# Download Sysmon
Invoke-WebRequest -Uri https://download.sysinternals.com/files/Sysmon.zip -OutFile Sysmon.zip
Expand-Archive Sysmon.zip -DestinationPath C:\Tools\Sysmon

# Download SwiftOnSecurity config (recommended baseline)
Invoke-WebRequest -Uri https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml `
  -OutFile C:\Tools\Sysmon\sysmonconfig.xml

# Install Sysmon with the config
C:\Tools\Sysmon\Sysmon64.exe -accepteula -i C:\Tools\Sysmon\sysmonconfig.xml
```

See [`configs/sysmon/sysmon-config.xml`](../configs/sysmon/sysmon-config.xml) for a customized config used in this lab.

Verify Sysmon is running:
```powershell
Get-Service Sysmon64
# Check Event Viewer → Applications and Services Logs → Microsoft → Windows → Sysmon → Operational
```

---

## Attacker VM Setup (Kali Linux)

1. Download Kali Linux ISO from [kali.org](https://www.kali.org/get-kali/).
2. Create a VM on vmbr1 (attacker network).
   - 4 GB RAM, 60 GB storage
3. Set a static IP in the 10.10.1.0/24 range with gateway 10.10.1.1 (pfSense attacker LAN).
4. Update and install tools:
   ```bash
   sudo apt update && sudo apt full-upgrade -y
   # Mimikatz (via Wine on Linux or use Windows VM for PowerShell-based tools)
   # Atomic Red Team is installed on the Windows victim VMs
   ```

Check storage after installation:
```bash
lsblk
df -h
```

---

## SIEM Setup

### Splunk (Free)
1. Download Splunk Enterprise from [splunk.com](https://www.splunk.com/en_us/download/splunk-enterprise.html) (free license: 500 MB/day ingestion).
2. Install on a dedicated Ubuntu VM or directly on the Security Onion host.
3. Deploy the **Splunk Universal Forwarder** on victim Windows VMs to forward Sysmon events.
4. See [`configs/splunk/inputs.conf`](../configs/splunk/inputs.conf) for the forwarder configuration.

### Wazuh (Open Source)
1. Follow the [Wazuh quickstart guide](https://documentation.wazuh.com/current/quickstart.html).
2. Deploy Wazuh agent on Windows victim VMs.
3. See [`configs/wazuh/local_rules.xml`](../configs/wazuh/local_rules.xml) for custom detection rules.

---

## Remote Access (Tailscale)

Tailscale provides secure, MFA-protected remote access to the lab without exposing any ports publicly.

```bash
# Install Tailscale on Proxmox host (Debian/Ubuntu)
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up --advertise-routes=10.10.1.0/24,10.10.2.0/24 --accept-routes
```

Enable **subnet routing** in the Tailscale admin console for the lab subnets.  
Enable **MFA** on your Tailscale account before advertising routes.

**Optional: Cloudflare Tunnel**  
For web-based access (e.g., Proxmox web UI) via Cloudflare Zero Trust:
```bash
# Install cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared-linux-amd64.deb
cloudflared tunnel login
cloudflared tunnel create soc-lab
```

---

## Next Steps

After completing setup:
1. Run attack simulations → [`attack-simulations/README.md`](../attack-simulations/README.md)
2. Apply detection rules → [`detections/README.md`](../detections/README.md)
3. Investigate cases → [`investigation-cases/README.md`](../investigation-cases/README.md)
