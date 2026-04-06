# SIEM Integration

This document describes the complete Security Information and Event Management (SIEM) integration for the SOC Detection Lab, based on Security Onion as the central platform.

---

## 1. Security Onion Component Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                     SECURITY ONION STACK                         │
│                                                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────────────────┐  │
│  │  Suricata   │  │    Zeek     │  │        Wazuh           │  │
│  │  (Network   │  │   (NSM /    │  │  (Host-based IDS)      │  │
│  │   IDS)      │  │  Protocol)  │  │  Manager + Agents      │  │
│  └──────┬──────┘  └──────┬──────┘  └───────────┬────────────┘  │
│         │                │                      │               │
│         └────────────────┴──────────────────────┘               │
│                          │                                       │
│                          ▼                                       │
│                  ┌──────────────┐                                │
│                  │   Logstash   │  (parse, normalize, enrich)    │
│                  └──────┬───────┘                                │
│                         │                                        │
│                         ▼                                        │
│               ┌──────────────────┐                              │
│               │  Elasticsearch   │  (index & store all events)  │
│               └──────────┬───────┘                              │
│                          │                                       │
│                          ▼                                       │
│                    ┌──────────┐                                  │
│                    │  Kibana  │  (search, visualize, alert)      │
│                    └──────────┘                                  │
└──────────────────────────────────────────────────────────────────┘
```

| Component | Version | Purpose |
|---|---|---|
| Security Onion | 2.4.x | Platform orchestrator |
| Suricata | 6.x | Network IDS (signature-based) |
| Zeek | 5.x | Network security monitor (protocol analysis) |
| Wazuh Manager | 4.x | Host-based IDS, log collection agent manager |
| Elasticsearch | 7.x | Log indexing and storage |
| Logstash | 7.x | Log ingestion, normalization, enrichment |
| Kibana | 7.x | Search, dashboards, alerting |

---

## 2. Windows Event Forwarding (WEF) Configuration

### 2.1 Sysmon Event IDs Collected

| Event ID | Name | Why Collected |
|---|---|---|
| 1 | Process Create | Detect malware execution, command-line analysis |
| 3 | Network Connection | C2 detection, lateral movement |
| 5 | Process Terminate | Track short-lived malicious processes |
| 6 | Driver Load | Rootkit/kernel exploit detection |
| 7 | Image Load (DLL) | DLL hijacking, side-loading detection |
| 8 | CreateRemoteThread | Process injection (Mimikatz, shellcode) |
| 10 | Process Access | LSASS access (credential dumping) |
| 11 | FileCreate | Malware dropper, ransomware detection |
| 12/13/14 | Registry Events | Persistence via run keys, COM hijacking |
| 15 | FileCreateStreamHash | Alternate Data Streams (ADS) hiding |
| 17/18 | Pipe Create/Connect | Named pipe attacks (PsExec, Cobalt Strike) |
| 22 | DNS Query | DNS-based C2 beaconing detection |
| 23 | FileDelete | Evidence wiping detection |
| 25 | ProcessTampering | Process hollowing, DLL injection variants |

### 2.2 How Logs Reach Security Onion

```
Windows Victim
  │
  │  Sysmon → Windows Event Log (Microsoft-Windows-Sysmon/Operational)
  │
  ▼
WinLogBeat Agent
  │  Config: winlogbeat.yml
  │  Reads: Sysmon, Security, System, PowerShell event channels
  │
  ▼  [TCP port 5044 — Beats protocol]
  │
Logstash on Security Onion
  │  Parses and normalizes events
  │
  ▼
Elasticsearch (index: winlogbeat-YYYY.MM.DD)
```

### 2.3 WinLogBeat Configuration
```yaml
# winlogbeat.yml — deployed on each Windows victim
winlogbeat.event_logs:
  - name: Microsoft-Windows-Sysmon/Operational
    ignore_older: 72h
  - name: Security
    event_id: 4624, 4625, 4648, 4672, 4688, 4697, 4698,
              4720, 4732, 4756, 4776
  - name: System
    event_id: 7045
  - name: Microsoft-Windows-PowerShell/Operational
    event_id: 4103, 4104
  - name: Microsoft-Windows-WMI-Activity/Operational
    event_id: 5857, 5858, 5861

output.logstash:
  hosts: ["10.20.20.100:5044"]

logging.level: info
logging.to_files: true
logging.files:
  path: C:\ProgramData\winlogbeat\logs
```

### 2.4 Wazuh Agent Configuration (wazuh-agent.conf excerpt)
```xml
<ossec_config>
  <client>
    <server>
      <address>10.20.20.100</address>
      <port>1514</port>
      <protocol>udp</protocol>
    </server>
  </client>

  <localfile>
    <location>Microsoft-Windows-Sysmon/Operational</location>
    <log_format>eventchannel</log_format>
  </localfile>

  <localfile>
    <location>Security</location>
    <log_format>eventchannel</log_format>
    <query>Event/System[EventID != 5156]</query>
  </localfile>
</ossec_config>
```

---

## 3. Linux Syslog Configuration

### 3.1 Rsyslog Forwarding (Kioptrix)
```
# /etc/rsyslog.conf
# Forward all logs to Security Onion
*.* @10.20.20.100:514
auth,authpriv.* @10.20.20.100:514

# Local logging still enabled
auth,authpriv.*    /var/log/auth.log
*.*;auth,authpriv.none  /var/log/syslog
```

### 3.2 Key Linux Log Sources
| Log | Event Type | Detection Use |
|---|---|---|
| auth.log | SSH login/failure, sudo | Brute force, privilege escalation |
| syslog | General system events | Service starts/stops, cron jobs |
| kern.log | Kernel messages | Rootkit activity, exploit crashes |

---

## 4. Network Sensor Configuration

Security Onion sensors run in **passive monitoring mode** on both vmbr1 (attacker) and vmbr2 (victim) bridges.

### 4.1 Suricata — Monitored Interfaces
```yaml
# /etc/suricata/suricata.yaml (excerpt)
af-packet:
  - interface: vmbr1
    cluster-id: 98
    cluster-type: cluster_flow
    defrag: yes
  - interface: vmbr2
    cluster-id: 99
    cluster-type: cluster_flow
    defrag: yes
```

### 4.2 Zeek — Monitored Interfaces
```
# /etc/zeek/node.cfg
[worker-1]
type=worker
host=localhost
interface=vmbr1

[worker-2]
type=worker
host=localhost
interface=vmbr2
```

---

## 5. Detection Rules Strategy

### 5.1 Network-Based Detection (Suricata)
Suricata uses signature rules from the Emerging Threats (ET) ruleset plus custom rules:

| Rule Category | Examples |
|---|---|
| Scanning | Nmap scan detection, port sweep alerts |
| Exploitation | EternalBlue (MS17-010), Log4Shell, SQLi |
| Malware | Meterpreter, Cobalt Strike, known C2 domains |
| Lateral Movement | PsExec traffic, SMB admin share access |
| Exfiltration | Large DNS TXT responses, ICMP tunneling |

### 5.2 Host-Based Detection (Wazuh)
Wazuh applies rules to incoming Windows and Linux events:

| Rule ID Range | Category |
|---|---|
| 60000–61000 | Windows authentication events |
| 61100–61200 | Sysmon process events |
| 61200–61300 | Sysmon network events |
| 80700–80799 | LSASS/credential access |
| 91000–91999 | Linux authentication events |

### 5.3 Correlation Detection
Wazuh can correlate multiple events into compound alerts:

```xml
<!-- Example: Detect brute force followed by successful logon -->
<rule id="100200" level="12">
  <if_sid>60106</if_sid>  <!-- multiple failed logins -->
  <same_source_ip />
  <options>alert_by_email</options>
  <description>Possible brute force attack followed by successful login</description>
  <group>authentication_success,pci_dss_10.2.4,pci_dss_10.2.5</group>
</rule>
```

---

## 6. Custom Detection Rules

### 6.1 Mimikatz Detection (Wazuh)
```xml
<rule id="100100" level="15">
  <if_group>sysmon_event1</if_group>
  <field name="win.eventdata.image" type="pcre2">(?i)mimikatz</field>
  <description>Mimikatz execution detected via Sysmon</description>
  <mitre>
    <id>T1003.001</id>
  </mitre>
</rule>

<rule id="100101" level="14">
  <if_group>sysmon_event10</if_group>
  <field name="win.eventdata.targetImage" type="pcre2">(?i)lsass\.exe</field>
  <description>LSASS memory access — possible credential dumping</description>
  <mitre>
    <id>T1003.001</id>
  </mitre>
</rule>
```

### 6.2 Lateral Movement Detection (Wazuh)
```xml
<rule id="100110" level="12">
  <if_group>sysmon_event11</if_group>
  <field name="win.eventdata.targetFilename" type="pcre2">(?i)PSEXESVC\.exe</field>
  <description>PsExec service binary dropped — lateral movement detected</description>
  <mitre>
    <id>T1021.002</id>
  </mitre>
</rule>
```

### 6.3 Data Exfiltration Detection (Suricata)
```
# Custom Suricata rule — large DNS TXT response (DNS tunneling)
alert dns any any -> any any (
  msg:"ET CUSTOM Possible DNS Tunneling — Large TXT Response";
  dns.query;
  content:"TXT";
  dsize:>500;
  threshold: type limit, track by_src, count 5, seconds 60;
  sid:9000001;
  rev:1;
)
```

---

## 7. Alert Handling Workflow

```
ALERT GENERATED (Suricata / Wazuh)
    │
    ▼
SEVERITY ASSESSMENT
  ├── Critical (10-15): Immediate investigation required
  ├── High (8-9): Investigate within 1 hour
  ├── Medium (5-7): Investigate within 4 hours
  └── Low (1-4): Review during next shift
    │
    ▼
INITIAL INVESTIGATION
  → Open Kibana Discover
  → Search by alert source IP or affected host
  → Pull related Sysmon / Zeek / Suricata logs
    │
    ▼
CORRELATION
  → Match network events with endpoint events
  → Build attack timeline
  → Identify MITRE ATT&CK technique
    │
    ▼
RESPONSE
  ├── Isolate affected VM in Proxmox (if needed)
  ├── Capture memory/disk image for forensics
  ├── Block attacker IP in pfSense
  └── Document findings in investigation case
    │
    ▼
REPORTING
  → Export timeline from Kibana
  → Write incident report
  → Update detection rules if gap identified
```
