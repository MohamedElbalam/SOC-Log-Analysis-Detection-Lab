# SOC-Log-Analysis-Detection-Lab
Demonstrate attacks on the computer Network and capture all the traffic and analyze it.
This project simulates a real Security Operations Center (SOC) workflow.  
It demonstrates skills in:

- Log collection (Sysmon)
- Log analysis (Splunk or Wazuh)
- Attack simulation (process injection, Mimikatz, PowerShell abuse)
- Detection engineering (custom Splunk queries)
- Incident investigation
- Professional reporting

This environment is built on a Windows VM with Sysmon installed and logs forwarded to a SIEM.

---
Tasks for the lab:
    -take snapchats of useful machines
    -install win-server, security-onion os and pfsense

## Project Structure

**machines architectures**
    - for each machine with security concern use seperate storage for testing and labs
    - snapchats
    -resizing window issue for linux 
        => fix: using hardware: DISPLAY: SPICE xql machine:q35 wayland(modern display server protocol) GUI instead of xfce x11             protocol all with spice-vdagent and xserver-xorg-video-qxl 
            command: sudo apt install -y spice-vdagent xserver-xorg-video-qxl
**main issues & fixes:**
    - installing linux => never strated after first shutdown? 
    modern display server protocol
