# Security Onion Setup

Security Onion is an all-in-one NSM (Network Security Monitoring) and SIEM platform used in this lab to capture, detect, and investigate traffic.

## Goal

Deploy a SOC-style monitoring VM that passively captures all lab network traffic and generates alerts via Suricata and Zeek logs.

## Architecture Used

**EVAL mode** — consolidates all roles (manager, search node, sensor) onto a single VM. Chosen due to hardware constraints.

## VM Specifications

| Setting | Value |
|---------|-------|
| RAM | 12 GB minimum (16 GB recommended) |
| CPU | 4 cores |
| Disk | 200 GB |
| NIC 1 | vmbr0 (management — for admin access) |
| NIC 2 | vmbr1 or span port (monitor — promiscuous) |

> **Note:** The monitor NIC must have **MAC address spoofing enabled** in Proxmox so it can see traffic from other VMs on the bridge.

## Installation Steps

### 1. Download ISO

Security Onion ISO must be downloaded manually — the in-installer fetch URL is unreliable.

Download from: https://github.com/Security-Onion-Solutions/securityonion/releases

### 2. Create VM in Proxmox

1. Upload ISO to Proxmox storage
2. Create VM: 12 GB RAM, 4 cores, 200 GB disk, **two NICs**
3. NIC 1 → `vmbr0` (management)
4. NIC 2 → `vmbr1` (monitor) — enable **"MAC address spoofing"** in NIC options

### 3. Install OS

Boot from ISO → follow CentOS/Rocky Linux installer → set a strong password.

### 4. Run Security Onion Setup

```bash
sudo so-setup
```

Select:
- **EVAL** installation type
- Management NIC: `eth0` (vmbr0)
- Monitor NIC: `eth1` (vmbr1)
- Set strong passwords for admin and analyst accounts

Setup takes 15–30 minutes.

### 5. Access the Web Interface

After setup completes, navigate to `https://<management-ip>` in a browser.

Login with the analyst credentials you created during setup.

### 6. Verify Detection Stack

```bash
# Check all services are running
sudo so-status
```

Expected running services: `suricata`, `zeek`, `elasticsearch`, `kibana`, `logstash`.

## Key Notes from Personal Setup

- **Cannot fetch OS URL** during setup wizard → download ISO manually before starting
- **MAC spoofing must be enabled** on the monitor interface, otherwise Security Onion cannot see traffic from other VMs
- EVAL mode consolidates manager/search/sensor — sufficient for a home lab
- All traffic on vmbr1 and vmbr2 is captured by the monitor interface

## Lessons Learned

- Virtual switches on Proxmox must allow MAC spoofing for IDS sensors to function
- 200 GB storage fills up quickly with full packet capture — tune retention settings
- Enable hardware offloading on monitor NIC for better capture performance

## Verification

1. Generate test traffic: run `ping` between attacker and victim VMs
2. Open Kibana → Discover → filter by `event.module: zeek`
3. Confirm connection logs appear for the test traffic
4. Run a basic Suricata-triggering scan: `nmap -sV 192.168.20.x` from Kali
5. Check alerts in Security Onion console
