# Case 02 — Unusual Network Activity

**Difficulty:** Intermediate  
**MITRE ATT&CK:** T1048 (Exfiltration), T1071.001 (Web Protocols), T1071.004 (DNS)  
**Estimated Time:** 45–60 minutes

---

## Scenario

A Suricata alert fired at 3:47 PM for "Large Outbound HTTP POST Possible Data Exfil" from `192.168.20.31` (the Windows Server 2022 — `WS-SERVER`).

The server hosts internal HR documents and financial spreadsheets. The server administrator says no scheduled backup or sync tasks should be running at that time.

Your task: determine what data was sent, where, and how the attacker gained the ability to exfiltrate.

---

## Available Log Sources

- Suricata alerts (`eve.json`)
- Zeek `conn.log`, `dns.log`, `http.log`, `files.log`
- Sysmon logs from `WS-SERVER` (EventIDs 1, 3, 11)

---

## Log Samples

### Suricata Alert (3:47:02 PM)

```json
{
  "timestamp": "2024-01-16T15:47:02.334Z",
  "event_type": "alert",
  "src_ip": "192.168.20.31",
  "src_port": 51234,
  "dest_ip": "203.0.113.45",
  "dest_port": 80,
  "proto": "TCP",
  "alert": {
    "action": "allowed",
    "gid": 1,
    "signature_id": 9000004,
    "rev": 1,
    "signature": "LAB - Large Outbound HTTP POST Possible Data Exfil",
    "category": "Policy Violation",
    "severity": 2
  }
}
```

### Zeek http.log (3:47:02 PM)

```
ts            uid          id.orig_h      id.resp_h     method  uri              request_body_len  status_code  user_agent
1705417622.0  CkFjRz...   192.168.20.31  203.0.113.45  POST    /upload.php      54525952          200          Mozilla/5.0 (Windows NT 10.0; Win64; x64)
```

### Zeek conn.log — Multiple Connections (3:30 PM – 3:47 PM)

```
ts            id.orig_h      id.resp_h      id.resp_p  proto  orig_bytes   resp_bytes  duration
1705416612.0  192.168.20.31  203.0.113.45   80         tcp    145          832         0.12
1705416890.0  192.168.20.31  203.0.113.45   80         tcp    298          512         0.08
1705417022.0  192.168.20.31  8.8.8.8        53         udp    90           150         0.01
1705417622.0  192.168.20.31  203.0.113.45   80         tcp    54525952     200         12.34
```

### Zeek dns.log (3:33 PM – 3:46 PM — Suspicious)

```
ts            id.orig_h      query                                                           answers
1705416800.0  192.168.20.31  ZmluYW5jaWFscy5 [truncated 60 chars] .attacker.lab              NX
1705416830.0  192.168.20.31  cmVwb3J0cy56aXA [truncated 58 chars] .attacker.lab              NX
1705416862.0  192.168.20.31  aW52b2ljZXMuZG8 [truncated 62 chars] .attacker.lab              NX
1705416894.0  192.168.20.31  dXNlcm5hbWVzLnQ [truncated 55 chars] .attacker.lab              NX
```

### Sysmon Event ID 11 — FileCreate (3:28 PM)

```xml
<EventData>
    <Data Name="Image">C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe</Data>
    <Data Name="TargetFilename">C:\Windows\Temp\archive.zip</Data>
</EventData>
```

### Sysmon Event ID 1 — Process Create (3:25 PM)

```xml
<EventData>
    <Data Name="Image">C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe</Data>
    <Data Name="CommandLine">powershell.exe -enc Q29tcHJlc3MtQXJjaGl2ZSAtUGF0aCBDOlxVc2Vyc1xBZG1pblxEb2N1bWVudHMgLURlc3RpbmF0aW9uUGF0aCBDOlxXaW5kb3dzXFRlbXBcYXJjaGl2ZS56aXA=</Data>
    <Data Name="ParentImage">C:\Windows\System32\cmd.exe</Data>
    <Data Name="User">WS-SERVER\Administrator</Data>
</EventData>
```

### Sysmon Event ID 3 — Network Connection (3:47 PM)

```xml
<EventData>
    <Data Name="Image">C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe</Data>
    <Data Name="DestinationIp">203.0.113.45</Data>
    <Data Name="DestinationPort">80</Data>
    <Data Name="Initiated">true</Data>
</EventData>
```

---

## Guiding Questions

1. Decode the Base64-encoded PowerShell command. What did it do?
2. What does the DNS log reveal? Decode the suspicious DNS query subdomains.
3. How large was the data exfiltrated in the final HTTP POST?
4. What was likely the **full exfiltration sequence**?
5. What is the destination IP `203.0.113.45`? Is it internal or external?
6. What two **exfiltration channels** were potentially used?
7. What should you check next to determine how the attacker gained access?

---

## Answer Key

<details>
<summary>Click to reveal answers</summary>

### 1. Decoded PowerShell Command

Base64 decode of `Q29tcHJlc3MtQXJjaGl2ZSAtUGF0aCBDOlxVc2Vyc1xBZG1pblxEb2N1bWVudHMgLURlc3RpbmF0aW9uUGF0aCBDOlxXaW5kb3dzXFRlbXBcYXJjaGl2ZS56aXA=`:

```
Compress-Archive -Path C:\Users\Admin\Documents -DestinationPath C:\Windows\Temp\archive.zip
```

The attacker compressed the entire Administrator Documents folder into a zip file in the Temp directory.

### 2. DNS Log — Decoded Subdomains

The long DNS subdomains are Base64-encoded file names:
- `ZmluYW5jaWFscy4=` → `financials.`
- `cmVwb3J0cy56aXA=` → `reports.zip`
- `aW52b2ljZXMuZG8=` → `invoices.do`
- `dXNlcm5hbWVzLnQ=` → `usernames.t`

This is **DNS tunneling** — small chunks of data (file names or file content) encoded in DNS query subdomains. The NXDOMAIN responses suggest the DNS exfil was incomplete or being used for reconnaissance.

### 3. Exfiltration Size

The HTTP POST in the Zeek conn.log shows `orig_bytes: 54,525,952` — approximately **52 MB** of data sent in a single POST request. This is the `archive.zip` file.

### 4. Full Exfiltration Sequence

| Time | Action |
|------|--------|
| 3:25 PM | PowerShell compresses Admin\Documents into archive.zip |
| 3:28 PM | archive.zip written to C:\Windows\Temp\ |
| 3:30 PM | Reconnaissance HTTP requests to attacker C2 |
| 3:33–3:46 PM | DNS tunneling (possibly sending file index or small files) |
| 3:47 PM | HTTP POST of archive.zip (52 MB) to 203.0.113.45 |

### 5. Destination IP

`203.0.113.45` is in the `203.0.113.0/24` range — this is a **TEST-NET** address used in documentation, meaning in your lab this represents an external attacker-controlled server (on the internet side of pfSense).

### 6. Two Exfiltration Channels

1. **DNS Tunneling** — data encoded in DNS query subdomains (Zeek dns.log)
2. **HTTP POST** — compressed archive sent via HTTP to external server (Zeek http.log, Suricata alert)

### 7. Next Investigation Steps

- Check for prior logon events: `EventID=4624` before 3:25 PM on `WS-SERVER`
- Look for the initial delivery: phishing email, web exploit, or RDP brute force
- Check if `203.0.113.45` appears in other logs (other victim hosts)
- Search for `archive.zip` on other machines using Splunk/EDR
- Determine if domain `attacker.lab` resolves internally or externally

</details>

---

## Report Template

Document your findings using: [../../reports/incident-report-template.md](../../reports/incident-report-template.md)
