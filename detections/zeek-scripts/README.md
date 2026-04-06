# Zeek NSM Scripts & Analysis

This document covers Zeek log analysis and custom scripts for detecting anomalous network behavior in the lab.

## Zeek Log Files Reference

| Log File | Contents |
|----------|----------|
| `conn.log` | All TCP/UDP/ICMP connections (duration, bytes, state) |
| `dns.log` | DNS queries and responses |
| `http.log` | HTTP requests and responses |
| `ssl.log` | TLS/SSL connections (certificate info, SNI) |
| `files.log` | Files transferred over the network |
| `weird.log` | Protocol anomalies and unexpected behaviors |
| `notice.log` | Zeek-generated notices and alerts |
| `software.log` | Software detected from user-agent strings |

Log location on Security Onion: `/nsm/zeek/logs/current/`

---

## Command-Line Log Analysis

### View Active Connections

```bash
zeek-cut id.orig_h id.resp_h id.resp_p proto orig_bytes resp_bytes duration \
    < /nsm/zeek/logs/current/conn.log | \
    sort -t$'\t' -k5 -rn | head -20
```

### Find Large Data Transfers (Possible Exfiltration)

```bash
# Connections where orig_bytes (client sent) > 5 MB
zeek-cut ts id.orig_h id.resp_h id.resp_p orig_bytes resp_bytes \
    < /nsm/zeek/logs/current/conn.log | \
    awk -F'\t' '$5 > 5000000 {print $0}' | \
    sort -t$'\t' -k5 -rn
```

### Find Long DNS Query Names (Possible DNS Tunneling)

```bash
# DNS queries with query name longer than 50 chars
zeek-cut ts id.orig_h query qtype_name answers \
    < /nsm/zeek/logs/current/dns.log | \
    awk -F'\t' 'length($3) > 50 {print $0}'
```

### Identify Rare User-Agents

```bash
# List HTTP user agents and their frequency
zeek-cut user_agent < /nsm/zeek/logs/current/http.log | \
    sort | uniq -c | sort -rn | head -20
```

### Find Connections to Unusual Ports

```bash
# Outbound to non-standard ports (not 80/443/53/22/25)
zeek-cut ts id.orig_h id.resp_h id.resp_p orig_bytes \
    < /nsm/zeek/logs/current/conn.log | \
    awk -F'\t' '$4 != 80 && $4 != 443 && $4 != 53 && $4 != 22 && $4 != 25 \
        && $3 !~ /^192\.168\./ {print $0}' | \
    sort -t$'\t' -k4 -n
```

---

## Custom Zeek Scripts

### ZEEk-001 — Detect Large Outbound Transfers

Save as `/opt/zeek/share/zeek/site/large-transfer-detect.zeek`:

```zeek
@load base/protocols/conn

module LargeTransfer;

export {
    redef enum Notice::Type += {
        Large_Outbound_Transfer
    };

    const threshold_bytes: count = 10000000 &redef;  # 10 MB
    const internal_networks: set[subnet] = { 192.168.0.0/16, 10.0.0.0/8 } &redef;
}

event connection_state_remove(c: connection) {
    if (c$orig$size > threshold_bytes &&
        c$id$orig_h in internal_networks &&
        c$id$resp_h !in internal_networks) {
        NOTICE([$note=Large_Outbound_Transfer,
                $conn=c,
                $msg=fmt("Large outbound transfer: %s -> %s (%d bytes)",
                    c$id$orig_h, c$id$resp_h, c$orig$size),
                $identifier=cat(c$id$orig_h)]);
    }
}
```

---

### ZEEK-002 — Detect DNS with Long Queries

Save as `/opt/zeek/share/zeek/site/dns-tunneling.zeek`:

```zeek
@load base/protocols/dns

module DNSTunneling;

export {
    redef enum Notice::Type += {
        Possible_DNS_Tunneling
    };

    const suspicious_query_len: count = 50 &redef;
    const threshold: count = 5 &redef;
}

global long_query_count: table[addr] of count &default=0 &create_expire=5min;

event dns_request(c: connection, msg: dns_msg, query: string, qtype: count, qclass: count) {
    if (|query| > suspicious_query_len) {
        local src = c$id$orig_h;
        long_query_count[src] += 1;

        if (long_query_count[src] >= threshold) {
            NOTICE([$note=Possible_DNS_Tunneling,
                    $conn=c,
                    $msg=fmt("Possible DNS tunneling from %s: %d long queries (last: %s)",
                        src, long_query_count[src], query),
                    $identifier=cat(src)]);
        }
    }
}
```

---

### ZEEK-003 — Track SMB Connections (Lateral Movement)

Save as `/opt/zeek/share/zeek/site/smb-tracking.zeek`:

```zeek
@load base/protocols/smb

module SMBTracking;

export {
    redef enum Notice::Type += {
        Multiple_SMB_Connections
    };

    const smb_threshold: count = 10 &redef;
}

global smb_conn_count: table[addr] of count &default=0 &create_expire=5min;

event connection_established(c: connection) {
    if (c$id$resp_p == 445/tcp || c$id$resp_p == 139/tcp) {
        local src = c$id$orig_h;
        smb_conn_count[src] += 1;

        if (smb_conn_count[src] >= smb_threshold) {
            NOTICE([$note=Multiple_SMB_Connections,
                    $conn=c,
                    $msg=fmt("Host %s made %d SMB connections in 5 minutes",
                        src, smb_conn_count[src]),
                    $identifier=cat(src)]);
        }
    }
}
```

---

## Loading Custom Scripts

```bash
# Add to local.zeek
echo "@load ./large-transfer-detect" >> /opt/zeek/share/zeek/site/local.zeek
echo "@load ./dns-tunneling" >> /opt/zeek/share/zeek/site/local.zeek
echo "@load ./smb-tracking" >> /opt/zeek/share/zeek/site/local.zeek

# Deploy (if using zeekctl)
zeekctl deploy

# Or restart zeek
zeekctl restart
```

## Viewing Notices in Security Onion

```bash
# View notice.log
zeek-cut ts note msg src \
    < /nsm/zeek/logs/current/notice.log | \
    sort -t$'\t' -k1 -r | head -50
```

Or in Kibana: filter `event.dataset: zeek.notice`.
