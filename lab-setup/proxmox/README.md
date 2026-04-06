# Proxmox VE Setup

Proxmox VE is the type-1 hypervisor that hosts all lab VMs.

## Specifications Used

- **Proxmox VE version:** 8.x
- **Hardware:** Lenovo ThinkPad T430 (or similar)
- **Storage:** 500 GB SSD allocated for VM disks
- **RAM:** 32 GB

## Installation Steps

### 1. Download and Flash Proxmox ISO

```bash
# Download from https://www.proxmox.com/en/downloads
# Flash to USB with Rufus (Windows) or dd (Linux):
sudo dd if=proxmox-ve_8.x-x.iso of=/dev/sdX bs=4M status=progress
```

### 2. Install Proxmox

1. Boot from USB and select **Install Proxmox VE (Graphical)**
2. Accept EULA → select target disk → set timezone and keyboard
3. Set a strong root password and admin email
4. Configure management network (static IP recommended, e.g. `192.168.1.100/24`)
5. Complete installation and reboot

### 3. Configure Network Bridges

After first boot, edit `/etc/network/interfaces`:

```
auto lo
iface lo inet loopback

# Physical NIC (WAN uplink)
auto enp0s25
iface enp0s25 inet manual

# vmbr0 — WAN bridge (internet access)
auto vmbr0
iface vmbr0 inet dhcp
    bridge-ports enp0s25
    bridge-stp off
    bridge-fd 0

# vmbr1 — Attacker network (no uplink)
auto vmbr1
iface vmbr1 inet static
    address 192.168.10.1/24
    bridge-ports none
    bridge-stp off
    bridge-fd 0

# vmbr2 — Victim network (no uplink)
auto vmbr2
iface vmbr2 inet static
    address 192.168.20.1/24
    bridge-ports none
    bridge-stp off
    bridge-fd 0
```

Apply changes:

```bash
systemctl restart networking
```

### 4. Enable AES-NI (BIOS)

Reboot into BIOS and enable **Intel VT-x** and **AES-NI** for hardware-accelerated encryption and better VM performance.

### 5. Create Admin User

In the Proxmox web UI (`https://<proxmox-ip>:8006`):

1. Datacenter → Users → Add user (e.g. `labadmin`)
2. Datacenter → Permissions → Add → User Permission → role `Administrator`

### 6. Install QEMU Guest Agent on VMs

Run inside each VM after OS installation:

- **Linux:** `sudo apt install qemu-guest-agent && sudo systemctl enable --now qemu-guest-agent`
- **Windows:** Install from VirtIO ISO

## Notes

- Personal notes from setup:
  - Space allocation issue: mount additional storage manually with `lsblk` to verify disk layout
  - TPM (small software vault) is useful for encrypted VM disks but optional for the lab

## Verification

- All VMs show as "Running" in Proxmox UI
- Bridges `vmbr0`, `vmbr1`, `vmbr2` appear in `ip a`
- Can ping between VMs on the same bridge
