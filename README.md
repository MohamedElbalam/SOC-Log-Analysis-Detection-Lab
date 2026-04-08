# SOC Log Analysis Detection Lab

A hands-on home lab for practising SOC analyst skills: log collection, threat detection, attack simulation, and incident investigation — built on Proxmox with pfSense, Security Onion, Kali Linux, and Ubuntu VMs.

## Overview

| Goal | Description |
|---|---|
| **Collect** | Gather logs from network, OS, and security tools |
| **Detect** | Write and tune custom detection rules |
| **Simulate** | Run realistic attack scenarios with Kali Linux |
| **Investigate** | Work through incident investigation cases |
| **Report** | Produce professional SOC-style reports |

## Prerequisites

- Physical host with at least **16 GB RAM** and **500 GB storage**
- CPU with **virtualisation support** (Intel VT-x / AMD-V) and **AES-NI**
- Internet connection for downloading ISOs and packages
- Basic familiarity with Linux and networking concepts

## Quick Start

1. **Install Proxmox VE** on your bare-metal host — see [`lab-setup/proxmox/`](lab-setup/proxmox/readme.md)
2. **Deploy pfSense** as the virtual firewall/router — see [`lab-setup/pfsense/`](lab-setup/pfsense/readme.md)
3. **Install Security Onion** (Eval mode) for SOC monitoring — see [`lab-setup/security-onion-os/`](lab-setup/security-onion-os/README.md)
4. **Spin up Kali Linux and Ubuntu** VMs for attack/victim machines — see [`lab-setup/kali-linux-main/`](lab-setup/kali-linux-main/READ.md) and [`lab-setup/Ubuntu-main/`](lab-setup/Ubuntu-main/readME.md)

> For full step-by-step instructions, configuration details, and troubleshooting tips, see **[SETUP.md](SETUP.md)**.

## Directory Structure

```
SOC-Log-Analysis-Detection-Lab/
├── README.md                  # This file — project overview & quick start
├── SETUP.md                   # Detailed setup guide
├── lab-setup/                 # Per-component installation notes
│   ├── proxmox/               # Proxmox hypervisor setup
│   ├── pfsense/               # pfSense firewall/router setup
│   ├── security-onion-os/     # Security Onion SOC platform setup
│   ├── kali-linux-main/       # Kali Linux attacker VM setup
│   ├── Ubuntu-main/           # Ubuntu victim VM setup
│   └── remote-access/         # Tailscale & Cloudflare Tunnel setup
├── detections/                # Custom detection rules
├── attack-simulations/        # Documented attack scenarios
├── investigation-cases/       # Incident investigation walkthroughs
├── reports/                   # SOC report templates & writeups
├── architecture_diagram/      # Lab network diagram
├── tool-used/                 # Tools and purpose reference
└── screenshots/               # Lab screenshots
```

## Tools Used

| Tool | Role |
|---|---|
| Proxmox VE | Type-1 hypervisor hosting all VMs |
| pfSense | Virtual firewall and router |
| Security Onion (Eval) | IDS / log management / SOC platform |
| Kali Linux | Attacker / penetration testing VM |
| Ubuntu | Victim / endpoint VM |
| Tailscale | Secure remote access (MFA + subnet routing) |

## Status

- [x] Lab structure created
- [x] Setup documentation written
- [ ] Attack simulations added
- [ ] Custom detections added
- [ ] Investigation cases added
- [ ] Reports written
- [ ] Finalised for portfolio/resume

## Author

**Moha Zackry**  
[View full setup guide →](SETUP.md)