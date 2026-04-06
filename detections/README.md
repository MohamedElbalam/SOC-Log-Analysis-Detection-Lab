# Detections

This directory contains custom detection rules, SIEM queries, and Sigma rules developed from the attack simulations performed in this lab.

---

## Structure

```
detections/
├── splunk/          ← Splunk SPL search queries
├── sigma/           ← Sigma rules (portable format)
└── wazuh/           ← Wazuh custom rules (XML)
```

---

## Detection Template

Each detection should be documented with:

### Rule Name
A concise, descriptive name.

### MITRE ATT&CK Mapping
Technique ID(s) this rule covers (e.g., `T1059.001 - PowerShell`).

### Description
What adversary behavior this detection identifies.

### Query / Rule
The raw SPL, KQL, Sigma YAML, or XML.

### Tuning Notes
Known false-positive sources and recommended exclusions.

### References
- Link to related attack simulation in [`attack-simulations/`](../attack-simulations/)
- Any external threat intelligence or public Sigma rule

---

## Planned Detections

| # | Detection Name | MITRE Technique | Format | Status |
|---|---|---|---|---|
| 1 | LSASS memory access | T1003.001 | Splunk SPL | Planned |
| 2 | Suspicious PowerShell encoding | T1059.001 | Sigma | Planned |
| 3 | Remote service creation | T1021.002 | Splunk SPL | Planned |
| 4 | Unusual parent-child process | T1055 | Sigma | Planned |
| 5 | DNS beaconing pattern | T1071.004 | Wazuh | Planned |

---

> Detection rules should be tested against both true-positive (lab attack) and true-negative (normal traffic) samples before being marked complete.
