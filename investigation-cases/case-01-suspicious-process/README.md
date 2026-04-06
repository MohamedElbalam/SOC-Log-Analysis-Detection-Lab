# Case 01 — Suspicious Process Execution

**Difficulty:** Beginner  
**MITRE ATT&CK:** T1059.001 (PowerShell), T1055 (Process Injection)  
**Estimated Time:** 30–45 minutes

---

## Scenario

It is Monday morning. Your SOC monitoring system fired an alert at 02:14 AM:

> **Alert:** Sysmon Event ID 8 — Remote thread created in `explorer.exe` from `svchost.exe`

The source workstation is `DESKTOP-WIN10` (192.168.20.30), a standard employee workstation with no after-hours scheduled tasks. The user (`jsmith`) was not logged in at that time.

Your task is to investigate whether this is a true positive and determine what happened.

---

## Available Log Sources

- Sysmon logs from `DESKTOP-WIN10` (EventIDs 1, 3, 8, 10, 11, 13)
- Windows Security Event Log (EventIDs 4624, 4688)
- Zeek `conn.log` from Security Onion

---

## Log Samples

### Sysmon Event ID 8 — CreateRemoteThread (Alert)

```xml
<Event>
  <System>
    <EventID>8</EventID>
    <TimeCreated SystemTime="2024-01-15T02:14:33.123Z"/>
    <Computer>DESKTOP-WIN10</Computer>
  </System>
  <EventData>
    <Data Name="SourceProcessId">2344</Data>
    <Data Name="SourceImage">C:\Windows\System32\svchost.exe</Data>
    <Data Name="TargetProcessId">1832</Data>
    <Data Name="TargetImage">C:\Windows\explorer.exe</Data>
    <Data Name="StartAddress">0x00007FFAB1234567</Data>
  </EventData>
</Event>
```

### Sysmon Event ID 3 — Network Connection (02:14:40 AM)

```xml
<Event>
  <System>
    <EventID>3</EventID>
    <TimeCreated SystemTime="2024-01-15T02:14:40.887Z"/>
    <Computer>DESKTOP-WIN10</Computer>
  </System>
  <EventData>
    <Data Name="Image">C:\Windows\explorer.exe</Data>
    <Data Name="Initiated">true</Data>
    <Data Name="DestinationIp">192.168.10.10</Data>
    <Data Name="DestinationPort">4444</Data>
    <Data Name="Protocol">tcp</Data>
  </EventData>
</Event>
```

### Sysmon Event ID 1 — Process Create (02:12:15 AM)

```xml
<Event>
  <System>
    <EventID>1</EventID>
    <TimeCreated SystemTime="2024-01-15T02:12:15.456Z"/>
    <Computer>DESKTOP-WIN10</Computer>
  </System>
  <EventData>
    <Data Name="Image">C:\Users\Public\svcupdate.exe</Data>
    <Data Name="CommandLine">C:\Users\Public\svcupdate.exe</Data>
    <Data Name="ParentImage">C:\Windows\System32\cmd.exe</Data>
    <Data Name="ParentCommandLine">cmd.exe /c C:\Users\Public\svcupdate.exe</Data>
    <Data Name="User">DESKTOP-WIN10\jsmith</Data>
    <Data Name="Hashes">SHA256=A1B2C3D4E5F6...</Data>
  </EventData>
</Event>
```

### Sysmon Event ID 11 — FileCreate (02:11:55 AM)

```xml
<Event>
  <System>
    <EventID>11</EventID>
    <TimeCreated SystemTime="2024-01-15T02:11:55.234Z"/>
    <Computer>DESKTOP-WIN10</Computer>
  </System>
  <EventData>
    <Data Name="Image">C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe</Data>
    <Data Name="TargetFilename">C:\Users\Public\svcupdate.exe</Data>
  </EventData>
</Event>
```

### Zeek conn.log (02:11:30 AM)

```
ts            id.orig_h       id.resp_h      id.resp_p  proto  orig_bytes  resp_bytes
1705278690.0  192.168.20.30   192.168.10.10  8080       tcp    312         47823
```

### Windows Security Event 4624 (02:11:28 AM)

```
EventID: 4624
LogonType: 10 (RemoteInteractive)
AccountName: jsmith
IpAddress: 192.168.10.10
WorkstationName: KALI-ATTACKER
```

---

## Guiding Questions

Answer these before looking at the answer key:

1. What was the **initial access vector**? When did the attacker first get in?
2. What did the attacker do at `02:11:30 AM`? What does the Zeek conn.log tell you?
3. What process was the malicious payload (`svcupdate.exe`) disguised as?
4. What is the significance of a network connection from `explorer.exe` to port `4444`?
5. What is the **complete attack timeline** in chronological order?
6. What **MITRE ATT&CK techniques** were used?
7. What **containment actions** would you take immediately?

---

## Answer Key

> **Spoilers below — attempt the case first!**

<details>
<summary>Click to reveal answers</summary>

### 1. Initial Access Vector

The attacker logged in remotely via RDP (LogonType 10) from `192.168.10.10` (Kali Linux) at **02:11:28 AM** using `jsmith`'s credentials. This suggests prior credential compromise.

### 2. Activity at 02:11:30 AM

The Zeek conn.log shows a connection from the victim (`192.168.20.30`) to the attacker (`192.168.10.10`) on port **8080**, where the victim received **47,823 bytes**. This is the attacker serving the `svcupdate.exe` payload via HTTP (e.g., `python3 -m http.server 8080`).

### 3. Payload Disguise

`svcupdate.exe` is placed in `C:\Users\Public\` and named to resemble a Windows service update process, trying to blend in with legitimate svchost.exe activity.

### 4. Network Connection from explorer.exe

Explorer.exe does not normally initiate outbound network connections. A connection from `explorer.exe` to port `4444` indicates successful **process injection** — the attacker injected a Meterpreter shell into explorer.exe (Event ID 8 confirms this), and the injected code established a C2 connection back to the attacker.

### 5. Attack Timeline

| Time | Event |
|------|-------|
| 02:11:28 AM | RDP logon from 192.168.10.10 as jsmith |
| 02:11:30 AM | HTTP download of svcupdate.exe (47 KB) |
| 02:11:55 AM | svcupdate.exe written to C:\Users\Public\ by PowerShell |
| 02:12:15 AM | svcupdate.exe executed via cmd.exe |
| 02:14:33 AM | Remote thread injected into explorer.exe (Event ID 8) |
| 02:14:40 AM | explorer.exe establishes C2 connection to 192.168.10.10:4444 |

### 6. MITRE ATT&CK Mapping

| Technique | ID |
|-----------|----|
| Valid Accounts (RDP) | T1078 |
| PowerShell | T1059.001 |
| Ingress Tool Transfer | T1105 |
| Process Injection | T1055 |
| Remote Access Software (Meterpreter) | T1219 |

### 7. Containment Actions

1. **Isolate** `DESKTOP-WIN10` from the network immediately (disable NIC or move to quarantine VLAN)
2. **Revoke** jsmith's credentials and reset password
3. **Block** outbound connections to `192.168.10.10:4444` at pfSense
4. **Image** the VM for forensic analysis before any remediation
5. **Search** for `svcupdate.exe` across all hosts using EDR or Splunk

</details>

---

## Report Template

Document your findings using: [../../reports/incident-report-template.md](../../reports/incident-report-template.md)
