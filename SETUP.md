# Setup Guide — SOC Log Analysis Detection Lab

This guide walks you through building the full lab environment from scratch.  
Start here if you are setting up for the first time, or jump to the relevant section if you are adding a single component.

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Lab Architecture](#2-lab-architecture)
3. [Step 1 — Install Proxmox VE](#step-1--install-proxmox-ve)
4. [Step 2 — Deploy pfSense Firewall](#step-2--deploy-pfsense-firewall)
5. [Step 3 — Install Security Onion](#step-3--install-security-onion)
6. [Step 4 — Set Up Kali Linux (Attacker VM)](#step-4--set-up-kali-linux-attacker-vm)
7. [Step 5 — Set Up Ubuntu (Victim VM)](#step-5--set-up-ubuntu-victim-vm)
8. [Step 6 — Configure Remote Access](#step-6--configure-remote-access)
9. [Troubleshooting](#troubleshooting)
10. [Next Steps](#next-steps)

---

## 1. Prerequisites

### Hardware

| Resource | Minimum | Recommended |
|---|---|---|
| RAM | 16 GB | 32 GB |
| Storage | 500 GB HDD | 1 TB SSD |
| CPU cores | 4 (with VT-x / AMD-V) | 8+ |
| Network interfaces | 1 NIC | 2 NICs |

> **Important:** Verify that **AES-NI** and **virtualisation extensions** (Intel VT-x or AMD-V) are enabled in your BIOS before you begin.

### Software / ISOs to Download in Advance

| Component | Version | Download |
|---|---|---|
| Proxmox VE | 8.x | https://www.proxmox.com/en/downloads |
| pfSense CE | 2.7.x | https://www.pfsense.org/download/ |
| Security Onion | 2.4.x | https://github.com/Security-Onion-Solutions/securityonion/releases |
| Kali Linux | Latest | https://www.kali.org/get-kali/ |
| Ubuntu Server/Desktop | 22.04 LTS | https://ubuntu.com/download |

### Knowledge Prerequisites

- Basic Linux command-line usage
- Networking fundamentals (IP addressing, subnets, VLANs, routing)
- Familiarity with virtualisation concepts

---

## 2. Lab Architecture

```
Internet
    │
    ▼
[Proxmox Host]
    │
    ├── vmbr0 (WAN bridge — physical NIC, DHCP from home router)
    │       │
    │   [pfSense VM]  ← firewall / router
    │       │
    └── vmbr1 (LAN bridge — isolated internal network 192.168.10.0/24)
            │
            ├── [Security Onion VM]   ← SOC / IDS / log management
            ├── [Kali Linux VM]       ← attacker
            └── [Ubuntu VM]           ← victim / endpoint
```

**Remote access:** Tailscale subnet router installed on Proxmox provides MFA-protected access to all VMs from anywhere.

See [`architecture_diagram/`](architecture_diagram/) for the visual diagram.

---

## Step 1 — Install Proxmox VE

**Reference:** [`lab-setup/proxmox/readme.md`](lab-setup/proxmox/readme.md)

1. Download the Proxmox VE ISO and write it to a USB drive (use Rufus or `dd`).
2. Boot your physical host from the USB and follow the installer:
   - Select the target disk for installation.
   - Set a static IP address for the Proxmox management interface.
   - Set a strong root password and email address.
3. After installation, access the web UI at `https://<proxmox-ip>:8006`.
4. In the Proxmox shell, verify AES-NI is available:
   ```bash
   grep -o 'aes' /proc/cpuinfo | head -1
   # Expected output: aes
   ```
5. Install the QEMU guest agent package on Proxmox so VMs can communicate with the host:
   ```bash
   apt update && apt install -y qemu-guest-agent
   ```
6. Create a dedicated admin user in **Datacenter → Users** with the `Administrator` role.
7. Create two virtual bridges in **System → Network**:
   - `vmbr0` — bridged to your physical NIC (WAN)
   - `vmbr1` — no physical NIC attached (internal LAN, e.g. `192.168.10.1/24`)

---

## Step 2 — Deploy pfSense Firewall

**Reference:** [`lab-setup/pfsense/readme.md`](lab-setup/pfsense/readme.md)

1. Create a new VM in Proxmox (2 vCPUs, 2 GB RAM, 20 GB disk).
2. Add **two network interfaces**: one on `vmbr0` (WAN) and one on `vmbr1` (LAN).
3. Attach the pfSense ISO and boot the VM.
4. Follow the pfSense installer — accept defaults and reboot.
5. Assign interfaces when prompted:
   - WAN → the NIC on `vmbr0`
   - LAN → the NIC on `vmbr1` (set a static IP, e.g. `192.168.10.1/24`)
6. Access the pfSense web UI from any VM on the LAN: `http://192.168.10.1`  
   Default credentials: `admin` / `pfsense` — **change immediately**.
7. Install the QEMU guest agent inside the pfSense shell:
   ```bash
   pkg install -y qemu-guest-agent
   echo 'qemu_guest_agent_enable="YES"' >> /etc/rc.conf.local
   echo 'virtio_console_load="YES"' >> /boot/loader.conf.local
   ```

---

## Step 3 — Install Security Onion

**Reference:** [`lab-setup/security-onion-os/README.md`](lab-setup/security-onion-os/README.md)

**VM specifications:** 2 vCPUs, **12 GB RAM**, **200 GB disk**, 2 NICs

> Security Onion in **Eval** mode consolidates the manager, search node, and sensor roles — ideal for a single-host home lab.

1. Create a new VM in Proxmox with the specs above.
2. Attach **two NICs**:
   - NIC 1 on `vmbr1` — management (gets a static IP on the LAN)
   - NIC 2 on `vmbr1` — sniffing interface (no IP — promiscuous mode)
3. Download the Security Onion ISO directly (the URL-based fetch may fail in some environments) and attach it to the VM.
4. Boot and follow the installer; reboot into the installed OS.
5. Run the Security Onion setup wizard:
   ```bash
   sudo so-setup
   ```
   - Select **Eval** installation type.
   - Set the management NIC (the one with the IP).
   - Set the sniffing NIC (the one without an IP).
6. **Enable MAC address spoofing** on the sniffing NIC in Proxmox (VM → Hardware → Network Device → check "Firewall" off and note that the vSwitch must allow MAC changes for IDS capture to work).
7. Once setup completes, access the Security Onion web console at `https://<so-management-ip>`.

---

## Step 4 — Set Up Kali Linux (Attacker VM)

**Reference:** [`lab-setup/kali-linux-main/READ.md`](lab-setup/kali-linux-main/READ.md)

1. Create a VM in Proxmox (2 vCPUs, 4 GB RAM, 80 GB disk) on `vmbr1`.
2. Attach the Kali Linux ISO, install with defaults.
3. If the installer reports insufficient space, check available disk with:
   ```bash
   lsblk
   ```
   Expand or add storage in Proxmox if needed, then mount the additional space:
   ```bash
   sudo fdisk /dev/sda        # create new partition
   sudo mkfs.ext4 /dev/sda3
   sudo mount /dev/sda3 /mnt/extra
   ```
4. After installation, update the system:
   ```bash
   sudo apt update && sudo apt full-upgrade -y
   ```
5. Confirm connectivity to the LAN and internet via pfSense.

---

## Step 5 — Set Up Ubuntu (Victim VM)

**Reference:** [`lab-setup/Ubuntu-main/readME.md`](lab-setup/Ubuntu-main/readME.md)

1. Create a VM in Proxmox (2 vCPUs, 4 GB RAM, 60 GB disk) on `vmbr1`.
2. Attach the Ubuntu ISO and install with defaults.
3. If storage is tight during install, mount additional disk space manually (same process as Kali — see Step 4).
4. After installation, install the QEMU guest agent:
   ```bash
   sudo apt update
   sudo apt install -y qemu-guest-agent
   sudo systemctl enable --now qemu-guest-agent
   ```
5. Confirm the VM is reachable from Kali and from Security Onion.

---

## Step 6 — Configure Remote Access

**Reference:** [`lab-setup/remote-access/readme.md`](lab-setup/remote-access/readme.md)

### Tailscale (Recommended — start here)

Tailscale provides encrypted, MFA-protected access to all lab VMs from any device.

1. Install Tailscale on the Proxmox host:
   ```bash
   curl -fsSL https://tailscale.com/install.sh | sh
   sudo tailscale up --advertise-routes=192.168.10.0/24 --accept-dns=false
   ```
2. Approve the subnet route in the [Tailscale admin console](https://login.tailscale.com/admin/machines).
3. Install the Tailscale client on your remote machine and connect to the same tailnet.
4. You can now reach all VMs on `192.168.10.0/24` from anywhere.

### Cloudflare Tunnel (Optional — for web-based access)

Useful if you want to expose the Security Onion dashboard or pfSense UI via a custom domain for web penetration testing practice.

1. Install `cloudflared` on the Proxmox host or a dedicated VM.
2. Authenticate and create a tunnel:
   ```bash
   cloudflared tunnel login
   cloudflared tunnel create soc-lab
   ```
3. Configure `~/.cloudflared/config.yml` to forward traffic to the desired internal service.
4. Start the tunnel:
   ```bash
   cloudflared tunnel run soc-lab
   ```

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---|---|---|
| `vmbr1` is down in Proxmox | Bridge not created or not saved | Go to **System → Network**, create `vmbr1`, apply changes, reboot if needed |
| pfSense can't reach WAN | Wrong NIC assignment or vmbr0 not bridged | Re-assign interfaces in pfSense console |
| Security Onion sniffing NIC shows no traffic | MAC spoofing not allowed on the virtual bridge | Enable MAC spoofing / promiscuous mode on the Proxmox virtual switch |
| Security Onion ISO URL fetch fails | Network restriction or mirror issue | Download the ISO manually from the official GitHub releases page and upload it to Proxmox |
| Kali/Ubuntu can't get DHCP from pfSense | pfSense DHCP server not enabled on LAN | In pfSense UI go to **Services → DHCP Server → LAN** and enable it |
| Can't reach VMs via Tailscale | Subnet routes not approved | Approve routes in the Tailscale admin console |
| Low disk space during installation | Default partition too small | Add a second virtual disk in Proxmox and mount it manually after install |

---

## Next Steps

Once the lab is running, proceed to:

1. **[`detections/`](detections/)** — Write your first Sigma or Suricata rule.
2. **[`attack-simulations/`](attack-simulations/)** — Run a basic attack from Kali and verify Security Onion detects it.
3. **[`investigation-cases/`](investigation-cases/)** — Work through an investigation case end to end.
4. **[`reports/`](reports/)** — Document your findings using the SOC report template.

### Useful Resources

- [Security Onion Documentation](https://docs.securityonion.net/)
- [pfSense Documentation](https://docs.netgate.com/pfsense/en/latest/)
- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)
- [Tailscale Docs — Subnet Routing](https://tailscale.com/kb/1019/subnets/)
- [Kali Linux Documentation](https://www.kali.org/docs/)

---

*Back to [README.md](README.md)*
