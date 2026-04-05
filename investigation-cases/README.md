# Investigation Cases

This directory contains structured incident investigation case studies based on attack simulations performed in the lab. Each case follows a realistic SOC analyst workflow.

---

## Case Index

| Case # | Title | ATT&CK Techniques | Status |
|---|---|---|---|
| [CASE-001](#case-001-suspected-credential-dumping) | Suspected Credential Dumping | T1003.001 | 🔄 In Progress |
| [CASE-002](#case-002-powershell-c2-beacon) | PowerShell C2 Beacon | T1059.001 | ⬜ Planned |
| [CASE-003](#case-003-lateral-movement-via-psexec) | Lateral Movement via PsExec | T1570, T1550.002 | ⬜ Planned |

---

## Investigation Template

Each case follows this structure:

```
## CASE-XXX: [Title]

**Date:** YYYY-MM-DD
**Severity:** Critical / High / Medium / Low
**Status:** Open / Closed
**ATT&CK Techniques:** TXXXX.XXX

### 1. Detection / Alert
- How the incident was detected (alert name, tool, timestamp)

### 2. Initial Triage
- First 5 minutes: what do we know?
- Scope: how many systems are affected?
- Priority: is this a true positive?

### 3. Investigation Timeline
- Chronological events with timestamps
- Key log entries (Event IDs, source/destination IPs, user accounts)

### 4. Root Cause Analysis
- How did the attacker gain initial access?
- What was their objective?
- What artifacts were left behind?

### 5. Containment Actions
- Isolation steps taken
- Accounts disabled/reset
- Network blocks applied

### 6. Evidence Collected
- Log extracts
- Screenshots
- PCAP snippets

### 7. Lessons Learned
- What detection gaps existed?
- What rule changes are needed?
- What process improvements are recommended?
```

---

## CASE-001: Suspected Credential Dumping

**Date:** 2024-04-05  
**Severity:** Critical  
**Status:** 🔄 In Progress  
**ATT&CK Techniques:** [T1003.001 — LSASS Memory](https://attack.mitre.org/techniques/T1003/001/)

### 1. Detection / Alert

**Alert:** Sysmon Event ID 10 — Process Access to `lsass.exe`  
**Tool:** Security Onion / Kibana  
**Timestamp:** 2024-04-05 14:32:17 UTC  
**Host:** WIN10-VICTIM (192.168.100.20)

The alert triggered when `mimikatz.exe` opened a handle to `lsass.exe` with `GrantedAccess: 0x1010`.

### 2. Initial Triage

- **True positive?** Yes — `mimikatz.exe` is known credential dumping tool
- **Systems affected:** 1 (WIN10-VICTIM)
- **User context:** `WORKGROUP\Administrator`
- **Initial priority:** P1 — Critical

### 3. Investigation Timeline

| Time (UTC) | Event | Source |
|---|---|---|
| 14:28:03 | RDP connection from 10.10.10.100 (Kali) to WIN10-VICTIM | Zeek conn.log |
| 14:30:45 | `mimikatz.exe` process created | Sysmon EID 1 |
| 14:32:17 | `lsass.exe` handle opened with 0x1010 access | Sysmon EID 10 |
| 14:32:19 | `sekurlsa::logonpasswords` executed | PowerShell EID 4104 |
| 14:33:01 | Outbound connection to 10.10.10.100:4444 | Zeek conn.log |

### 4. Root Cause Analysis

The attacker gained initial access via RDP using valid credentials (likely from a previous phishing simulation). They escalated to Administrator context and executed Mimikatz to dump credentials from LSASS memory.

### 5. Containment Actions

- [ ] Isolate WIN10-VICTIM from the network (lab: revert to clean snapshot)
- [ ] Reset all accounts that were logged in at the time of the dump
- [ ] Block attacker IP (10.10.10.100) at pfSense

### 6. Evidence Collected

*Screenshots and log extracts to be added in [`screenshots/`](../screenshots/).*

### 7. Lessons Learned

- Detection worked as expected — Sysmon EID 10 alert fired within seconds
- Consider tuning the alert to also catch `rundll32.exe` and `comsvcs.dll` LSASS dump variants
- RDP should require MFA even in lab — simulate a more realistic initial access vector

---

## CASE-002: PowerShell C2 Beacon

**Status:** ⬜ Planned

*Investigation case coming soon.*

---

## CASE-003: Lateral Movement via PsExec

**Status:** ⬜ Planned

*Investigation case coming soon.*

---

## Resources

- [SANS Incident Handler's Handbook](https://www.sans.org/white-papers/33901/)
- [NIST SP 800-61 Rev 2 — Incident Handling Guide](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf)
- [MITRE ATT&CK Navigator](https://mitre-attack.github.io/attack-navigator/)
