# Detection Rules & Queries

This directory documents detection rules written for Splunk and Wazuh to identify the attack techniques simulated in this lab. Each rule includes an explanation of what it detects, why it works, and known false positives.

---

## Table of Contents
1. [Detection Methodology](#detection-methodology)
2. [Splunk Detection Queries](#splunk-detection-queries)
   - [Process Injection](#splunk-process-injection)
   - [Credential Dumping — LSASS Access](#splunk-credential-dumping--lsass-access)
   - [Encoded PowerShell Commands](#splunk-encoded-powershell-commands)
   - [C2 Reverse Shell](#splunk-c2-reverse-shell)
3. [Wazuh Detection Rules](#wazuh-detection-rules)
4. [Security Onion / Suricata Rules](#security-onion--suricata-rules)
5. [Tuning and False Positive Management](#tuning-and-false-positive-management)

---

## Detection Methodology

Each detection follows this workflow:

1. **Hypothesis** — Based on MITRE ATT&CK technique, what artifact does the attacker leave?
2. **Log Source** — Which event log or SIEM data source captures that artifact?
3. **Query** — Write a query to surface those artifacts.
4. **Threshold** — Tune to reduce false positives (allowlist known-good processes, time windows).
5. **Alert** — Trigger an alert with context for triage (user, host, parent process, command line).
6. **Validate** — Run the attack simulation and confirm the rule fires; verify it doesn't fire on clean traffic.

---

## Splunk Detection Queries

All queries below assume:
- Sysmon events are in the `wineventlog` or `sysmon` index.
- Windows Security events are in the `wineventlog` index.
- Adjust index names to match your Splunk configuration.

### Splunk: Process Injection

Detects `CreateRemoteThread` calls (Sysmon Event ID 8) from suspicious source processes.

```splunk
index=sysmon EventCode=8
| eval suspicious_source=if(match(SourceImage, "(?i)(powershell|cmd|wscript|cscript|mshta|regsvr32|rundll32)"), 1, 0)
| where suspicious_source=1
| table _time, ComputerName, SourceImage, SourceProcessId, TargetImage, TargetProcessId, StartAddress, StartFunction
| sort -_time
```

**What it detects**: Remote thread injection originating from common attacker-controlled processes.  
**Known false positives**: Some AV/EDR products use CreateRemoteThread legitimately. Allowlist by `SourceImage` if needed.

---

### Splunk: Credential Dumping — LSASS Access

Detects Sysmon Event ID 10 (ProcessAccess) targeting `lsass.exe` with high-privilege access rights.

```splunk
index=sysmon EventCode=10 TargetImage="*lsass.exe"
| eval suspicious_rights=if(match(GrantedAccess, "(?i)(0x1fffff|0x1010|0x143a|0x40)"), 1, 0)
| where suspicious_rights=1
| table _time, ComputerName, SourceImage, SourceProcessId, TargetImage, GrantedAccess
| sort -_time
```

**What it detects**: Mimikatz-style LSASS memory reads using known access right masks.  
**Known false positives**: AV products and Windows Defender access LSASS. Allowlist `SourceImage` for known-good tools.

---

### Splunk: Encoded PowerShell Commands

Detects PowerShell launched with encoded command flags (common obfuscation technique).

```splunk
index=sysmon EventCode=1 Image="*powershell.exe"
(CommandLine="*-EncodedCommand*" OR CommandLine="*-Enc *" OR CommandLine="*-e *")
| table _time, ComputerName, User, ParentImage, CommandLine
| sort -_time
```

**What it detects**: PowerShell execution using Base64-encoded commands.  
**Known false positives**: Some legitimate IT automation tools and scripts use encoded commands. Review `ParentImage` and `User` for context.

Extended version — also catches common obfuscation patterns:

```splunk
index=sysmon EventCode=1 Image="*powershell.exe"
| eval encoded=if(match(CommandLine, "(?i)(-enc|-encodedcommand|-e\s)"), 1, 0)
| eval downloadcradle=if(match(CommandLine, "(?i)(downloadstring|iex|invoke-expression|webclient)"), 1, 0)
| eval amsi=if(match(CommandLine, "(?i)(amsiutils|amsiInitFailed)"), 1, 0)
| where encoded=1 OR downloadcradle=1 OR amsi=1
| table _time, ComputerName, User, ParentImage, CommandLine, encoded, downloadcradle, amsi
| sort -_time
```

---

### Splunk: C2 Reverse Shell

Detects outbound network connections from known interpreter processes on non-standard ports (Sysmon Event ID 3).

```splunk
index=sysmon EventCode=3
(Image="*powershell.exe" OR Image="*cmd.exe" OR Image="*python.exe" OR Image="*nc.exe")
NOT (DestinationPort=80 OR DestinationPort=443 OR DestinationPort=53)
NOT DestinationIp IN ("10.10.2.*", "10.10.1.*", "127.0.0.1")
| table _time, ComputerName, User, Image, SourceIp, DestinationIp, DestinationPort, DestinationHostname
| sort -_time
```

**What it detects**: Shells and interpreters connecting outbound on unusual ports (potential reverse shell or C2 beacon).  
**Known false positives**: Adjust the exclusion list for known update servers or internal services.

Beaconing detection — look for repeated connections at regular intervals:

```splunk
index=sysmon EventCode=3 Image="*powershell.exe"
| bin _time span=1m
| stats count by _time, ComputerName, DestinationIp, DestinationPort
| eventstats avg(count) as avg_count, stdev(count) as stdev_count by ComputerName, DestinationIp, DestinationPort
| where count > (avg_count + 2*stdev_count)
| table _time, ComputerName, DestinationIp, DestinationPort, count, avg_count
```

---

## Wazuh Detection Rules

Custom rules go in `/var/ossec/etc/rules/local_rules.xml`. See [`../configs/wazuh/local_rules.xml`](../configs/wazuh/local_rules.xml) for the full file.

### Rule: LSASS Access (Mimikatz)
```xml
<rule id="100001" level="12">
  <if_group>sysmon_event_10</if_group>
  <field name="win.eventdata.targetImage" type="pcre2">(?i)lsass\.exe</field>
  <field name="win.eventdata.grantedAccess" type="pcre2">0x1fffff|0x1010|0x143a</field>
  <description>Possible Mimikatz: LSASS memory access with suspicious rights</description>
  <mitre>
    <id>T1003.001</id>
  </mitre>
</rule>
```

### Rule: Encoded PowerShell
```xml
<rule id="100002" level="10">
  <if_group>sysmon_event1</if_group>
  <field name="win.eventdata.image" type="pcre2">(?i)powershell\.exe</field>
  <field name="win.eventdata.commandLine" type="pcre2">(?i)-enc|-encodedcommand</field>
  <description>PowerShell launched with encoded command — possible obfuscation</description>
  <mitre>
    <id>T1059.001</id>
  </mitre>
</rule>
```

### Rule: Suspicious Outbound Connection from PowerShell
```xml
<rule id="100003" level="10">
  <if_group>sysmon_event3</if_group>
  <field name="win.eventdata.image" type="pcre2">(?i)powershell\.exe|cmd\.exe</field>
  <field name="win.eventdata.destinationPort" type="pcre2">^(?!80$|443$|53$)\d+$</field>
  <description>PowerShell/cmd making outbound connection on non-standard port — possible C2</description>
  <mitre>
    <id>T1071.001</id>
  </mitre>
</rule>
```

---

## Security Onion / Suricata Rules

Security Onion uses the Emerging Threats (ET) ruleset by default. For custom rules, add them to `/etc/suricata/rules/local.rules`.

### Custom Rule: Detect Mimikatz User-Agent
```suricata
alert http $HOME_NET any -> $EXTERNAL_NET any (
  msg:"Possible Mimikatz HTTP C2 beacon";
  content:"User-Agent|3a 20|Mimikatz";
  nocase;
  sid:9000001; rev:1;
)
```

### Custom Rule: Detect Reverse Shell on Non-Standard Port
```suricata
alert tcp $HOME_NET any -> $EXTERNAL_NET !80 !443 !53 (
  msg:"Possible reverse shell — outbound connection on non-standard port";
  flags:S;
  threshold: type both, track by_src, count 5, seconds 60;
  sid:9000002; rev:1;
)
```

---

## Tuning and False Positive Management

| Technique | Common FP Source | Mitigation |
|-----------|-----------------|-----------|
| LSASS access (T1003) | Windows Defender, CrowdStrike, Malwarebytes | Allowlist by `SourceImage` for known AV processes |
| Encoded PowerShell (T1059.001) | SCCM, automation scripts | Allowlist by `ParentImage` or `User` for known admin accounts |
| Outbound PS connection (T1071) | Windows Update, telemetry | Add known Microsoft IP ranges to exclusion list |
| CreateRemoteThread (T1055) | Browser plugins, AV | Allowlist specific `SourceImage` + `TargetImage` pairs |

Always validate new rules by:
1. Running the simulation → confirming the rule fires.
2. Running normal operations → confirming the rule does NOT fire.
3. Documenting the rule's logic, FP rate, and tuning decisions here.
