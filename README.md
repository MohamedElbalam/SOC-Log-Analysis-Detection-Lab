# SOC Log Analysis & Detection Lab

> A hands-on home lab that simulates a real Security Operations Center (SOC) workflow — from attack simulation to log collection, SIEM analysis, detection engineering, and incident reporting.

| Machines | Networks | SIEM | IDS/NSM |
|----------|----------|------|---------|
| 7 VMs | 3 (Attacker / Monitoring / Victim) | Security Onion / Wazuh | Suricata + Zeek |

---

## Overview

This lab demonstrates end-to-end SOC operations in a fully isolated virtual environment built on **Proxmox VE**. It replicates the kind of infrastructure you would find in a real enterprise SOC, including:

- **Attacker machines** (Kali Linux, Parrot OS) launching realistic attack techniques
- **Victim machines** (Windows 10/11, Windows Server 2022, Kioptrix) acting as target endpoints
- **pfSense firewall** segmenting and controlling traffic between networks
- **Security Onion** performing network and host-based monitoring, alerting, and log analysis

### Skills Developed

| Area | Skills |
|------|--------|
| Log Collection | Sysmon configuration, Windows Event Forwarding, log shipping |
| SIEM | Security Onion dashboards, Wazuh alerts, log analysis |
| Attack Simulation | Process injection, Mimikatz, PowerShell abuse, lateral movement |
| Detection Engineering | Custom Suricata rules, Zeek scripts, SIEM correlation rules |
| Incident Investigation | Alert triage, forensic timeline reconstruction, root-cause analysis |
| Reporting | Professional incident reports, detection summaries |

---

## Architecture

```
                          ┌─────────────────────────────┐
                          │         PROXMOX VE          │
                          │    (Virtualization Host)     │
                          └──────────────┬──────────────┘
                                         │
                    ┌────────────────────┼────────────────────┐
                    │                    │                    │
              vmbr0 (WAN)          vmbr1 (Attacker)    vmbr2 (Victim)
                    │                    │                    │
             ┌──────┴──────┐    ┌────────┴───────┐  ┌────────┴────────┐
             │   pfSense   │    │   Kali Linux   │  │  Windows 10/11  │
             │  Firewall   │    │   Parrot OS    │  │  Win Server 2022│
             └──────┬──────┘    └────────────────┘  │  Kioptrix Linux │
                    │                                └─────────────────┘
             ┌──────┴──────┐
             │  Security   │  ← monitors both vmbr1 and vmbr2
             │   Onion     │
             └─────────────┘
```

See the full diagram and component details in [`architecture_diagram/ReadMe.md`](architecture_diagram/ReadMe.md) and the annotated ASCII breakdown in [`architecture_diagram/ARCHITECTURE_EXPLAINED.md`](architecture_diagram/ARCHITECTURE_EXPLAINED.md).

### Three-Tier Network Design

| Tier | Bridge | Purpose |
|------|--------|---------|
| Attacker | `vmbr1` | Offensive machines — Kali Linux, Parrot OS |
| Monitoring | `vmbr0` | pfSense WAN + Security Onion span port |
| Victim | `vmbr2` | Target endpoints — Windows, Linux |

---

## Lab Features

- **Comprehensive attack scenarios** — network scans, exploitation, credential harvesting, lateral movement, data exfiltration
- **Real-world detection** — Suricata IDS rules, Zeek network logs, Wazuh host alerts
- **Full traffic capture** — pcap files and Zeek conn logs for every scenario
- **Multiple target OS types** — Windows endpoints, Windows Server, vulnerable Linux
- **Professional investigation workflow** — alert → triage → timeline → report

---

## Quick Start

### Prerequisites

| Requirement | Minimum |
|-------------|---------|
| RAM | 32 GB |
| CPU | 8 cores (VT-x/AMD-V enabled) |
| Storage | 500 GB SSD |
| Hypervisor | Proxmox VE 8.x |

### Setup Steps

1. **Clone this repository**
   ```bash
   git clone https://github.com/MohamedElbalam/SOC-Log-Analysis-Detection-Lab.git
   cd SOC-Log-Analysis-Detection-Lab
   ```

2. **Set up Proxmox and network bridges** — follow [`lab-setup/proxmox/readme.md`](lab-setup/proxmox/readme.md)

3. **Deploy pfSense** — follow [`lab-setup/pfsense/readme.md`](lab-setup/pfsense/readme.md)

4. **Deploy Security Onion** — follow [`lab-setup/security-onion-os/README.md`](lab-setup/security-onion-os/README.md)

5. **Set up attacker machines** — follow [`lab-setup/kali-linux-main/READ.md`](lab-setup/kali-linux-main/READ.md)

6. **Set up victim machines** — follow [`lab-setup/Ubuntu-main/readME.md`](lab-setup/Ubuntu-main/readME.md)

7. **Configure remote access** — follow [`lab-setup/remote-access/readme.md`](lab-setup/remote-access/readme.md)

### First Attack Simulation

1. Log in to your Kali Linux VM
2. Pick a scenario from [`attack-simulations/`](attack-simulations/)
3. Follow the reproduction steps in the scenario README
4. Open Security Onion dashboards and observe alerts
5. Investigate using the workflow in [`investigation-cases/`](investigation-cases/)
6. Write up your findings using the template in [`reports/`](reports/)

---

## Project Structure

```
SOC-Log-Analysis-Detection-Lab/
├── README.md                    ← You are here
├── architecture_diagram/        ← Network diagrams and architecture docs
│   ├── ReadMe.md                ← Component details and setup overview
│   ├── ARCHITECTURE_EXPLAINED.md← ASCII diagrams and data flow
│   └── Detection_lab.drawio.svg ← Visual architecture diagram
├── lab-setup/                   ← Step-by-step installation guides
│   ├── proxmox/                 ← Hypervisor setup
│   ├── pfsense/                 ← Firewall configuration
│   ├── security-onion-os/       ← SIEM/IDS deployment
│   ├── kali-linux-main/         ← Attacker machine setup
│   ├── Ubuntu-main/             ← Victim machine setup
│   └── remote-access/           ← VPN / SSH access configuration
├── attack-simulations/          ← Documented attack scenarios
├── detections/                  ← Detection rules and SIEM queries
├── investigation-cases/         ← Guided incident investigation exercises
├── reports/                     ← Analysis reports and templates
├── screenshots/                 ← Lab screenshots and evidence captures
└── tool-used/                   ← Tools reference and documentation
```

---

## Key Components

### Proxmox VE (Hypervisor)
Hosts all virtual machines and manages three Linux bridges (`vmbr0`, `vmbr1`, `vmbr2`) that create isolated network segments. Snapshots are taken before each attack scenario so the environment can be reset quickly.

### pfSense (Firewall / Router)
Acts as the gateway between the attacker network, victim network, and WAN. Enforces firewall rules, performs NAT for outbound traffic, and provides a central point for traffic logging and control.

### Security Onion (SIEM / IDS / NSM)
The core monitoring platform. Runs **Suricata** (IDS), **Zeek** (NSM/protocol analysis), and **Wazuh** (host-based detection). Receives logs from victim endpoints and captures traffic from both network segments.

### Attacker Machines
- **Kali Linux** — primary offensive platform with a full suite of penetration testing tools
- **Parrot OS** — secondary attacker machine for additional tool coverage

### Victim Machines
- **Windows 10 / Windows 11** — modern endpoints with Sysmon installed for host logging
- **Windows Server 2022** — Active Directory and server workload target
- **Kioptrix** — intentionally vulnerable Linux machine for CTF-style exercises

### Monitoring Agents
- **Sysmon** — detailed Windows event logging (process creation, network connections, registry)
- **Zeek** — network protocol analysis and conn logs
- **Suricata** — signature-based IDS alerts

---

## Learning Path

Follow this recommended progression to get the most from the lab:

1. **Architecture** — Read [`architecture_diagram/ReadMe.md`](architecture_diagram/ReadMe.md) to understand the network design
2. **Lab Setup** — Work through [`lab-setup/`](lab-setup/) guides in order
3. **First Scenario** — Run a basic network scan from Kali and find it in Security Onion
4. **Attack Simulations** — Progress through scenarios in [`attack-simulations/`](attack-simulations/)
5. **Detection Engineering** — Explore and customise rules in [`detections/`](detections/)
6. **Investigation** — Practice alert triage using [`investigation-cases/`](investigation-cases/)
7. **Reporting** — Document findings using templates in [`reports/`](reports/)

---

## Skills Demonstrated

- **System Administration** — Linux and Windows server configuration, VM management
- **Networking** — Firewall rules, NAT, VLANs, network segmentation, packet capture
- **Offensive Security** — Attack techniques, tool usage, exploitation, C2 simulation
- **Defensive Security** — IDS/IPS tuning, SIEM correlation, detection rule creation
- **Incident Response** — Alert triage, log analysis, forensic timeline reconstruction
- **Security Tooling** — Sysmon, Zeek, Suricata, Security Onion, Wazuh, Kali Linux tools
- **Documentation** — Technical writing, incident reporting, professional communication

---

## Next Steps

| Resource | Location |
|----------|----------|
| Architecture details | [`architecture_diagram/ReadMe.md`](architecture_diagram/ReadMe.md) |
| ASCII diagram + data flow | [`architecture_diagram/ARCHITECTURE_EXPLAINED.md`](architecture_diagram/ARCHITECTURE_EXPLAINED.md) |
| Lab setup guides | [`lab-setup/`](lab-setup/) |
| Attack scenarios | [`attack-simulations/`](attack-simulations/) |
| Detection rules | [`detections/`](detections/) |
| Investigation exercises | [`investigation-cases/`](investigation-cases/) |
| Reports & templates | [`reports/`](reports/) |

---

> **Issues / Feedback** — Open a GitHub issue in this repository to report problems or suggest improvements.
