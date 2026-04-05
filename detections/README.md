# Detection Rules

This directory contains custom detection rules and SIEM queries written to identify attack techniques observed in the lab. Rules are organized by log source and technique.

---

## Detection Index

| # | Detection Name | ATT&CK ID | Log Source | Query Type | Status |
|---|---|---|---|---|---|
| 1 | [LSASS Memory Access](#1-lsass-memory-access) | T1003.001 | Sysmon (EID 10) | Splunk SPL | 🔄 In Progress |
| 2 | [PowerShell Obfuscation](#2-powershell-obfuscation) | T1059.001 | PowerShell EID 4104 | Splunk SPL | 🔄 In Progress |
| 3 | [Mimikatz via Command Line](#3-mimikatz-via-command-line) | T1003 | Sysmon (EID 1) | Splunk SPL | 🔄 In Progress |
| 4 | [Suspicious Scheduled Task Creation](#4-suspicious-scheduled-task-creation) | T1053.005 | Windows EID 4698 | Splunk SPL | ⬜ Planned |
| 5 | [Lateral Movement — PsExec](#5-lateral-movement--psexec) | T1570 | Sysmon (EID 1,3) | Splunk SPL | ⬜ Planned |
| 6 | [Network Scan — Nmap](#6-network-scan--nmap) | T1046 | Zeek conn.log | Zeek/SOC | ⬜ Planned |

---

## Query Reference

### Log Sources Used

| Source | Description |
|---|---|
| Sysmon | Windows endpoint telemetry (process, network, file events) |
| Windows Security Log | Authentication, privilege use, process creation |
| PowerShell Operational Log | Script block logging |
| Zeek conn.log | Network connection metadata |
| Suricata | Signature-based network alerts |

---

## 1. LSASS Memory Access

**ATT&CK Technique:** [T1003.001 — OS Credential Dumping: LSASS Memory](https://attack.mitre.org/techniques/T1003/001/)  
**Log Source:** Sysmon Event ID 10 (ProcessAccess)  
**Corresponding Attack:** [`attack-simulations/README.md#1-credential-dumping--lsass`](../attack-simulations/README.md)

### Description
Detects when a process opens a handle to `lsass.exe` with access rights commonly used for credential dumping (e.g., `PROCESS_VM_READ`).

### Splunk SPL Query

```spl
index=sysmon EventCode=10
TargetImage="*\\lsass.exe"
(GrantedAccess=0x1010 OR GrantedAccess=0x1410 OR GrantedAccess=0x147a OR GrantedAccess=0x143a)
| table _time, ComputerName, SourceImage, TargetImage, GrantedAccess, CallTrace
| sort -_time
```

### Sigma Rule Equivalent

```yaml
title: LSASS Memory Access - Credential Dumping
status: experimental
description: Detects process access to LSASS memory with credential dumping access rights
logsource:
    category: process_access
    product: windows
detection:
    selection:
        TargetImage|endswith: '\lsass.exe'
        GrantedAccess|contains:
            - '0x1010'
            - '0x1410'
            - '0x147a'
    condition: selection
falsepositives:
    - AV software
    - EDR solutions
    - Legitimate debugging tools
level: high
tags:
    - attack.credential_access
    - attack.t1003.001
```

### False Positive Guidance
Antivirus and EDR products routinely access LSASS. Whitelist known security tool processes (e.g., `MsMpEng.exe`, `CylanceSvc.exe`) by adding exclusions to the `SourceImage` field.

---

## 2. PowerShell Obfuscation

**ATT&CK Technique:** [T1059.001 — Command and Scripting Interpreter: PowerShell](https://attack.mitre.org/techniques/T1059/001/)  
**Log Source:** PowerShell Operational Log (Event ID 4104)  
**Corresponding Attack:** [`attack-simulations/README.md#2-powershell-obfuscated-command-execution`](../attack-simulations/README.md)

### Description
Detects PowerShell script block logging events containing obfuscation indicators such as encoded commands, download cradles, or execution policy bypasses.

### Splunk SPL Query

```spl
index=wineventlog source="*PowerShell*" EventCode=4104
(ScriptBlockText="*-EncodedCommand*" OR ScriptBlockText="*-Enc *"
 OR ScriptBlockText="*DownloadString*" OR ScriptBlockText="*IEX*"
 OR ScriptBlockText="*Invoke-Expression*"
 OR ScriptBlockText="*-ExecutionPolicy Bypass*"
 OR ScriptBlockText="*-WindowStyle Hidden*")
| eval risk_score=case(
    match(ScriptBlockText, "DownloadString|IEX|Invoke-Expression"), 80,
    match(ScriptBlockText, "EncodedCommand|Enc "), 60,
    true(), 40)
| table _time, ComputerName, UserID, ScriptBlockText, risk_score
| sort -risk_score
```

### Sysmon Process Creation Alternative (Event ID 1)

```spl
index=sysmon EventCode=1
Image="*\\powershell.exe"
(CommandLine="*-enc*" OR CommandLine="*-EncodedCommand*"
 OR CommandLine="*-ExecutionPolicy Bypass*"
 OR CommandLine="*-WindowStyle Hidden*"
 OR CommandLine="*DownloadString*")
| table _time, ComputerName, User, CommandLine, ParentImage
| sort -_time
```

### False Positive Guidance
Legitimate software management tools (SCCM, Chocolatey, some MSI installers) may use encoded PowerShell. Correlate with user context and parent process.

---

## 3. Mimikatz via Command Line

**ATT&CK Technique:** [T1003 — OS Credential Dumping](https://attack.mitre.org/techniques/T1003/)  
**Log Source:** Sysmon Event ID 1 (ProcessCreate)

### Splunk SPL Query

```spl
index=sysmon EventCode=1
(Image="*\\mimikatz.exe"
 OR CommandLine="*sekurlsa*"
 OR CommandLine="*privilege::debug*"
 OR CommandLine="*lsadump*"
 OR CommandLine="*kerberos::*")
| table _time, ComputerName, User, Image, CommandLine, ParentImage, ParentCommandLine
| sort -_time
```

---

## 4. Suspicious Scheduled Task Creation

**ATT&CK Technique:** [T1053.005](https://attack.mitre.org/techniques/T1053/005/)  
**Log Source:** Windows Security Event ID 4698  
**Status:** ⬜ Planned

*Detection rule coming soon.*

---

## 5. Lateral Movement — PsExec

**ATT&CK Technique:** [T1570](https://attack.mitre.org/techniques/T1570/)  
**Status:** ⬜ Planned

*Detection rule coming soon.*

---

## 6. Network Scan — Nmap

**ATT&CK Technique:** [T1046](https://attack.mitre.org/techniques/T1046/)  
**Log Source:** Zeek conn.log / Security Onion  
**Status:** ⬜ Planned

*Detection rule coming soon.*

---

## Detection Tuning Tips

1. **Baseline first** — run queries against known-good traffic before going live
2. **Use risk scoring** — assign scores to reduce alert fatigue
3. **Correlate across sources** — combine endpoint (Sysmon) with network (Zeek) for high-confidence alerts
4. **Document false positives** — record whitelisted processes and reasons
5. **Review Sigma community rules** — [https://github.com/SigmaHQ/sigma](https://github.com/SigmaHQ/sigma)

---

## Resources

- [Sigma Rules Repository](https://github.com/SigmaHQ/sigma)
- [Splunk Security Essentials](https://splunkbase.splunk.com/app/3435)
- [Sysmon Event IDs Reference](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon#events)
- [MITRE ATT&CK for Enterprise](https://attack.mitre.org/matrices/enterprise/)
