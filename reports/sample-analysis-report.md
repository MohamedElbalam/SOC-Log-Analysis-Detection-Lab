# Sample Analysis Report

**Classification:** INTERNAL  
**Report Number:** IR-2024-001  
**Date:** 2024-01-15  
**Analyst:** Moha Zackry  
**Status:** FINAL

---

## 1. Executive Summary

On January 15, 2024, a Meterpreter reverse shell was detected on workstation `DESKTOP-WIN10` at 02:14 AM after an attacker gained unauthorized access via RDP using compromised credentials. The attacker downloaded and executed a malicious payload (`svcupdate.exe`), then injected into the `explorer.exe` process to establish a covert command-and-control channel. The workstation was isolated at 02:52 AM. No evidence of lateral movement or data exfiltration was found. The affected user's credentials were revoked.

---

## 2. Incident Details

| Field | Value |
|-------|-------|
| Incident ID | IR-2024-001 |
| Date/Time Detected | 2024-01-15 02:14 UTC |
| Date/Time Reported | 2024-01-15 02:25 UTC |
| Severity | High |
| Status | Resolved |
| Affected Systems | DESKTOP-WIN10 (192.168.20.30) |
| Affected Users | jsmith |
| Data at Risk | Local files on DESKTOP-WIN10 (no exfiltration confirmed) |

---

## 3. Detection

**How was the incident detected?**

- [x] SIEM Alert (rule: DET-001 — Remote Thread Creation in Unusual Process)

**Alert Details:**

```
Alert Name: Sysmon EventID 8 — CreateRemoteThread in explorer.exe
Alert Time: 2024-01-15T02:14:33Z
Log Source: Sysmon (DESKTOP-WIN10)
SourceImage: C:\Windows\System32\svchost.exe
TargetImage: C:\Windows\explorer.exe
```

---

## 4. Initial Triage

**Severity Justification:**

| Factor | Assessment |
|--------|-----------|
| Impact scope | Single host |
| Data sensitivity | Medium (user workstation) |
| Attacker capability | Intermediate (used Metasploit) |
| Containment status | Contained |

**Initial Assessment:**

True positive. Thread injection from `svcupdate.exe` (impersonating svchost) into `explorer.exe`, followed by a network connection from `explorer.exe` to an internal attacker IP on port 4444 (Meterpreter default port).

---

## 5. Timeline of Events

| Timestamp (UTC) | Host | Event | Evidence |
|-----------------|------|-------|---------|
| 2024-01-15 02:11:28 | DESKTOP-WIN10 | RDP logon as jsmith from 192.168.10.10 | Security Event 4624 (Type 10) |
| 2024-01-15 02:11:30 | Network | 47 KB downloaded from 192.168.10.10:8080 | Zeek conn.log |
| 2024-01-15 02:11:55 | DESKTOP-WIN10 | svcupdate.exe written to C:\Users\Public\ by PowerShell | Sysmon Event 11 |
| 2024-01-15 02:12:15 | DESKTOP-WIN10 | svcupdate.exe executed via cmd.exe | Sysmon Event 1 |
| 2024-01-15 02:14:33 | DESKTOP-WIN10 | Remote thread injected into explorer.exe | Sysmon Event 8 |
| 2024-01-15 02:14:40 | DESKTOP-WIN10 | explorer.exe connects to 192.168.10.10:4444 | Sysmon Event 3 |
| 2024-01-15 02:25:00 | SOC | Analyst alerted, investigation begun | — |
| 2024-01-15 02:52:00 | DESKTOP-WIN10 | Host isolated from network | — |

---

## 6. Attack Narrative

### Initial Access

The attacker gained access to `DESKTOP-WIN10` via RDP (LogonType 10) at 02:11:28 UTC from `192.168.10.10` (Kali Linux attacker machine) using the credentials of user `jsmith`. This indicates the attacker had previously compromised `jsmith`'s credentials through an unknown prior method (phishing or password reuse suspected).

### Execution

Using the RDP session, the attacker opened a command prompt and executed a PowerShell command that downloaded a 47 KB executable (`svcupdate.exe`) from their HTTP server at `192.168.10.10:8080`. The file was written to `C:\Users\Public\` and immediately executed.

### Process Injection

At 02:14:33, `svcupdate.exe` created a remote thread in `explorer.exe` (PID 1832). This technique (T1055) allowed the malicious code to execute under the context of `explorer.exe`, which is more trusted and less likely to be blocked by security tools. Seven seconds later, `explorer.exe` made an outbound TCP connection to `192.168.10.10:4444`, establishing a Meterpreter reverse shell.

### Impact

The attacker had a live Meterpreter session on `DESKTOP-WIN10` from 02:14 AM until the host was isolated at 02:52 AM — approximately 38 minutes. No evidence of additional payload execution, persistence mechanisms, credential dumping, lateral movement, or data exfiltration was found in this window.

---

## 7. Evidence Collected

| Evidence Item | Type | Notes |
|---------------|------|-------|
| Sysmon EVTX | Log file | Exported from DESKTOP-WIN10 |
| Security EVTX | Log file | Exported from DESKTOP-WIN10 |
| svcupdate.exe | Malware sample | SHA256: A1B2C3D4... (submitted to sandbox) |
| Zeek conn.log | Network log | 2024-01-15 02:00–03:00 UTC window |

---

## 8. Indicators of Compromise (IOCs)

### File Hashes

| Hash (SHA256) | Filename | Detection |
|---------------|----------|-----------|
| `A1B2C3D4E5F6789...` | svcupdate.exe | Trojan.Meterpreter (VirusTotal: 54/72) |

### IP Addresses

| IP Address | Port | Role |
|------------|------|------|
| 192.168.10.10 | 4444 | Meterpreter C2 (Kali attacker) |
| 192.168.10.10 | 8080 | Payload delivery HTTP server |

### Registry Keys

No persistence mechanisms were found.

---

## 9. MITRE ATT&CK Mapping

| Tactic | Technique | ID | Evidence |
|--------|-----------|-----|---------|
| Initial Access | Valid Accounts (RDP) | T1078 | Security Event 4624 LogonType=10 |
| Execution | Command and Scripting Interpreter: PowerShell | T1059.001 | Sysmon Event 1, ParentImage=powershell.exe |
| Defense Evasion | Process Injection | T1055 | Sysmon Event 8, TargetImage=explorer.exe |
| Command and Control | Non-Standard Port | T1571 | Sysmon Event 3, DestPort=4444 |

---

## 10. Containment Actions Taken

- [x] Isolated DESKTOP-WIN10 from network at 02:52 AM (moved to quarantine VLAN)
- [x] Revoked jsmith's credentials; password reset required on next logon
- [x] Blocked outbound connections to 192.168.10.10:4444 at pfSense
- [x] Preserved Sysmon and Security EVTX logs

---

## 11. Root Cause

**Initial access method:** RDP with compromised credentials.

**Root cause:** jsmith's credentials were compromised prior to this incident. The method of initial credential compromise was not determined within the scope of this investigation but likely occurred through phishing or password reuse from a third-party breach.

---

## 12. Recommendations

| Priority | Recommendation | Owner | Due Date |
|----------|---------------|-------|---------|
| Critical | Reset jsmith's password; enforce MFA for all RDP accounts | IT Admin | Immediately |
| High | Restrict RDP access by IP at pfSense (whitelist only IT admin subnet) | Security Team | 3 days |
| High | Enable Windows Defender Credential Guard on all workstations | IT Admin | 7 days |
| Medium | Implement PowerShell Constrained Language Mode or AMSI | Security Team | 30 days |
| Low | Audit all accounts with RDP access; remove unnecessary permissions | IT Admin | 30 days |

---

## 13. Lessons Learned

**What went well:**

- Sysmon Event 8 alert fired correctly and led to fast detection
- Network isolation was completed within 38 minutes of the alert

**What could be improved:**

- No alert fired on the initial RDP logon at 02:11 AM — should add detection for off-hours RDP logons
- 38-minute window between C2 establishment and isolation is too long; target <15 minutes

**Detection gaps identified:**

- No rule for off-hours (non-business-hours) RDP logons → add DET-013
- No alert for `explorer.exe` making outbound TCP connections → add DET-014

---

*Report prepared by: Moha Zackry*  
*Date: 2024-01-15*
