# Attack Simulation Implementation Outline

## Attack 1: Network Reconnaissance

### Scenario Description
TODO: Write
- What is being attacked?
- How does attacker proceed?
- What's the objective?

### Prerequisites
TODO: Verify
- [ ] Kali Linux deployed
- [ ] Can reach victim network
- [ ] Security Onion monitoring
- [ ] Kibana accessible

### Attack Execution Steps
TODO: Execute
- [ ] Step 1: Start Wireshark on Kali
    - Capture command:
    - Expected output:
    - Verify:

- [ ] Step 2: Run network scan
    - Command: `nmap -sV 10.20.20.0/24`
    - Expected output:
    - Capture screenshot

- [ ] Step 3: Analyze traffic
    - What packets are sent?
    - How does victim respond?
    - Document findings

### Expected Detection
TODO: Verify Detection
- [ ] Suricata detects scan (Rule: ?)
- [ ] Zeek logs connections
- [ ] Alert appears in Kibana
- [ ] Screenshot evidence

### Log Analysis
TODO: Analyze Logs
- [ ] Find scan in Suricata logs
- [ ] Find in Zeek conn.log
- [ ] Find in pfSense logs
- [ ] Correlate timing

### Investigation Notes
TODO: Document
- What does analyst see?
- How would you respond?
- What evidence would you collect?
- What would you report?

### Success Criteria
- [ ] Attack executed
- [ ] Detected by SIEM
- [ ] Logged properly
- [ ] Can be investigated
- [ ] All documented

---

## Attack 2: Exploitation (Example: RDP Brute Force or Similar)

### Scenario Description
TODO: Write
- Attacker targets vulnerable service
- Goal: Gain access
- Methods used

### Prerequisites
TODO: Verify
- [ ] Vulnerable service running on victim
- [ ] Attacker tool available
- [ ] SIEM monitoring ready

### Attack Execution Steps
TODO: Execute
1. [ ] Identify service
    - Command:
    - Expected:

2. [ ] Attempt exploit
    - Tool:
    - Command:
    - Expected:

3. [ ] Monitor attack
    - On victim: Check logs
    - On SIEM: Check alerts
    - On Kali: Monitor traffic

### Expected Detection
TODO: Verify
- [ ] Suricata detects exploit (Rule ID: ?)
- [ ] Wazuh detects failed logins
- [ ] Host logs show suspicious activity
- [ ] Multiple alerts correlate

### Log Analysis
TODO: Analyze
- Which log source detected it first?
- How long until detection?
- False positive probability?
- Evidence for investigation?

### Investigation Scenario
TODO: Document
- Alert received at time X
- What queries would you run?
- What would timeline look like?
- How would you determine impact?
- What would report say?

---

## Attack 3: Post-Exploitation (Example: Process Injection or C2 Communication)

### Scenario Description
TODO: Write
- Attacker has foothold
- Goal: Maintain persistence or exfiltrate data
- Methods: Process injection, registry modification, etc.

### Prerequisites
TODO: Verify
- [ ] Initial access achieved
- [ ] Admin/elevated access
- [ ] Tools available on victim
- [ ] SIEM tuned for host events

### Attack Execution Steps
TODO: Execute
1. [ ] Execute payload
    - Method:
    - Command:
    - Expected behavior:

2. [ ] Monitor execution
    - Sysmon: Which events generated?
    - Event Logs: What entries created?
    - Network: Any communications?

3. [ ] Check for artifacts
    - Registry changes?
    - File created?
    - Process spawning children?

### Expected Detection
TODO: Verify
- [ ] Sysmon Event 1: Process created
- [ ] Sysmon Event 3: Network connection
- [ ] Sysmon Event 11: File created
- [ ] Wazuh rule triggered
- [ ] Alert in Kibana

### Timeline Construction
TODO: Build timeline
- T+0: Initial access
- T+30s: Process injection
- T+45s: Registry modification
- T+60s: Network communication
- Detection at T+?

### Investigation Walkthrough
TODO: Document investigation
1. Alert received for suspicious process
2. Pivot to Sysmon logs
3. Find child processes
4. Check network connections
5. Identify attacker infrastructure
6. Determine data accessed
7. Create incident report

---

## Attack 4: Data Exfiltration

### Scenario Description
TODO: Write
- Data theft objective
- Methods: SMB, FTP, DNS tunneling, etc.

### Attack Execution Steps
TODO: Execute
1. [ ] Identify sensitive data
2. [ ] Copy to attacker location (or staging)
3. [ ] Exfiltrate via network

### Detection Strategy
TODO: Verify Detection
- Large data transfer?
- Unusual destination?
- Off-hours activity?
- Unusual process behavior?

### Investigation Notes
TODO: Document
- How to identify exfiltration
- What evidence to collect
- How to quantify data loss
- Remediation steps

---

## Documentation Requirement

For each attack, create file: `attack-simulations/[ATTACK-NAME]/README.md`

TODO: Document
- [ ] Attack description
- [ ] Step-by-step execution
- [ ] Expected logs from each source
- [ ] Detection rules used
- [ ] False positive analysis
- [ ] Investigation guide
- [ ] Screenshots of execution
- [ ] Screenshots of detection
- [ ] Lessons learned

---

## Testing Checklist

Before finalizing attack simulation:
- [ ] Attack executes successfully
- [ ] All expected logs generated
- [ ] SIEM detects attack
- [ ] Analyst can investigate
- [ ] Timeline can be constructed
- [ ] Full documentation complete
- [ ] Can be repeated consistently
- [ ] No destructive side effects
