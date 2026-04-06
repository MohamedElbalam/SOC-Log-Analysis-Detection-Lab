# Suricata IDS Rules

This document contains custom Suricata rules designed to detect the network-based indicators of the attack techniques simulated in this lab.

## Rule File Location

Place these rules in a file such as `/etc/suricata/rules/lab-custom.rules` on the Security Onion sensor, then add it to `/etc/suricata/suricata.yaml` under the `rule-files` section.

## Rule Format Reference

```
action proto src_ip src_port -> dst_ip dst_port (msg:"..."; options; sid:XXXXXXX; rev:1;)
```

---

## Lateral Movement Rules

### SUR-001 — PSExec Remote Execution Detected

```
alert tcp $HOME_NET any -> $HOME_NET 445 (
    msg:"LAB - PSExec Remote Execution Attempt";
    flow:established,to_server;
    content:"PSEXESVC";
    nocase;
    classtype:trojan-activity;
    sid:9000001;
    rev:1;
)
```

**What it detects:** PSExec service binary name in SMB traffic, commonly used for remote execution during lateral movement.

---

### SUR-002 — SMB Admin Share Access

```
alert tcp $HOME_NET any -> $HOME_NET 445 (
    msg:"LAB - SMB Admin Share Access ADMIN$";
    flow:established,to_server;
    content:"|5C 00 41 00 44 00 4D 00 49 00 4E 00 24|";
    classtype:policy-violation;
    sid:9000002;
    rev:1;
)
```

**What it detects:** Access to the ADMIN$ share over SMB (Unicode-encoded path).

---

### SUR-003 — Possible Pass-the-Hash — NTLM with No Domain

```
alert tcp $HOME_NET any -> $HOME_NET 445 (
    msg:"LAB - NTLM Authentication to Admin Share";
    flow:established,to_server;
    content:"NTLMSSP";
    content:"|00 00|";
    within:3;
    classtype:attempted-admin;
    threshold:type both, track by_src, count 5, seconds 60;
    sid:9000003;
    rev:1;
)
```

**What it detects:** Multiple NTLM authentication attempts to SMB within 60 seconds — potential PTH or spray.

---

## Data Exfiltration Rules

### SUR-004 — Large HTTP POST Outbound

```
alert http $HOME_NET any -> $EXTERNAL_NET any (
    msg:"LAB - Large Outbound HTTP POST Possible Data Exfil";
    flow:established,to_server;
    http.method; content:"POST";
    dsize:>1000000;
    classtype:policy-violation;
    sid:9000004;
    rev:1;
)
```

**What it detects:** HTTP POST requests with bodies larger than 1 MB to external destinations.

---

### SUR-005 — DNS Query with Unusually Long Subdomain (DNS Exfil)

```
alert dns any any -> any 53 (
    msg:"LAB - Possible DNS Tunneling Long Subdomain";
    dns.query;
    pcre:"/^[a-zA-Z0-9+\/]{40,}\./";
    threshold:type both, track by_src, count 3, seconds 30;
    classtype:policy-violation;
    sid:9000005;
    rev:1;
)
```

**What it detects:** DNS queries where the subdomain portion is 40+ characters (common in DNS tunneling/exfiltration tools like dnscat2 or iodine).

---

### SUR-006 — Outbound Connection on Non-Standard Port

```
alert tcp $HOME_NET any -> $EXTERNAL_NET !80 !443 !53 !25 !22 (
    msg:"LAB - Outbound Connection on Non-Standard Port";
    flow:established,to_server;
    threshold:type both, track by_src, count 3, seconds 60;
    classtype:policy-violation;
    sid:9000006;
    rev:1;
)
```

**What it detects:** Internal hosts making outbound connections on ports other than common service ports. Tune the exclusion list for your environment.

---

## Command and Control (C2) Rules

### SUR-007 — Meterpreter-style Reverse Shell Beacon

```
alert tcp $HOME_NET any -> any 4444 (
    msg:"LAB - Possible Meterpreter Reverse Shell to Port 4444";
    flow:established,to_server;
    classtype:trojan-activity;
    sid:9000007;
    rev:1;
)
```

**What it detects:** Outbound connections to port 4444 — the default Metasploit Meterpreter port.

---

### SUR-008 — Suspicious PowerShell Download

```
alert http $HOME_NET any -> $EXTERNAL_NET any (
    msg:"LAB - PowerShell Downloading File via HTTP";
    flow:established,to_server;
    http.user_agent;
    content:"PowerShell";
    nocase;
    classtype:trojan-activity;
    sid:9000008;
    rev:1;
)
```

**What it detects:** HTTP requests using a PowerShell user-agent string — often used in staged payload delivery.

---

## Loading Rules in Suricata

```bash
# Test rule syntax
suricata -T -c /etc/suricata/suricata.yaml -v

# Reload rules without restart
suricatasc -c reload-rules

# Verify rule is loaded
grep "SID:9000001" /var/log/suricata/stats.log
```

## Viewing Alerts in Security Onion

1. Open Kibana → Discover
2. Filter: `event.module: suricata`
3. Filter: `event.dataset: suricata.eve`
4. Look for `alert.signature_id` matching the SIDs above

Or from the command line:

```bash
jq 'select(.event_type=="alert") | {time: .timestamp, sig: .alert.signature, src: .src_ip, dst: .dest_ip}' /nsm/suricata/eve.json
```
