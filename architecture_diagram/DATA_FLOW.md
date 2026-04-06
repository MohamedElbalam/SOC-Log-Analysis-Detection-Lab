# Data Flow

This document visualizes the data flows through the SOC Detection Lab — covering attack workflows, log aggregation paths, detection-to-investigation pipelines, traffic monitoring points, and a full end-to-end example scenario.

---

## 1. Attack Workflow

The following shows the typical phases an attacker progresses through, and the corresponding data generated at each step:

```
PHASE 1 — RECONNAISSANCE
┌─────────────────────────────────────────────────────────────┐
│ Kali Linux (10.10.10.50)                                    │
│   nmap -sV -p- 10.20.20.0/24                               │
│                                                             │
│ Data Generated:                                             │
│   → SYN packets to all ports on victim range                │
│   → Zeek: conn.log entries (many short-lived connections)   │
│   → Suricata: ET SCAN Nmap alert                            │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼
PHASE 2 — INITIAL ACCESS
┌─────────────────────────────────────────────────────────────┐
│ Kali Linux exploits vulnerable service on Windows 10        │
│   msfconsole → exploit/windows/smb/ms17_010_eternalblue     │
│                                                             │
│ Data Generated:                                             │
│   → TCP session to 10.20.20.10:445                          │
│   → Suricata: ET EXPLOIT EternalBlue alert                  │
│   → Zeek: smb.log entry                                     │
│   → Sysmon Event 3: network connection to attacker IP       │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼
PHASE 3 — COMMAND EXECUTION
┌─────────────────────────────────────────────────────────────┐
│ Attacker runs commands on victim via Meterpreter shell       │
│   whoami, ipconfig, net user                                │
│                                                             │
│ Data Generated:                                             │
│   → Sysmon Event 1: cmd.exe / powershell.exe spawned        │
│   → Windows Event 4688: process created                     │
│   → Sysmon Event 3: C2 callback connection                  │
└─────────────────────────────────────────────────────────────┘
                         │
                         ▼
PHASE 4 — LATERAL MOVEMENT
┌─────────────────────────────────────────────────────────────┐
│ Attacker moves from Windows 10 → Windows Server 2022        │
│   PsExec \\10.20.20.20 -u admin -p Password1 cmd           │
│                                                             │
│ Data Generated:                                             │
│   → Sysmon Event 3: SMB connection 10.20.20.10→10.20.20.20 │
│   → Windows Event 4648: logon with explicit credentials     │
│   → Windows Event 4624 (Type 3): network logon on target    │
│   → Zeek: smb.log shows file write (PSEXESVC.exe)          │
│   → Sysmon Event 11: PSEXESVC.exe created on target        │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Log Aggregation Flow

Each log source feeds into Security Onion through its own pipeline:

```
┌──────────────────────────────────────────────────────────────────┐
│                    LOG AGGREGATION FLOW                          │
│                                                                  │
│  ┌──────────────────┐                                           │
│  │  Windows Victims  │                                           │
│  │  Sysmon + EvtLog  │──[WinLogBeat port 5044]──┐              │
│  └──────────────────┘                            │              │
│                                                  ▼              │
│  ┌──────────────────┐              ┌─────────────────────────┐  │
│  │  Kioptrix Linux  │              │      Security Onion      │  │
│  │  Rsyslog         │──[UDP 514]──▶│  Logstash (ingest)      │  │
│  └──────────────────┘              │  Wazuh Manager          │  │
│                                    │  Elasticsearch (store)  │  │
│  ┌──────────────────┐              │  Kibana (visualize)     │  │
│  │  Suricata / Zeek │              └─────────────────────────┘  │
│  │  (vmbr1, vmbr2)  │──[Eve JSON / local]──────────▲           │
│  └──────────────────┘                               │           │
│                                                      │           │
│  ┌──────────────────┐                               │           │
│  │  pfSense         │──[Syslog UDP 514]─────────────┘           │
│  │  Firewall logs   │                                           │
│  └──────────────────┘                                           │
└──────────────────────────────────────────────────────────────────┘
```

---

## 3. Detection to Investigation Flow

When Security Onion detects a threat, the following pipeline activates:

```
STEP 1 — ALERT GENERATED
┌──────────────────────────────────────────────────┐
│ Suricata fires: ET SCAN Nmap Detected            │
│ Wazuh fires: Multiple failed logins              │
│ Alert appears in Security Onion Alerts dashboard │
└──────────────────────────────────────────────────┘
                         │
                         ▼
STEP 2 — ALERT SEARCHED
┌──────────────────────────────────────────────────┐
│ Analyst opens Kibana Discover                    │
│ Queries: src_ip: 10.10.10.50                    │
│ Finds 500+ connection attempts in last hour      │
└──────────────────────────────────────────────────┘
                         │
                         ▼
STEP 3 — TIMELINE BUILT
┌──────────────────────────────────────────────────┐
│ Analyst uses Kibana Timeline                     │
│ Orders events by @timestamp                      │
│ Identifies sequence:                             │
│   10:10 — Nmap scan                             │
│   10:18 — EternalBlue exploit attempt           │
│   10:23 — Meterpreter shell spawned             │
│   10:30 — Lateral movement to DC               │
└──────────────────────────────────────────────────┘
                         │
                         ▼
STEP 4 — ROOT CAUSE ANALYSIS
┌──────────────────────────────────────────────────┐
│ Analyst correlates Sysmon + network logs         │
│ Confirms initial access via EternalBlue (SMB)    │
│ Traces lateral movement path                     │
│ Identifies compromised accounts                  │
└──────────────────────────────────────────────────┘
                         │
                         ▼
STEP 5 — CASE DOCUMENTED & REPORTED
┌──────────────────────────────────────────────────┐
│ Case created in investigation tracker            │
│ Timeline exported from Kibana                    │
│ Findings written up with IOCs                    │
│ Recommendations for remediation documented       │
└──────────────────────────────────────────────────┘
```

---

## 4. Traffic Monitoring Points

| Network Point | Sensor | Detection Capability |
|---|---|---|
| vmbr1 — all traffic | Suricata (IDS) | Signature-based alerts on attacker traffic (scans, exploits, C2) |
| vmbr1 — all traffic | Zeek (NSM) | Protocol metadata for DNS, HTTP, SMB, SSL connections |
| vmbr2 — all traffic | Suricata (IDS) | Lateral movement, exfiltration, malware callbacks |
| vmbr2 — all traffic | Zeek (NSM) | Victim-side protocol analysis |
| Windows endpoints | Sysmon | Process chains, network connections, file/registry changes |
| Linux endpoint | Rsyslog | Auth events, cron jobs, service changes |
| pfSense | Firewall logs | Blocked connections, inter-VLAN routing |

---

## 5. Example Scenario — Full Lateral Movement Attack

### Scenario: Kali Linux compromises Windows 10, then moves to Windows Server 2022

```
[T=0] Kali (10.10.10.50) — nmap scan
  │
  │  Zeek conn.log: 10.10.10.50 → 10.20.20.0/24 (many SYNs)
  │  Suricata alert: ET SCAN Nmap
  │
  ▼
[T=8m] Kali — EternalBlue exploit against Windows 10 (10.20.20.10:445)
  │
  │  Suricata alert: ET EXPLOIT EternalBlue (MS17-010)
  │  Zeek smb.log: unusual SMB session from 10.10.10.50
  │  Sysmon Event 3 on Windows 10: inbound SMB from attacker
  │
  ▼
[T=9m] Windows 10 — cmd.exe spawned by SYSTEM (lsass.exe parent)
  │
  │  Sysmon Event 1: cmd.exe, ParentImage=lsass.exe ← suspicious!
  │  Windows Event 4688: new process created
  │
  ▼
[T=11m] Windows 10 — Meterpreter downloads payload
  │
  │  Sysmon Event 11: malware.exe created in C:\Users\Public\
  │  Sysmon Event 3: HTTP connection to 10.10.10.50:4444 (C2)
  │  Suricata alert: ET MALWARE Meterpreter reverse shell
  │
  ▼
[T=15m] Windows 10 — Mimikatz extracts credentials
  │
  │  Sysmon Event 10: ProcessAccess on lsass.exe (credential dump)
  │  Wazuh alert: Credential Access — LSASS Access
  │
  ▼
[T=18m] Windows 10 — PsExec lateral movement to Windows Server 2022
  │
  │  Sysmon Event 3 (Win10): SMB to 10.20.20.20:445
  │  Sysmon Event 11 (Win2022): PSEXESVC.exe created in C:\Windows\
  │  Windows Event 4648 (Win10): logon with explicit credentials
  │  Windows Event 4624 Type 3 (Win2022): network logon from 10.20.20.10
  │  Zeek smb.log: file write — PSEXESVC.exe
  │
  ▼
[T=19m] Windows Server 2022 — cmd.exe spawned by PSEXESVC.exe
  │
  │  Sysmon Event 1 (Win2022): cmd.exe, ParentImage=PSEXESVC.exe
  │  Wazuh alert: Lateral Movement — Remote Service Execution
  │
  ▼
[T=25m] Analyst receives alerts in Security Onion dashboard
         Opens Kibana → Discover → searches 10.10.10.50
         Builds attack timeline
         Identifies IOCs:
           - Attacker IP: 10.10.10.50
           - Malware path: C:\Users\Public\malware.exe
           - Credential dump target: lsass.exe
           - Lateral movement from 10.20.20.10 to 10.20.20.20
           - Service installed: PSEXESVC.exe
```

### Detection Coverage Summary for This Scenario

| Attack Phase | Detected By | Alert/Log Type |
|---|---|---|
| Reconnaissance | Suricata | ET SCAN Nmap |
| EternalBlue exploit | Suricata | ET EXPLOIT MS17-010 |
| Reverse shell C2 | Suricata | ET MALWARE Meterpreter |
| Process creation anomaly | Sysmon Event 1 | lsass.exe spawning cmd.exe |
| Credential dump | Sysmon Event 10 | ProcessAccess on lsass.exe |
| Lateral movement (SMB) | Zeek smb.log | Remote file write |
| Remote service execution | Sysmon Event 11 + Win Event 4624 | PSEXESVC.exe + Type 3 logon |
| Wazuh correlation | Wazuh rules | Aggregated alert with severity HIGH |
