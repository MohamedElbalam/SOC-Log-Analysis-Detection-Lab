# pfSense Firewall Setup

pfSense is a FreeBSD-based open-source firewall and router that sits between the attacker and victim networks.

## Role in the Lab

- Routes and controls traffic between WAN, attacker (vmbr1), and victim (vmbr2) networks
- Provides NAT for outbound internet access
- Enforces firewall rules to simulate real enterprise perimeter controls

## VM Specifications

| Setting | Value |
|---------|-------|
| RAM | 2 GB |
| CPU | 2 cores |
| Disk | 20 GB |
| NIC 1 | vmbr0 (WAN) |
| NIC 2 | vmbr1 (Attacker LAN) |
| NIC 3 | vmbr2 (Victim LAN) |

## Installation Steps

### 1. Create VM in Proxmox

1. Upload pfSense ISO to Proxmox storage
2. Create VM: General → Name: `pfsense`; OS → select ISO; System → defaults; Disks → 20 GB; CPU → 2 cores; Memory → 2 GB
3. Add two additional network interfaces (vmbr1 and vmbr2) under Network tab

### 2. Install pfSense

1. Boot VM from ISO
2. Accept copyright and start installation
3. Select **Install pfSense** → Auto (ZFS) or UFS partition
4. Reboot after installation

### 3. Initial Console Setup

During first boot, assign interfaces:

```
WAN → vtnet0  (vmbr0 — internet)
LAN → vtnet1  (vmbr1 — attacker, or use for victim)
OPT1 → vtnet2 (vmbr2 — victim)
```

Set static IP on LAN: `192.168.20.1/24`
Set static IP on OPT1: `192.168.10.1/24`

### 4. Web UI Configuration

Access `https://192.168.20.1` from a VM on vmbr2:

- Hostname: `pfsense-lab`
- DNS: `8.8.8.8`, `1.1.1.1`
- WAN: DHCP from vmbr0
- LAN/OPT1: static IPs as above

### 5. Install QEMU Guest Agent

In pfSense shell (`Diagnostics → Command Prompt` or SSH):

```bash
pkg install -y qemu-guest-agent
echo 'qemu_guest_agent_enable="YES"' >> /etc/rc.conf.local
echo 'virtio_console_load="YES"' >> /boot/loader.conf.local
```

### 6. Firewall Rules

**LAN (Victim):** Allow all outbound to WAN; block attacker-to-victim by default  
**OPT1 (Attacker):** Allow internet access; block direct access to victim without explicit rule  
**WAN:** Block inbound by default (anti-spoofing)

### 7. NAT

Under Firewall → NAT → Outbound: set to Automatic Outbound NAT for both LAN and OPT1.

## Issues & Fixes

| Issue | Fix |
|-------|-----|
| `vmbr1 can't come up` using `ip link set vmbr1 up` | Not required — Proxmox manages bridge state; ensure NIC is assigned correctly in VM config |
| Network installation error during pfSense setup | Check that each NIC is on a separate bridge in Proxmox |
| Can't reach pfSense web UI | Verify firewall anti-lockout rule is enabled on LAN interface |

## Verification

```bash
# From Kali (vmbr1) — should reach internet
ping 8.8.8.8

# From Kali — should NOT reach victim directly (if rules applied)
nmap 192.168.20.0/24

# From victim VM — should reach internet
ping google.com
```
