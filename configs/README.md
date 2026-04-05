# Configuration Examples

This directory contains sanitized example configurations for the tools used in the SOC Detection Lab.

> ⚠️ All sensitive values (IP addresses, passwords, API keys) have been removed or replaced with placeholders. Customize these files for your specific lab environment before deploying.

---

## Directory Structure

```
configs/
├── sysmon/
│   └── sysmon-config.xml      # Sysmon event filtering rules (based on SwiftOnSecurity)
├── splunk/
│   └── inputs.conf            # Splunk Universal Forwarder input configuration
└── wazuh/
    └── local_rules.xml        # Custom Wazuh detection rules (local_rules.xml)
```

---

## Sysmon Configuration

**File**: `sysmon/sysmon-config.xml`  
**Deploy to**: `C:\Tools\Sysmon\` on each Windows victim VM

```powershell
# Install or update Sysmon with this config
C:\Tools\Sysmon\Sysmon64.exe -accepteula -i configs\sysmon\sysmon-config.xml

# Update existing installation
C:\Tools\Sysmon\Sysmon64.exe -c configs\sysmon\sysmon-config.xml
```

Key events captured:
- **Event ID 1** — Process Creation (all, with selective exclusions)
- **Event ID 3** — Network Connections from high-risk processes
- **Event ID 7** — Image Load (unsigned DLLs, suspicious paths)
- **Event ID 8** — CreateRemoteThread (process injection)
- **Event ID 10** — ProcessAccess (LSASS access → Mimikatz)
- **Event ID 11** — File Create (suspicious locations)
- **Event ID 12/13/14** — Registry persistence keys
- **Event ID 22** — DNS Queries from high-risk processes

---

## Splunk Universal Forwarder

**File**: `splunk/inputs.conf`  
**Deploy to**: `C:\Program Files\SplunkUniversalForwarder\etc\system\local\inputs.conf`

Key log sources:
- Sysmon Operational log → `sysmon` index
- Windows Security log (filtered to high-value event IDs) → `wineventlog` index
- PowerShell Operational log → `wineventlog` index
- Windows Defender log → `wineventlog` index
- Task Scheduler log → `wineventlog` index

After deploying:
```powershell
Restart-Service SplunkForwarder
```

---

## Wazuh Custom Rules

**File**: `wazuh/local_rules.xml`  
**Deploy to**: `/var/ossec/etc/rules/local_rules.xml` on the Wazuh manager

Custom rules included:
- **100010** — Process Injection via CreateRemoteThread (T1055)
- **100020** — LSASS access with suspicious rights (T1003.001)
- **100030** — Encoded PowerShell command (T1059.001)
- **100031** — PowerShell download cradle (T1059.001)
- **100040** — Interpreter outbound on non-standard port (T1071.001)
- **100050** — Registry Run key modification (T1547.001)
- **100060** — Scheduled task creation (T1053.005)
- **100070** — Brute force — multiple failed logons (T1110)

After deploying:
```bash
systemctl restart wazuh-manager
# Verify rules loaded
/var/ossec/bin/wazuh-logtest
```
