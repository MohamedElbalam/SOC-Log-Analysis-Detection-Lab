# Screenshots

This directory stores lab screenshots organized by section.

## Structure

```
screenshots/
├── lab-setup/       # VM installation and configuration
├── attacks/         # Attack simulation evidence
├── detections/      # SIEM alerts and detection rule triggers
└── analysis/        # Investigation case walkthroughs
```

## Screenshot Guidelines

### lab-setup/
- Proxmox VM list showing all running VMs
- pfSense dashboard with interface assignments
- Security Onion status (`so-status` output)
- Kibana/Elasticsearch index health
- Tailscale admin console showing subnet routes

### attacks/
- Kali terminal showing attack commands
- Meterpreter session established
- Credential dump output (redact real passwords — use lab-only dummy credentials)
- Network traffic in Wireshark during attack

### detections/
- Kibana/Splunk alert firing
- Suricata alert in Security Onion console
- Sysmon Event in Windows Event Viewer
- Detection dashboard showing all active alerts

### analysis/
- Splunk search results for investigation case
- Timeline view of events in Kibana
- MITRE ATT&CK Navigator heatmap
- Final report excerpt

## Naming Convention

Use descriptive names with the following format:

```
YYYY-MM-DD_<section>_<description>.png
```

Examples:
```
2024-01-15_lab-setup_proxmox-vm-list.png
2024-01-15_attacks_meterpreter-session.png
2024-01-15_detections_lsass-alert-kibana.png
2024-01-15_analysis_case01-timeline.png
```

## Tips

- Use full-screen screenshots for dashboards
- Crop sensitive data (real IPs, hostnames, credentials from production environments)
- Add screenshots to README files in the relevant section as evidence
