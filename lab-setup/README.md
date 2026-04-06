# Lab Setup

This directory contains setup notes and configuration guides for every component of the SOC home lab. Each subdirectory covers one VM or service.

---

## Lab Overview

| Component | Role | Subdirectory |
|---|---|---|
| Proxmox VE | Hypervisor (hosts all VMs) | [`proxmox/`](proxmox/) |
| pfSense | Perimeter firewall and router | [`pfsense/`](pfsense/) |
| Security Onion | NSM / IDS (Suricata, Zeek) | [`security-onion-os/`](security-onion-os/) |
| Kali Linux | Attack simulation | [`kali-linux-main/`](kali-linux-main/) |
| Ubuntu | Victim / monitoring workstation | [`Ubuntu-main/`](Ubuntu-main/) |
| Remote Access | Tailscale and Cloudflare tunnel | [`remote-access/`](remote-access/) |

---

## High-Level Build Order

1. Install and configure **Proxmox VE** on bare-metal hardware.
2. Deploy **pfSense** VM and configure WAN/LAN/OPT interfaces.
3. Deploy **Security Onion** VM with two NICs (management + mirror port).
4. Deploy **attacker VMs** (Kali Linux, Parrot OS) on vmbr1.
5. Deploy **victim VMs** (Windows 10/11, Windows Server, Ubuntu) on vmbr2.
6. Set up **remote access** via Tailscale subnet routing.
7. Verify traffic flows and Security Onion is capturing alerts.

For a full step-by-step guide see [`docs/SETUP_GUIDE.md`](../docs/SETUP_GUIDE.md).

---

## Key Lessons Learned

- Virtual switches (Linux bridges) must have **MAC spoofing** enabled for Security Onion IDS sensors.
- Security Onion in **Eval mode** consolidates manager, search, and sensor roles — suitable for limited hardware.
- Install `qemu-guest-agent` on each VM to enable clean shutdown and IP reporting from Proxmox.
- Use **Tailscale subnet routing** to access isolated lab segments remotely without exposing them to the internet.
