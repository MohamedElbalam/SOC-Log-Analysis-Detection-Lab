# Detections

This directory contains detection rules, queries, and scripts for identifying the attack techniques simulated in this lab.

## Detection Coverage Matrix

| Attack | Splunk | Suricata | Zeek | Sysmon |
|--------|--------|----------|------|--------|
| Process Injection (T1055) | Yes | No | No | Yes |
| Credential Harvesting (T1003) | Yes | No | No | Yes |
| Persistence (T1547/T1053) | Yes | No | No | Yes |
| Lateral Movement (T1021) | Yes | Yes | Yes | Yes |
| Data Exfiltration (T1048) | Yes | Yes | Yes | No |

## Tool Guides

| Tool | Guide | Use Case |
|------|-------|----------|
| Splunk | [splunk-queries/README.md](splunk-queries/README.md) | SIEM queries over Windows event logs and Sysmon |
| Suricata | [suricata-rules/README.md](suricata-rules/README.md) | Network-based IDS signature detection |
| Zeek | [zeek-scripts/README.md](zeek-scripts/README.md) | Network traffic analysis and anomaly detection |
| Sysmon | [sysmon-rules/README.md](sysmon-rules/README.md) | Host-based endpoint telemetry rules |

## Detection Engineering Process

For each attack technique:

1. Run the attack simulation (see [../attack-simulations/](../attack-simulations/README.md))
2. Identify the log entries generated
3. Write a detection rule/query
4. Validate that it fires on attack traffic
5. Test for false positives on normal traffic
6. Document rule logic and tuning notes

## Log Sources

| Source | Format | Location |
|--------|--------|----------|
| Sysmon | Windows EVTX (XML) | `Applications and Services Logs\Microsoft\Windows\Sysmon\Operational` |
| Windows Security | Windows EVTX | `Security` |
| Zeek | TSV / JSON | `/nsm/zeek/logs/current/` on Security Onion |
| Suricata | JSON (eve.json) | `/nsm/suricata/eve.json` on Security Onion |
