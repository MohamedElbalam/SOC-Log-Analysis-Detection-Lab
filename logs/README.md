# Logs

This directory is a placeholder for sample and sanitized log files used in lab exercises.

---

## Guidelines

- **Never commit raw logs** containing real hostnames, usernames, IP addresses, or sensitive data
- **Sanitize logs** before committing — replace real values with placeholders (e.g., `192.168.100.XX`, `HOSTNAME-01`)
- **Preferred formats:** JSON, CSV, plain text; avoid binary formats (.evtx, .pcap) unless absolutely necessary
- The `.gitignore` in this repository excludes `.log`, `.pcap`, `.cap`, and `.evtx` files by default

---

## Directory Structure (Suggested)

```
logs/
├── sysmon/       ← Sanitized Sysmon EVTX exports (JSON format)
├── zeek/         ← Sanitized Zeek connection logs
├── suricata/     ← Example Suricata alert logs
└── windows/      ← Sanitized Windows Security Event logs
```

---

## Adding Log Samples

When adding sanitized log samples:
1. Export from your SIEM in JSON or CSV format
2. Use a text editor to replace real values with placeholders
3. Name files descriptively: `sysmon-lsass-access-example.json`
4. Document the context (what attack generated this log) in a comment at the top of the file
