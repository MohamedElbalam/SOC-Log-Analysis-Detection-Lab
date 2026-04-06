# Kali Linux (Attacker Machine) Setup

Kali Linux is the primary attack platform used to simulate adversary techniques against the victim network.

## VM Specifications

| Setting | Value |
|---------|-------|
| RAM | 4 GB |
| CPU | 2 cores |
| Disk | 80 GB |
| NIC | vmbr1 (attacker network, 192.168.10.0/24) |

## Installation Steps

### 1. Download ISO

Download the latest Kali Linux ISO from: https://www.kali.org/get-kali/

Use the **Installer** image (not live).

### 2. Create VM in Proxmox

1. Upload ISO to Proxmox storage
2. Create VM: 4 GB RAM, 2 cores, 80 GB disk
3. NIC → `vmbr1`
4. Start VM and boot from ISO

### 3. Install Kali

- Select **Graphical Install**
- Set hostname: `kali-attacker`
- Create a non-root user and password
- Use guided partitioning (entire disk)
- Select all default software (including desktop environment)

### 4. Post-Installation Configuration

#### Set Static IP

Edit `/etc/network/interfaces`:

```bash
auto eth0
iface eth0 inet static
    address 192.168.10.10
    netmask 255.255.255.0
    gateway 192.168.10.1
    dns-nameservers 8.8.8.8
```

```bash
sudo systemctl restart networking
```

#### Install QEMU Guest Agent

```bash
sudo apt update && sudo apt install -y qemu-guest-agent
sudo systemctl enable --now qemu-guest-agent
```

#### Update and Install Common Tools

```bash
sudo apt update && sudo apt full-upgrade -y

# Key tools for this lab
sudo apt install -y \
    metasploit-framework \
    impacket-scripts \
    crackmapexec \
    nmap \
    wireshark \
    tcpdump \
    python3-pip
```

#### Install Mimikatz (for Windows credential attacks via Metasploit)

Mimikatz runs on the victim Windows machine but is uploaded/executed from Kali:

```bash
# Mimikatz is available through Metasploit's hashdump / kiwi module
# Or download Windows binary from: https://github.com/gentilkiwi/mimikatz/releases
# Store in /opt/mimikatz/
```

## Issues & Fixes

| Issue | Fix |
|-------|-----|
| Cannot reach victim network | Verify pfSense OPT1 rules allow traffic from 192.168.10.0/24 |
| No internet from Kali | Check pfSense NAT is configured for OPT1 interface |
| Disk space issue | Use `lsblk` to verify partition; mount additional space manually if needed |

## Verification

```bash
# Confirm IP is on attacker segment
ip a show eth0

# Confirm internet access
ping 8.8.8.8

# Confirm can reach pfSense gateway
ping 192.168.10.1

# Basic scan of victim network
nmap -sn 192.168.20.0/24
```
