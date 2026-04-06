# Lab Setup Guide

This guide walks through the complete setup of the SOC Log Analysis Detection Lab from bare metal to a fully operational monitoring environment.

---

## Table of Contents

1. [Hardware Requirements](#hardware-requirements)
2. [Network Design](#network-design)
3. [Step 1: Install Proxmox VE](#step-1-install-proxmox-ve)
4. [Step 2: Configure pfSense](#step-2-configure-pfsense)
5. [Step 3: Deploy Security Onion](#step-3-deploy-security-onion)
6. [Step 4: Set Up Attacker VMs](#step-4-set-up-attacker-vms)
7. [Step 5: Set Up Victim VMs](#step-5-set-up-victim-vms)
8. [Step 6: Configure Remote Access](#step-6-configure-remote-access)
9. [Step 7: Verify the Lab](#step-7-verify-the-lab)

---

## Hardware Requirements

| Resource | Minimum | Recommended |
|---|---|---|
| CPU | 4 cores (VT-x / AMD-V) | 8+ cores |
| RAM | 16 GB | 32 GB |
| Storage | 256 GB SSD | 500 GB+ SSD |
| NICs | 1 | 2+ |

Enable **VT-x / AMD-V** and **AES-NI** in the BIOS before installing Proxmox.

---

## Network Design

```
Internet (WAN)
      │
   pfSense (firewall/router)
   ├── vmbr0  ── Management network (Proxmox host)
   ├── vmbr1  ── Attacker network (Kali, Parrot OS)
   └── vmbr2  ── Victim network  (Windows, Ubuntu)
                       │
              Security Onion (mirrors vmbr1 + vmbr2)
```

---

## Step 1: Install Proxmox VE

1. Download Proxmox VE ISO from [proxmox.com](https://www.proxmox.com/en/downloads).
2. Flash to USB with Rufus or `dd`.
3. Boot the target machine from USB and complete the graphical installer.
4. Set a static IP for the management interface.
5. After reboot, access the web UI at `https://<proxmox-ip>:8006`.
6. Update the package list:
   ```bash
   apt update && apt dist-upgrade -y
   ```
7. Install the QEMU guest agent package on Proxmox:
   ```bash
   apt install -y qemu-guest-agent
   ```

See [`lab-setup/proxmox/`](../lab-setup/proxmox/) for additional notes.

---

## Step 2: Configure pfSense

1. Download the pfSense CE ISO from [netgate.com](https://www.pfsense.org/download/).
2. Create a new VM in Proxmox (2 CPUs, 2 GB RAM, 20 GB disk).
3. Add **three network interfaces**: vmbr0 (WAN), vmbr1 (LAN/Attacker), vmbr2 (OPT1/Victim).
4. Boot from ISO and follow the installer.
5. After install, assign interfaces via the console menu.
6. Access the web GUI at `https://<pfsense-lan-ip>` to complete configuration.
7. Enable NAT for outbound internet access from lab VMs.

See [`lab-setup/pfsense/`](../lab-setup/pfsense/) for detailed notes and known issues.

---

## Step 3: Deploy Security Onion

1. Download Security Onion ISO from [securityonionsolutions.com](https://securityonionsolutions.com/).
2. Create a VM in Proxmox (4 CPUs, 12 GB RAM, 200 GB disk, **2 NICs**):
   - NIC 1: Management (vmbr0)
   - NIC 2: Monitoring (vmbr1 or vmbr2, with MAC spoofing enabled)
3. Boot and run the Security Onion installer — choose **Eval** mode.
4. After install, access the Security Onion console at `https://<so-ip>`.

**Important:** Enable **MAC spoofing** on the Proxmox bridge used for the monitoring NIC, otherwise the IDS sensor will not capture traffic correctly.

See [`lab-setup/security-onion-os/`](../lab-setup/security-onion-os/) for notes.

---

## Step 4: Set Up Attacker VMs

1. Create VMs connected to **vmbr1** (attacker network).
2. Recommended distributions:
   - **Kali Linux** — `apt update && apt full-upgrade`
   - **Parrot OS** — alternative attack platform
3. Install `qemu-guest-agent` for Proxmox integration.

See [`lab-setup/kali-linux-main/`](../lab-setup/kali-linux-main/) for notes.

---

## Step 5: Set Up Victim VMs

1. Create VMs connected to **vmbr2** (victim network).
2. Deploy:
   - Windows 10 or Windows 11 (evaluation ISOs from Microsoft)
   - Windows Server 2022 (evaluation ISO from Microsoft)
   - Ubuntu 22.04 LTS
3. On **all Windows VMs**, install **Sysmon** with the SwiftOnSecurity config:
   ```powershell
   Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile Sysmon.zip
   Expand-Archive Sysmon.zip -DestinationPath C:\Sysmon
   C:\Sysmon\Sysmon64.exe -accepteula -i sysmonconfig.xml
   ```
4. Install Wazuh agent or Winlogbeat to forward logs to the SIEM.

---

## Step 6: Configure Remote Access

1. Install **Tailscale** on the Proxmox host:
   ```bash
   curl -fsSL https://tailscale.com/install.sh | sh
   tailscale up --advertise-routes=<lab-subnet>/24 --accept-routes
   ```
2. Approve subnet routes in the Tailscale admin console.
3. Enable **MFA** on your Tailscale account.

See [`lab-setup/remote-access/`](../lab-setup/remote-access/) for details.

---

## Step 7: Verify the Lab

Run through this checklist before starting attack simulations:

- [ ] Proxmox web UI accessible
- [ ] pfSense web GUI accessible, internet reachable from lab VMs
- [ ] Security Onion dashboard shows network traffic
- [ ] Sysmon running on all Windows VMs
- [ ] SIEM receiving Windows event logs
- [ ] Attacker VM can reach victim VMs
- [ ] Remote access via Tailscale working
