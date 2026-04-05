# Screenshots

This directory stores screenshots taken during lab exercises as evidence of successful attack simulations and detections.

---

## Organization

Screenshots should be named descriptively and organized by exercise:

```
screenshots/
├── lab-setup/         ← VM and network setup screenshots
├── attack-sims/       ← Attack simulation evidence
├── detections/        ← Alert and detection screenshots
└── investigation/     ← Investigation timeline screenshots
```

---

## Naming Convention

Use the format: `CASE-XXX_description_YYYYMMDD.png`

Examples:
- `CASE-001_lsass-access-alert_20240405.png`
- `CASE-001_mimikatz-process-create_20240405.png`
- `setup_security-onion-dashboard_20240301.png`

---

## Guidelines

- Capture the full relevant window — include timestamps and context
- Annotate screenshots when helpful (highlight the relevant field/alert)
- Keep file sizes reasonable — compress large screenshots before committing
- Reference screenshots in investigation case files: `![Alert Screenshot](../screenshots/CASE-001_lsass-access-alert_20240405.png)`
