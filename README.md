# SOC Log Analysis & Detection Lab

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Status](https://img.shields.io/badge/status-active-brightgreen.svg)
![Platform](https://img.shields.io/badge/platform-Proxmox%20%7C%20Windows%20%7C%20Linux-lightgrey.svg)
![SIEM](https://img.shields.io/badge/SIEM-Splunk%20%7C%20Security%20Onion-orange.svg)

> A hands-on home lab that simulates a real Security Operations Center (SOC) workflow — from network traffic capture to detection engineering and incident reporting.

---

## Overview

This project demonstrates a full SOC analyst workflow built on a virtualized home lab environment. It covers attack simulation, log collection, SIEM analysis, detection rule authoring, and professional incident reporting.

**Core skills demonstrated:**
- Log collection with Sysmon, Suricata, and Zeek
- Log analysis and correlation using Splunk and Security Onion
- Attack simulation (process injection, Mimikatz, PowerShell abuse, C2)
- Custom detection engineering (Splunk queries, Wazuh rules)
- Incident investigation and triage
- Professional SOC reporting

---

## Lab Architecture

The lab runs entirely on a Proxmox hypervisor with three virtual networks:

| Network | Bridge | Purpose |
|---------|--------|---------|
| WAN / Internet | vmbr0 | Outbound access via pfSense NAT |
| Attacker Network | vmbr1 | Kali Linux, Parrot OS |
| Victim Network | vmbr2 | Windows 10/11, Windows Server 2022, Kioptrix |

**Key components:**
- **Proxmox VE** — hypervisor managing all VMs
- **pfSense** — firewall/router between attacker and victim networks
- **Security Onion** (EVAL mode) — IDS/NSM with Suricata + Zeek, 2 NICs, 200 GB storage, 12 GB RAM
- **Kali Linux / Parrot OS** — attack simulation platforms
- **Windows 10/11 + Server 2022** — victim machines with Sysmon installed
- **Splunk / Wazuh** — SIEM for log aggregation and alerting

See [`architecture_diagram/`](./architecture_diagram/) for the full network diagram.

---

## Prerequisites

| Requirement | Details |
|-------------|---------|
| Hardware | Bare-metal host with AES-NI, 32+ GB RAM, 1 TB+ storage recommended |
| Hypervisor | Proxmox VE 7+ |
| Network | Minimum 3 virtual bridges (vmbr0, vmbr1, vmbr2) |
| Remote Access | Tailscale or Cloudflare Tunnel for out-of-band access |
| Knowledge | Basic networking, Windows administration, Linux CLI |

---

## Project Structure

```
SOC-Log-Analysis-Detection-Lab/
├── README.md                    # This file
├── LICENSE                      # MIT License
├── CONTRIBUTING.md              # Contribution guidelines
├── SECURITY.md                  # Security best practices for the lab
├── CHANGELOG.md                 # Version history
├── .gitignore                   # Exclude VM files, logs, secrets
│
├── architecture_diagram/        # Network topology and diagrams
├── lab-setup/                   # Per-component setup notes
│   ├── proxmox/
│   ├── pfsense/
│   ├── security-onion-os/
│   ├── Ubuntu-main/
│   ├── kali-linux-main/
│   └── remote-access/
│
├── attack-simulations/          # Attack playbooks and steps
├── detections/                  # Detection rules and SIEM queries
├── configs/                     # Sysmon, Splunk, Wazuh config examples
├── scripts/                     # Automation and utility scripts
├── investigation-cases/         # Realistic incident triage walkthroughs
├── reports/                     # SOC report templates and findings
├── screenshots/                 # Lab screenshots and evidence
├── docs/                        # Extended documentation
│   ├── SETUP.md
│   ├── ARCHITECTURE.md
│   └── TOOLS.md
└── tool-used/                   # Tool notes and references
```

---

## Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/MohamedElbalam/SOC-Log-Analysis-Detection-Lab.git
   cd SOC-Log-Analysis-Detection-Lab
   ```

2. **Review the architecture** — see [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md)

3. **Set up the environment** — follow [`docs/SETUP.md`](./docs/SETUP.md)

4. **Run attack simulations** — see [`attack-simulations/README.md`](./attack-simulations/README.md)

5. **Apply detection rules** — see [`detections/README.md`](./detections/README.md)

6. **Investigate and report** — see [`investigation-cases/`](./investigation-cases/) and [`reports/`](./reports/)

---

## Lab Exercises & Learning Objectives

| Exercise | Objective | Difficulty |
|----------|-----------|------------|
| Sysmon Deployment | Configure and validate log collection | Beginner |
| Process Injection Detection | Detect common injection techniques via Splunk | Intermediate |
| Mimikatz Detection | Identify credential dumping events | Intermediate |
| PowerShell Abuse | Detect obfuscated and encoded PS commands | Intermediate |
| C2 Simulation | Identify beaconing behavior via network logs | Advanced |
| Full Incident Response | Triage → Contain → Report a multi-stage attack | Advanced |

---

## Security Warnings

> ⚠️ **This lab is for educational purposes only.**
> - All attack simulations must be run **only in the isolated lab environment** — never against systems you do not own or have explicit written permission to test.
> - Do **not** expose lab machines directly to the public internet.
> - Use pfSense rules and Tailscale MFA to restrict remote access.
> - Take **snapshots** of each VM before and after any attack simulation.
> - Regularly rotate credentials used in the lab; do not reuse real passwords.

See [`SECURITY.md`](./SECURITY.md) for full lab safety guidelines.

---

## Results & Findings

Track completed exercises in [`reports/`](./reports/) and triage walkthroughs in [`investigation-cases/`](./investigation-cases/). Screenshots of detections and SIEM dashboards go in [`screenshots/`](./screenshots/).

---

## Lab Status

| Component | Status |
|-----------|--------|
| Lab structure & architecture | ✅ Complete |
| Proxmox / pfSense / Security Onion setup | ✅ Complete |
| Remote access (Tailscale) | ✅ Complete |
| Sysmon deployment | ⬜ In progress |
| Attack simulations | ⬜ In progress |
| Detection rules | ⬜ In progress |
| Investigation cases | ⬜ In progress |
| Final reports | ⬜ Planned |

---

## References & Resources

- [Sysmon — SwiftOnSecurity config](https://github.com/SwiftOnSecurity/sysmon-config)
- [Atomic Red Team](https://github.com/redcanaryco/atomic-red-team)
- [Security Onion Documentation](https://docs.securityonion.net/)
- [Splunk Search Reference](https://docs.splunk.com/Documentation/Splunk/latest/SearchReference)
- [Wazuh Rules Documentation](https://documentation.wazuh.com/current/user-manual/ruleset/)
- [MITRE ATT&CK Framework](https://attack.mitre.org/)
- [pfSense Documentation](https://docs.netgate.com/pfsense/en/latest/)

---

## Author

**Mohamed Elbalam** — SOC Analyst Home Lab Project  
[GitHub](https://github.com/MohamedElbalam)

---

## License

This project is licensed under the MIT License — see [`LICENSE`](./LICENSE) for details.
