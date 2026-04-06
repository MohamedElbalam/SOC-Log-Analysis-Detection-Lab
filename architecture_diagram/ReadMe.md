
# Home Lab Architecture for Security Detection

This repository showcases the architecture of my home lab, designed for security testing and detection. It includes attacker and victim networks, monitoring with Security Onion, and firewall protection with pfSense. The lab simulates a real-world corporate environment where attacks can be launched, detected, and investigated end-to-end.

## Architecture Diagram

The following diagram illustrates the architecture of my security lab setup. It includes two networks: an **Attacker Network** (for simulating attacks) and a **Victim Network** (with different operating systems for testing). The traffic between these networks is monitored by **Security Onion** for detection and analysis, with all logs centralized for SIEM correlation.

![Lab Architecture Diagram](/architecture_diagram/Detection_lab.drawio(5).svg)

## Components of the Lab

1. **Proxmox VE (Virtualization Host)**
   - The host running all the virtual machines (VMs) in this setup.
   - It manages the attacker, victim, and monitoring VMs through **Linux Bridges (vmbr0, vmbr1, vmbr2)**.

2. **pfSense Firewall**
   - A **pfSense firewall** sits between the attacker and victim networks.
   - It controls traffic flow and provides protection to the victim network.
   - It also enables **NAT** for outbound internet access.
   - Firewall rules allow attacker-to-victim traffic while denying victim-initiated connections back to the attacker network.

3. **Security Onion**
   - **Security Onion** is used for monitoring network traffic and centralizing logs.
   - It runs IDS/NSM tools like **Suricata** and **Zeek** to detect any malicious activities.
   - It listens on the attacker (vmbr1) and victim (vmbr2) networks to monitor east-west and north-south traffic.
   - Hosts **Wazuh** for host-based log collection and **Elasticsearch/Kibana** for search and visualization.

4. **Attacker Network (vmbr1) — 10.10.10.0/24**
   - The attacker network contains **Kali Linux** (10.10.10.50) and **Parrot OS** (10.10.10.51), which are used to simulate various attack techniques.
   - These VMs can launch attacks against the victim network and external systems.
   - Security Onion passively monitors this network segment (10.10.10.100).

5. **Victim Network (vmbr2) — 10.20.20.0/24**
   - The victim network includes multiple operating systems to act as targets:
     - **Windows 10** (10.20.20.10)
     - **Windows 11** (10.20.20.11)
     - **Windows Server 2022** (10.20.20.20)
     - **Kioptrix** (10.20.20.30) — a vulnerable Linux machine for CTF-style exercises
   - Security Onion passively monitors this network segment (10.20.20.100).
   - All Windows victims run **Sysmon** and **WinLogBeat** to forward endpoint logs.

6. **Management Network (vmbr0) — 192.168.1.0/24**
   - Analyst workstation (192.168.1.100) accesses the Security Onion web UI and Kibana dashboards over HTTPS.
   - Proxmox host (192.168.1.10) and pfSense WAN interface (192.168.1.50) reside here.

7. **Internet (WAN)**
   - **Outbound internet access** is provided through pfSense, allowing the attacker VMs to connect to external targets for reconnaissance, C2 communication, or downloading payloads.

## Logging Architecture

### Log Sources
1. **Windows Victims** — Sysmon (process creation, network connections, file events), Windows Event Logs
2. **Linux Victim** — Syslog, auth logs
3. **Network** — Suricata IDS alerts, Zeek NSM connection logs

### Log Forwarding Pipeline
- **Windows:** Sysmon Agent → WinLogBeat → Security Onion Wazuh Manager
- **Linux:** Rsyslog → Security Onion Syslog Receiver → Wazuh
- **Network:** Suricata/Zeek → Eve JSON → Elasticsearch

### Log Aggregation
- Centralized in Security Onion (Wazuh + Elasticsearch)
- Correlation and enrichment of events across host and network sources
- Real-time alert generation via Suricata and Wazuh rules

For the full logging strategy see [LOGGING_ARCHITECTURE.md](LOGGING_ARCHITECTURE.md).

## How to Set Up the Lab

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/MohamedElbalam/SOC-Log-Analysis-Detection-Lab.git
   cd SOC-Log-Analysis-Detection-Lab
   ```

2. **Install Proxmox VE** on bare-metal hardware (minimum 32 GB RAM, 8 cores, 1 TB storage). See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for hardware specifications.

3. **Create Network Bridges** in Proxmox:
   - `vmbr0` — Management network (192.168.1.0/24)
   - `vmbr1` — Attacker network (10.10.10.0/24)
   - `vmbr2` — Victim network (10.20.20.0/24)

4. **Deploy pfSense Firewall:**
   - WAN interface on `vmbr0` (192.168.1.50)
   - LAN interfaces on `vmbr1` and `vmbr2`
   - Configure firewall rules to allow attacker→victim and deny victim→attacker
   - Enable NAT for outbound internet access

5. **Deploy Security Onion:**
   - Attach interfaces to `vmbr1` and `vmbr2` for passive monitoring
   - Attach management interface to `vmbr0`
   - Run the Security Onion setup wizard (choose Distributed or Standalone)
   - Enable Suricata, Zeek, Wazuh, Elasticsearch, and Kibana

6. **Deploy Victim VMs:**
   - Attach all victim VMs to `vmbr2`
   - Assign static IPs: Windows 10 (10.20.20.10), Windows 11 (10.20.20.11), Windows Server 2022 (10.20.20.20), Kioptrix (10.20.20.30)

7. **Deploy Attacker VMs:**
   - Attach Kali Linux and Parrot OS to `vmbr1`
   - Assign IPs: Kali (10.10.10.50), Parrot (10.10.10.51)

8. **Install Sysmon on Windows Victims:**
   ```powershell
   # Download Sysmon and the SwiftOnSecurity config
   Invoke-WebRequest -Uri https://download.sysinternals.com/files/Sysmon.zip -OutFile Sysmon.zip
   Expand-Archive Sysmon.zip
   .\Sysmon64.exe -accepteula -i sysmonconfig.xml
   ```

9. **Install and Configure WinLogBeat:**
   - Download WinLogBeat on each Windows victim
   - Point it to the Security Onion Wazuh manager (10.20.20.100 / 10.10.10.100)
   - Restart the WinLogBeat service

10. **Configure Linux Log Forwarding:**
    ```bash
    # On Kioptrix — forward syslog to Security Onion
    echo "*.* @10.20.20.100:514" >> /etc/rsyslog.conf
    systemctl restart rsyslog
    ```

11. **Verify Connectivity and Log Ingestion:**
    - From analyst workstation, open `https://192.168.1.100` (Security Onion web UI)
    - Check Kibana dashboards for incoming logs
    - Trigger a test alert (e.g., `nmap` scan from Kali) and confirm Suricata fires

## Additional Documentation

| Document | Description |
|---|---|
| [LOGGING_ARCHITECTURE.md](LOGGING_ARCHITECTURE.md) | Full logging strategy — sources, forwarding, aggregation |
| [NETWORK_TOPOLOGY.md](NETWORK_TOPOLOGY.md) | IP addressing, VLANs, firewall rules, network flows |
| [DATA_FLOW.md](DATA_FLOW.md) | Attack and detection data flow diagrams |
| [SIEM_INTEGRATION.md](SIEM_INTEGRATION.md) | Security Onion component configuration and detection rules |
| [ANALYST_WORKFLOW.md](ANALYST_WORKFLOW.md) | Investigation process, Kibana usage, example scenarios |
| [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) | Hardware specs, VM table, step-by-step deployment, troubleshooting |

## Troubleshooting

| Issue | Solution |
|---|---|
| Logs not arriving in Elasticsearch | Check WinLogBeat service status and verify network connectivity to Security Onion |
| Suricata not alerting | Confirm Security Onion interfaces are in promiscuous mode on vmbr1 and vmbr2 |
| pfSense blocking expected traffic | Review firewall rules — ensure attacker network has `allow any` to victim network |
| Kibana dashboards empty | Verify index pattern is set to `*:logstash-*` or `*:so-*` |
| Wazuh agent not connecting | Check that port 1514/UDP is open between victim VMs and Security Onion |
