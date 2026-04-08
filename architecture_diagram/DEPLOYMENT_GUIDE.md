# Complete Lab Deployment and Configuration Guide

## Hardware Requirements

### Proxmox Host (bare-metal server)
- **CPU**: 8+ cores (Intel or AMD with VT-x/AMD-V virtualization enabled in BIOS)
- **RAM**: 64 GB recommended (32 GB minimum)
- **Storage**: 500 GB+ SSD (for VMs and log storage)
- **Network**: Dual NICs recommended (one for management, one for VM traffic)

## Software Versions

### Hypervisor
- Proxmox VE 8.0+

### Security Appliances
- pfSense 2.7+
- Security Onion 2.4+

### Attacker Operating Systems
- Kali Linux 2024.1+
- Parrot Security OS 6.1+

### Victim Operating Systems
- Windows 10 22H2
- Windows 11 23H2
- Windows Server 2022
- Kioptrix 1.0 (intentionally vulnerable Linux)

### Logging and Detection Agents
- Sysmon 15.0+
- Winlogbeat 8.10+
- Zeek 6.0+
- Suricata 7.0+

## VM Specifications

| VM | vCPU | RAM | Disk | OS |
|----|------|-----|------|----|
| Kali Linux | 4 | 8 GB | 50 GB | Linux |
| Parrot OS | 4 | 8 GB | 50 GB | Linux |
| Windows 10 | 4 | 8 GB | 100 GB | Windows |
| Windows 11 | 4 | 8 GB | 100 GB | Windows |
| Windows Server 2022 | 4 | 16 GB | 100 GB | Windows |
| Kioptrix | 2 | 2 GB | 20 GB | Linux |
| Security Onion | 8 | 32 GB | 200 GB | Linux |

## Deployment Steps

### Step 1: Proxmox Installation
1. Download the Proxmox VE ISO from https://www.proxmox.com/en/downloads
2. Boot the host from the ISO and follow the installation wizard
3. Configure a static IP for the management interface (e.g., 192.168.1.10)
4. After installation, access the web UI: `https://192.168.1.10:8006`
5. Update Proxmox: `apt update && apt dist-upgrade`

### Step 2: Network Bridge Configuration
In Proxmox web UI → Node → Network → Create Linux Bridge:

```
vmbr0: Management network
  IP:     192.168.1.10/24
  Bridge: Attach to physical NIC

vmbr1: Attacker network (internal only)
  IP:     (none — bridge only)
  VLAN:   100

vmbr2: Victim network (internal only)
  IP:     (none — bridge only)
  VLAN:   200
```

### Step 3: pfSense Deployment
1. Download pfSense ISO from https://www.pfsense.org/download/
2. Create VM: 2 vCPU, 4 GB RAM, 20 GB disk
3. Attach interfaces:
   - `vtnet0` → vmbr0 (WAN, receives 192.168.1.50 from DHCP or static)
   - `vtnet1` → vmbr1 (LAN for attackers, 10.10.10.1/24)
   - `vtnet2` → vmbr2 (LAN for victims, 10.20.20.1/24)
4. Complete the pfSense setup wizard
5. Configure firewall rules (see [NETWORK_TOPOLOGY.md](./NETWORK_TOPOLOGY.md) for rule table)
6. Enable NAT on WAN interface for attacker VMs

### Step 4: Security Onion Deployment
1. Download Security Onion ISO from https://github.com/Security-Onion-Solutions/securityonion
2. Create VM: 8 vCPU, 32 GB RAM, 200 GB disk
3. Attach interfaces:
   - `eth0` → vmbr2 (management, static IP: 10.20.20.100)
   - `eth1` → vmbr1 (passive monitoring — promiscuous mode)
   - `eth2` → vmbr2 (passive monitoring — promiscuous mode)
4. Boot and complete the Security Onion installer
5. Select **Standalone** mode for a single-server deployment
6. Designate `eth0` as management, `eth1`/`eth2` as monitor interfaces
7. Access the dashboard: `https://10.20.20.100`

### Step 5: Victim Machine Setup
For each Windows victim machine:
1. Create VM with specs from the table above
2. Attach network interface to vmbr2
3. Set static IP (see [NETWORK_TOPOLOGY.md](./NETWORK_TOPOLOGY.md))
4. Install Windows OS from ISO
5. Disable Windows Defender (for lab testing only — do not do this in production)
6. Enable PowerShell script block logging via Group Policy

For Kioptrix:
1. Download Kioptrix VM image
2. Import into Proxmox
3. Attach to vmbr2, set IP 10.20.20.30

### Step 6: Attacker Machine Setup
For Kali Linux and Parrot OS:
1. Create VM with specs from the table above
2. Attach to vmbr1
3. Set static IPs (Kali: 10.10.10.50, Parrot: 10.10.10.51)
4. Install from ISO and update: `apt update && apt upgrade`

### Step 7: Sysmon Installation on Windows Victims
```powershell
# Download Sysmon and the SwiftOnSecurity config
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile C:\Sysmon.zip
Expand-Archive -Path C:\Sysmon.zip -DestinationPath C:\Sysmon

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" `
  -OutFile C:\Sysmon\sysmonconfig.xml

# Install Sysmon with the config
C:\Sysmon\Sysmon64.exe -accepteula -i C:\Sysmon\sysmonconfig.xml

# Verify Sysmon is running
Get-Service Sysmon64
```

### Step 8: Winlogbeat Installation on Windows Victims
```powershell
# Download Winlogbeat
Invoke-WebRequest -Uri "https://artifacts.elastic.co/downloads/beats/winlogbeat/winlogbeat-8.10.0-windows-x86_64.zip" `
  -OutFile C:\winlogbeat.zip
Expand-Archive -Path C:\winlogbeat.zip -DestinationPath "C:\Program Files\winlogbeat"

# Edit winlogbeat.yml — set output.elasticsearch host to Security Onion
# output.elasticsearch:
#   hosts: ["10.20.20.100:9200"]

# Install and start the service
cd "C:\Program Files\winlogbeat"
.\install-service-winlogbeat.ps1
Start-Service winlogbeat
```

### Step 9: Rsyslog Configuration on Kioptrix
```bash
# Forward all syslog to Security Onion
echo "*.* @10.20.20.100:514" | sudo tee -a /etc/rsyslog.conf

# Restart rsyslog to apply changes
sudo systemctl restart rsyslog

# Verify logs are being sent
logger "Test log from Kioptrix"
```

### Step 10: SIEM Validation
1. Log into Security Onion: `https://10.20.20.100`
2. Navigate to **Kibana → Discover**
3. Verify events from all log sources are arriving:
   - Sysmon events from Windows victims
   - Rsyslog events from Kioptrix
   - Suricata and Zeek alerts from both network interfaces
4. Run a test attack from Kali (e.g., `nmap -sS 10.20.20.0/24`)
5. Confirm Suricata generates a "Network Scan" alert in the dashboard

## Troubleshooting Guide

### Issue 1: VMs Cannot Communicate Between Networks
- **Check**: Verify pfSense firewall rules allow the intended traffic
- **Check**: Confirm each VM is connected to the correct bridge (vmbr1 or vmbr2)
- **Check**: Verify IP addresses and gateway settings on each VM
- **Fix**: Review pfSense logs under Firewall → Logs to see blocked traffic

### Issue 2: Logs Not Arriving at Security Onion
- **Check**: Confirm Winlogbeat service is running on Windows VMs (`Get-Service winlogbeat`)
- **Check**: Verify Rsyslog is running on Kioptrix (`systemctl status rsyslog`)
- **Check**: Test network connectivity from victim to Security Onion (`ping 10.20.20.100`)
- **Check**: Verify Security Onion firewall allows inbound syslog (port 514) and beats (port 5044)
- **Fix**: Check Security Onion log ingestion status: `sudo so-status`

### Issue 3: Suricata/Zeek Alerts Not Generating
- **Check**: Confirm Security Onion monitoring interfaces (eth1, eth2) are in promiscuous mode
- **Check**: Verify Suricata and Zeek are running: `sudo so-status`
- **Check**: Confirm traffic is actually flowing through vmbr1/vmbr2 (run a test scan)
- **Fix**: Restart sensors: `sudo so-sensor-restart`

### Issue 4: Security Onion Dashboard Not Accessible
- **Check**: Verify Security Onion is running: `sudo so-status`
- **Check**: Confirm the analyst workstation can reach 10.20.20.100 (routing via pfSense)
- **Check**: Verify HTTPS certificate is accepted in the browser
- **Fix**: Restart Security Onion services: `sudo so-restart`

### Issue 5: Performance Issues
- **Check**: Proxmox host resource usage (CPU, RAM, disk I/O)
- **Check**: Elasticsearch heap usage: `curl -s localhost:9200/_cat/nodes?v`
- **Fix**: Reduce log verbosity on Sysmon (tune the config to exclude noisy events)
- **Fix**: Add more RAM to the Security Onion VM if Elasticsearch is memory-constrained

## Related Documentation

- [LOGGING_ARCHITECTURE.md](./LOGGING_ARCHITECTURE.md) — log sources and forwarding pipeline
- [NETWORK_TOPOLOGY.md](./NETWORK_TOPOLOGY.md) — network segments, IPs, and firewall rules
- [DATA_FLOW.md](./DATA_FLOW.md) — end-to-end data flow and attack scenario walkthroughs
- [SIEM_INTEGRATION.md](./SIEM_INTEGRATION.md) — SIEM component details and detection rules
- [ANALYST_WORKFLOW.md](./ANALYST_WORKFLOW.md) — investigation workflow and reporting
