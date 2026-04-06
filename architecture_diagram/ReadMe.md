
# Home Lab Architecture for Security Detection

This repository showcases the architecture of my home lab, designed for security testing and detection. It includes attacker and victim networks, monitoring with Security Onion, and firewall protection with pfSense.

## Architecture Diagram

The following diagram illustrates the architecture of my security lab setup. It includes two networks: an **Attacker Network** (for simulating attacks) and a **Victim Network** (with different operating systems for testing). The traffic between these networks is monitored by **Security Onion** for detection and analysis.

![Lab Architecture Diagram](/architecture_diagram/Detection_lab.drawio(5).svg)

## Components of the Lab

1. **Proxmox VE (Virtualization Host)**
   - The host running all the virtual machines (VMs) in this setup.
   - It manages the attacker, victim, and monitoring VMs through **Linux Bridges (vmbr0, vmbr1, vmbr2)**.

2. **pfSense Firewall**
   - A **pfSense firewall** sits between the attacker and victim networks.
   - It controls traffic flow and provides protection to the victim network.
   - It also enables **NAT** for outbound internet access.

3. **Security Onion**
   - **Security Onion** is used for monitoring network traffic.
   - It runs IDS/NSM tools like **Suricata** and **Zeek** to detect any malicious activities.
   - It listens on the attacker (vmbr1) and victim (vmbr2) networks to monitor east-west and north-south traffic.

4. **Attacker Network (vmbr1)**
   - The attacker network contains **Kali Linux** and **Parrot OS**, which are used to simulate various attack techniques.
   - These VMs can launch attacks against the victim network and external systems.

5. **Victim Network (vmbr2)**
   - The victim network includes multiple operating systems to act as targets:
     - **Windows 10**
     - **Windows 11**
     - **Windows Server 2022**
     - **Kioptrix** (a vulnerable Linux machine for CTF-style exercises)

6. **Internet (WAN)**
   - **Outbound internet access** is provided through pfSense, allowing the attacker VMs to connect to external targets for reconnaissance, C2 communication, or downloading payloads.

## Logging Architecture

All logs generated in this lab flow through a centralized pipeline into Security Onion for storage, analysis, and alerting.

### Log Sources
- **Windows Victims**: Sysmon (endpoint telemetry), Windows Event Logs, PowerShell logs — forwarded via WinLogBeat/Windows Event Forwarder
- **Linux Victim (Kioptrix)**: Syslog, auth logs, Apache/SSH logs — forwarded via Rsyslog
- **Network Traffic**: Suricata IDS alerts and Zeek NSM logs captured passively on vmbr1 and vmbr2

### Log Forwarding Pipeline
```
Sysmon Agent     → Windows Event Forwarder → Security Onion (Wazuh)
Linux Rsyslog    → Syslog Receiver         → Security Onion (Wazuh)
Suricata/Zeek    → Eve/JSON logs           → Elasticsearch
```

### Log Aggregation
Security Onion provides centralized indexing via **Elasticsearch**, correlation via **Wazuh** rules, and visualization via **Kibana**. All alert generation and investigation happens through the Security Onion web dashboard.

For detailed information on logging, see:
- [LOGGING_ARCHITECTURE.md](./LOGGING_ARCHITECTURE.md) — log sources, pipeline, and retention
- [DATA_FLOW.md](./DATA_FLOW.md) — end-to-end data flow and traffic patterns
- [SIEM_INTEGRATION.md](./SIEM_INTEGRATION.md) — SIEM component details and detection rules
- [NETWORK_TOPOLOGY.md](./NETWORK_TOPOLOGY.md) — IP addresses, VLANs, and firewall rules
- [ANALYST_WORKFLOW.md](./ANALYST_WORKFLOW.md) — SOC analyst investigation process
- [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) — complete setup and configuration guide

## How to Set Up the Lab

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/MohamedElbalam/SOC-Log-Analysis-Detection-Lab.git
   cd SOC-Log-Analysis-Detection-Lab
   ```

2. **Install Proxmox VE (8.0+):**
   - Download the Proxmox VE ISO from https://www.proxmox.com/en/downloads
   - Install on a bare-metal host with virtualization support enabled in BIOS/UEFI
   - Access the web UI at `https://<host-ip>:8006`

3. **Configure Network Bridges in Proxmox:**
   - `vmbr0` — Management network (192.168.1.0/24)
   - `vmbr1` — Attacker network (10.10.10.0/24, VLAN 100)
   - `vmbr2` — Victim network (10.20.20.0/24, VLAN 200)

4. **Deploy pfSense Firewall:**
   - Create a new VM and install pfSense 2.7+
   - Assign WAN interface to vmbr0 and LAN interfaces to vmbr1/vmbr2
   - Configure firewall rules to allow attacker→victim traffic and block victim→internet
   - Enable NAT for outbound internet access from attacker VMs

5. **Deploy Security Onion:**
   - Create a VM (8 vCPU, 32GB RAM, 200GB disk) and install Security Onion 2.4+
   - Connect monitoring interfaces to vmbr1 and vmbr2 in promiscuous mode
   - Complete the Security Onion setup wizard (standalone or distributed mode)
   - Access the dashboard at `https://10.20.20.100`

6. **Deploy Victim Machines:**
   - **Windows 10** (10.20.20.10): Connect to vmbr2
   - **Windows 11** (10.20.20.11): Connect to vmbr2
   - **Windows Server 2022** (10.20.20.20): Connect to vmbr2
   - **Kioptrix** (10.20.20.30): Connect to vmbr2

7. **Deploy Attacker Machines:**
   - **Kali Linux** (10.10.10.50): Connect to vmbr1
   - **Parrot OS** (10.10.10.51): Connect to vmbr1

8. **Install Sysmon on Windows Victims:**
   ```powershell
   # Download Sysmon and SwiftOnSecurity config
   Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile Sysmon.zip
   Expand-Archive Sysmon.zip
   # Install with recommended config
   .\Sysmon64.exe -accepteula -i sysmonconfig.xml
   ```

9. **Install WinLogBeat on Windows Victims:**
   ```powershell
   # Download WinLogBeat and configure output to Security Onion
   # Edit winlogbeat.yml to point to Security Onion IP
   .\winlogbeat.exe setup
   Start-Service winlogbeat
   ```

10. **Configure Rsyslog on Kioptrix:**
    ```bash
    # Forward syslog to Security Onion
    echo "*.* @10.20.20.100:514" >> /etc/rsyslog.conf
    systemctl restart rsyslog
    ```

11. **Validate Log Flow:**
    - Log into Security Onion dashboard at `https://10.20.20.100`
    - Navigate to Kibana → Discover and verify events from all sources are arriving
    - Run a test attack (e.g., Nmap scan from Kali) and confirm Suricata generates an alert

## Additional Documentation

| File | Description |
|------|-------------|
| [LOGGING_ARCHITECTURE.md](./LOGGING_ARCHITECTURE.md) | Log sources, forwarding pipeline, and retention policy |
| [NETWORK_TOPOLOGY.md](./NETWORK_TOPOLOGY.md) | IP addressing, VLANs, and pfSense firewall rules |
| [DATA_FLOW.md](./DATA_FLOW.md) | End-to-end data flow and example attack scenarios |
| [SIEM_INTEGRATION.md](./SIEM_INTEGRATION.md) | Security Onion components and detection rules |
| [ANALYST_WORKFLOW.md](./ANALYST_WORKFLOW.md) | Investigation workflow and example scenarios |
| [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) | Hardware requirements, VM specs, and deployment steps |
