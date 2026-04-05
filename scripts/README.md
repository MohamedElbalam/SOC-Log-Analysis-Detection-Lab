# Scripts

This directory contains automation and helper scripts for the SOC Detection Lab.

---

## Scripts

| Script | Description | Run On |
|---|---|---|
| [`snapshot-vms.sh`](./snapshot-vms.sh) | Take Proxmox snapshots of all lab VMs | Proxmox host |
| [`restore-vms.sh`](./restore-vms.sh) | Restore all lab VMs to a named snapshot | Proxmox host |

---

## Usage

### snapshot-vms.sh

Takes a snapshot of all lab VMs before starting a lab exercise:

```bash
# Take a snapshot with auto-generated name (recommended)
./scripts/snapshot-vms.sh

# Take a snapshot with a custom name
./scripts/snapshot-vms.sh pre-mimikatz-lab
```

### restore-vms.sh

Restores all VMs to a clean state after a lab exercise:

```bash
# Restore to a named snapshot
./scripts/restore-vms.sh pre-mimikatz-lab

# Restore to the most recent snapshot
./scripts/restore-vms.sh pre-lab-20240405-1430
```

---

## Before Running Scripts

1. Update the `VM_IDS` and `VM_NAMES` arrays in each script to match your Proxmox VM IDs
2. Ensure you are running the scripts directly on the Proxmox host (or via SSH)
3. The `qm` command must be available (it is part of Proxmox VE by default)

---

## Adding New Scripts

When adding new scripts:
1. Add a comment block at the top with: description, usage, and requirements
2. Use `set -euo pipefail` for safety
3. Make the script executable: `chmod +x scripts/your-script.sh`
4. Update the table above with a description
