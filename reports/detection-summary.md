# Detection Summary

This document summarizes all detection rules created in this lab, their effectiveness, and tuning notes.

## Summary Table

| ID | Name | Tool | MITRE ID | True Positives | False Positives | Status |
|----|------|------|----------|----------------|-----------------|--------|
| DET-001 | Remote Thread in System Process | Sysmon/Splunk | T1055 | 3 | 1 (AV) | Active |
| DET-002 | LSASS Process Access | Sysmon/Splunk | T1003.001 | 5 | 2 (AV) | Active |
| DET-003 | Mimikatz Command Line | Sysmon/Splunk | T1003 | 2 | 0 | Active |
| DET-004 | SAM Hive Access | Security/Splunk | T1003.002 | 1 | 0 | Active |
| DET-005 | Registry Run Key Modified | Sysmon/Splunk | T1547.001 | 4 | 3 (software installs) | Active (tuned) |
| DET-006 | Suspicious Scheduled Task | Security/Splunk | T1053.005 | 2 | 1 (Windows update) | Active |
| DET-007 | New Service Installed | System/Splunk | T1543.003 | 1 | 2 (AV updates) | Active (tuned) |
| DET-008 | PTH NTLM Logon Pattern | Security/Splunk | T1550.002 | 3 | 5 (legacy apps) | Active (tuned) |
| DET-009 | Admin Share Access | Security/Splunk | T1021.002 | 3 | 1 (IT admin) | Active |
| DET-010 | PSExec Pattern | Sysmon/Splunk | T1569.002 | 2 | 0 | Active |
| DET-011 | Large Outbound Transfer | Zeek/Splunk | T1048 | 1 | 2 (backups) | Active (tuned) |
| DET-012 | PowerShell Outbound Connection | Sysmon/Splunk | T1059.001 | 4 | 1 (Windows Update) | Active |
| SUR-001 | PSExec via SMB | Suricata | T1021.002 | 2 | 0 | Active |
| SUR-004 | Large HTTP POST | Suricata | T1048.003 | 1 | 3 (file uploads) | Active (tuned) |
| SUR-005 | DNS Long Subdomain | Suricata | T1071.004 | 1 | 0 | Active |
| SUR-007 | Reverse Shell Port 4444 | Suricata | T1571 | 5 | 0 | Active |
| ZEEK-001 | Large Outbound Transfer | Zeek | T1048 | 1 | 2 (backups) | Active (tuned) |
| ZEEK-002 | DNS Tunneling | Zeek | T1071.004 | 1 | 0 | Active |
| ZEEK-003 | Multiple SMB Connections | Zeek | T1021.002 | 3 | 1 (network scan) | Active |

---

## Attack Coverage Analysis

### By Attack Stage

| Stage | Coverage | Rules |
|-------|----------|-------|
| Initial Access | Partial | DET-008 (PTH logon) |
| Execution | Good | DET-003, DET-012 |
| Persistence | Good | DET-005, DET-006, DET-007 |
| Privilege Escalation | Partial | DET-002 (LSASS dump) |
| Defense Evasion | Good | DET-001 (process injection) |
| Credential Access | Excellent | DET-002, DET-003, DET-004 |
| Lateral Movement | Excellent | DET-008, DET-009, DET-010, SUR-001, ZEEK-003 |
| Exfiltration | Good | DET-011, DET-012, SUR-004, SUR-005, ZEEK-001, ZEEK-002 |

### Detection Gaps

| Gap | Description | Proposed Rule |
|-----|-------------|---------------|
| Off-hours RDP logon | No alert for RDP outside business hours | DET-013 (planned) |
| explorer.exe outbound | No rule for system processes making outbound connections | DET-014 (planned) |
| Encoded PowerShell | No Suricata rule for encoded commands over HTTP | SUR-009 (planned) |
| Kerberoasting | No detection for excessive TGS requests | DET-015 (planned) |

---

## False Positive Tuning Log

### DET-005 — Registry Run Key

- **Problem:** Windows software installers trigger this rule frequently
- **Fix:** Added exclusion for `msiexec.exe`, `setup.exe`, and `Teams.exe` as source images
- **Current FPR:** ~3 per day (acceptable)

### DET-008 — PTH NTLM Logon

- **Problem:** Legacy applications in the environment use NTLM Type 3 logons legitimately
- **Fix:** Added threshold (>5 per 10 min from same source) to reduce noise from single logons
- **Current FPR:** ~1 per day (review each manually)

### DET-011 / ZEEK-001 — Large Outbound Transfer

- **Problem:** Nightly backup jobs generate 100+ MB outbound transfers
- **Fix:** Added time window exclusion (01:00–04:00 UTC) and destination whitelist for backup server IPs
- **Current FPR:** 0 after tuning

### SUR-004 — Large HTTP POST

- **Problem:** File upload applications (SharePoint, Confluence) trigger this rule
- **Fix:** Added destination IP whitelist for known file-sharing servers
- **Current FPR:** ~2 per day (review each)

---

## Planned Improvements

- [ ] Add detection for Kerberoasting (EventID 4769 with RC4 encryption type)
- [ ] Add detection for DCSync (EventID 4662 on domain controller)
- [ ] Add Zeek script for detecting beaconing patterns (periodic outbound connections)
- [ ] Add detection for Living-off-the-Land (LOLBin) execution (regsvr32, mshta, certutil)
- [ ] Integrate Atomic Red Team for automated detection validation
