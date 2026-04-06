# SIEM Configuration Implementation Outline

## Part 1: Elasticsearch Setup

### Section 1.1: Index Configuration
TODO: Research
- What is an Elasticsearch index?
- How does log rotation work?
- What index naming convention should you use?

TODO: Configure
- [ ] Create daily indices
- [ ] Set index retention (30 days hot, 90 days warm)
- [ ] Configure index templates
- [ ] Test index creation
- [ ] Document your configuration

### Section 1.2: Data Ingestion
TODO: Research
- How does Wazuh send data to Elasticsearch?
- What is a Logstash pipeline?
- How to parse different log formats?

TODO: Configure
- [ ] Set up log parsers
- [ ] Configure field mapping
- [ ] Test data ingestion from each source
- [ ] Verify field extraction

---

## Part 2: Detection Rules

### Section 2.1: Suricata Rules
TODO: Research
- What is Suricata rule syntax?
- How do rule priorities work?
- Where do ET Open rules come from?

TODO: Implement
- [ ] Review default Suricata rules
- [ ] Understand rule structure
- [ ] Create 1 custom rule
- [ ] Test rule with known attack
- [ ] Document rule purpose and testing

**Example: Create a rule that detects Nmap scans**
TODO:
1. Research Nmap traffic patterns
2. Write Suricata rule for port scans
3. Test with: `nmap -sV 10.20.20.0/24`
4. Verify alert generates
5. Document findings

### Section 2.2: Wazuh Rules
TODO: Research
- How do Wazuh rules work?
- What is a rule ID and priority?
- How to write custom rules?

TODO: Implement
- [ ] Review Sysmon event mapping
- [ ] Understand Wazuh rule syntax
- [ ] Create 1 custom rule for Sysmon
- [ ] Test with process execution
- [ ] Document rule and testing

**Example: Create a rule that detects suspicious process execution**
TODO:
1. Understand Sysmon Event ID 1
2. Write Wazuh rule for cmd.exe execution
3. Execute cmd.exe on Windows victim
4. Check Wazuh alerts
5. Document findings

### Section 2.3: Correlation Rules
TODO: Research
- What is alert correlation?
- How to correlate multi-source events?
- How does Elasticsearch aggregation work?

TODO: Implement
- [ ] Find one attack that generates multiple alerts
- [ ] Document all alerts involved
- [ ] Create correlation query in Kibana
- [ ] Test correlation with real attack
- [ ] Document correlation logic

**Example: Correlate network scan + process execution**
TODO:
1. Execute nmap scan from Kali
2. Verify Suricata alert
3. Verify Zeek conn.log
4. Create Kibana query showing both
5. Document time correlation

---

## Part 3: Kibana Dashboards

### Section 3.1: Investigation Dashboard
TODO: Create Dashboard that shows:
- [ ] Last 24 hours of alerts
- [ ] Alert severity distribution
- [ ] Top source IPs
- [ ] Top destination ports
- [ ] Alert timeline
- [ ] Alert table with details

TODO: Document:
- Purpose of each visualization
- How to use for investigation
- Example use case

### Section 3.2: Host Monitoring Dashboard
TODO: Create Dashboard showing:
- [ ] Process execution timeline
- [ ] Network connections per host
- [ ] Failed login attempts
- [ ] File access activity
- [ ] Host alert count

TODO: Document:
- Metrics being tracked
- Interpretation guidance
- When to escalate

### Section 3.3: Network Monitoring Dashboard
TODO: Create Dashboard showing:
- [ ] Network traffic heatmap
- [ ] Top talkers (IPs)
- [ ] Protocol distribution
- [ ] Zeek DNS queries
- [ ] SSL/TLS certificates

TODO: Document:
- What normal looks like
- What suspicious looks like
- Investigation workflow

---

## Part 4: Alert Tuning

### Section 4.1: Identify False Positives
TODO:
1. Run lab for 1 week
2. Collect all alerts
3. Analyze each alert type
4. Identify which are false positives
5. Document findings

### Section 4.2: Tune Rules
TODO: For each false positive alert:
- [ ] Understand why it's triggering
- [ ] Research if rule needs adjustment
- [ ] Modify rule if needed
- [ ] Test modified rule
- [ ] Document change and rationale

### Section 4.3: Whitelist Configuration
TODO:
- [ ] Identify legitimate traffic to whitelist
- [ ] Add internal IPs to whitelist
- [ ] Add trusted external IPs
- [ ] Whitelist internal services
- [ ] Test whitelist effectiveness

---

## Part 5: Documentation Requirements

### Section 5.1: Rule Documentation
TODO: For each rule you create, document:
- [ ] Rule ID and name
- [ ] What it detects
- [ ] Why it matters
- [ ] Log sources used
- [ ] Alert example
- [ ] Testing procedure
- [ ] False positive rate
- [ ] Remediation steps

### Section 5.2: Dashboard Documentation
TODO: For each dashboard, document:
- [ ] Purpose
- [ ] Key metrics shown
- [ ] How to interpret
- [ ] Investigation workflow
- [ ] Example scenario

### Section 5.3: Runbook Documentation
TODO: Create runbook for:
- [ ] "High severity alert received" workflow
- [ ] Investigation checklist
- [ ] Escalation criteria
- [ ] Evidence collection
- [ ] Report generation
