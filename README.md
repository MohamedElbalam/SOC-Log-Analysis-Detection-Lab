# SOC Log Analysis & Detection Lab

> A hands-on home lab that simulates a real Security Operations Center (SOC) workflow — covering attack simulation, log collection, detection engineering, and incident investigation.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Contributions Welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg)](CONTRIBUTING.md)

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Lab Architecture](#lab-architecture)
- [Directory Structure](#directory-structure)
- [Getting Started](#getting-started)
- [Tools Used](#tools-used)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This project demonstrates end-to-end SOC analyst skills in a self-hosted virtualized environment. Attacks are simulated on an isolated network, traffic is captured and forwarded to a SIEM, and detections are engineered from scratch.

**Skills demonstrated:**

- Log collection with Sysmon and Security Onion
- Log analysis with Splunk / Wazuh
- Attack simulation (process injection, Mimikatz, PowerShell abuse)
- Detection engineering (custom SIEM queries and Sigma rules)
- Incident investigation and case management
- Professional SOC reporting

---

## Prerequisites

| Requirement | Details |
|---|---|
| Virtualization host | Proxmox VE 7+ (bare-metal or nested) |
| RAM | 32 GB recommended (16 GB minimum) |
| Storage | 500 GB+ (SSD preferred) |
| OS knowledge | Linux CLI basics, Windows administration |
| Networking | Understanding of VLANs, NAT, and bridged networking |

---

## Lab Architecture

The lab is built on **Proxmox VE** and consists of three logical network segments:

| Segment | Purpose | Key VMs |
|---|---|---|
| **Attacker Network** (vmbr1) | Launch simulated attacks | Kali Linux, Parrot OS |
| **Victim Network** (vmbr2) | Target systems | Windows 10/11, Windows Server 2022, Ubuntu |
| **Management** (vmbr0) | Remote access & hypervisor | Proxmox, Tailscale |

**pfSense** acts as the perimeter firewall and router between networks.  
**Security Onion** (Eval mode) monitors east-west and north-south traffic using Suricata and Zeek.

See [`architecture_diagram/`](architecture_diagram/) for the full visual diagram.

---

## Directory Structure

```
SOC-Log-Analysis-Detection-Lab/
├── README.md                  ← You are here
├── CONTRIBUTING.md            ← Contribution guidelines
├── CODE_OF_CONDUCT.md         ← Community standards
├── LICENSE                    ← MIT license
├── ENHANCEMENT_PLAN.md        ← Roadmap and planned features
├── .gitignore
│
├── architecture_diagram/      ← Network and system diagrams
├── lab-setup/                 ← Per-component setup notes
│   ├── proxmox/
│   ├── pfsense/
│   ├── security-onion-os/
│   ├── kali-linux-main/
│   ├── Ubuntu-main/
│   └── remote-access/
├── attack-simulations/        ← Documented attack scenarios
├── detections/                ← SIEM queries and Sigma rules
├── investigation-cases/       ← Full incident investigation walkthroughs
├── reports/                   ← SOC report templates and examples
├── tool-used/                 ← Tool inventory and configuration notes
├── screenshots/               ← Visual evidence and lab screenshots
└── docs/                      ← Additional documentation
    └── SETUP_GUIDE.md
```

---

## Getting Started

1. **Clone the repository**

   ```bash
   git clone https://github.com/MohamedElbalam/SOC-Log-Analysis-Detection-Lab.git
   cd SOC-Log-Analysis-Detection-Lab
   ```

2. **Set up the hypervisor** — follow [`lab-setup/proxmox/`](lab-setup/proxmox/)
3. **Configure the firewall** — follow [`lab-setup/pfsense/`](lab-setup/pfsense/)
4. **Deploy Security Onion** — follow [`lab-setup/security-onion-os/`](lab-setup/security-onion-os/)
5. **Spin up attacker & victim VMs** — follow the respective guides under [`lab-setup/`](lab-setup/)
6. **Run your first attack simulation** — see [`attack-simulations/`](attack-simulations/)
7. **Build detections** — see [`detections/`](detections/)

For a detailed walkthrough, see [`docs/SETUP_GUIDE.md`](docs/SETUP_GUIDE.md).

---

## Tools Used

| Tool | Role |
|---|---|
| Proxmox VE | Hypervisor / virtualization platform |
| pfSense | Perimeter firewall and router |
| Security Onion | NSM / IDS monitoring (Suricata, Zeek) |
| Kali Linux / Parrot OS | Attack simulation |
| Sysmon | Windows endpoint telemetry |
| Splunk / Wazuh | SIEM log aggregation and analysis |
| Tailscale | Secure remote access (MFA) |
| Atomic Red Team | Adversary simulation framework |

---

## Contributing

Contributions, improvements, and new detection rules are welcome!  
Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

---

## License

This project is licensed under the [MIT License](LICENSE).


