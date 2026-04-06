# Remote Access Setup

This guide covers remote access to the lab environment from outside the local network.

## Tools Used

| Tool | Purpose |
|------|---------|
| **Tailscale** | Secure VPN mesh for remote access to Proxmox and VMs |
| **Cloudflare Tunnel** | Web-based access to the Proxmox UI (optional) |
| **SSH** | Terminal access to Linux VMs via Tailscale IP |

## Architecture

```
Remote Machine (laptop/home PC)
        │
   [Tailscale VPN]
        │
  Proxmox Host (Tailscale node)
        │
   Lab VMs (reachable via subnet routing)
```

---

## Tailscale Setup (Primary Method)

Tailscale creates a secure mesh network using WireGuard under the hood and supports MFA.

### Step 1: Install Tailscale on Proxmox

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up --advertise-routes=192.168.10.0/24,192.168.20.0/24 --accept-routes
```

The `--advertise-routes` flag makes Tailscale act as a subnet router, allowing access to all lab VMs through the Proxmox node.

### Step 2: Approve Subnet Routes

1. Log in to https://login.tailscale.com/admin/machines
2. Find the Proxmox machine → click `...` → Edit route settings
3. Enable the advertised routes

### Step 3: Install Tailscale on Your Remote Machine

Download from https://tailscale.com/download and log in with the same account.

### Step 4: Enable MFA (Recommended)

In Tailscale admin console → Settings → Authentication → Enable MFA.

### Step 5: Connect to Lab

```bash
# SSH to Proxmox
ssh root@<tailscale-ip-of-proxmox>

# SSH to a victim VM (via subnet routing)
ssh labuser@192.168.20.20

# Access Proxmox UI
https://<tailscale-ip-of-proxmox>:8006
```

---

## Cloudflare Tunnel (Optional — Web UI Access)

Useful for accessing the Proxmox web UI without exposing port 8006 to the internet.

### Setup

```bash
# Install cloudflared on Proxmox
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared-linux-amd64.deb

# Authenticate with Cloudflare
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create lab-proxmox

# Create config: /etc/cloudflared/config.yml
tunnel: <tunnel-id>
credentials-file: /root/.cloudflared/<tunnel-id>.json
ingress:
  - hostname: proxmox.yourdomain.com
    service: https://localhost:8006
    originRequest:
      noTLSVerify: true
  - service: http_status:404

# Install as service
cloudflared service install
systemctl enable --now cloudflared
```

---

## Resume Statement

> Architected a virtualized pentesting environment using Proxmox and pfSense, utilizing Tailscale Subnet Routing for secure, MFA-protected remote access to isolated attack segments.

---

## Learning Roadmap

- [ ] Tailscale basic setup (done)
- [ ] Cloudflare Tunnel for web access
- [ ] Terraform for automating Proxmox VM provisioning
- [ ] Ansible for VM configuration management
