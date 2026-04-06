# Tools Used

This directory documents the tools deployed in the SOC Lab, their roles, and relevant configuration notes.

---

## Tool Inventory

| Tool | Category | Purpose |
|---|---|---|
| **Proxmox VE** | Virtualization | Hypervisor hosting all lab VMs |
| **pfSense** | Networking | Perimeter firewall, NAT, and VLAN routing |
| **Security Onion** | Monitoring / IDS | Network security monitoring (Suricata, Zeek, Elastic) |
| **Kali Linux** | Offensive | Attack simulation and penetration testing |
| **Parrot OS** | Offensive | Alternative attack platform |
| **Windows 10 / 11** | Victim | Endpoint target with Sysmon instrumentation |
| **Windows Server 2022** | Victim | Active Directory and server workload target |
| **Ubuntu 22.04** | Victim / Admin | Linux target and management workstation |
| **Sysmon** | Endpoint telemetry | Detailed Windows process, network, and file events |
| **Splunk (Free)** | SIEM | Log aggregation, search, and alerting |
| **Wazuh** | SIEM / HIDS | Open-source SIEM and host-based intrusion detection |
| **Atomic Red Team** | Adversary simulation | Lightweight attack technique library |
| **Tailscale** | Remote access | Zero-trust VPN with MFA for lab remote access |
| **Cloudflare Tunnel** | Remote access | Secure web-based access to Proxmox UI |

---

## Configuration Notes

### Sysmon
- Uses the [SwiftOnSecurity Sysmon config](https://github.com/SwiftOnSecurity/sysmon-config) as a baseline.
- Deployed on all Windows victim VMs.
- Logs forwarded to Splunk / Wazuh via Winlogbeat or the Wazuh agent.

### Security Onion
- Deployed in **Eval mode** to minimize hardware requirements.
- Monitors two network bridges: vmbr1 (attacker) and vmbr2 (victim).
- IDS alerts tuned to reduce noise from internal lab traffic.

### Splunk
- Running the free license tier (500 MB/day ingest limit).
- Custom dashboards for process creation, network connections, and authentication events.

---

## Status

| Tool | Deployed | Configured | Tested |
|---|---|---|---|
| Proxmox VE | ✅ | ✅ | ✅ |
| pfSense | ✅ | ✅ | ✅ |
| Security Onion | ✅ | ✅ | ⬜ |
| Kali Linux | ✅ | ✅ | ✅ |
| Windows VMs | ✅ | ⬜ | ⬜ |
| Sysmon | ⬜ | ⬜ | ⬜ |
| Splunk / Wazuh | ⬜ | ⬜ | ⬜ |
| Tailscale | ✅ | ✅ | ✅ |
