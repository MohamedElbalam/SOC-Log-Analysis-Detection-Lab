# Lab Setup Guide

This directory contains step-by-step setup guides for every component in the SOC home lab.

## Setup Order

Follow this order to avoid network dependency issues:

| Step | Component | Guide |
|------|-----------|-------|
| 1 | Proxmox VE (hypervisor) | [proxmox/README.md](proxmox/README.md) |
| 2 | pfSense (firewall) | [pfsense/README.md](pfsense/README.md) |
| 3 | Security Onion (SIEM/IDS) | [security-onion-os/README.md](security-onion-os/README.md) |
| 4 | Kali Linux (attacker) | [kali-linux-main/README.md](kali-linux-main/README.md) |
| 5 | Ubuntu / Windows (victims) | [Ubuntu-main/README.md](Ubuntu-main/README.md) |
| 6 | Remote access | [remote-access/README.md](remote-access/README.md) |

## Minimum Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU cores | 8 (with VT-x/AMD-V) | 12+ with AES-NI |
| RAM | 32 GB | 64 GB |
| Storage | 500 GB SSD | 1 TB NVMe |
| NICs | 1 | 2 (management + lab) |

## Network Plan

| Segment | Bridge | Subnet | Purpose |
|---------|--------|--------|---------|
| WAN | vmbr0 | DHCP | Internet uplink |
| Attacker | vmbr1 | 192.168.10.0/24 | Kali / Parrot OS |
| Victim | vmbr2 | 192.168.20.0/24 | Target machines |

## Tips

- Take Proxmox snapshots before and after each major change so you can roll back
- Enable MAC address spoofing on Security Onion's monitor interface
- Install the QEMU guest agent on every VM for better Proxmox integration
