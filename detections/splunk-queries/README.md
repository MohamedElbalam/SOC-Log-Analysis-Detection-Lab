# Splunk Detection Queries

This document contains Splunk SPL (Search Processing Language) queries to detect the attack techniques simulated in this lab. All queries target Windows Event Logs and Sysmon events.

## Index and Source Configuration

These queries assume:
- Index: `wineventlog` for Windows Security events
- Index: `sysmon` for Sysmon events (or same index with `source=XmlWinEventLog:Microsoft-Windows-Sysmon/Operational`)

Adjust index names to match your Splunk configuration.

---

## Process Injection (T1055)

### DET-001 — Remote Thread Creation in Unusual Process

```spl
index=sysmon EventCode=8
| where NOT (SourceImage LIKE "%MsMpEng.exe" OR SourceImage LIKE "%svchost.exe")
| table _time, Computer, SourceImage, TargetImage, TargetProcessId, StartAddress
| sort -_time
```

**What it detects:** Sysmon Event 8 (CreateRemoteThread) from processes other than known-good security tools.

**False positives:** JIT compilers, some legitimate AV engines. Tune the exclusion list.

---

### DET-002 — Process Accessing LSASS Memory

```spl
index=sysmon EventCode=10 TargetImage="*\\lsass.exe"
| where NOT (SourceImage LIKE "%MsMpEng.exe" OR SourceImage LIKE "%svchost.exe" OR SourceImage LIKE "%SecurityHealthService.exe")
| table _time, Computer, SourceImage, TargetImage, GrantedAccess, CallTrace
| sort -_time
```

**What it detects:** Any process (other than whitelisted security tools) opening a handle to lsass.exe.

**MITRE:** T1003.001

---

## Credential Harvesting (T1003)

### DET-003 — Mimikatz Command Line Indicators

```spl
index=sysmon EventCode=1
| where (CommandLine LIKE "%sekurlsa%" OR CommandLine LIKE "%privilege::debug%" OR CommandLine LIKE "%lsadump::" OR CommandLine LIKE "%kiwi%")
| table _time, Computer, User, Image, CommandLine, ParentImage
| sort -_time
```

**What it detects:** Known Mimikatz command patterns in process command-line arguments.

---

### DET-004 — SAM Registry Hive Access

```spl
index=wineventlog EventCode=4661
| search ObjectName="*\\SAM\\*" OR ObjectName="*\\SECURITY\\*"
| where ProcessName!="C:\\Windows\\System32\\lsass.exe"
| table _time, Computer, AccountName, ProcessName, ObjectName
| sort -_time
```

**What it detects:** Access to SAM or SECURITY registry hives from processes other than LSASS.

---

## Persistence (T1547 / T1053)

### DET-005 — Registry Run Key Modification

```spl
index=sysmon EventCode=13
| where TargetObject LIKE "%\\CurrentVersion\\Run%" OR TargetObject LIKE "%\\CurrentVersion\\RunOnce%"
| where Image!="C:\\Windows\\regedit.exe" AND Image!="C:\\Windows\\System32\\msiexec.exe"
| table _time, Computer, User, Image, TargetObject, Details
| sort -_time
```

**What it detects:** New entries added to autorun registry keys from uncommon processes.

---

### DET-006 — Suspicious Scheduled Task Creation

```spl
index=wineventlog EventCode=4698
| eval TaskContent=coalesce(TaskContent, "")
| where NOT (TaskName LIKE "%Microsoft%")
| rex field=TaskContent "Command>(?<command>[^<]+)<"
| table _time, Computer, TaskName, command, SubjectUserName
| sort -_time
```

**What it detects:** Newly created scheduled tasks with non-Microsoft names.

---

### DET-007 — New Service Installed

```spl
index=wineventlog source="WinEventLog:System" EventCode=7045
| where ServiceName!="*" AND NOT (ServiceName LIKE "%Update%" OR ServiceName LIKE "%Windows%")
| table _time, Computer, ServiceName, ImagePath, ServiceType, StartType
| sort -_time
```

**What it detects:** New services installed on Windows hosts, excluding common update-related services.

---

## Lateral Movement (T1021)

### DET-008 — Pass-the-Hash — Network Logon with NTLM

```spl
index=wineventlog EventCode=4624 LogonType=3 AuthenticationPackageName=NTLM
| where AccountName!="ANONYMOUS LOGON" AND AccountName!="*$"
| stats count by _time, AccountName, IpAddress, WorkstationName, Computer
| where count > 5
| sort -count
```

**What it detects:** Multiple NTLM network logons from the same source, which may indicate credential spraying or PTH.

---

### DET-009 — Admin Share Access

```spl
index=wineventlog EventCode=5140
| where ShareName="\\\\*\\ADMIN$" OR ShareName="\\\\*\\C$" OR ShareName="\\\\*\\IPC$"
| where AccountName!="*$"
| table _time, Computer, AccountName, IpAddress, ShareName, ObjectType
| sort -_time
```

**What it detects:** Access to Windows admin shares (ADMIN$, C$) from user accounts.

---

### DET-010 — PSExec-style Lateral Movement

```spl
index=sysmon EventCode=1
| where (Image LIKE "%PSEXESVC.exe" OR Image LIKE "%paexec.exe" OR Image LIKE "%remcom.exe")
| table _time, Computer, User, Image, CommandLine, ParentImage
| sort -_time
```

**What it detects:** Execution of known remote administration tools used in lateral movement.

---

## Data Exfiltration (T1048)

### DET-011 — Large Outbound Data Transfer

```spl
index=zeek sourcetype=zeek_conn
| where orig_bytes > 10000000 AND local_orig=true AND local_resp=false
| eval MB_sent = round(orig_bytes/1024/1024, 2)
| table _time, id.orig_h, id.resp_h, id.resp_p, MB_sent, proto
| sort -MB_sent
```

**What it detects:** Internal hosts sending more than 10 MB outbound in a single connection.

---

### DET-012 — PowerShell Making Outbound Network Connection

```spl
index=sysmon EventCode=3
| where Image LIKE "%powershell.exe" OR Image LIKE "%pwsh.exe"
| where Initiated="true" AND NOT DestinationIp LIKE "192.168.%"
| table _time, Computer, User, Image, DestinationIp, DestinationPort, DestinationHostname
| sort -_time
```

**What it detects:** PowerShell initiating connections to external IPs (common in staged exfiltration and C2).

---

## Summary Dashboard Search

```spl
index=sysmon OR index=wineventlog
| eval rule=case(
    EventCode=8, "DET-001: Remote Thread",
    EventCode=10 AND TargetImage LIKE "*lsass*", "DET-002: LSASS Access",
    EventCode=13 AND TargetObject LIKE "*Run*", "DET-005: Run Key",
    EventCode=4698, "DET-006: Scheduled Task",
    EventCode=7045, "DET-007: New Service",
    EventCode=4624 AND LogonType=3 AND AuthenticationPackageName="NTLM", "DET-008: PTH",
    1=1, "Other"
)
| where rule!="Other"
| stats count by rule, Computer
| sort -count
```

Use this search to get a high-level view of all detections across all lab machines.
