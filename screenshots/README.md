# Screenshots

This directory stores screenshots used as visual evidence and documentation throughout the lab.

---

## Organization

Organize screenshots by the phase of the lab they document:

```
screenshots/
├── lab-setup/           ← VM installation and configuration screenshots
├── attack-simulations/  ← Screenshots of attacks in progress
├── detections/          ← SIEM alerts and detection rule outputs
├── investigation-cases/ ← Evidence gathered during investigations
└── reports/             ← Completed dashboard or report screenshots
```

---

## Naming Convention

Use descriptive, lowercase, hyphen-separated filenames with a date prefix:

```
YYYY-MM-DD-<description>.png
```

**Examples:**
```
2024-01-15-security-onion-dashboard.png
2024-01-20-mimikatz-lsass-alert.png
2024-02-01-splunk-powershell-detection.png
```

---

## Guidelines

- Capture the full context (application window + relevant data).
- Redact or blur any personal information or real credentials before committing.
- Keep file sizes reasonable — compress screenshots if over 2 MB.
- Do not commit raw PCAP files or log exports here; those belong in their respective directories.
