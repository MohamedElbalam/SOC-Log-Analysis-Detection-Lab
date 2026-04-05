#!/usr/bin/env bash
# =============================================================================
# snapshot-vms.sh
# Description : Takes Proxmox snapshots of all lab VMs before a lab exercise
# Usage       : ./snapshot-vms.sh [snapshot-name]
# Requirements: Run on Proxmox host; requires pvesh or qm commands
# =============================================================================

set -euo pipefail

SNAPSHOT_NAME="${1:-pre-lab-$(date +%Y%m%d-%H%M)}"

# VM IDs — update these to match your Proxmox setup
VM_IDS=(100 101 102 103 104 105)
VM_NAMES=("pfsense" "security-onion" "kali-linux" "windows10" "windows11" "win-server-2022")

echo "================================================"
echo " SOC Lab VM Snapshot Utility"
echo " Snapshot name: ${SNAPSHOT_NAME}"
echo "================================================"
echo ""

for i in "${!VM_IDS[@]}"; do
    VMID="${VM_IDS[$i]}"
    VMNAME="${VM_NAMES[$i]}"
    echo "[*] Taking snapshot of VM ${VMID} (${VMNAME})..."
    if qm snapshot "${VMID}" "${SNAPSHOT_NAME}" --description "Pre-lab snapshot taken on $(date)" 2>/dev/null; then
        echo "[+] Snapshot created: ${VMNAME} -> ${SNAPSHOT_NAME}"
    else
        echo "[!] Warning: Could not snapshot VM ${VMID} (${VMNAME}) — skipping"
    fi
done

echo ""
echo "[+] Snapshot complete. Name: ${SNAPSHOT_NAME}"
echo "    To revert: ./restore-vms.sh ${SNAPSHOT_NAME}"
