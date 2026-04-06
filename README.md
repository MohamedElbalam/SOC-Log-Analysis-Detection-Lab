# SOC Log Analysis Detection Lab

## Overview

The **SOC Log Analysis Detection Lab** is a comprehensive hands-on training platform designed for security professionals, SOC analysts, and incident response teams to develop expertise in log analysis and threat detection strategies. This repository simulates real-world attack scenarios on computer networks, captures network traffic and system logs, and provides tools for analyzing and detecting security threats.

Whether you're new to cybersecurity or an experienced analyst looking to sharpen your skills, this lab provides practical experience with:
- 🎯 Real-world attack simulations
- 📊 Log analysis techniques
- 🔍 Threat detection methodologies
- 🛡️ Incident response procedures
- 📈 Custom detection rule creation

## Features

- **Attack Simulations**: Multiple attack scenarios including network reconnaissance, brute force, lateral movement, and data exfiltration
- **Sample Logs**: Real-world log formats from Windows, Linux, web servers, and network devices
- **Detection Rules**: Pre-built detection rules for common attack patterns
- **Analysis Scripts**: Automated tools for log parsing, correlation, and threat analysis
- **Configuration Templates**: Ready-to-use configs for SIEM and log analysis tools
- **Comprehensive Documentation**: Step-by-step guides and best practices
- **Unit Tests**: Automated testing for script reliability and code quality

## Directory Structure

```
SOC-Log-Analysis-Detection-Lab/
├── data/                    # Sample log files for analysis
│   ├── windows/            # Windows Security Event Logs
│   ├── linux/              # Linux system and auth logs
│   ├── network/            # Network traffic and IDS logs
│   └── application/        # Application-level logs
│
├── scripts/                # Analysis and processing scripts
│   ├── parsers/           # Log parsing utilities
│   ├── correlation/       # Event correlation scripts
│   ├── analysis/          # Statistical analysis tools
│   └── utils/             # Helper functions
│
├── configs/               # Configuration files
│   ├── siem/             # SIEM tool configurations
│   ├── ids/              # IDS/IPS rule configurations
│   └── log-collectors/   # Log collection tool configs
│
├── detections/           # Custom detection rules
│   ├── sigma/            # SIGMA detection rules
│   ├── yara/             # YARA malware detection rules
│   └── custom/           # Custom detection logic
│
├── attack-simulations/   # Attack scenario documentation
│   ├── reconnaissance/   # Network scanning and enumeration
│   ├── brute-force/      # Credential attack scenarios
│   ├── lateral-movement/ # Post-compromise movement techniques
│   └── data-exfiltration/# Data theft scenarios
│
├── docs/                 # Comprehensive documentation
│   ├── setup.md          # Installation and setup guide
│   ├── usage.md          # How to use the lab
│   ├── detection-guide.md# Detection methodology
│   └── contributing.md   # Contribution guidelines
│
└── tests/               # Unit tests for scripts and functions
```

## Quick Start

### Prerequisites

- **OS**: Linux (Ubuntu 20.04+), macOS, or Windows (WSL2)
- **Python**: 3.8 or higher
- **Tools**: Git, Docker (optional)
- **Knowledge**: Basic understanding of log formats and network protocols

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/MohamedElbalam/SOC-Log-Analysis-Detection-Lab.git
   cd SOC-Log-Analysis-Detection-Lab
   ```

2. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the setup script**:
   ```bash
   python setup.py
   ```

4. **Verify installation**:
   ```bash
   python -m pytest tests/
   ```

### Basic Usage

#### Analyzing Logs

```bash
# Parse Windows Security Event Logs
python scripts/parsers/windows_parser.py data/windows/security.evtx

# Analyze network traffic logs
python scripts/analysis/network_analyzer.py data/network/traffic.log

# Run correlation analysis
python scripts/correlation/correlate_events.py data/ --timeframe 1h
```

#### Running Detection Rules

```bash
# Apply SIGMA detection rules
python scripts/detections/apply_sigma_rules.py data/ --rules detections/sigma/

# Generate detection report
python scripts/analysis/generate_report.py data/ --output report.html
```

#### Simulating Attacks

```bash
# Run attack simulation
bash attack-simulations/brute-force/run_simulation.sh

# Capture network traffic during attack
sudo tcpdump -i eth0 -w capture.pcap
```

## Learning Paths

### Beginner
1. Review `docs/setup.md` - Install and configure the lab
2. Analyze sample logs in `data/` directory
3. Complete basic log parsing exercises in `scripts/parsers/`
4. Study `docs/detection-guide.md`

### Intermediate
1. Run attack simulations from `attack-simulations/`
2. Create custom detection rules using SIGMA format
3. Correlate events across multiple log sources
4. Analyze false positives and tune detections

### Advanced
1. Build custom analysis scripts
2. Integrate with your SIEM platform
3. Develop complex detection correlations
4. Contribute new attack scenarios and rules

## Attack Scenarios Included

- **Reconnaissance**: Network scanning, service enumeration, vulnerability scanning
- **Brute Force**: SSH login attempts, HTTP authentication attacks, password spraying
- **Lateral Movement**: Privilege escalation, credential theft, internal reconnaissance
- **Data Exfiltration**: Large file transfers, unusual network connections, data staging

For detailed attack reproduction steps, see `attack-simulations/README.md`.

## Detection Examples

### Example 1: Detect Brute Force SSH Attacks

```bash
python scripts/analysis/detect_ssh_bruteforce.py data/linux/auth.log --threshold 10 --window 5m
```

### Example 2: Correlate Multiple Security Events

```bash
python scripts/correlation/correlate_events.py data/ \
  --rules detections/sigma/windows_suspicious_process.yml \
  --timeframe 10m
```

### Example 3: Generate Detection Report

```bash
python scripts/analysis/generate_report.py data/ \
  --output detection_report.html \
  --include-statistics
```

For more examples, see `docs/usage.md`.

## Tools & Technologies

- **Languages**: Python, Bash, YAML
- **Log Analysis**: Pandas, NumPy, Regular Expressions
- **Detection Formats**: SIGMA rules, YARA rules
- **SIEM Integration**: Splunk, Elasticsearch, ArcSight
- **Optional**: Docker, Kubernetes for scalable deployments

## Testing

Run the test suite to ensure all scripts function correctly:

```bash
# Run all tests
python -m pytest tests/ -v

# Run specific test module
python -m pytest tests/test_parsers.py -v

# Run with coverage report
python -m pytest tests/ --cov=scripts/ --cov-report=html
```

## Configuration

Sample configurations are provided in the `configs/` directory. Customize these files based on your environment:

- `configs/siem/splunk_inputs.conf` - Splunk log input configuration
- `configs/ids/snort_rules.conf` - IDS rule configuration
- `configs/log-collectors/filebeat.yml` - Log collection configuration

## Contribution

Contributions are welcome! We're looking for:
- New attack simulation scenarios
- Additional detection rules
- Improved analysis scripts
- Documentation improvements
- Bug fixes and performance enhancements

Please read `docs/contributing.md` for guidelines on:
- Code style and standards
- Testing requirements
- Pull request process
- Documentation standards

## Troubleshooting

**Issue**: Scripts fail to run
- **Solution**: Ensure all dependencies are installed: `pip install -r requirements.txt`

**Issue**: Log files not found
- **Solution**: Check that log files exist in `data/` directory and paths are correct

**Issue**: Detection rules not matching events
- **Solution**: Verify log format matches rule expectations. Review `docs/detection-guide.md`

For more troubleshooting, see `docs/troubleshooting.md`.

## Resources & References

- [MITRE ATT&CK Framework](https://attack.mitre.org/) - Adversary tactics and techniques
- [SIGMA Rules](https://github.com/SigmaHQ/sigma) - Generic detection rule format
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework) - Industry standards
- [OWASP Logging Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html)

## License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## Support & Contact

- **Issues**: Report bugs or feature requests via [GitHub Issues](https://github.com/MohamedElbalam/SOC-Log-Analysis-Detection-Lab/issues)
- **Discussions**: Join discussions in [GitHub Discussions](https://github.com/MohamedElbalam/SOC-Log-Analysis-Detection-Lab/discussions)
- **Author**: [Mohamed Elbalam](https://github.com/MohamedElbalam)

## Disclaimer

This lab is designed for **educational purposes only**. All attack simulations should only be performed in isolated lab environments with proper authorization. Unauthorized access to computer systems is illegal.

---

**Last Updated**: 2026-04-06 | **Version**: 1.0.0