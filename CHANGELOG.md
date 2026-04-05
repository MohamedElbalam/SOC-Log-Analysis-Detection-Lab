# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Planned
- Complete Windows victim VM Sysmon deployment documentation
- Add Mimikatz credential dumping simulation write-up
- Add LSASS access detection rule (Splunk SPL)
- Add PowerShell abuse simulation and detection
- Add lateral movement investigation case study
- Add incident report template

---

## [0.3.0] - 2024-04-05

### Added
- Comprehensive main `README.md` with architecture overview, prerequisites, and lab exercises
- `LICENSE` (MIT)
- `CONTRIBUTING.md` with contribution guidelines
- `SECURITY.md` with lab safety best practices
- `CHANGELOG.md` (this file)
- `.gitignore` covering VM artifacts, sensitive files, and log files
- `docs/SETUP.md` — detailed step-by-step environment setup guide
- `docs/ARCHITECTURE.md` — lab infrastructure and network design documentation
- `attack-simulations/README.md` — attack catalogue with MITRE ATT&CK mappings
- `detections/README.md` — detection rules index with example Splunk queries
- `investigation-cases/README.md` — structured case study format
- `reports/README.md` — SOC report templates and examples
- `configs/` directory with example Sysmon configuration
- `scripts/` directory with helper automation scripts
- `logs/.gitkeep` placeholder

### Changed
- Fixed typos in original README ("snapchats" → "snapshots")
- Improved all sub-directory README files for clarity

---

## [0.2.0] - 2024-03-01

### Added
- Lab setup guides for pfSense, Proxmox, Security Onion, Kali Linux, and Ubuntu
- Architecture diagram (DrawIO SVG) with network topology
- Remote access documentation (Tailscale)
- Tool reference documentation

---

## [0.1.0] - 2024-01-15

### Added
- Initial repository structure
- Basic README with project description
- Directory scaffolding: `attack-simulations/`, `detections/`, `investigation-cases/`, `reports/`, `screenshots/`
