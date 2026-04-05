# Scripts

This directory contains automation and utility scripts for the SOC Detection Lab.

---

## Purpose

Scripts in this directory help automate:
- VM setup and configuration tasks
- Sysmon deployment and updates
- Log collection validation
- Attack simulation helpers
- Report generation

---

## Usage Guidelines

- All scripts include a header comment with purpose, usage, and dependencies.
- Scripts do **not** contain hardcoded credentials, IP addresses, or API keys — use environment variables or parameter arguments.
- Test scripts in the lab environment before running in any production-like setting.

---

## Planned Scripts

| Script | Language | Purpose | Status |
|--------|----------|---------|--------|
| `deploy-sysmon.ps1` | PowerShell | Download and install Sysmon with lab config | Planned |
| `validate-logging.ps1` | PowerShell | Verify Sysmon and Splunk UF are running and forwarding | Planned |
| `snapshot-all-vms.sh` | Bash | Trigger Proxmox snapshots for all lab VMs via API | Planned |
| `run-atomics.ps1` | PowerShell | Run a batch of Atomic Red Team tests and log results | Planned |
| `parse-sysmon-events.py` | Python | Parse Sysmon EVTX exports for offline analysis | Planned |

---

Add scripts to this directory as the lab matures. Follow the naming convention `<action>-<target>.<extension>`.
