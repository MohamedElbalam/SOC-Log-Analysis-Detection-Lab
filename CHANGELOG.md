# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Planned
- Sysmon deployment documentation and config
- First attack simulation playbooks (process injection, Mimikatz)
- Splunk detection query library
- Incident investigation case walkthroughs
- Final SOC report templates

---

## [0.2.0] — 2025-04-05

### Added
- Comprehensive `README.md` with architecture overview, prerequisites, lab structure, and security warnings
- `LICENSE` (MIT)
- `CONTRIBUTING.md` with contribution guidelines
- `SECURITY.md` with lab safety and credential hygiene guidance
- `.gitignore` covering VM files, logs, secrets, OS artifacts, and editor files
- `docs/SETUP.md` — step-by-step environment setup guide
- `docs/ARCHITECTURE.md` — lab network topology documentation
- `docs/TOOLS.md` — tools reference with purpose and configuration notes
- `attack-simulations/README.md` — comprehensive attack playbooks (process injection, Mimikatz, PowerShell abuse, C2 simulation)
- `detections/README.md` — Splunk and Wazuh detection rules with methodology
- `configs/` directory with example configurations:
  - `configs/sysmon/sysmon-config.xml` — production-ready Sysmon configuration
  - `configs/splunk/inputs.conf` — Splunk universal forwarder inputs
  - `configs/wazuh/local_rules.xml` — custom Wazuh detection rules
- `scripts/README.md` — automation scripts directory
- `results/README.md` — findings and reports directory

### Changed
- Fixed typos in original README (`snapchats` → `snapshots`)
- Improved formatting and clarity across existing lab-setup subdirectory notes

---

## [0.1.0] — 2025 (Initial)

### Added
- Initial repository structure
- Basic `README.md`
- Lab setup notes for Proxmox, pfSense, Security Onion, Ubuntu, Kali Linux, and remote access
- Architecture diagram (SVG)
- Placeholder README files for attack-simulations, detections, investigation-cases, and reports
