# Sysmon Detection Rules

This document contains Sysmon XML configuration rules and event descriptions for detecting host-based attack indicators.

## What is Sysmon?

Sysmon (System Monitor) is a Windows system service that logs detailed process, network, and file activity to the Windows Event Log. The log source is:

```
Applications and Services Logs\Microsoft\Windows\Sysmon\Operational
```

## Installation

```powershell
# Download Sysmon from Sysinternals
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile "C:\Tools\Sysmon.zip"
Expand-Archive "C:\Tools\Sysmon.zip" -DestinationPath "C:\Tools\Sysmon\"

# Install with SwiftOnSecurity config (recommended baseline)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile "C:\Tools\sysmonconfig.xml"
C:\Tools\Sysmon\Sysmon64.exe -accepteula -i C:\Tools\sysmonconfig.xml
```

## Key Event IDs

| Event ID | Event Name | Use Case |
|----------|-----------|----------|
| 1 | Process Create | Detect suspicious process spawning |
| 3 | Network Connection | Detect C2 beacons, exfiltration |
| 7 | Image Loaded | Detect DLL hijacking |
| 8 | CreateRemoteThread | Detect process injection |
| 10 | ProcessAccess | Detect LSASS dumping |
| 11 | FileCreate | Detect dropped malware, staged files |
| 12/13 | Registry Events | Detect persistence via Run keys |
| 15 | FileCreateStreamHash | Detect MOTW bypass (ADS) |
| 22 | DnsQuery | Detect C2 over DNS |

---

## Custom Sysmon Configuration Rules

The following XML rules can be merged into a Sysmon configuration file.

### SYSMON-001 — Detect LSASS Process Access

Add to the `ProcessAccess` section:

```xml
<!-- Alert on ANY process accessing LSASS, except known good -->
<RuleGroup name="" groupRelation="or">
    <ProcessAccess onmatch="include">
        <TargetImage condition="end with">lsass.exe</TargetImage>
    </ProcessAccess>
</RuleGroup>
<RuleGroup name="" groupRelation="or">
    <ProcessAccess onmatch="exclude">
        <SourceImage condition="end with">MsMpEng.exe</SourceImage>
        <SourceImage condition="end with">svchost.exe</SourceImage>
        <SourceImage condition="end with">SecurityHealthService.exe</SourceImage>
        <SourceImage condition="end with">taskmgr.exe</SourceImage>
        <GrantedAccess condition="is">0x1000</GrantedAccess>
    </ProcessAccess>
</RuleGroup>
```

**Triggers on:** Mimikatz, Meterpreter kiwi, procdump targeting lsass.exe

---

### SYSMON-002 — Detect Remote Thread Creation

Add to the `CreateRemoteThread` section:

```xml
<RuleGroup name="" groupRelation="or">
    <CreateRemoteThread onmatch="include">
        <TargetImage condition="end with">explorer.exe</TargetImage>
        <TargetImage condition="end with">svchost.exe</TargetImage>
        <TargetImage condition="end with">lsass.exe</TargetImage>
        <TargetImage condition="end with">winlogon.exe</TargetImage>
        <TargetImage condition="end with">spoolsv.exe</TargetImage>
    </CreateRemoteThread>
</RuleGroup>
```

**Triggers on:** Process injection into system processes

---

### SYSMON-003 — Detect PowerShell Downloading Files

Add to the `ProcessCreate` section:

```xml
<RuleGroup name="" groupRelation="or">
    <ProcessCreate onmatch="include">
        <CommandLine condition="contains">Invoke-WebRequest</CommandLine>
        <CommandLine condition="contains">DownloadFile</CommandLine>
        <CommandLine condition="contains">DownloadString</CommandLine>
        <CommandLine condition="contains">WebClient</CommandLine>
        <CommandLine condition="contains">IEX</CommandLine>
        <CommandLine condition="contains">Invoke-Expression</CommandLine>
        <CommandLine condition="contains">-EncodedCommand</CommandLine>
        <CommandLine condition="contains">-enc </CommandLine>
    </ProcessCreate>
</RuleGroup>
```

**Triggers on:** PowerShell cradles, encoded commands, file downloads

---

### SYSMON-004 — Detect Persistence via Registry Run Keys

Add to the `RegistryEvent` section:

```xml
<RuleGroup name="" groupRelation="or">
    <RegistryEvent onmatch="include">
        <TargetObject condition="contains">CurrentVersion\Run</TargetObject>
        <TargetObject condition="contains">CurrentVersion\RunOnce</TargetObject>
        <TargetObject condition="contains">CurrentVersion\RunServices</TargetObject>
        <TargetObject condition="contains">Winlogon\Userinit</TargetObject>
        <TargetObject condition="contains">Winlogon\Shell</TargetObject>
    </RegistryEvent>
</RuleGroup>
```

**Triggers on:** Persistence via run keys, Winlogon hijacking

---

### SYSMON-005 — Detect Outbound Connections from Script Hosts

Add to the `NetworkConnect` section:

```xml
<RuleGroup name="" groupRelation="or">
    <NetworkConnect onmatch="include">
        <Image condition="end with">powershell.exe</Image>
        <Image condition="end with">pwsh.exe</Image>
        <Image condition="end with">wscript.exe</Image>
        <Image condition="end with">cscript.exe</Image>
        <Image condition="end with">mshta.exe</Image>
        <Image condition="end with">regsvr32.exe</Image>
        <Image condition="end with">rundll32.exe</Image>
    </NetworkConnect>
</RuleGroup>
```

**Triggers on:** Script host C2 callbacks, LOLBin-based download/execute

---

### SYSMON-006 — Detect Scheduled Task Created via CLI

Add to the `ProcessCreate` section:

```xml
<RuleGroup name="" groupRelation="or">
    <ProcessCreate onmatch="include">
        <Image condition="end with">schtasks.exe</Image>
        <CommandLine condition="contains">/create</CommandLine>
    </ProcessCreate>
</RuleGroup>
```

**Triggers on:** Scheduled task persistence created via command line

---

## Applying Configuration Updates

```powershell
# Update running Sysmon with new config
C:\Tools\Sysmon\Sysmon64.exe -c C:\Tools\sysmonconfig.xml

# Verify Sysmon is running
Get-Service Sysmon64

# Check event log for recent events
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 20 |
    Format-List TimeCreated, Id, Message
```

## Forwarding Sysmon Logs to SIEM

### Via Winlogbeat (Elasticsearch/Security Onion)

In `winlogbeat.yml`:

```yaml
winlogbeat.event_logs:
  - name: Microsoft-Windows-Sysmon/Operational
    event_id: 1, 3, 7, 8, 10, 11, 12, 13, 15, 22

output.elasticsearch:
  hosts: ["https://192.168.20.1:9200"]
  username: "winlogbeat_writer"
  password: "changeme"
```
