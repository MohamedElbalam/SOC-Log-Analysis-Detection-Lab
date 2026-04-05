# Configs

This directory contains example configuration files used in the SOC Detection Lab.

---

## Files

| File | Description |
|---|---|
| [`sysmon-config.xml`](./sysmon-config.xml) | Sysmon configuration for Windows endpoint telemetry |

---

## Usage

### Sysmon Configuration

Deploy Sysmon with this configuration on Windows victim VMs:

```powershell
# Install Sysmon with this config
C:\Sysmon\Sysmon64.exe -accepteula -i configs\sysmon-config.xml

# Update existing Sysmon installation
C:\Sysmon\Sysmon64.exe -c configs\sysmon-config.xml

# Verify events are being generated
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 10
```

This configuration is based on the [SwiftOnSecurity sysmon-config](https://github.com/SwiftOnSecurity/sysmon-config) with lab-specific additions for:
- LSASS access monitoring (Event ID 10)
- Common attacker port network connections (Event ID 3)
- Suspicious file creation in Temp directories (Event ID 11)

---

## Adding New Configs

When adding configuration files:
1. Place the file in this directory
2. Update the table above with a description
3. Add usage instructions below
4. Reference the config in the relevant `lab-setup/` README

---

## Resources

- [SwiftOnSecurity Sysmon Config](https://github.com/SwiftOnSecurity/sysmon-config)
- [Olaf Hartong Sysmon Modular](https://github.com/olafhartong/sysmon-modular)
- [Sysmon Schema Reference](https://learn.microsoft.com/en-us/sysinternals/downloads/sysmon)
