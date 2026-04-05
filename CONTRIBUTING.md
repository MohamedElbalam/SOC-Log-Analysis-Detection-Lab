# Contributing to SOC Log Analysis Detection Lab

Thank you for your interest in contributing! This is primarily a personal learning lab, but structured contributions are welcome.

---

## How to Contribute

### Reporting Issues
- Use GitHub Issues to report typos, broken links, or factual errors in documentation.
- Include a clear title, description of the problem, and the file path affected.

### Suggesting Improvements
- Open an Issue first to discuss the change before submitting a pull request.
- Label it `enhancement` or `documentation` as appropriate.

### Submitting Pull Requests

1. **Fork** the repository.
2. **Create a branch** with a descriptive name:
   ```bash
   git checkout -b feature/add-mimikatz-detection-rule
   ```
3. **Make your changes** following the conventions below.
4. **Test** any scripts or queries before submitting.
5. **Submit a pull request** with a clear description of what was changed and why.

---

## Contribution Guidelines

### Documentation
- Write in clear, concise English.
- Use proper Markdown formatting (headings, code blocks, tables).
- Place code samples in fenced code blocks with the appropriate language tag (` ```bash `, ` ```powershell `, ` ```splunk `).
- Do not include screenshots that contain real credentials, IP addresses from production systems, or sensitive personal information.

### Attack Simulations
- Document each technique with its MITRE ATT&CK tactic and technique ID (e.g., `T1055 — Process Injection`).
- Provide step-by-step reproduction steps.
- Include the expected log evidence generated.
- Do **not** contribute malware samples, exploit code targeting real CVEs, or tools that could cause harm outside an isolated lab.

### Detection Rules
- Include the SIEM platform the rule targets (Splunk, Wazuh, Security Onion).
- Explain what the rule detects and why it is effective.
- Note known false positives.

### Scripts
- Include a header comment explaining the script's purpose, usage, and dependencies.
- Prefer Python or PowerShell for portability.
- Do not hardcode credentials, IP addresses, or hostnames.

### Configuration Files
- Sanitize all configs before committing — remove real IPs, passwords, and API keys.
- Add comments explaining non-obvious configuration choices.

---

## Code of Conduct

- Be respectful and constructive in all interactions.
- This project is for **educational and defensive security purposes only**. Contributions that promote offensive use outside authorized environments will be rejected.

---

## Questions?

Open a GitHub Issue or reach out via the repository's contact information.
