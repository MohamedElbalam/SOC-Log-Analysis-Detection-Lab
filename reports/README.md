# Reports

This directory contains professional SOC report templates and completed incident reports generated from lab investigations.

---

## Structure

```
reports/
├── templates/           ← Reusable report templates
│   ├── incident-report-template.md
│   └── executive-summary-template.md
└── completed/           ← Finished reports (one per incident)
    └── YYYY-MM-DD-<title>/
```

---

## Report Types

### Incident Report
A detailed technical report covering the full lifecycle of a detected incident:
- Detection alert details
- Investigation timeline
- Affected systems and accounts
- IOCs
- Remediation steps taken
- Lessons learned

### Executive Summary
A non-technical one-page summary suitable for management:
- What happened (plain language)
- Business impact
- Actions taken
- Recommended follow-ups

---

## Writing Standards

- Use past tense for completed events.
- Include timestamps in ISO 8601 format (`YYYY-MM-DD HH:MM:SS UTC`).
- Redact or anonymize any real personal data before committing.
- Link to supporting evidence in [`screenshots/`](../screenshots/) and [`investigation-cases/`](../investigation-cases/).
