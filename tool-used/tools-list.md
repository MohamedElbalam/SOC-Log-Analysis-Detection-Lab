# Tools List

Complete inventory of all tools used in the SOC home lab.

---

## Virtualization & Infrastructure

### Proxmox VE

| Field | Details |
|-------|---------|
| **Version** | 8.x |
| **Purpose** | Type-1 hypervisor hosting all lab VMs |
| **Documentation** | https://pve.proxmox.com/wiki/Main_Page |
| **Config notes** | Three Linux bridges (vmbr0/1/2); AES-NI enabled; QEMU guest agent on all VMs |

### pfSense

| Field | Details |
|-------|---------|
| **Version** | 2.7.x (FreeBSD-based) |
| **Purpose** | Firewall, NAT router, network segmentation |
| **Documentation** | https://docs.netgate.com/pfsense/en/latest/ |
| **Config notes** | WAN=vmbr0, LAN=vmbr2 (victim), OPT1=vmbr1 (attacker); `qemu-guest-agent` installed |

---

## Security Monitoring

### Security Onion

| Field | Details |
|-------|---------|
| **Version** | 2.4.x |
| **Purpose** | All-in-one NSM/SIEM platform; manages Suricata, Zeek, Elasticsearch, Kibana |
| **Documentation** | https://docs.securityonion.net/ |
| **Config notes** | EVAL mode; 200 GB disk, 12 GB RAM; MAC spoofing enabled on monitor NIC |

### Suricata

| Field | Details |
|-------|---------|
| **Version** | 7.x (via Security Onion) |
| **Purpose** | Network-based IDS; signature-based detection of malicious traffic |
| **Documentation** | https://suricata.io/documentation/ |
| **Config notes** | Custom rules in `/etc/suricata/rules/lab-custom.rules`; eve.json output enabled |

### Zeek (formerly Bro)

| Field | Details |
|-------|---------|
| **Version** | 6.x (via Security Onion) |
| **Purpose** | Network Security Monitor; generates structured logs (conn, dns, http, ssl, files) |
| **Documentation** | https://docs.zeek.org/ |
| **Config notes** | Custom scripts in `/opt/zeek/share/zeek/site/`; logs in `/nsm/zeek/logs/current/` |

### Elasticsearch + Kibana

| Field | Details |
|-------|---------|
| **Version** | 8.x (via Security Onion) |
| **Purpose** | Log storage and search (Elasticsearch); visualization and dashboards (Kibana) |
| **Documentation** | https://www.elastic.co/docs/ |
| **Config notes** | Integrated with Security Onion; access via `https://<SO-IP>` |

### Splunk Free

| Field | Details |
|-------|---------|
| **Version** | 9.x |
| **Purpose** | SIEM for Windows event log analysis and SPL-based detection |
| **Documentation** | https://docs.splunk.com/ |
| **Config notes** | Free tier (500 MB/day limit); receives logs from Winlogbeat; custom alert rules |

---

## Endpoint Monitoring

### Sysmon (System Monitor)

| Field | Details |
|-------|---------|
| **Version** | 15.x |
| **Purpose** | Windows endpoint telemetry: process creation, network connections, registry changes |
| **Documentation** | https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon |
| **Config notes** | Deployed with SwiftOnSecurity config: https://github.com/SwiftOnSecurity/sysmon-config |

### Winlogbeat

| Field | Details |
|-------|---------|
| **Version** | 8.x |
| **Purpose** | Forwards Windows Event Logs (Security, Sysmon) to Elasticsearch |
| **Documentation** | https://www.elastic.co/beats/winlogbeat |
| **Config notes** | Configured to ship `Microsoft-Windows-Sysmon/Operational` and `Security` channels |

### Wazuh Agent

| Field | Details |
|-------|---------|
| **Version** | 4.x |
| **Purpose** | Alternative to Winlogbeat; HIDS agent with active response capability |
| **Documentation** | https://documentation.wazuh.com/ |
| **Config notes** | Optional; used as alternative to Winlogbeat in some configurations |

---

## Attack Tools (Attacker Machine — Kali Linux)

### Metasploit Framework

| Field | Details |
|-------|---------|
| **Version** | 6.x |
| **Purpose** | Exploit framework; payload generation, delivery, and post-exploitation |
| **Documentation** | https://docs.metasploit.com/ |
| **Config notes** | Pre-installed on Kali; used for Meterpreter payloads and kiwi (Mimikatz) module |

### Mimikatz

| Field | Details |
|-------|---------|
| **Version** | 2.2.x |
| **Purpose** | Windows credential extraction: LSASS dump, pass-the-hash, Kerberos tickets |
| **Documentation** | https://github.com/gentilkiwi/mimikatz |
| **Config notes** | Windows binary uploaded to victim; also available via Metasploit kiwi module |

### Impacket

| Field | Details |
|-------|---------|
| **Version** | 0.11.x |
| **Purpose** | Python SMB/Kerberos toolkit: psexec.py, wmiexec.py, secretsdump.py |
| **Documentation** | https://github.com/fortra/impacket |
| **Config notes** | Installed via `pip install impacket` on Kali |

### CrackMapExec (NetExec)

| Field | Details |
|-------|---------|
| **Version** | 5.x / NetExec 1.x |
| **Purpose** | Network-wide credential validation and lateral movement automation |
| **Documentation** | https://github.com/Pennyw0rth/NetExec |
| **Config notes** | `crackmapexec smb` / `netexec smb` for SMB operations |

### Nmap

| Field | Details |
|-------|---------|
| **Version** | 7.94 |
| **Purpose** | Network discovery and service enumeration |
| **Documentation** | https://nmap.org/book/man.html |
| **Config notes** | Pre-installed on Kali; used for initial reconnaissance |

---

## Remote Access

### Tailscale

| Field | Details |
|-------|---------|
| **Version** | Latest |
| **Purpose** | Secure VPN mesh for remote access to the lab from anywhere |
| **Documentation** | https://tailscale.com/kb/ |
| **Config notes** | Installed on Proxmox host; subnet routing configured for 192.168.10.0/24 and 192.168.20.0/24 |

### Cloudflare Tunnel

| Field | Details |
|-------|---------|
| **Version** | cloudflared latest |
| **Purpose** | Web-accessible Proxmox UI without port forwarding |
| **Documentation** | https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/ |
| **Config notes** | Optional; proxies `https://localhost:8006` to a public Cloudflare domain |
