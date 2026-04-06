# Investigation Case Implementation Outline

## Case 1: Suspicious Process Execution

### Case Overview
TODO: Write
- Scenario: What happened?
- Initial alert: What triggered investigation?
- Timeline: When did events occur?
- Scope: Which systems affected?

### Initial Alert
TODO: Document

```
Alert: Sysmon detected suspicious process
Source: Windows 10 (10.20.20.10)
Time: 2026-04-06 14:30:45 UTC
Event: Process "cmd.exe" spawned by "explorer.exe"
Severity: Medium
```

### Investigation Phase 1: Data Collection
TODO: Complete Investigation Checklist
- [ ] List all process execution events on Windows 10
- [ ] Find parent process details
- [ ] Identify process command line
- [ ] Check process hash/signature
- [ ] Find network connections from process
- [ ] Check registry modifications
- [ ] List files created/accessed
- [ ] Find user account used

### Investigation Phase 2: Timeline Construction
TODO: Build Timeline

```
T+00:00 - [Event] Process creation detected
T+00:05 - [Event] Child process spawned
T+00:10 - [Event] Network connection established
T+00:15 - [Event] File created
T+00:20 - [Event] Registry modified
```

TODO: Questions to Answer
- What is the complete attack sequence?
- When did it start?
- What was the objective?
- How was initial access gained?

### Investigation Phase 3: Root Cause Analysis
TODO: Analyze
1. [ ] How did attacker gain initial access?
2. [ ] What attack technique was used? (MITRE ATT&CK mapping)
3. [ ] Which systems were affected?
4. [ ] What was the attacker's objective?
5. [ ] Were controls bypassed? How?

### Investigation Phase 4: Evidence Collection
TODO: Collect Evidence
- [ ] Screenshot of Sysmon logs
- [ ] Screenshot of process tree
- [ ] Screenshot of network connections
- [ ] Hash of suspicious file
- [ ] Registry modification details
- [ ] Timeline visualization

### Investigation Report
TODO: Write Report

```markdown
INCIDENT INVESTIGATION REPORT

Case ID: 2026-04-06-001
Severity: [High/Medium/Low]
Date: [Date]
Analyst: [Your Name]

EXECUTIVE SUMMARY
[Write 2-3 sentence summary of incident]

AFFECTED SYSTEMS
- [List systems]

ATTACK TIMELINE
[Detailed timeline from above]

TECHNICAL ANALYSIS
1. Initial Access Method:
2. Attack Technique (MITRE):
3. Command Used:
4. Objective:
5. Indicators of Compromise:

FINDINGS
- [Finding 1]
- [Finding 2]
- [Finding 3]

RECOMMENDATIONS
1. [Remediation step]
2. [Detection improvement]
3. [Prevention measure]

CONCLUSION
[Summary conclusion]
```

### Learning Outcomes
TODO: Document
- What did you learn about this attack?
- What new detection did you create?
- How would you prevent this in future?
- What skills improved?

---

## Case 2: Lateral Movement Detection

### Case Overview
TODO: Write
- Attacker compromised one machine
- Goal: Access other machines
- Method: SMB/Pass-the-hash/etc

### Initial Alert
TODO: Document Alert Details

### Investigation Phases
TODO: Complete (similar to Case 1)
- Phase 1: Data collection
- Phase 2: Timeline
- Phase 3: Root cause
- Phase 4: Evidence

### Key Investigations
TODO: Answer
1. How did attacker move laterally?
2. What credentials were used?
3. Which machines were accessed?
4. What was the objective?
5. How long did attacker have access?

---

## Case 3: Data Exfiltration

### Case Overview
TODO: Write
- Data theft scenario
- Detection method
- Scope of impact

### Investigation Steps
TODO: Complete
1. Identify unusual data transfer
2. Determine source and destination
3. Identify attacker infrastructure
4. Calculate data loss
5. Identify accessed files

---

## Investigation Case Templates

### Template: Case File Structure

```
investigation-cases/[CASE-NAME]/
├── README.md (Full case documentation)
├── logs/
│   ├── process-execution.csv
│   ├── network-connections.csv
│   ├── file-access.csv
│   └── sysmon-events.json
├── screenshots/
│   ├── initial-alert.png
│   ├── timeline.png
│   ├── investigation-query.png
│   └── final-report.png
└── report.md (Investigation report)
```

### Investigation Workflow Template

```markdown
# Investigation Workflow

## Initial Alert
[Alert details]

## Questions to Answer
- [ ] Question 1?
- [ ] Question 2?
- [ ] Question 3?

## Data Collection
- [ ] Logs searched
- [ ] Artifacts identified
- [ ] Timeline created

## Root Cause Analysis
[Findings]

## Impact Assessment
[Scope of impact]

## Recommendations
[Mitigation steps]
```

---

## Success Criteria for Case
- [ ] Case scenario written
- [ ] Can be investigated step-by-step
- [ ] All needed logs present
- [ ] Answer key documented
- [ ] Screenshots included
- [ ] Report template filled
- [ ] Learning outcomes captured
