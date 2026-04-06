# Attack Simulations

This directory contains documented attack techniques performed in the lab. Each simulation includes step-by-step reproduction instructions, expected log artifacts, and detection opportunities.

> Warning: All attacks documented here were performed exclusively in an isolated, self-contained lab environment. Never use these techniques against systems you do not own or have explicit permission to test.

## MITRE ATT&CK Coverage

| # | Technique | MITRE ID | Status |
|---|-----------|----------|--------|
| 01 | [Process Injection](01-process-injection/README.md) | T1055 | Documented |
| 02 | [Credential Harvesting](02-credential-harvesting/README.md) | T1003 | Documented |
| 03 | [Persistence](03-persistence/README.md) | T1547 | Documented |
| 04 | [Lateral Movement](04-lateral-movement/README.md) | T1021 | Documented |
| 05 | [Data Exfiltration](05-data-exfiltration/README.md) | T1048 | Documented |

## How to Use These Simulations

1. Set up the lab environment following lab-setup/
2. Take a Proxmox snapshot of all VMs before running attacks (for easy rollback)
3. Start with 01-process-injection and work through sequentially
4. After each attack, switch to the detections/ folder to practice finding evidence
5. Complete an investigation case to simulate a full SOC workflow

## Attack Flow

Initial Access -> Process Injection -> Credential Harvesting -> Persistence -> Lateral Movement -> Data Exfiltration

## Tools Used

| Tool | Purpose |
|------|---------|
| Metasploit | Exploit framework and payload generation |
| Mimikatz | Credential extraction from LSASS |
| Impacket | SMB/WMI lateral movement |
| CrackMapExec | Network-wide credential spraying |
| PowerShell | Living-off-the-land techniques |
| Netcat | Reverse shells and file transfer |
