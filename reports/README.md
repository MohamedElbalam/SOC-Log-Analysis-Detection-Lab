# SOC Reports

This directory contains professional SOC-style incident reports and report templates. Reports document the full lifecycle of a security incident from detection through remediation.

---

## Report Index

| Report | Incident | Date | Status |
|---|---|---|---|
| [RPT-001](#rpt-001-template) | Incident Report Template | — | ✅ Available |
| RPT-002 | Mimikatz Credential Dump — WIN10-VICTIM | 2024-04-05 | 🔄 Draft |

---

## RPT-001: Template

Use this template for all incident reports in the lab.

**Report ID:** RPT-XXX  
**Date of Incident:** YYYY-MM-DD  
**Date of Report:** YYYY-MM-DD  
**Analyst:** [Name]  
**Severity:** Critical / High / Medium / Low  
**Status:** Open / Closed / Under Review  

### Executive Summary

[2-3 sentence non-technical summary of what happened, impact, and current status.]

### Incident Details

| Field | Value |
|---|---|
| Detection Source | [Alert name / tool] |
| Affected Systems | [Hostnames / IPs] |
| ATT&CK Techniques | [T1003.001, etc.] |
| Attacker IP | [IP if known] |
| Time of Detection | YYYY-MM-DD HH:MM UTC |
| Time of Containment | YYYY-MM-DD HH:MM UTC |
| Time to Detect (TTD) | X minutes |
| Time to Contain (TTC) | X minutes |

### Timeline of Events

| Timestamp (UTC) | Event Description | Evidence Source |
|---|---|---|
| YYYY-MM-DD HH:MM | [Event] | [Sysmon / Zeek / etc.] |

### Technical Analysis

**Initial Access:** [How the attacker gained access]

**Execution:** [What commands / tools were used]

**Persistence:** [Any persistence mechanisms established]

**Credential Access:** [Any credential theft attempted / successful]

**Lateral Movement:** [Any movement to other systems]

### Indicators of Compromise (IOCs)

| Type | Value | Description |
|---|---|---|
| IP | x.x.x.x | Attacker C2 server |
| File Hash (MD5) | xxxxxxxx | Malicious binary |
| File Name | mimikatz.exe | Credential dump tool |

### Containment & Remediation

| Action | Status | Notes |
|---|---|---|
| Isolate affected host | ✅ Done | Reverted to clean snapshot |
| Reset compromised accounts | ✅ Done | |
| Block attacker IP | ✅ Done | pfSense firewall rule |

### Lessons Learned

**What Worked:**
- [Detection X fired within N seconds]

**What Needs Improvement:**
- [Gap identified]

**Rule/Process Changes Recommended:**
- [Specific action item]

---

## Reporting Best Practices

1. **Be factual** — only document what the evidence supports
2. **Include timestamps** — always use UTC for consistency
3. **Quantify impact** — TTD and TTC are key metrics
4. **Separate technical and executive sections** — different audiences need different levels of detail
5. **Document IOCs** — makes it easy to add detections for future similar incidents
6. **Link evidence** — reference screenshots, log extracts, and PCAP files

---

## Resources

- [SANS Incident Response Report Template](https://www.sans.org/score/incident-forms/)
- [NIST SP 800-61 Rev 2](https://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-61r2.pdf)
- [Cyber Kill Chain Framework](https://www.lockheedmartin.com/en-us/capabilities/cyber/cyber-kill-chain.html)
