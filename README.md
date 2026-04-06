# SOC Log Analysis & Detection Lab

> A hands-on home lab simulating a real Security Operations Center (SOC) workflow — from attack simulation to log analysis, detection engineering, and incident reporting.

![Lab Architecture](architecture_diagram/Detection_lab.drawio\(5\).svg)

---

## 🎯 Lab Objectives

This lab demonstrates end-to-end SOC analyst skills:

| Skill | Tooling |
|-------|---------|
| Attack simulation | Kali Linux, Metasploit, Mimikatz |
| Traffic capture & monitoring | Security Onion, Zeek, Suricata |
| Log collection | Sysmon, Windows Event Logs |
| SIEM analysis | Splunk / Wazuh |
| Detection engineering | Custom Splunk SPL, Suricata rules, Sysmon XML |
| Incident investigation | Structured case walkthroughs |
| Professional reporting | Incident report templates & sample reports |

---

## ��️ Lab Architecture

The lab runs entirely on a **Proxmox** hypervisor and is segmented into three networks:

```
Internet (WAN)
      │
  [pfSense Firewall]
   /            \
[Attacker Net]  [Victim Net]
 Kali Linux      Windows 10/11
 Parrot OS       Windows Server 2022
                 Kioptrix (Linux)
      │                │
      └─── [Security Onion] ───┘
            Zeek · Suricata · Kibana
```

See [`architecture_diagram/`](architecture_diagram/) for the full SVG diagram and a detailed component breakdown.

---

## 📁 Repository Structure

```
SOC-Log-Analysis-Detection-Lab/
├── architecture_diagram/        # Lab topology diagram and explanation
├── lab-setup/                   # Step-by-step setup guides for every VM
│   ├── proxmox/                 # Hypervisor configuration
│   ├── pfsense/                 # Firewall setup
│   ├── security-onion-os/       # IDS/NSM/SIEM stack
│   ├── Ubuntu-main/             # Ubuntu target setup
│   ├── kali-linux-main/         # Attacker machine setup
│   └── remote-access/           # Tailscale / remote management
├── attack-simulations/          # Documented attack techniques with steps
│   ├── 01-process-injection/
│   ├── 02-credential-harvesting/
│   ├── 03-persistence/
│   ├── 04-lateral-movement/
│   └── 05-data-exfiltration/
├── detections/                  # Detection rules and queries
│   ├── splunk-queries/
│   ├── suricata-rules/
│   ├── zeek-scripts/
│   └── sysmon-rules/
├── investigation-cases/         # Structured incident scenarios to solve
│   ├── case-01-suspicious-process/
│   ├── case-02-unusual-network-activity/
│   └── case-03-credential-access/
├── reports/                     # Incident report templates and examples
├── tool-used/                   # Tools inventory with documentation links
└── screenshots/                 # Lab evidence organized by section
```

---

## 🚀 Quick Start

### Prerequisites

- Physical or virtual machine with at least **32 GB RAM** and **500 GB storage**
- Proxmox VE 8.x installed
- ISOs for: Kali Linux, Security Onion, pfSense, Windows 10/11, Windows Server 2022

### Setup Order

1. **[Proxmox](lab-setup/proxmox/README.md)** — Install the hypervisor and create virtual bridges
2. **[pfSense](lab-setup/pfsense/README.md)** — Configure firewall and network segmentation
3. **[Security Onion](lab-setup/security-onion-os/README.md)** — Deploy IDS/NSM monitoring
4. **[Kali Linux](lab-setup/kali-linux-main/README.md)** — Set up the attacker machine
5. **[Ubuntu targets](lab-setup/Ubuntu-main/README.md)** — Deploy victim machines
6. **[Remote Access](lab-setup/remote-access/README.md)** — Configure Tailscale for remote management

---

## ⚔️ Attack Simulations

Each simulation includes: description, prerequisites, step-by-step commands, expected network traffic, and log artifacts.

| # | Technique | MITRE ATT&CK |
|---|-----------|--------------|
| 01 | [Process Injection](attack-simulations/01-process-injection/README.md) | T1055 |
| 02 | [Credential Harvesting](attack-simulations/02-credential-harvesting/README.md) | T1003 |
| 03 | [Persistence](attack-simulations/03-persistence/README.md) | T1547 |
| 04 | [Lateral Movement](attack-simulations/04-lateral-movement/README.md) | T1021 |
| 05 | [Data Exfiltration](attack-simulations/05-data-exfiltration/README.md) | T1048 |

---

## 🔍 Detections

Custom rules and queries to detect the attacks above:

| Tool | Coverage |
|------|----------|
| [Splunk SPL Queries](detections/splunk-queries/README.md) | Windows event logs, Sysmon |
| [Suricata Rules](detections/suricata-rules/README.md) | Network-based IDS |
| [Zeek Scripts](detections/zeek-scripts/README.md) | NSM / traffic analysis |
| [Sysmon Rules](detections/sysmon-rules/README.md) | Host-based endpoint telemetry |

---

## 🕵️ Investigation Cases

Hands-on incident scenarios with log data, guiding questions, and answer keys:

| Case | Scenario |
|------|---------|
| [Case 01](investigation-cases/case-01-suspicious-process/README.md) | Suspicious process execution on workstation |
| [Case 02](investigation-cases/case-02-unusual-network-activity/README.md) | Unusual outbound network connections |
| [Case 03](investigation-cases/case-03-credential-access/README.md) | Credential access and lateral movement |

---

## 📊 Reports

- [Incident Report Template](reports/incident-report-template.md)
- [Sample Analysis Report](reports/sample-analysis-report.md)
- [Detection Summary](reports/detection-summary.md)

---

## 🛠️ Tools Used

See [`tool-used/`](tool-used/README.md) for the full inventory with versions, documentation links, and configuration notes.

---

## 📸 Screenshots

Lab screenshots organized by section in [`screenshots/`](screenshots/README.md).

---

## 👤 Author

**Moha Zackry**  
SOC Analyst | Home Lab Enthusiast

---

## 📄 License

This project is for educational purposes. All attack simulations are performed in an isolated, self-contained lab environment.
