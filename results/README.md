# Results & Findings

This directory stores completed lab exercise results, detection validation evidence, and analysis summaries.

---

## Purpose

Each subdirectory or file here represents a completed lab exercise with documented findings. This serves as a portfolio record of the work done in the lab.

---

## Structure

```
results/
├── README.md                          # This file
├── YYYY-MM-DD-<exercise-name>/        # One folder per completed exercise
│   ├── summary.md                     # What was tested, what was detected
│   ├── splunk-queries-used.md         # Queries that fired (or didn't)
│   └── screenshots/                   # SIEM screenshots (sanitized)
└── ...
```

---

## Exercise Log

| Date | Exercise | Result | Detection Rate |
|------|----------|--------|----------------|
| — | — | — | — |

Add rows here as exercises are completed.

---

## Reporting Guidelines

- Summarize each exercise with: technique used, tools, log evidence found, detection status (detected / missed), and lessons learned.
- Sanitize all screenshots — remove real external IP addresses and personal information before committing.
- Do **not** commit raw log files (`.evtx`, `.log`, `.pcap`) — these are excluded by `.gitignore`.
- Store only sanitized summaries and screenshots in this directory.

For full SOC report templates, see [`../reports/`](../reports/).
