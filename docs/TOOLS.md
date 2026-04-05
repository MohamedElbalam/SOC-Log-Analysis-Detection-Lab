# Tools Reference

An overview of every tool used in this lab, its purpose, and where to find configuration or usage notes.

---

## Virtualization

| Tool | Version | Purpose | Notes |
|------|---------|---------|-------|
| **Proxmox VE** | 7+ | Hypervisor — manages all VMs and virtual networks | Enable AES-NI in BIOS |
| **QEMU Guest Agent** | Latest | Allows Proxmox to communicate with running VMs | Required for clean snapshots |

---

## Networking & Firewall

| Tool | Purpose | Notes |
|------|---------|-------|
| **pfSense CE** | Firewall, router, NAT between lab networks | BSD-based; FreeBSD VM type in Proxmox |
| **Tailscale** | Secure remote access with MFA and subnet routing | Free tier sufficient for home lab |
| **Cloudflare Tunnel** | Web UI access without open ports | Optional; useful for Proxmox management |

---

## Attack Platforms

| Tool | Platform | Purpose |
|------|----------|---------|
| **Kali Linux** | Attacker VM (vmbr1) | Primary penetration testing distro |
| **Parrot OS** | Attacker VM (vmbr1) | Lightweight alternative attacker OS |
| **Metasploit Framework** | Kali | Exploit framework — modules for common attacks |
| **Mimikatz** | Windows | Credential dumping, pass-the-hash, Kerberoasting |
| **Impacket** | Kali/Python | SMB, Kerberos, NTLM attack toolset |
| **Atomic Red Team** | Windows victim VMs | MITRE ATT&CK-mapped attack simulation library |
| **Nmap** | Kali | Network discovery and port scanning |
| **Netcat / ncat** | Kali | Reverse shells, C2 simulation |

---

## Log Collection

| Tool | Platform | Purpose | Config |
|------|----------|---------|--------|
| **Sysmon** | Windows victim VMs | Deep Windows event logging (process, network, file, registry) | [`configs/sysmon/sysmon-config.xml`](../configs/sysmon/sysmon-config.xml) |
| **Splunk Universal Forwarder** | Windows victim VMs | Ships Windows events to Splunk indexer | [`configs/splunk/inputs.conf`](../configs/splunk/inputs.conf) |
| **Wazuh Agent** | Windows/Linux victim VMs | Agent-based HIDS and log forwarding | [`configs/wazuh/local_rules.xml`](../configs/wazuh/local_rules.xml) |
| **Zeek** | Security Onion | Network protocol analysis — DNS, HTTP, SSL, conn logs | Built into Security Onion EVAL |
| **Suricata** | Security Onion | Signature-based network IDS/IPS | Built into Security Onion EVAL |

---

## SIEM & Analysis

| Tool | Purpose | Access |
|------|---------|--------|
| **Splunk Enterprise (Free)** | Log search, dashboards, detection queries | `http://<splunk-host>:8000` |
| **Wazuh Manager + Dashboard** | HIDS alerting, compliance, threat intel | `https://<wazuh-host>` |
| **Security Onion / Kibana** | Network event dashboards, alert management | `https://<securityonion-host>` |
| **Elasticsearch** | Log storage backend for Security Onion | Internal to SO |

---

## Victim Operating Systems

| OS | Role | Key Software |
|----|------|-------------|
| **Windows 10** | Primary victim | Sysmon, Wazuh agent, Splunk UF |
| **Windows 11** | Secondary victim | Sysmon, Wazuh agent |
| **Windows Server 2022** | Active Directory target | AD DS, DNS, Sysmon |
| **Kioptrix** | Vulnerable Linux target | CTF-style vulnerable web app |
| **Ubuntu Server** | SIEM host / utility VM | Splunk or Wazuh manager |

---

## Useful References

| Resource | URL |
|----------|-----|
| Sysmon — SwiftOnSecurity config | https://github.com/SwiftOnSecurity/sysmon-config |
| Atomic Red Team | https://github.com/redcanaryco/atomic-red-team |
| MITRE ATT&CK | https://attack.mitre.org/ |
| Security Onion Docs | https://docs.securityonion.net/ |
| Splunk Search Reference | https://docs.splunk.com/Documentation/Splunk/latest/SearchReference |
| Wazuh Ruleset Docs | https://documentation.wazuh.com/current/user-manual/ruleset/ |
| Proxmox Docs | https://pve.proxmox.com/wiki/Main_Page |
| pfSense Docs | https://docs.netgate.com/pfsense/en/latest/ |
| Tailscale Docs | https://tailscale.com/kb/ |
| Impacket | https://github.com/fortra/impacket |
