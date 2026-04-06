# Architecture Explained — SOC Log Analysis & Detection Lab

This document provides ASCII diagrams, annotated data flow paths, and example scenario walkthroughs to help you understand exactly how the lab components interact.

For component descriptions and setup instructions, see [ReadMe.md](ReadMe.md).

---

## ASCII Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PROXMOX VE HOST                             │
│                     (Bare-metal Hypervisor)                         │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    NETWORK BRIDGES                           │   │
│  │                                                              │   │
│  │   vmbr0 (WAN)          vmbr1 (Attacker)    vmbr2 (Victim)   │   │
│  │   ─────────────        ────────────────    ───────────────   │   │
│  │   Physical NIC         Internal only       Internal only     │   │
│  └────────┬───────────────────────┬──────────────────┬──────────┘   │
│           │                       │                  │              │
│    ┌──────┴──────┐        ┌───────┴──────┐   ┌──────┴────────┐     │
│    │   pfSense   │        │  Kali Linux  │   │  Windows 10   │     │
│    │  Firewall   │        │  192.168.1.10│   │  192.168.2.20 │     │
│    │             ├─vmbr1──┤              │   │               │     │
│    │  vmbr0(WAN) │        │  Parrot OS   │   │  Windows 11   │     │
│    │  vmbr1(LAN1)│        │  192.168.1.11│   │  192.168.2.21 │     │
│    │  vmbr2(LAN2)├─vmbr2──┤──────────────┘   │               │     │
│    └──────┬──────┘        │                  │  Win Srv 2022 │     │
│           │               │  Security Onion  │  192.168.2.22 │     │
│           │               │  ─────────────── │               │     │
│      ┌────┴────┐          │  Mgmt: vmbr0     │  Kioptrix     │     │
│      │Internet │          │  Mon1: vmbr1 ◄──►│  192.168.2.30 │     │
│      │  (WAN)  │          │  Mon2: vmbr2 ◄──►└───────────────┘     │
│      └─────────┘          └──────────────────────────────────────── │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

Legend:
  ◄──► = Monitoring (promiscuous / span port — no routing)
  ───  = Routed network connection
  vmbr = Virtual Machine Bridge (Linux bridge on Proxmox)
```

---

## Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    COMPONENT INTERACTIONS                        │
│                                                                  │
│  ATTACKER SIDE                    DEFENDER SIDE                  │
│  ─────────────                    ────────────                   │
│                                                                  │
│  ┌─────────────┐  attack traffic  ┌──────────────┐              │
│  │  Kali Linux │ ───────────────► │ Victim (Win) │              │
│  │  Parrot OS  │                  │ Sysmon logs  │              │
│  └─────────────┘                  └──────┬───────┘              │
│         │                                │                       │
│         │ traffic                        │ Wazuh agent           │
│         ▼                                ▼                       │
│  ┌─────────────┐               ┌──────────────────┐             │
│  │   pfSense   │               │  Security Onion  │             │
│  │  Firewall   │               │                  │             │
│  │  (routing)  │               │  ┌────────────┐  │             │
│  └─────────────┘               │  │  Wazuh     │◄─┘ host logs  │
│         │                      │  │  (HIDS)    │  │             │
│         │ all traffic          │  └────────────┘  │             │
│         ▼                      │  ┌────────────┐  │             │
│  ┌─────────────┐               │  │  Suricata  │  │             │
│  │  vmbr1 span │──────────────►│  │  (IDS)     │  │             │
│  │  vmbr2 span │               │  └────────────┘  │             │
│  └─────────────┘               │  ┌────────────┐  │             │
│                                │  │  Zeek      │  │             │
│                                │  │  (NSM)     │  │             │
│                                │  └────────────┘  │             │
│                                │  ┌────────────┐  │             │
│                                │  │  Kibana    │◄─┘ dashboards  │
│                                │  │  UI        │  │             │
│                                │  └─────┬──────┘  │             │
│                                └────────┼─────────┘             │
│                                         │                        │
│                                         ▼                        │
│                                  ┌─────────────┐                │
│                                  │   Analyst   │                │
│                                  │  (You / SOC)│                │
│                                  └─────────────┘                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Network Segmentation Strategy

### Why Three Separate Networks?

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Attacker   │    │   pfSense    │    │    Victim    │
│   Network    │◄──►│   Firewall   │◄──►│   Network    │
│   (vmbr1)    │    │              │    │   (vmbr2)    │
└──────────────┘    └──────────────┘    └──────────────┘
       ▲                                       ▲
       │                                       │
       └─────────┐               ┌─────────────┘
                 │               │
          ┌──────┴───────────────┴──────┐
          │       Security Onion        │
          │   (passive monitoring on    │
          │    both segments — no       │
          │    routing, just capture)   │
          └─────────────────────────────┘
```

**Security benefits of this design:**

| Isolation | Benefit |
|-----------|---------|
| Attacker ↔ Victim separated by pfSense | Attacks are controlled — you decide what traffic to allow |
| Security Onion is passive | The monitoring VM cannot be attacked through its monitoring interfaces |
| Victim network has no direct internet | Victims cannot exfiltrate data unless pfSense rules permit it |
| Separate bridges (not VLANs) | Stronger isolation — bridge-level separation, not just tagging |

**Monitoring advantages:**

- Security Onion sees **all traffic** on both segments before and after pfSense filtering
- Enables detection of **lateral movement** (attacker-to-victim on vmbr2)
- Enables detection of **C2 communication** (attacker-to-internet on vmbr1)
- Enables detection of **data exfiltration** (victim-to-internet via vmbr2→pfSense→vmbr0)

---

## Detailed Data Flow

### Attack Flow

```
Step 1: Recon
──────────────
Kali Linux → nmap scan → pfSense (vmbr1→vmbr2) → Victim VM
                                    ▲
                              Suricata fires
                              "ET SCAN Nmap"
                              alert in SO

Step 2: Exploitation
────────────────────
Kali Linux → exploit payload → pfSense → Victim (port open)
                                              ▲
                                         Sysmon logs
                                         process creation
                                         event (ID 1)

Step 3: Post-Exploitation
──────────────────────────
Victim VM (compromised) ← C2 beacon → Attacker C2 (internet)
                               ▲
                         Zeek conn log
                         shows periodic
                         outbound connection
                         Suricata fires C2
                         signature (if rule exists)
```

### Logging Flow

```
Victim Windows VM
       │
       ├── Sysmon → Windows Event Log (Application and Services Logs\Microsoft\Windows\Sysmon)
       │                    │
       │                    └── Wazuh Agent → (port 1514/UDP) → Security Onion Wazuh Manager
       │                                                                  │
       │                                                          Indexed in Elasticsearch
       │                                                          Visible in Kibana dashboards
       │
       └── Windows Security Events → Wazuh Agent → Security Onion
```

### Detection Flow

```
Network Traffic (on vmbr1 or vmbr2)
       │
       ├── Suricata
       │     ├── Matches signature → Alert created
       │     └── Alert stored in Security Onion → Visible in Alerts dashboard
       │
       └── Zeek
             ├── Parses protocols (HTTP, DNS, SSL, SMB, etc.)
             ├── Writes structured logs (conn.log, dns.log, http.log, etc.)
             └── Logs indexed in Elasticsearch → Searchable in Hunt dashboard
```

### Investigation Flow

```
Alert fires in Security Onion
       │
       ▼
Analyst opens Alerts dashboard
       │
       ├── Identifies source IP, destination IP, port, timestamp
       │
       ▼
Analyst pivots to Hunt (Zeek logs)
       │
       ├── Searches conn.log for related connections
       ├── Searches dns.log for suspicious lookups
       └── Searches http.log for payloads / file transfers
       │
       ▼
Analyst opens PCAP (Kibana → PCAP download)
       │
       └── Full packet inspection to confirm attack
       │
       ▼
Analyst checks Wazuh host logs
       │
       └── Sysmon events on victim VM — process tree, network connections, files
       │
       ▼
Analyst reconstructs timeline
       │
       └── Documents: when, what, how, impact
       │
       ▼
Analyst writes incident report → reports/
```

---

## Traffic Monitoring Points

```
┌──────────────────────────────────────────────────────────┐
│                   MONITORING COVERAGE MAP                 │
│                                                          │
│  vmbr1 (Attacker Network)        vmbr2 (Victim Network)  │
│  ────────────────────────        ────────────────────    │
│                                                          │
│  What Zeek captures:             What Zeek captures:     │
│  • All TCP/UDP connections        • All TCP/UDP conns     │
│  • DNS queries from Kali          • SMB, RDP, WinRM      │
│  • HTTP/HTTPS traffic             • C2 beacons (outbound) │
│  • File transfers                 • Lateral movement      │
│                                                          │
│  What Suricata detects:          What Suricata detects:  │
│  • Nmap/masscan signatures        • Exploit patterns      │
│  • Metasploit payloads            • Mimikatz signatures   │
│  • C2 framework traffic           • Ransomware patterns   │
│  • Tool-specific patterns         • Data exfiltration     │
│                                                          │
│  What Wazuh collects:                                    │
│  • Sysmon events from victim VMs (all Windows machines)  │
│    - Process creation (Event ID 1)                       │
│    - Network connections (Event ID 3)                    │
│    - File creation (Event ID 11)                         │
│    - Registry changes (Event ID 12/13)                   │
│    - Process injection (Event ID 8)                      │
│  • Windows Security Events (logon, privilege use, etc.)  │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Example Scenario Flows

### Scenario 1 — Network-Based Attack (Port Scan → Exploitation)

```
[Kali Linux]
    │
    ├─ 1. nmap -sV 192.168.2.0/24
    │         └─► Suricata: "ET SCAN Nmap Scripting Engine"
    │             Zeek: conn.log shows many short connections to port 22, 80, 443, 445...
    │
    ├─ 2. msfconsole → exploit/windows/smb/ms17_010_eternalblue
    │         └─► pfSense: allows SMB (port 445) to victim
    │             Suricata: "ET EXPLOIT EternalBlue"
    │             Zeek: conn.log shows SMB session to Win7 victim
    │
    └─ 3. Meterpreter session opened on victim
              └─► Sysmon Event ID 1: lsass.exe spawned by exploit
                  Sysmon Event ID 3: outbound connection from victim to Kali:4444
                  Wazuh alert: "Possible reverse shell connection"
```

### Scenario 2 — Host-Based Attack (Credential Harvesting)

```
[Attacker — already has shell on victim]
    │
    ├─ 1. Run Mimikatz: sekurlsa::logonpasswords
    │         └─► Sysmon Event ID 10: mimikatz.exe accessing lsass.exe (process injection)
    │             Wazuh alert: "Credential access — LSASS memory read"
    │
    ├─ 2. Extract NTLM hashes
    │         └─► Sysmon Event ID 1: mimikatz process creation with suspicious args
    │             Windows Event ID 4688: process creation
    │
    └─ 3. Pass-the-Hash using CrackMapExec
              └─► Zeek: SMB authentication to other victim VMs
                  Suricata: "ET LATERAL_MOVEMENT Pass-the-Hash attempt"
                  Wazuh alert: "Lateral movement — multiple SMB auth failures"
```

### Scenario 3 — Lateral Movement Attack

```
[Attacker — foothold on Windows 10]
    │
    ├─ 1. Discover Windows Server via net view / nmap
    │         └─► Sysmon Event ID 3: network connection to server
    │             Zeek: SMB and LDAP queries on vmbr2
    │
    ├─ 2. PsExec to Windows Server using stolen credentials
    │         └─► Sysmon Event ID 1: psexesvc.exe created on server
    │             Windows Event ID 7045: new service installed
    │             Wazuh alert: "PsExec service installation detected"
    │
    └─ 3. Dump SAM database on server
              └─► Sysmon Event ID 11: file creation in TEMP (SAM copy)
                  Wazuh alert: "Possible SAM database access"
                  Analyst: pivot to Zeek SMB logs → see file transfer
```

### Scenario 4 — Credential Access (Phishing Simulation)

```
[Attacker — sets up malicious payload]
    │
    ├─ 1. Create macro-enabled Word document with msfvenom payload
    │
    ├─ 2. Victim "opens" document (manual execution in lab)
    │         └─► Sysmon Event ID 1: winword.exe → cmd.exe (suspicious parent-child)
    │             Wazuh alert: "Office application spawned shell"
    │             Suricata: Metasploit stager detected on network
    │
    └─ 3. Reverse shell established
              └─► Zeek: conn.log — outbound connection from victim to attacker
                  Sysmon Event ID 3: powershell.exe network connection
                  Wazuh alert: "PowerShell outbound connection"
```

---

## Key Sysmon Event IDs Reference

| Event ID | Description | SOC Use Case |
|----------|-------------|--------------|
| 1 | Process Creation | Detect malicious processes, suspicious parent-child |
| 3 | Network Connection | Detect C2, lateral movement, exfiltration |
| 7 | Image Loaded | Detect DLL injection, malicious DLL loading |
| 8 | CreateRemoteThread | Detect process injection techniques |
| 10 | ProcessAccess | Detect LSASS access (credential dumping) |
| 11 | FileCreate | Detect file drops, payload staging |
| 12/13 | Registry Set/Delete | Detect persistence via registry run keys |
| 22 | DNS Query | Detect C2 domain lookups, DNS tunnelling |

---

*Back to architecture overview: [ReadMe.md](ReadMe.md)*  
*Back to main lab: [README.md](../README.md)*
