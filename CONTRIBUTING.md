# Contributing to SOC Log Analysis Detection Lab

Thank you for your interest in contributing! This is primarily a personal learning and portfolio project, but community contributions are welcome.

---

## 🤝 How to Contribute

### Types of Contributions Welcome

- **Bug fixes** in scripts or configuration examples
- **New attack simulation** write-ups (with MITRE ATT&CK mapping)
- **New detection rules** (Splunk SPL, Wazuh rules, Sigma format)
- **Documentation improvements** (grammar, clarity, completeness)
- **New investigation case studies** (based on real-world scenarios)
- **Example configs** for Sysmon, Suricata, Zeek, etc.

### Not Accepted

- Actual malware samples or weaponized exploit code
- Credentials, API keys, or any sensitive data
- Changes that remove the educational focus of the lab

---

## 🔄 Contribution Process

1. **Fork** the repository
2. **Create a feature branch** from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
3. **Make your changes** following the style guidelines below
4. **Test your changes** — ensure scripts run correctly and docs render properly
5. **Commit** with a clear, descriptive message:
   ```bash
   git commit -m "Add: Mimikatz detection rule for LSASS access (T1003.001)"
   ```
6. **Push** your branch and open a **Pull Request**

---

## 📝 Style Guidelines

### Documentation
- Use clear, concise English
- Include MITRE ATT&CK technique IDs where applicable (e.g., `T1059.001`)
- Add screenshots where they add value
- Keep a consistent structure with existing files in the same directory

### Attack Simulations
Each simulation write-up should include:
- **Technique name** and MITRE ATT&CK ID
- **Prerequisites** (what must be set up first)
- **Step-by-step commands** with explanations
- **Expected log artifacts** (what events/fields to look for)
- **Detection** (link to corresponding detection rule)

### Detection Rules
Each detection should include:
- **Rule name** and description
- **Log source** (Sysmon Event ID, Windows Event Log, Zeek, etc.)
- **Query** (Splunk SPL, Wazuh rule XML, or Sigma format)
- **False positive guidance**
- **Corresponding attack simulation** (link back)

### Scripts
- Include a comment block at the top describing purpose, usage, and requirements
- Validate inputs and handle errors gracefully
- Use descriptive variable names

---

## 🐛 Reporting Issues

Use GitHub Issues to report:
- Broken links or missing files
- Incorrect commands or outdated instructions
- Typos or unclear documentation

Please include enough context for someone to reproduce the issue.

---

## 📜 Code of Conduct

- Be respectful and constructive in all interactions
- Provide factual, evidence-based feedback
- Remember: this is a learning environment — mistakes happen

---

## 📄 License

By contributing, you agree that your contributions will be licensed under the same [MIT License](./LICENSE) that covers this project.
