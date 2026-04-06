## SOC-Log-Analysis-Detection-Lab

Demonstrate attacks on the computer network and capture all the traffic and analyze it.
This project simulates a real Security Operations Center (SOC) workflow.  
It demonstrates skills in:

- Log collection (Sysmon)
- Log analysis (Splunk or Wazuh)
- Attack simulation (process injection, Mimikatz, PowerShell abuse)
- Detection engineering (custom Splunk queries)
- Incident investigation
- Professional reporting

This environment is built on a Windows VM with Sysmon installed and logs forwarded to a SIEM.

## Lab Tasks

- Take snapshots of useful machines
- Install Windows Server, Security Onion OS, and pfSense

## Project Structure

**Machine Architectures**

- For each machine with security concerns, use separate storage for testing and labs
- Create snapshots for each configuration