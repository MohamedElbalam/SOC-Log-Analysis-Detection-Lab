# Investigation Cases

This directory contains end-to-end incident investigation walkthroughs based on attack simulations performed in this lab. Each case follows a structured SOC analyst workflow.

---

## Structure

```
investigation-cases/
└── <case-id>-<short-title>/
    ├── README.md        ← Full investigation write-up
    └── screenshots/     ← Evidence and timeline artifacts
```

---

## Investigation Template

Each case should follow the standard investigation workflow:

### Case Metadata
| Field | Value |
|---|---|
| Case ID | CASE-XXXX |
| Date | YYYY-MM-DD |
| Severity | Critical / High / Medium / Low |
| Status | Open / Closed |
| MITRE Techniques | T1XXX, T1XXX |

### Executive Summary
One-paragraph overview of what happened and the outcome.

### Timeline of Events
Chronological reconstruction of attacker activity.

### Investigation Steps
Step-by-step analysis performed (SIEM queries, log pivots, host triage).

### Indicators of Compromise (IOCs)
- File hashes
- IP addresses / domains
- Registry keys
- Process names

### Root Cause
What allowed the attack to succeed.

### Recommendations
Remediation and hardening actions taken or proposed.

---

## Planned Cases

| Case ID | Title | Severity | Status |
|---|---|---|---|
| CASE-001 | Credential Dumping via LSASS | High | Planned |
| CASE-002 | PowerShell Reverse Shell | High | Planned |
| CASE-003 | Lateral Movement via PsExec | Medium | Planned |
