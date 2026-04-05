#!/usr/bin/env bash
# =============================================================================
# restore-vms.sh
# Description : Restores all lab VMs to a named Proxmox snapshot
# Usage       : ./restore-vms.sh <snapshot-name>
# Requirements: Run on Proxmox host; requires qm commands
# =============================================================================

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <snapshot-name>"
    echo "Example: $0 pre-lab-20240405-1430"
    exit 1
fi

SNAPSHOT_NAME="$1"

# VM IDs — update these to match your Proxmox setup
VM_IDS=(100 101 102 103 104 105)
VM_NAMES=("pfsense" "security-onion" "kali-linux" "windows10" "windows11" "win-server-2022")

echo "================================================"
echo " SOC Lab VM Restore Utility"
echo " Restoring to snapshot: ${SNAPSHOT_NAME}"
echo "================================================"
echo ""
echo "WARNING: This will roll back all VMs to snapshot '${SNAPSHOT_NAME}'."
read -r -p "Are you sure? (yes/no): " CONFIRM

if [[ "${CONFIRM}" != "yes" ]]; then
    echo "Aborted."
    exit 0
fi

for i in "${!VM_IDS[@]}"; do
    VMID="${VM_IDS[$i]}"
    VMNAME="${VM_NAMES[$i]}"
    echo "[*] Stopping and restoring VM ${VMID} (${VMNAME})..."
    qm stop "${VMID}" 2>/dev/null || true
    if qm rollback "${VMID}" "${SNAPSHOT_NAME}" 2>/dev/null; then
        qm start "${VMID}"
        echo "[+] Restored and started: ${VMNAME}"
    else
        echo "[!] Warning: Could not restore VM ${VMID} (${VMNAME}) — check snapshot name"
    fi
done

echo ""
echo "[+] Restore complete."
