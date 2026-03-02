
# Home Lab Architecture for Security Detection

This repository showcases the architecture of my home lab, designed for security testing and detection. It includes attacker and victim networks, monitoring with Security Onion, and firewall protection with pfSense.

## Architecture Diagram

The following diagram illustrates the architecture of my security lab setup. It includes two networks: an **Attacker Network** (for simulating attacks) and a **Victim Network** (with different operating systems for testing). The traffic between these networks is monitored by **Security Onion** for detection and analysis.

![Lab Architecture Diagram](/SOC-Log-Analysis-Detection-Lab/architecture_diagram/Lab_diagram.drawio.png)

## Components of the Lab

1. **Proxmox VE (Virtualization Host)**
   - The host running all the virtual machines (VMs) in this setup.
   - It manages the attacker, victim, and monitoring VMs through **Linux Bridges (vmbr0, vmbr1, vmbr2)**.

2. **pfSense Firewall**
   - A **pfSense firewall** sits between the attacker and victim networks.
   - It controls traffic flow and provides protection to the victim network.
   - It also enables **NAT** for outbound internet access.

3. **Security Onion**
   - **Security Onion** is used for monitoring network traffic.
   - It runs IDS/NSM tools like **Suricata** and **Zeek** to detect any malicious activities.
   - It listens on the attacker (vmbr1) and victim (vmbr2) networks to monitor east-west and north-south traffic.

4. **Attacker Network (vmbr1)**
   - The attacker network contains **Kali Linux** and **Parrot OS**, which are used to simulate various attack techniques.
   - These VMs can launch attacks against the victim network and external systems.

5. **Victim Network (vmbr2)**
   - The victim network includes multiple operating systems to act as targets:
     - **Windows 10**
     - **Windows 11**
     - **Windows Server 2022**
     - **Kioptrix** (a vulnerable Linux machine for CTF-style exercises)

6. **Internet (WAN)**
   - **Outbound internet access** is provided through pfSense, allowing the attacker VMs to connect to external targets for reconnaissance, C2 communication, or downloading payloads.

## How to Set Up the Lab

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/MohamedElbalam/home-lab-architecture.git
