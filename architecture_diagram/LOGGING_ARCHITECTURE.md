# Logging Architecture

## Overview

This document describes how logs are generated, collected, forwarded, and stored throughout the SOC lab. Every event from endpoints and network sensors flows into Security Onion, enabling centralized detection, correlation, and investigation.

## Log Sources

### 1. Windows Victim Machines
- **Sysmon logs** — detailed endpoint telemetry (process creation, network connections, file access, registry changes, DNS queries)
- **Windows Event Logs** — system, security, and application event channels
- **PowerShell logs** — script block logging and module logging
- **Application logs** — IIS, SQL Server, and other installed services

### 2. Linux Victim (Kioptrix)
- **Syslog** — general system messages
- **Auth logs** (`/var/log/auth.log`) — SSH login attempts, sudo usage, authentication events
- **Apache/SSH logs** — web server access and error logs, SSH daemon logs

### 3. Network Traffic
- **Zeek (NSM logs)** — network metadata: `conn.log`, `dns.log`, `ssl.log`, `http.log`, `files.log`, and more
- **Suricata (IDS alerts)** — signature-based detection alerts in Eve JSON format

## Log Forwarding Pipeline

```
Windows Victims
  Sysmon + Windows Event Logs
    → WinLogBeat agent
      → Security Onion (Wazuh Agent Receiver, port 1514)

Linux Victim (Kioptrix)
  Syslog / Auth logs
    → Rsyslog
      → Security Onion (Syslog Receiver, port 514)

Network Sensors (vmbr1, vmbr2)
  Suricata → Eve JSON logs → Elasticsearch
  Zeek     → Zeek logs     → Elasticsearch
```

## Log Aggregation

Security Onion acts as the central SIEM for the lab:

| Component | Role |
|-----------|------|
| **Wazuh** | Agent-based log collection, rule-based alerting, HIDS |
| **Elasticsearch** | Full-text indexing and storage of all log data |
| **Kibana** | Visualization, dashboards, and ad-hoc search |
| **Suricata** | Network IDS — generates alerts from packet inspection |
| **Zeek** | Network NSM — generates rich metadata from traffic |

All log data is indexed in Elasticsearch with daily indices for efficient retention management and query performance.

## Log Retention

| Tier | Age | Access Speed |
|------|-----|--------------|
| Hot data | 0–30 days | Fully searchable, real-time queries |
| Warm data | 30–90 days | Searchable, slightly slower queries |
| Cold storage | 90+ days | Archived, rarely accessed |

Elasticsearch index lifecycle management (ILM) policies control the automatic movement of indices between tiers.

## Analysis and Investigation

1. Analyst logs into the **Security Onion web dashboard** (`https://10.20.20.100`)
2. Uses **Kibana Discover** to search across all log sources simultaneously
3. Applies time filters, host filters, and field filters to narrow down events
4. Correlates network logs (Zeek/Suricata) with host logs (Sysmon/WinLogBeat)
5. Creates **investigation cases** in Security Onion to document findings
6. Generates reports summarizing the attack timeline and recommendations

## Related Documentation

- [NETWORK_TOPOLOGY.md](./NETWORK_TOPOLOGY.md) — network segments and IPs
- [DATA_FLOW.md](./DATA_FLOW.md) — end-to-end data flow diagrams
- [SIEM_INTEGRATION.md](./SIEM_INTEGRATION.md) — Security Onion component details
- [ANALYST_WORKFLOW.md](./ANALYST_WORKFLOW.md) — investigation process
