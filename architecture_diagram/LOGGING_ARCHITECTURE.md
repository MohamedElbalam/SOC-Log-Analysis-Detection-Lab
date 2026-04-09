# Logging Architecture

This document describes the complete logging strategy for the SOC Detection Lab — covering all log sources, forwarding methods, aggregation pipeline, retention policies, and investigation capabilities.

---

## 1. Log Sources

### 1.1 Windows Victims (10.20.20.10, 10.20.20.11, 10.20.20.20)

#### Sysmon Events Collected
| Event ID | Description |
|---|---|
| 1 | Process creation |
| 3 | Network connection |
| 5 | Process terminated |
| 6 | Driver loaded |
| 7 | Image loaded (DLL) |
| 8 | CreateRemoteThread (process injection) |
| 10 | ProcessAccess (credential access via LSASS) |
| 11 | FileCreate |
| 12/13/14 | Registry events |
| 15 | FileCreateStreamHash (ADS) |
| 17/18 | Pipe created / connected |
| 22 | DNS query |
| 23 | FileDelete |
| 25 | ProcessTampering |

#### Windows Event Log Channels
| Channel | Key Event IDs |
|---|---|
| Security | 4624, 4625, 4648, 4672, 4688, 4697, 4698, 4720, 4776 |
| System | 7045 (new service installed) |
| PowerShell/Operational | 4103, 4104 (script block logging) |
| Microsoft-Windows-WMI-Activity | 5857, 5858, 5861 |

### 1.2 Linux Victim — Kioptrix (10.20.20.30)

| Log File | Content |
|---|---|
| `/var/log/auth.log` | SSH logins, sudo usage, PAM events |
| `/var/log/syslog` | General system messages |
| `/var/log/kern.log` | Kernel messages |
| `/var/log/apache2/access.log` | Web server access (if applicable) |

### 1.3 Network Logs (Security Onion sensors on vmbr1 and vmbr2)

| Tool | Log Type | Location |
|---|---|---|
| Suricata | IDS alerts (Eve JSON) | `/nsm/suricata/eve.json` |
| Zeek | Connection logs | `/nsm/zeek/logs/current/conn.log` |
| Zeek | DNS logs | `/nsm/zeek/logs/current/dns.log` |
| Zeek | HTTP logs | `/nsm/zeek/logs/current/http.log` |
| Zeek | SSL/TLS logs | `/nsm/zeek/logs/current/ssl.log` |
| Zeek | Files logs | `/nsm/zeek/logs/current/files.log` |
| pfSense | Firewall logs | Syslog forwarded to Security Onion |

---

## 2. Log Forwarding Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                     LOG FORWARDING PIPELINE                 │
│                                                             │
│  Windows Victims                                            │
│  ┌──────────┐    ┌────────────┐    ┌──────────────────┐    │
│  │  Sysmon  │───▶│ WinLogBeat │───▶│  Security Onion  │    │
│  │ (Events) │    │  (Agent)   │    │  Wazuh Manager   │    │
│  └──────────┘    └────────────┘    │  :5044 (Beats)   │    │
│                                    └──────────────────┘    │
│  Linux Victim                                               │
│  ┌──────────┐    ┌────────────┐    ┌──────────────────┐    │
│  │ Rsyslog  │───▶│ Syslog UDP │───▶│  Security Onion  │    │
│  │ (Syslog) │    │  Forward   │    │  Syslog :514     │    │
│  └──────────┘    └────────────┘    └──────────────────┘    │
│                                                             │
│  Network (Inline sensor on vmbr1 & vmbr2)                  │
│  ┌──────────┐    ┌────────────┐    ┌──────────────────┐    │
│  │ Suricata │───▶│  Eve JSON  │───▶│  Elasticsearch   │    │
│  │   Zeek   │───▶│    Logs    │───▶│  (Logstash pipe) │    │
│  └──────────┘    └────────────┘    └──────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### 2.1 Windows — WinLogBeat Configuration (excerpt)
```yaml
winlogbeat.event_logs:
  - name: Microsoft-Windows-Sysmon/Operational
    ignore_older: 72h
  - name: Security
    event_id: 4624, 4625, 4648, 4672, 4688, 4697, 4698, 4720, 4776
  - name: System
  - name: Microsoft-Windows-PowerShell/Operational
    event_id: 4103, 4104

output.logstash:
  hosts: ["10.20.20.100:5044"]
```

### 2.2 Linux — Rsyslog Forwarding Configuration
```
# /etc/rsyslog.conf (add at the bottom)
*.* @10.20.20.100:514        # UDP syslog to Security Onion
auth,authpriv.* @10.20.20.100:514
```

### 2.3 Network — Suricata Eve JSON
Security Onion automatically reads Suricata's Eve JSON output and ships it to Elasticsearch via its internal Logstash pipeline. No additional configuration is needed for the lab.

---

## 3. Log Aggregation

All log sources feed into the Security Onion stack:

```
┌───────────────────────────────────────────────────────┐
│              Security Onion Aggregation Stack          │
│                                                       │
│  Logstash (ingest & enrich)                           │
│    │                                                  │
│    ▼                                                  │
│  Elasticsearch (index & store)                        │
│    │                                                  │
│    ▼                                                  │
│  Kibana (search, visualize, alert)                    │
│    │                                                  │
│    ▼                                                  │
│  Wazuh (HIDS rules & active response)                 │
└───────────────────────────────────────────────────────┘
```

- **Logstash** parses, normalizes, and enriches incoming logs (GeoIP, DNS enrichment)
- **Elasticsearch** indexes events into time-series indices for fast search
- **Kibana** provides dashboards, Discover search, alerting, and Canvas reports
- **Wazuh** applies host-based detection rules and generates alerts with severity levels

---

## 4. Retention Policy

| Log Type | Retention Period | Justification |
|---|---|---|
| Suricata IDS alerts | 90 days | Enough for investigation windows |
| Zeek connection logs | 30 days | High volume, retain for short-term |
| Sysmon / Windows logs | 90 days | Critical for host forensics |
| Linux syslog | 30 days | General system health |
| pfSense firewall logs | 30 days | Network perimeter visibility |

> In a production SOC, retention is typically 90–365 days depending on compliance requirements.

---

## 5. Example Log Entries

### 5.1 Sysmon Event 1 — Process Creation (Mimikatz)
```json
{
  "EventID": 1,
  "UtcTime": "2024-11-15 10:23:45.123",
  "ProcessGuid": "{ab123456-...}",
  "Image": "C:\\Users\\analyst\\Downloads\\mimikatz.exe",
  "CommandLine": "mimikatz.exe privilege::debug sekurlsa::logonpasswords",
  "ParentImage": "C:\\Windows\\System32\\cmd.exe",
  "User": "VICTIM\\analyst"
}
```

### 5.2 Suricata Alert — Port Scan Detection
```json
{
  "timestamp": "2024-11-15T10:20:00.000Z",
  "event_type": "alert",
  "src_ip": "10.10.10.50",
  "dest_ip": "10.20.20.10",
  "proto": "TCP",
  "alert": {
    "signature": "ET SCAN Nmap Scripting Engine User-Agent Detected",
    "category": "Attempted Information Leak",
    "severity": 2
  }
}
```

### 5.3 Zeek Connection Log — Lateral Movement
```
ts           uid            orig_h        orig_p  resp_h        resp_p  proto  service  duration  orig_bytes  resp_bytes
1700000000   CXY123abc      10.20.20.10   49152   10.20.20.20   445     tcp    smb      0.35      2048        4096
```

### 5.4 Windows Security Event 4625 — Failed Logon (Brute Force)
```json
{
  "EventID": 4625,
  "TimeCreated": "2024-11-15T10:30:00Z",
  "TargetUserName": "Administrator",
  "LogonType": 3,
  "IpAddress": "10.10.10.50",
  "FailureReason": "%%2313",
  "SubStatus": "0xC000006A"
}
```

---

## 6. Analysis and Investigation Capabilities

| Capability | Tool | Use Case |
|---|---|---|
| Full-text log search | Kibana Discover | Find specific IPs, hashes, or user names across all logs |
| Timeline construction | Kibana Timeline | Order events chronologically during an investigation |
| Network flow analysis | Zeek conn.log + Kibana | Identify lateral movement and exfiltration paths |
| Host process tracing | Sysmon Event 1/3 | Trace malware execution chain |
| Alert triage | Wazuh Alerts + Suricata | Prioritize by severity and category |
| Threat correlation | Wazuh rules | Correlate login failures + Mimikatz = credential attack chain |
| Custom dashboards | Kibana Canvas | Executive-level reporting and SOC metrics |
