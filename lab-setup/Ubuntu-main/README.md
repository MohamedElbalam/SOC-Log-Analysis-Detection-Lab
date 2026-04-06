# Ubuntu / Windows Victim Machine Setup

This guide covers setting up victim machines on the victim network (vmbr2). Both Ubuntu and Windows targets are covered.

## Ubuntu Target

### VM Specifications

| Setting | Value |
|---------|-------|
| RAM | 4 GB |
| CPU | 2 cores |
| Disk | 50 GB |
| NIC | vmbr2 (victim network, 192.168.20.0/24) |
| OS | Ubuntu Server 22.04 LTS |

### Installation Steps

1. Download Ubuntu Server ISO from https://ubuntu.com/download/server
2. Create VM in Proxmox (4 GB RAM, 2 cores, 50 GB disk, NIC on vmbr2)
3. Boot and follow the guided installer
4. Set hostname: `ubuntu-victim`
5. Create user: `labuser` with a strong password
6. Enable OpenSSH server during installation

### Post-Installation

```bash
sudo apt update && sudo apt upgrade -y

# Install QEMU guest agent
sudo apt install -y qemu-guest-agent
sudo systemctl enable --now qemu-guest-agent

# Install monitoring agent (choose one)
# Option A: Wazuh agent
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo apt-key add -
echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee /etc/apt/sources.list.d/wazuh.list
sudo apt update && sudo apt install -y wazuh-agent

# Option B: Filebeat (for Elasticsearch/Security Onion)
sudo apt install -y filebeat
```

### Set Static IP

```bash
# /etc/netplan/00-installer-config.yaml
network:
  ethernets:
    ens18:
      dhcp4: false
      addresses: [192.168.20.20/24]
      gateway4: 192.168.20.1
      nameservers:
        addresses: [8.8.8.8]
  version: 2
```

```bash
sudo netplan apply
```

---

## Windows Victim (Windows 10/11 / Server 2022)

### VM Specifications

| Setting | Value |
|---------|-------|
| RAM | 4–8 GB |
| CPU | 2–4 cores |
| Disk | 80 GB |
| NIC | vmbr2 (victim network, 192.168.20.0/24) |

### Installation Steps

1. Obtain Windows ISO (Windows 10/11/Server 2022 evaluation from Microsoft)
2. Create VM in Proxmox → attach Windows ISO + VirtIO drivers ISO
3. During install, load VirtIO storage driver when Windows cannot find disks
4. Complete standard Windows installation

### Post-Installation

#### Install QEMU Guest Agent

Download and install the VirtIO guest tools package from the VirtIO ISO.

#### Install Sysmon

```powershell
# Download Sysmon
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile "C:\Tools\Sysmon.zip"
Expand-Archive "C:\Tools\Sysmon.zip" -DestinationPath "C:\Tools\Sysmon\"

# Download SwiftOnSecurity config
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile "C:\Tools\sysmonconfig.xml"

# Install Sysmon with config
C:\Tools\Sysmon\Sysmon64.exe -accepteula -i C:\Tools\sysmonconfig.xml
```

#### Forward Logs to SIEM

Install Winlogbeat to forward Windows Event Logs and Sysmon logs to Elasticsearch:

```powershell
# Download Winlogbeat from elastic.co
# Configure winlogbeat.yml to point to Security Onion Elasticsearch IP
# Install as a service
.\install-service-winlogbeat.ps1
Start-Service winlogbeat
```

### Set Static IP

- Open Network & Internet Settings → Change adapter options
- Right-click Ethernet → Properties → IPv4 → Use the following IP address
- IP: `192.168.20.30` | Mask: `255.255.255.0` | Gateway: `192.168.20.1`
- DNS: `8.8.8.8`

## Verification

```bash
# From Security Onion — confirm victim logs are arriving
# Open Kibana → Discover → filter: host.name: "ubuntu-victim" or "windows-victim"
# Should see recent Sysmon / system events
```
