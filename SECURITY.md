# Security Policy

## ⚠️ Important Disclaimer

This repository is intended **strictly for educational purposes** in an **isolated, controlled lab environment**. All documented attack techniques and tools are provided for defensive security learning only.

**Never use these techniques against systems you do not own or do not have explicit, written permission to test.**

Unauthorized use of these techniques may violate local, national, and international laws including:
- The Computer Fraud and Abuse Act (CFAA) in the United States
- The Computer Misuse Act (CMA) in the United Kingdom
- Similar cybercrime legislation in your jurisdiction

---

## 🛡️ Lab Safety Guidelines

### Network Isolation
- **Always** run attack simulations on an isolated virtual network
- **Never** bridge your attack VMs directly to your home or corporate network
- Use pfSense or a similar firewall to segment attacker and victim networks
- Disable internet access for attacker VMs unless strictly required (and re-enable only temporarily)

### VM Snapshots
- Take snapshots of all VMs **before** running any attack simulation
- Label snapshots clearly with date and lab state (e.g., `clean-baseline-2024-01-15`)
- Restore to a clean snapshot after each lab exercise

### Credential Hygiene
- Use **throwaway credentials** for all lab VMs — never reuse real passwords
- Do not store real API keys, tokens, or credentials anywhere in this repository
- Use placeholder values (e.g., `YOUR_PASSWORD_HERE`) in any example configs

### Data Handling
- Do not commit raw log files containing real hostnames, IP addresses, or usernames
- Sanitize any captured pcap or EVTX files before sharing
- The `.gitignore` in this repo excludes common sensitive file types by default

---

## 🔑 Reporting Security Issues

If you discover a security vulnerability in the **scripts or configurations** within this repository (not in the tools it references), please:

1. **Do not** open a public GitHub issue
2. Email the maintainer directly with a description of the issue
3. Allow reasonable time for a fix before public disclosure

For vulnerabilities in third-party tools referenced here (Sysmon, Security Onion, pfSense, etc.), report to their respective maintainers.

---

## ✅ Ethical Use Checklist

Before running any attack simulation, confirm:

- [ ] All target VMs are on an isolated virtual network
- [ ] You have taken VM snapshots before starting
- [ ] No real credentials or sensitive data are present on victim VMs
- [ ] You have legal authorization to test these systems (your own lab)
- [ ] Internet access is disabled or tightly controlled on the attacker network
- [ ] You understand what the attack technique does before executing it

---

## 📚 Responsible Disclosure Resources

- [OWASP Responsible Disclosure](https://owasp.org/www-community/vulnerabilities/Repudiation)
- [CERT Coordination Center](https://www.kb.cert.org/vuls/)
- [HackerOne Disclosure Guidelines](https://www.hackerone.com/disclosure-guidelines)
