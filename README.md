# SOC Log Analysis & Detection Lab

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Status: Active](https://img.shields.io/badge/Status-Active-brightgreen)
![Platform: Proxmox](https://img.shields.io/badge/Platform-Proxmox-orange)
![SIEM: Security%20Onion](https://img.shields.io/badge/SIEM-Security%20Onion-blue)
![Firewall: pfSense](https://img.shields.io/badge/Firewall-pfSense-red)

> **⚠️ Educational Use Only:** This lab is designed for controlled, isolated environments. All attack simulations must only be run against systems you own or have explicit permission to test. Never run these techniques against production or unauthorized systems.

---

## 📋 Overview

This project simulates a real-world **Security Operations Center (SOC)** environment built on Proxmox virtualization. It demonstrates a complete detection and response workflow — from attack simulation to log analysis, threat detection, and professional incident reporting.

The lab is designed to help develop and demonstrate core SOC analyst skills:

| Skill | Tool |
|---|---|
| Log Collection | Sysmon, Security Onion (Zeek/Suricata) |
| Log Analysis & SIEM | Splunk / Wazuh |
| Attack Simulation | Kali Linux, Parrot OS, Atomic Red Team |
| Detection Engineering | Custom Splunk SPL / Wazuh rules |
| Network Monitoring | pfSense, Security Onion |
| Incident Investigation | Structured case analysis |
| Reporting | Professional SOC-style reports |

---

## 🏗️ Lab Architecture

The lab is built on a **Proxmox VE** host with isolated virtual networks:

```
Internet (WAN)
      │
 ┌────▼────┐
 │ pfSense │  ← Firewall / Router / NAT
 └──┬──┬───┘
    │  │
    │  └──── vmbr1 (Attacker Network)
    │              ├── Kali Linux
    │              └── Parrot OS
    │
    └──────── vmbr2 (Victim Network)
                   ├── Windows 10
                   ├── Windows 11
                   ├── Windows Server 2022
                   └── Kioptrix (vulnerable VM)

Security Onion (span port on vmbr1 + vmbr2)
  └── Suricata IDS + Zeek NSM + SOC dashboards
```

See [`architecture_diagram/`](./architecture_diagram/) for the full visual diagram.

---

## 📁 Project Structure

```
SOC-Log-Analysis-Detection-Lab/
├── README.md                    ← This file
├── LICENSE
├── CONTRIBUTING.md
├── SECURITY.md
├── CHANGELOG.md
├── .gitignore
│
├── architecture_diagram/        ← Lab network diagrams
├── lab-setup/                   ← Setup guides per component
│   ├── proxmox/
│   ├── pfsense/
│   ├── security-onion-os/
│   ├── kali-linux-main/
│   ├── Ubuntu-main/
│   └── remote-access/
│
├── attack-simulations/          ← Documented attack techniques
├── detections/                  ← Detection rules & SIEM queries
├── investigation-cases/         ← Incident analysis case studies
├── reports/                     ← SOC-style incident reports
├── screenshots/                 ← Lab evidence screenshots
├── tool-used/                   ← Tool reference and documentation
├── configs/                     ← Example configuration files
├── scripts/                     ← Automation and helper scripts
├── logs/                        ← Sample/sanitized log files
└── docs/                        ← Extended documentation
    ├── SETUP.md
    └── ARCHITECTURE.md
```

---

## ✅ Prerequisites

Before building this lab, ensure you have:

**Hardware:**
- CPU with virtualization support (Intel VT-x / AMD-V) and AES-NI enabled
- Minimum 32 GB RAM (Security Onion alone requires 12 GB)
- Minimum 500 GB storage (SSD recommended)
- At least 2 network interfaces (for WAN/LAN separation)

**Software & ISOs:**
- [Proxmox VE](https://www.proxmox.com/en/downloads) (bare-metal hypervisor)
- [pfSense](https://www.pfsense.org/download/) (firewall/router)
- [Security Onion](https://securityonionsolutions.com/software) (SIEM/NSM)
- [Kali Linux](https://www.kali.org/get-kali/) (attacker VM)
- Windows 10/11 and Windows Server 2022 ISOs (victim VMs)

**Knowledge:**
- Basic Linux command-line proficiency
- Networking fundamentals (IP, routing, VLANs)
- Familiarity with virtualization concepts

---

## 🚀 Quick Start

1. **Set up Proxmox VE** on bare metal — see [`lab-setup/proxmox/readme.md`](./lab-setup/proxmox/readme.md)
2. **Configure pfSense** as your firewall/router — see [`lab-setup/pfsense/readme.md`](./lab-setup/pfsense/readme.md)
3. **Deploy Security Onion** for monitoring — see [`lab-setup/security-onion-os/README.md`](./lab-setup/security-onion-os/README.md)
4. **Spin up attacker VMs** (Kali/Parrot) — see [`lab-setup/kali-linux-main/READ.md`](./lab-setup/kali-linux-main/READ.md)
5. **Spin up victim VMs** (Windows 10/11/Server) with Sysmon installed
6. **Run an attack simulation** — see [`attack-simulations/`](./attack-simulations/)
7. **Analyze the logs** in Security Onion or Splunk — see [`detections/`](./detections/)
8. **Document findings** — see [`investigation-cases/`](./investigation-cases/) and [`reports/`](./reports/)

For detailed step-by-step setup, see [`docs/SETUP.md`](./docs/SETUP.md).

---

## 🎯 Lab Objectives & Exercises

| # | Exercise | Skills Practiced |
|---|---|---|
| 1 | Deploy and configure Sysmon on Windows VMs | Log collection, EDR |
| 2 | Forward Windows events to Security Onion | SIEM integration |
| 3 | Simulate a credential dumping attack (Mimikatz) | Attack simulation |
| 4 | Write a detection rule for LSASS access | Detection engineering |
| 5 | Investigate a lateral movement scenario | Incident investigation |
| 6 | Simulate PowerShell-based C2 communication | Threat emulation |
| 7 | Create a professional incident report | SOC reporting |
| 8 | Configure pfSense firewall rules | Network security |
| 9 | Tune IDS signatures in Suricata | Alert triage |
| 10 | Perform network traffic analysis with Zeek | NSM / threat hunting |

---

## 🔬 Lab Components

### Attack Simulations
Documented attack techniques with step-by-step reproduction instructions.
→ See [`attack-simulations/README.md`](./attack-simulations/README.md)

### Detections
Custom detection rules and SIEM queries for identifying malicious activity.
→ See [`detections/README.md`](./detections/README.md)

### Investigation Cases
Structured case studies modeling real SOC analyst workflows.
→ See [`investigation-cases/README.md`](./investigation-cases/README.md)

### Reports
Professional SOC-style incident report templates and examples.
→ See [`reports/README.md`](./reports/README.md)

---

## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| **Proxmox VE** | Bare-metal hypervisor for all VMs |
| **pfSense** | Firewall, routing, NAT |
| **Security Onion** | SIEM, IDS/NSM (Suricata + Zeek) |
| **Sysmon** | Windows endpoint telemetry |
| **Splunk / Wazuh** | Log analysis and alerting |
| **Kali Linux** | Attack simulation platform |
| **Atomic Red Team** | MITRE ATT&CK-mapped attack emulation |
| **Tailscale** | Secure remote access to the lab |

---

## 📊 Lab Status

| Component | Status |
|---|---|
| Lab architecture designed | ✅ Complete |
| Proxmox setup | ✅ Complete |
| pfSense firewall configured | ✅ Complete |
| Security Onion deployed | ✅ Complete |
| Remote access (Tailscale) | ✅ Complete |
| Attacker VMs (Kali/Parrot) | ✅ Complete |
| Victim VMs (Windows 10/11/Server) | 🔄 In Progress |
| Sysmon deployment | 🔄 In Progress |
| Attack simulations documented | 🔄 In Progress |
| Detection rules written | 🔄 In Progress |
| Investigation case studies | ⬜ Planned |
| Final incident reports | ⬜ Planned |

---

## 📚 References & Resources

- [MITRE ATT&CK Framework](https://attack.mitre.org/)
- [Atomic Red Team](https://github.com/redcanaryco/atomic-red-team)
- [SwiftOnSecurity Sysmon Config](https://github.com/SwiftOnSecurity/sysmon-config)
- [Security Onion Documentation](https://docs.securityonion.net/)
- [pfSense Documentation](https://docs.netgate.com/pfsense/en/latest/)
- [Splunk SPL Reference](https://docs.splunk.com/Documentation/Splunk/latest/SearchReference/WhatsInThisManual)
- [Sigma Rules](https://github.com/SigmaHQ/sigma)
- [Blue Team Labs Online](https://blueteamlabs.online/)

---

## 🤝 Contributing

Contributions, suggestions, and improvements are welcome!
Please read [`CONTRIBUTING.md`](./CONTRIBUTING.md) before submitting a pull request.

---

## 🔒 Security

This lab is for **educational purposes only** in an **isolated network environment**.
Please review [`SECURITY.md`](./SECURITY.md) for important safety guidelines before running any attack simulations.

---

## 📄 License

This project is licensed under the MIT License — see [`LICENSE`](./LICENSE) for details.

---

## 👤 Author

**Mohamed Elbalam**
SOC Analyst | Home Lab Enthusiast
[GitHub](https://github.com/MohamedElbalam)
