# Analyst Workflow

This document describes the complete SOC analyst investigation workflow for the Detection Lab — from initial alert reception to final reporting.

---

## 1. Analyst Workstation

| Property | Value |
|---|---|
| IP Address | 192.168.1.100 |
| Network | Management (vmbr0) |
| OS | Any modern OS with browser |
| Access Method | HTTPS to Security Onion Web UI |
| Tools Available | Kibana, Security Onion dashboards, Wazuh UI |

### 1.1 Accessing Security Onion
```
Browser → https://10.20.20.100
  Login with Security Onion admin credentials
  Landing page shows: Alerts, Dashboards, Hunt, Cases
```

---

## 2. Investigation Workflow

### Step 1 — Alert Reception and Triage
```
Security Onion Alerts Dashboard
  │
  ├── Filter by Severity: HIGH / CRITICAL first
  ├── Review alert name, source IP, destination IP
  ├── Note timestamp and frequency
  └── Determine if alert is a true positive or false positive

Key Questions:
  ✓ Is the source IP in the attacker network (10.10.10.0/24)?
  ✓ Is the destination a victim machine (10.20.20.0/24)?
  ✓ Does the alert match a known attack pattern?
  ✓ Are there multiple related alerts in a short time window?
```

### Step 2 — Log Collection and Search
```
Kibana → Discover Tab
  │
  ├── Set time range: Last 24 hours (or around alert timestamp)
  ├── Search query examples:
  │     src_ip: 10.10.10.50
  │     winlog.event_data.Image: *mimikatz*
  │     alert.signature: *EternalBlue*
  │     winlog.event_id: 4625 AND winlog.event_data.IpAddress: 10.10.10.50
  │
  └── Export relevant events for timeline construction
```

### Step 3 — Timeline Construction
```
Kibana → Timeline (or Discover sorted by @timestamp)
  │
  ├── Anchor start time: first suspicious event
  ├── Add events in chronological order:
  │     [T+0min]  Nmap scan detected by Suricata
  │     [T+8min]  EternalBlue exploit attempt
  │     [T+9min]  Shell spawned (Sysmon Event 1)
  │     [T+11min] Malware file created (Sysmon Event 11)
  │     [T+15min] LSASS accessed (Sysmon Event 10)
  │     [T+18min] Lateral movement to DC (Event 4648 + Zeek SMB)
  │
  └── Identify gaps in the timeline (missed detections)
```

### Step 4 — Root Cause Analysis
```
Answer these questions:
  1. How did the attacker gain initial access?
     → Check Suricata for exploit signatures + Sysmon Event 3
  
  2. What did the attacker do after access?
     → Review Sysmon Event 1 (processes) + Event 11 (files)
  
  3. Did the attacker dump credentials?
     → Check Sysmon Event 10 (lsass.exe access)
  
  4. Did the attacker move laterally?
     → Check Event 4648 + Zeek smb.log + Sysmon Event 11 on targets
  
  5. Was data exfiltrated?
     → Check Zeek conn.log for large outbound transfers
     → Check Suricata for data exfiltration signatures
```

### Step 5 — Case Documentation
```
Security Onion Cases (or external tracker):
  Case ID:         SOC-YYYY-NNNN
  Severity:        Critical / High / Medium / Low
  Status:          Open → In Progress → Resolved
  Affected Systems:
    - Windows 10 (10.20.20.10) — initial compromise
    - Windows Server 2022 (10.20.20.20) — lateral movement target
  Attack Vector:   EternalBlue SMB exploit
  MITRE Techniques:
    - T1190 — Exploit Public-Facing Application
    - T1059.001 — PowerShell
    - T1003.001 — LSASS Memory
    - T1021.002 — SMB/Windows Admin Shares
  IOCs:
    - Attacker IP: 10.10.10.50
    - Malware path: C:\Users\Public\malware.exe
    - Hash: <sha256 of malware>
    - Service: PSEXESVC.exe
```

### Step 6 — Report Generation
```
Export from Kibana:
  → Screenshots of alert dashboard
  → Timeline exported as CSV or PDF
  → Relevant log entries highlighted

Write incident report (see reporting template below)
Review recommendations and detection gaps
```

---

## 3. Kibana Usage Guide

### 3.1 Discover Tab — Log Search
- **Index patterns**: `winlogbeat-*`, `suricata-*`, `zeek-*`, `wazuh-*`
- **Key fields to filter on**:
  - `src_ip` / `dest_ip` — source and destination IP
  - `winlog.event_id` — Windows Event ID
  - `alert.signature` — Suricata alert name
  - `winlog.event_data.Image` — process image path
  - `winlog.event_data.CommandLine` — full command line
  - `winlog.event_data.TargetImage` — target process (for injection)

### 3.2 Dashboard — Overview
Pre-built Security Onion dashboards include:
- **Suricata Overview** — alert frequency, top signatures, top talkers
- **Zeek Overview** — connection summary, DNS queries, HTTP user agents
- **Wazuh Overview** — host-based alert summary by severity
- **Windows Security** — logon events, privilege use, account changes

### 3.3 Creating Custom Canvas Reports
```
Kibana → Canvas → Create workpad
  Add visualizations:
    - Alert timeline chart
    - Top source IPs pie chart
    - Event count over time
    - Affected hosts table
  Export as PDF for management reporting
```

### 3.4 Alerting (Kibana Watcher / Security Onion Alerts)
```
Example alert: notify when >10 failed logins from same IP in 5 minutes
  Trigger: count(event_id:4625) > 10 in 5m grouped by src_ip
  Action:  Email / Slack notification to analyst
```

---

## 4. Example Investigation Scenarios

### Scenario A — Lateral Movement Investigation

**Alert**: Wazuh HIGH — "PsExec service binary dropped on Windows Server 2022"

**Investigation Steps**:
1. Open Kibana Discover, filter: `host.name: WIN-SERVER2022 AND @timestamp: [now-1h TO now]`
2. Find Sysmon Event 11: `C:\Windows\PSEXESVC.exe` created by `SYSTEM`
3. Expand timeline backwards: who triggered the SYSTEM process?
4. Find Event 4624 (Type 3) logon from `10.20.20.10` at T-2 minutes
5. Go back to `10.20.20.10`: find Sysmon Event 3 showing SMB connection to Server 2022
6. Trace further back on `10.20.20.10`: find EternalBlue exploit from `10.10.10.50`
7. **Root Cause**: Kali → EternalBlue → Win10 → PsExec → Win2022
8. Document in case, add IOCs, update detection rules

**Key Queries**:
```
# Find the service drop on the server
host.name: WIN-SERVER-2022 AND winlog.event_id: 11 AND winlog.event_data.TargetFilename: *PSEXESVC*

# Find logon event triggering the action
host.name: WIN-SERVER-2022 AND winlog.event_id: 4624 AND winlog.event_data.LogonType: 3

# Find originating SMB connection on Win10
host.name: WIN10 AND winlog.event_id: 3 AND winlog.event_data.DestinationPort: 445
```

---

### Scenario B — Data Exfiltration Detection

**Alert**: Suricata MEDIUM — "ET INFO Large HTTP POST to external IP"

**Investigation Steps**:
1. Find the Suricata alert in Kibana, note `src_ip: 10.20.20.10`, `dest_ip: 185.x.x.x`
2. Search Zeek http.log for HTTP POSTs from same IP in last 2 hours
3. Look at request size and frequency — is data being sent in chunks?
4. Check Sysmon Event 1 on Win10 for any archive/compression tools (7z, zip)
5. Check Sysmon Event 11 for large file creation in temp directories
6. **Finding**: 500MB data exfiltrated via HTTP POST to external C2
7. Document IOCs: external IP, HTTP URI, transferred file names

---

### Scenario C — Malware Execution Analysis

**Alert**: Wazuh CRITICAL — "Mimikatz execution detected"

**Investigation Steps**:
1. Kibana Discover: `winlog.event_data.Image: *mimikatz* AND winlog.event_id: 1`
2. Note: `CommandLine: mimikatz.exe privilege::debug sekurlsa::logonpasswords`
3. Find parent process: `ParentImage: C:\Windows\System32\cmd.exe`
4. Trace cmd.exe parent: who spawned it? → find `PSEXESVC.exe` or remote shell
5. Check Sysmon Event 10: `TargetImage: lsass.exe` (confirms credential dump)
6. Check for outbound connections after Mimikatz ran (credentials sent to C2)
7. **MITRE**: T1003.001 (OS Credential Dumping: LSASS Memory)

---

## 5. Reporting Template

```
═══════════════════════════════════════════════════════════
                    INCIDENT REPORT
═══════════════════════════════════════════════════════════

Case ID:          SOC-2024-0042
Date:             2024-11-15
Analyst:          [Analyst Name]
Severity:         HIGH

EXECUTIVE SUMMARY
─────────────────
An attacker from IP 10.10.10.50 (Kali Linux) exploited the
EternalBlue vulnerability on Windows 10 (10.20.20.10), then
moved laterally to Windows Server 2022 (10.20.20.20) using
PsExec with stolen credentials.

AFFECTED SYSTEMS
─────────────────
• Windows 10 (10.20.20.10) — Initial compromise
• Windows Server 2022 (10.20.20.20) — Lateral movement target

ATTACK TIMELINE
─────────────────
10:10:00 — Nmap scan from 10.10.10.50 against victim range
10:18:30 — EternalBlue exploit against 10.20.20.10:445
10:19:05 — cmd.exe spawned (SYSTEM) on Windows 10
10:23:00 — Mimikatz executed; LSASS accessed
10:28:00 — PsExec lateral movement to 10.20.20.20
10:29:00 — cmd.exe spawned on Windows Server 2022

FINDINGS
─────────
• CVE-2017-0144 (EternalBlue) exploited — patch missing
• Credential dump via Mimikatz — LSASS accessible
• No EDR response to block Mimikatz execution
• Lateral movement via stolen domain admin credentials

INDICATORS OF COMPROMISE (IOCs)
──────────────────────────────────
• Attacker IP:      10.10.10.50
• Malware:          C:\Users\Public\malware.exe
• Service dropped:  C:\Windows\PSEXESVC.exe
• Hash (malware):   <sha256>

MITRE ATT&CK TECHNIQUES
──────────────────────────
• T1190 — Exploit Public-Facing Application (EternalBlue)
• T1059.003 — Windows Command Shell
• T1003.001 — LSASS Memory (Mimikatz)
• T1021.002 — SMB/Windows Admin Shares (PsExec)

RECOMMENDATIONS
─────────────────
1. Apply MS17-010 patch on all Windows victims immediately
2. Restrict LSASS access via Windows Defender Credential Guard
3. Block PsExec execution via AppLocker or Defender ATP
4. Enable MFA to limit lateral movement via stolen credentials
5. Update Suricata rules to alert on Mimikatz command-line arguments

DETECTION GAPS IDENTIFIED
──────────────────────────
• No alert on PSEXESVC.exe execution (rule added: Wazuh 100110)
• Mimikatz downloaded via HTTP without HTTPS inspection alert

═══════════════════════════════════════════════════════════
```
