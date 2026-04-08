# Lab Setup Implementation Guide

## Phase 1: Infrastructure (Week 1-2)

### Step 1: Proxmox Installation
- [ ] Task 1.1: Download Proxmox ISO
    - TODO: Get ISO from official source
    - TODO: Verify checksum
    - TODO: Create bootable USB
    - TODO: Document hardware specs

- [ ] Task 1.2: Install Proxmox
    - TODO: Boot from USB
    - TODO: Follow installation wizard
    - TODO: Set root password
    - TODO: Configure network (IP: 192.168.1.10)
    - TODO: Verify web interface access (https://192.168.1.10:8006)
    - TODO: Take screenshot of successful login

- [ ] Task 1.3: Create Network Bridges
    - TODO: Create vmbr0 (management)
    - TODO: Create vmbr1 (attacker)
    - TODO: Create vmbr2 (victim)
    - TODO: Assign physical NICs
    - TODO: Test connectivity between bridges
    - TODO: Document network configuration

**Questions to Answer:**
- What is your Proxmox version?
- How much free RAM do you have after host OS?
- Are both bridges getting IP addresses correctly?

**Expected Outcome:**
- Proxmox accessible via web UI
- 3 working network bridges
- Network communication tested

---

### Step 2: pfSense Firewall Deployment
- [ ] Task 2.1: Deploy pfSense VM
    - TODO: Create VM (4 vCPU, 2GB RAM, 20GB disk)
    - TODO: Attach to vmbr0, vmbr1
    - TODO: Install pfSense OS
    - TODO: Configure WAN (vmbr0) - Get IP from DHCP or set static
    - TODO: Configure LAN (vmbr1) - Set 10.10.10.1/24
    - TODO: Test web interface

- [ ] Task 2.2: Configure Basic Firewall Rules
    - TODO: Block vmbr2 to vmbr1 traffic
    - TODO: Allow vmbr1 to vmbr2 traffic
    - TODO: Allow vmbr0 (management) to all networks
    - TODO: Enable NAT for WAN
    - TODO: Test each rule
    - TODO: Document rule set

- [ ] Task 2.3: Enable Logging
    - TODO: Enable firewall logging
    - TODO: Set log retention
    - TODO: Test log generation

**Questions to Answer:**
- Can you ping from vmbr1 to vmbr2?
- Can you access pfSense web interface?
- Are firewall logs being generated?

**Expected Outcome:**
- pfSense operational
- 3 networks connected
- Firewall rules enforced

---

## Phase 2: SIEM Setup (Week 2-3)

### Step 3: Security Onion Deployment
- [ ] Task 3.1: Deploy Security Onion VM
    - TODO: Create VM (8 vCPU, 32GB RAM, 200GB disk)
    - TODO: Attach to vmbr1 AND vmbr2 (dual monitoring)
    - TODO: Install Security Onion
    - TODO: Configure IP addresses (10.10.10.100 and 10.20.20.100)
    - TODO: Access web interface
    - TODO: Document credentials

- [ ] Task 3.2: Configure Network Sensors
    - TODO: Configure Suricata on vmbr1
    - TODO: Configure Suricata on vmbr2
    - TODO: Configure Zeek on vmbr1
    - TODO: Configure Zeek on vmbr2
    - TODO: Verify sensors are capturing traffic
    - TODO: Check for alerts in Kibana

- [ ] Task 3.3: Set Up Log Aggregation
    - TODO: Configure Wazuh manager
    - TODO: Set up Elasticsearch
    - TODO: Test index creation
    - TODO: Verify data ingestion

**Questions to Answer:**
- Can Suricata see traffic from both networks?
- Are Zeek logs being indexed?
- Can you access Kibana dashboard?

**Expected Outcome:**
- Security Onion operational
- Sensors capturing on both networks
- Logs flowing to Elasticsearch

---

## Phase 3: Victim Machines (Week 3-4)

### Step 4: Windows Victim Setup
- [ ] Task 4.1: Deploy Windows 10
    - TODO: Create VM (4 vCPU, 8GB RAM, 100GB disk)
    - TODO: Attach to vmbr2
    - TODO: Install Windows 10
    - TODO: Set IP: 10.20.20.10
    - TODO: Join domain (optional)
    - TODO: Enable RDP
    - TODO: Take screenshot

- [ ] Task 4.2: Install Sysmon
    - TODO: Download Sysmon
    - TODO: Download Sysmon config
    - TODO: Install Sysmon with config
    - TODO: Verify Event Log population
    - TODO: Test process creation logging
    - TODO: Check Event IDs (1, 3, 7, 8, 11, 22)

- [ ] Task 4.3: Install Logging Agent
    - TODO: Download WinLogBeat
    - TODO: Configure for Security Onion
    - TODO: Install service
    - TODO: Verify logs reaching SIEM
    - TODO: Check index in Elasticsearch

- [ ] Task 4.4: Harden Windows (Optional)
    - TODO: Disable unnecessary services
    - TODO: Enable Windows Defender
    - TODO: Configure firewall
    - TODO: Install EDR (optional)

**Questions to Answer:**
- Are Sysmon logs showing in Event Viewer?
- Can you see logs in Kibana from this host?
- Are process creation events being logged?

**Expected Outcome:**
- Windows 10 operational
- Sysmon installed and logging
- Logs flowing to SIEM

---

### Step 5: Attacker Machines (Week 4-5)

- [ ] Task 5.1: Deploy Kali Linux
    - TODO: Download Kali ISO
    - TODO: Create VM (4 vCPU, 8GB RAM, 50GB disk)
    - TODO: Attach to vmbr1
    - TODO: Install Kali
    - TODO: Set IP: 10.10.10.50
    - TODO: Install additional tools
    - TODO: Verify network connectivity

- [ ] Task 5.2: Test Connectivity
    - TODO: Ping victim machines
    - TODO: Scan victim network with nmap
    - TODO: Verify pfSense firewall allows attacks
    - TODO: Monitor in Security Onion

**Questions to Answer:**
- Can Kali reach victim network?
- Are scans being detected by SIEM?
- Can you see alerts in Kibana?

**Expected Outcome:**
- Kali Linux operational
- Can attack victim network
- Attacks detected by SIEM

---

## Phase 4: Testing and Validation (Week 5-6)

### Step 6: Verify Full Pipeline
- [ ] Task 6.1: Execute Simple Attack
    - TODO: Run nmap scan from Kali
    - TODO: Check Suricata detects it
    - TODO: Verify alert in Kibana
    - TODO: Screenshot the full pipeline

- [ ] Task 6.2: Host-Based Detection
    - TODO: Execute process on Windows 10
    - TODO: Check Sysmon logs
    - TODO: Verify in Kibana
    - TODO: Document expected behavior

- [ ] Task 6.3: Log Correlation
    - TODO: Find same event in multiple sources
    - TODO: Show network log + host log
    - TODO: Build timeline in Kibana
    - TODO: Document correlation

**Questions to Answer:**
- Is full attack-to-detection pipeline working?
- Can you see logs from all sources?
- Can you correlate events?

**Expected Outcome:**
- Complete lab functional
- Attack → Detection working
- Can analyze in SIEM

---

## Troubleshooting Section

### Common Issues
**Issue**: VMs cannot communicate
- TODO: Check bridge configuration
- TODO: Check firewall rules
- TODO: Verify IP addressing
- TODO: Check cable connections

**Issue**: Logs not reaching SIEM
- TODO: Verify WinLogBeat is running
- TODO: Check network connectivity
- TODO: Verify Wazuh is listening
- TODO: Check firewall rules

**Issue**: No alerts in Kibana
- TODO: Verify sensors are running
- TODO: Check rule configuration
- TODO: Test with known attack
- TODO: Check Elasticsearch indices

---

## Documentation Checklist

Before moving to implementation phase, document:
- [ ] Hardware specifications
- [ ] Network addressing scheme
- [ ] VM specifications
- [ ] Installed software versions
- [ ] Firewall rules
- [ ] Log forwarding configuration
- [ ] Sensor configuration
- [ ] Screenshots of each phase

---

## Success Criteria

You'll know Phase is complete when:
- ✓ Proxmox running with 3 bridges
- ✓ pfSense operational with rules
- ✓ Security Onion capturing traffic
- ✓ Windows with Sysmon logging
- ✓ Kali can attack and SIEM detects it
- ✓ All documentation complete
