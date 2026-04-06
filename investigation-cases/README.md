# Investigation Cases

Hands-on incident investigation scenarios. Each case simulates a real SOC analyst workflow with log data, guiding questions, and a full answer key.

## How to Use

1. Read the scenario description in each case folder
2. Examine the provided log samples
3. Answer the guiding questions independently
4. Compare your findings to the answer key
5. Document your investigation in the report template: [../reports/incident-report-template.md](../reports/incident-report-template.md)

## Cases

| Case | Scenario | Difficulty |
|------|---------|------------|
| [Case 01](case-01-suspicious-process/README.md) | Suspicious process execution on workstation | Beginner |
| [Case 02](case-02-unusual-network-activity/README.md) | Unusual outbound network connections | Intermediate |
| [Case 03](case-03-credential-access/README.md) | Credential access and lateral movement | Advanced |

## Investigation Methodology

Follow the SOC triage process for each case:

1. **Triage** — Determine the severity and scope
2. **Containment** — What would you do to stop the spread?
3. **Evidence Collection** — What logs confirm the attack?
4. **Root Cause Analysis** — How did the attacker get in?
5. **Timeline** — Build a chronological attack timeline
6. **Reporting** — Document findings in professional format

## Skills Practiced

- Log analysis (EVTX, Sysmon, Zeek, Suricata)
- Splunk SPL queries
- Incident timeline construction
- IOC (Indicator of Compromise) identification
- MITRE ATT&CK mapping
- Professional report writing
