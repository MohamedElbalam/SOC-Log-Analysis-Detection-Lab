# Incident Report Template

**Classification:** [CONFIDENTIAL / INTERNAL / PUBLIC]  
**Report Number:** IR-YYYY-XXX  
**Date:** YYYY-MM-DD  
**Analyst:** [Your Name]  
**Status:** [DRAFT / FINAL]

---

## 1. Executive Summary

> *2–4 sentences: What happened, what was affected, what was done. Non-technical.*

[Placeholder — write your executive summary here]

---

## 2. Incident Details

| Field | Value |
|-------|-------|
| Incident ID | IR-YYYY-XXX |
| Date/Time Detected | YYYY-MM-DD HH:MM UTC |
| Date/Time Reported | YYYY-MM-DD HH:MM UTC |
| Severity | [Critical / High / Medium / Low] |
| Status | [Investigating / Contained / Resolved] |
| Affected Systems | [hostname, IP] |
| Affected Users | [username(s)] |
| Data at Risk | [description of potentially accessed data] |

---

## 3. Detection

**How was the incident detected?**

- [ ] SIEM Alert (rule: ________________________)
- [ ] IDS/IPS Alert (signature: ________________________)
- [ ] User Report
- [ ] Threat Hunt
- [ ] Other: ________________________

**Alert Details:**

```
Alert Name:
Alert Time:
Log Source:
Raw Alert:
```

---

## 4. Initial Triage

**Severity Justification:**

| Factor | Assessment |
|--------|-----------|
| Impact scope | [Single host / Multiple hosts / Domain-wide] |
| Data sensitivity | [Low / Medium / High / Critical] |
| Attacker capability | [Script kiddie / Targeted APT] |
| Containment status | [Contained / Active / Unknown] |

**Initial Assessment:**

[Was this a true positive or false positive? What was your initial hypothesis?]

---

## 5. Timeline of Events

| Timestamp (UTC) | Host | Event | Evidence |
|-----------------|------|-------|---------|
| YYYY-MM-DD HH:MM | [hostname] | [what happened] | [Sysmon Event X / Log entry] |
| | | | |
| | | | |

---

## 6. Attack Narrative

> *Tell the story of the attack from the attacker's perspective. Chronological, technical.*

### Initial Access

[How did the attacker first gain access? Phishing? Exploit? Brute force?]

### Execution

[What did the attacker run? What payloads were deployed?]

### Privilege Escalation (if applicable)

[How did the attacker gain elevated privileges?]

### Lateral Movement (if applicable)

[Which other systems were accessed?]

### Impact

[What did the attacker achieve? Data accessed/stolen? Persistence established?]

---

## 7. Evidence Collected

| Evidence Item | Type | Location | Chain of Custody |
|---------------|------|----------|-----------------|
| Sysmon EVTX | Log file | C:\path\to\sysmon.evtx | Analyst → IR Lead |
| Memory dump | Binary | /evidence/memdump.raw | Analyst → IR Lead |
| Network PCAP | Packet capture | /evidence/traffic.pcap | Analyst → IR Lead |

---

## 8. Indicators of Compromise (IOCs)

### File Hashes

| Hash (SHA256) | Filename | Detection |
|---------------|----------|-----------|
| `abc123...` | payload.exe | Trojan.Meterpreter |

### IP Addresses

| IP Address | Port | Role |
|------------|------|------|
| 192.168.10.10 | 4444 | Attacker C2 |

### Domain Names / URLs

| Indicator | Type | Context |
|-----------|------|---------|
| attacker.lab | Domain | DNS tunneling destination |

### Registry Keys

| Key | Value | Purpose |
|-----|-------|---------|
| HKCU\...\Run\WindowsUpdate | C:\payload.exe | Persistence |

---

## 9. MITRE ATT&CK Mapping

| Tactic | Technique | ID | Evidence |
|--------|-----------|-----|---------|
| Initial Access | Valid Accounts | T1078 | RDP logon from 192.168.10.10 |
| Execution | PowerShell | T1059.001 | powershell.exe -enc ... |
| Persistence | Registry Run Keys | T1547.001 | Sysmon Event 13 |
| Credential Access | LSASS Memory | T1003.001 | Sysmon Event 10 |
| Lateral Movement | SMB/Admin Shares | T1021.002 | Event 5140 |
| Exfiltration | Exfil over HTTP | T1048.003 | Zeek http.log |

---

## 10. Containment Actions Taken

- [ ] Isolated affected host(s) from network
- [ ] Revoked compromised credentials
- [ ] Blocked IOCs at firewall
- [ ] Preserved forensic evidence (memory/disk image)
- [ ] Notified [stakeholders]

**Details:**

[Describe exactly what was done, by whom, and when]

---

## 11. Root Cause

[What was the root cause of the incident? Unpatched vulnerability? Weak credentials? User error?]

---

## 12. Recommendations

| Priority | Recommendation | Owner | Due Date |
|----------|---------------|-------|---------|
| Critical | Reset all domain admin passwords | IT Admin | Immediately |
| High | Block NTLM authentication on sensitive servers | IT Admin | 7 days |
| Medium | Deploy EDR with credential theft detection | Security Team | 30 days |
| Low | Add LSASS protection (PPL) on all servers | IT Admin | 60 days |

---

## 13. Lessons Learned

**What went well:**

**What could be improved:**

**Detection gaps identified:**

---

*Report prepared by: [Analyst Name]*  
*Reviewed by: [IR Lead Name]*  
*Date: YYYY-MM-DD*
