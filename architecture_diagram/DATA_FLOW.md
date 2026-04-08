# Data Flow and Traffic Patterns

## Attack Workflow Data Flow

### 1. Reconnaissance Phase
```
[Attacker VM]
    ↓ (Network Scan / Nmap)
[pfSense Firewall] — logs connection attempt
    ↓
[Security Onion — Suricata] — detects scan, generates alert
    ↓
[Elasticsearch / Wazuh] — indexes alert
    ↓
[Kibana Dashboard] — alert visible to analyst
```

### 2. Initial Access Phase
```
[Attacker VM] — sends malicious payload
    ↓
[Victim Machine] — receives and executes payload
    ↓ (Sysmon monitors execution)
[Windows Event Log] — records process creation
    ↓ (WinLogBeat forwards)
[Security Onion] — receives logs
    ↓ (correlates with network logs)
[Detection Rules] — matches suspicious behavior
    ↓
[Alert Generated] — analyst investigates
```

### 3. Log Aggregation Flow

**From Windows Machines:**
```
Sysmon Agent
  → Windows Event Forwarder
  → Security Onion (port 1514 / WEC)
  → Wazuh Agent Receiver
  → Elasticsearch (indexed by daily index)
  → Kibana Dashboard
```

**From Network Sensors:**
```
Suricata IDS (vmbr1, vmbr2)
  → Eve JSON logs
  → Elasticsearch
  → Kibana Alert Dashboard
```

**From Zeek NSM:**
```
Zeek Sensors (vmbr1, vmbr2)
  → Zeek Logs (conn, dns, ssl, http, files, etc.)
  → Elasticsearch
  → Kibana Zeek Dashboard
```

### 4. Detection to Investigation

```
[Alert Generated]
    ↓ (Severity >= 5)
[Analyst Notified] — Email / Dashboard notification
    ↓
[Search Logs] — correlate events across sources
    ↓
[Build Timeline] — understand attack progression
    ↓
[Create Case] — document investigation findings
    ↓
[Generate Report] — findings and recommendations
```

## Traffic Monitoring Points

### Point 1: vmbr1 (Attacker Network)
- **What is captured**: All attacker machine traffic
- **Tools**: Suricata, Zeek
- **Detects**: Outbound attacks, C2 beacons, scanning activity
- **Example alerts**: Port scans, malicious payloads, protocol anomalies

### Point 2: vmbr2 (Victim Network)
- **What is captured**: All victim machine traffic
- **Tools**: Suricata, Zeek
- **Detects**: Inbound attacks, lateral movement, data exfiltration
- **Example alerts**: Exploit attempts, credential theft, unusual outbound connections

### Point 3: pfSense Firewall
- **What is captured**: All inter-network traffic (attacker ↔ victim, outbound WAN)
- **Logs**: Connection states, rule matches, NAT translations
- **Detects**: Policy violations, blocked connections, firewall bypasses

### Point 4: Victim Endpoints (Host-based)
- **What is captured**: Process execution, file access, registry changes, DNS queries
- **Tools**: Sysmon, Windows Event Logs
- **Detects**: Privilege escalation, persistence mechanisms, malware execution

## Example Attack Scenario — Full Data Flow

### Scenario: Lateral Movement Attack

**Step 1: Reconnaissance**
```
[Attacker scans victim network on vmbr2]
  Security Onion detects Nmap scan via Suricata
  Alert generated: "Network Reconnaissance Detected"
  Zeek logs DNS queries and connection metadata
```

**Step 2: Initial Access**
```
[Attacker exploits Windows 10 vulnerability]
  pfSense logs connection: 10.10.10.50 → 10.20.20.10
  Suricata detects malicious payload in HTTP traffic
  Alert: "Exploit Attempt Detected"
```

**Step 3: Command Execution**
```
[Reverse shell executes on Windows 10]
  Sysmon detects process creation: cmd.exe from unusual parent
  Windows Event Log records process execution details
  Alert: "Suspicious process: cmd.exe spawned by explorer.exe"
```

**Step 4: Lateral Movement Attempt**
```
[Attacker tries to access Windows Server via SMB]
  pfSense logs SMB traffic: 10.20.20.10 → 10.20.20.20
  Suricata detects suspicious SMB activity
  Zeek logs SMB negotiation and file access patterns
```

**Step 5: Log Aggregation and Detection**
```
All logs arrive at Security Onion:
  - Process logs from Sysmon (host-based)
  - Network logs from Zeek (network metadata)
  - IDS alerts from Suricata (signature-based)
  - Firewall logs from pfSense (policy enforcement)

Correlation engine detects:
  1. Process execution on Windows 10
  2. Outbound SMB connection to Windows Server (unusual)
  3. SMB exploit signature match (unauthorized)
  4. All events within a 2-minute window

Alert Generated: "Possible Lateral Movement Detected"
```

**Step 6: Analyst Investigation**
```
[Analyst sees alert in dashboard]
  Pivots to Windows 10 host logs
  Reviews Sysmon process execution details
  Correlates with Zeek SMB connection logs
  Confirms lateral movement attempt
  Escalates to incident response
```

## Traffic Volume Expectations

| Source | Event Rate | Purpose |
|--------|-----------|---------|
| Sysmon (per victim) | 10–100 EPS | Process, file, and network monitoring |
| Windows Event Logs | 5–50 EPS | System and security events |
| Zeek (per interface) | 100–1000 EPS | Network metadata |
| Suricata (per interface) | 1–10 EPS | Alert-level events only |
| pfSense | 5–50 EPS | Firewall connection logs |

*(EPS = Events Per Second)*

## Data Retention and Indexing

| Tier | Age | Query Speed |
|------|-----|-------------|
| Hot data | 0–30 days | Real-time, fully searchable |
| Warm data | 30–90 days | Searchable, slower queries |
| Cold data | 90+ days | Archived, rarely accessed |

- **Elasticsearch shards**: 5 primary per index, 1 replica
- **Index rotation**: Daily indices for efficient retention management
- **ILM policies**: Automatically move indices between tiers based on age

## Related Documentation

- [LOGGING_ARCHITECTURE.md](./LOGGING_ARCHITECTURE.md) — log sources and forwarding pipeline
- [NETWORK_TOPOLOGY.md](./NETWORK_TOPOLOGY.md) — network segments and IPs
- [SIEM_INTEGRATION.md](./SIEM_INTEGRATION.md) — detection rules and SIEM components
- [ANALYST_WORKFLOW.md](./ANALYST_WORKFLOW.md) — investigation workflow
