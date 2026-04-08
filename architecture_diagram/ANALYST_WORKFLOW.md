# SOC Analyst Workflow and Investigation Process

## Lab Access Architecture

### Analyst Workstation Setup
- **Location**: Management network (vmbr0)
- **IP**: 192.168.1.100
- **OS**: Ubuntu or Windows (analyst's choice)
- **Tools installed**:
  - SSH client
  - Web browser (for Security Onion dashboard)
  - Wireshark (optional, for local packet analysis)
  - Log analysis tools (grep, jq, Python)

### Secure Access to SIEM
```
[Analyst Workstation] (192.168.1.100)
    ↓ (HTTPS / SSH tunnel)
[Security Onion Web UI] (https://10.20.20.100)
    ↓
[Kibana / Investigation Dashboard]
    ↓
[Elasticsearch — all log sources]
```

## Investigation Workflow

### Phase 1: Alert Reception
1. **Alert Notification**
   - Dashboard notification appears in Security Onion
   - Optional email alert from Wazuh
   - Review alert severity and source

2. **Initial Triage**
   - Check alert metadata (source IP, destination, rule triggered)
   - Assess false positive likelihood
   - Determine investigation priority based on severity

### Phase 2: Data Collection
1. **Log Search**
   - Query Elasticsearch for events related to the alert
   - Time window: ±30 minutes from alert timestamp
   - Search across network, host-based, and application sources

2. **Log samples to collect**
   ```
   FOR each affected host:
     - Process execution logs (Sysmon Event ID 1)
     - Network connections (Sysmon Event ID 3)
     - File access events (Sysmon Event ID 11)
     - DNS queries (Sysmon Event ID 22)

   FOR network traffic:
     - Zeek conn.log (all connections)
     - Zeek dns.log (DNS resolution)
     - Suricata Eve alerts
     - SSL/TLS certificate information (Zeek x509.log)
   ```

### Phase 3: Timeline Construction
1. **Event Ordering**
   - Sort all related events by timestamp
   - Build a chronological timeline of activity
   - Identify distinct attack phases (recon, access, execution, lateral movement)

2. **Example Timeline**
   ```
   14:05:23 - Network scan detected (Suricata alert)
   14:05:47 - Port 445 connection attempt from 10.10.10.50
   14:06:12 - Exploit attempt on SMB (Suricata alert)
   14:06:23 - Process created: cmd.exe on victim (Sysmon Event 1)
   14:06:45 - Network connection to Windows Server from Windows 10
   14:07:02 - Suspicious process spawned: psexec.exe (Sysmon Event 1)
   14:07:30 - Credential access attempt logged (Wazuh alert)
   ```

### Phase 4: Root Cause Analysis
1. **Questions to answer**
   - What was the initial compromise vector?
   - When did the attack begin?
   - Which systems were affected?
   - What was the attacker's objective?
   - Were any security controls bypassed? How?

2. **Correlation analysis**
   - Combine network logs (Zeek/Suricata) with host logs (Sysmon)
   - Identify tools and techniques used by the attacker
   - Map techniques to MITRE ATT&CK framework
   - Assess overall impact

### Phase 5: Documentation
1. **Investigation case creation**
   - Incident ID format: `YYYY-MM-DD-###`
   - Record severity level and affected systems
   - Document chronological attack timeline
   - Summarize findings and conclusions

2. **Evidence collection**
   - Screenshots of dashboard alerts and log views
   - Relevant log excerpts copied from Kibana
   - Network traffic captures (if available)
   - File hashes of any malicious artifacts

### Phase 6: Reporting
1. **Final report sections**
   - Executive summary
   - Technical analysis
   - Attack timeline
   - Affected systems and potential data impact
   - Recommended mitigations
   - Lessons learned and detection improvements

## Investigation Tools

### Kibana Dashboard Usage
```
[Kibana Discover]
  - Free-text search across all indexed logs
  - Filter by host, process name, IP address, port, etc.
  - Select time range (e.g., last 1 hour, custom range)
  - Analyze field distribution and top values

[Kibana Dashboard]
  - Pre-built views for Suricata alerts, Zeek connections, Sysmon events
  - Visual correlation of events over time
  - Drill down from dashboard widget into raw logs
```

### Command Line Tools on Security Onion
```bash
# SSH to Security Onion
ssh analyst@10.20.20.100

# Query Zeek connection logs
zeek-cut id.orig_h id.resp_h id.resp_p proto < /nsm/zeek/logs/current/conn.log | head -50

# Search Suricata alerts
jq '.alert.signature' /nsm/suricata/eve.json | sort | uniq -c | sort -rn

# Check Wazuh alerts
/var/ossec/bin/ossec-logtest

# Capture live traffic for analysis
sudo tcpdump -i vmbr2 -w /tmp/capture.pcap

# Analyze capture with tshark
tshark -r /tmp/capture.pcap -Y "tcp.flags.syn==1" -T fields -e ip.src -e ip.dst
```

## Example Investigation Scenarios

### Scenario 1: Suspected Lateral Movement
**Alert**: "Unusual SMB traffic to multiple hosts"

**Investigation steps**:
1. Search Kibana: `event.module:zeek AND network.transport:tcp AND destination.port:445`
2. Filter by source and destination hosts
3. Correlate with Sysmon host logs on the source machine
4. Build attack progression timeline
5. Check for similar SMB activity on other victim hosts
6. Conclude: Lateral movement confirmed or false positive

**Expected findings**:
- SMB connection attempts logged by Zeek
- Failed or successful authentication events
- File access events on remote shares
- Registry modifications indicating persistence

### Scenario 2: Data Exfiltration Detection
**Alert**: "Large outbound data transfer to external IP"

**Investigation steps**:
1. Search Zeek `conn.log` for connections with high `orig_bytes` values
2. Identify the source host and external destination IP
3. Query Sysmon logs: which process initiated the connection?
4. Review command line arguments of the responsible process
5. Check file creation timestamps for recently staged files
6. Correlate timing of file access and outbound connection

**Expected findings**:
- Specific process responsible for the transfer
- Files accessed or archived prior to exfiltration
- Timing correlation between file activity and network transfer
- External destination IP reputation

### Scenario 3: Malware Execution
**Alert**: "Sysmon detected suspicious process execution"

**Investigation steps**:
1. Review process details: image path, command line, parent process
2. Check image hash against known threat intelligence
3. Query for child processes spawned by the suspicious process
4. Review outbound network connections initiated by the process
5. Check registry modifications (persistence mechanisms)
6. Analyze file system activity (dropped files, modified configs)

**Expected findings**:
- Full process tree visualization
- Suspicious command line arguments (encoded PowerShell, unusual paths)
- Registry run key modifications for persistence
- Network indicators of compromise (C2 IPs, domains)

## Sample Investigation Report Structure

```
INCIDENT INVESTIGATION REPORT
==============================

Case ID:   2026-04-06-001
Date:      April 6, 2026
Analyst:   [Your Name]
Severity:  High

EXECUTIVE SUMMARY
-----------------
A malicious actor successfully compromised a Windows 10 workstation
and attempted lateral movement to the Windows file server using SMB.

AFFECTED SYSTEMS
----------------
- Windows 10 (10.20.20.10)     — Primary compromise
- Windows Server 2022 (10.20.20.20) — Lateral movement target

ATTACK TIMELINE
---------------
[Chronological list of all identified events with timestamps]

TECHNICAL ANALYSIS
------------------
[Detailed findings, indicators of compromise, MITRE ATT&CK mapping]

RECOMMENDATIONS
---------------
[Suggested mitigations and detection rule improvements]

EVIDENCE
--------
[Screenshots, log excerpts, file hashes, network IOCs]
```

## Related Documentation

- [LOGGING_ARCHITECTURE.md](./LOGGING_ARCHITECTURE.md) — log sources and pipeline
- [DATA_FLOW.md](./DATA_FLOW.md) — data flow and attack scenario walkthroughs
- [SIEM_INTEGRATION.md](./SIEM_INTEGRATION.md) — SIEM components and detection rules
- [NETWORK_TOPOLOGY.md](./NETWORK_TOPOLOGY.md) — network layout and IPs
