# Security Lab Best Practices

> ⚠️ **This repository documents a security research home lab. All techniques and tools described here are for educational and defensive purposes only. Use only in isolated, authorized environments.**

---

## Lab Isolation Requirements

### Network Segmentation
- Keep attacker (vmbr1) and victim (vmbr2) networks on separate virtual bridges — never bridge them directly.
- pfSense must be the only routing point between networks.
- Do **not** expose any lab VM directly to the internet without a firewall rule and authentication layer.
- Block outbound C2 traffic at the pfSense boundary during simulations unless specifically testing egress detection.

### Hypervisor Security
- Enable AES-NI in Proxmox BIOS settings for performance and encryption support.
- Assign a dedicated Proxmox admin user; do not use the root account for daily operations.
- Use strong, unique passwords for the Proxmox web interface and all VMs.

### Remote Access
- Use **Tailscale with MFA** for all remote access to the lab — never expose the Proxmox web interface on a public IP.
- If using Cloudflare Tunnel, apply Zero Trust Access policies.
- Regularly audit Tailscale device list and revoke stale devices.

---

## VM Snapshot Policy

- Take a **snapshot of every VM** before and after each attack simulation.
- Label snapshots clearly: `[date]-[vm-name]-[pre/post]-[exercise-name]`.
- Keep at least one clean "baseline" snapshot per VM.
- Revert to the baseline snapshot after each exercise to prevent state contamination between tests.

---

## Credential Hygiene

- Do **not** use real personal passwords in any lab VM.
- Do not reuse lab credentials across lab VMs and production accounts.
- Rotate all lab credentials after completing a simulation that involved credential dumping (e.g., Mimikatz).
- Do **not** commit credentials, API keys, or tokens to this repository. Use `.gitignore` to exclude sensitive files.

---

## Data Handling

- Log files collected during lab exercises may contain sensitive lab network information. Do not commit raw log files to this repository.
- Screenshots uploaded to `screenshots/` must not contain real external IPs, real email addresses, or other personally identifiable information.
- The `.gitignore` in this repository excludes common log file formats and VM disk images.

---

## Attack Simulation Safety Rules

1. **Authorization**: Only simulate attacks within your own lab environment. Obtaining written authorization is required for any testing against systems you do not personally own.
2. **Scope**: All attack simulations are scoped to the victim network (vmbr2) only.
3. **Internet**: Disable or firewall off C2 callbacks to the real internet unless your exercise specifically tests egress monitoring.
4. **Documentation**: Document every technique run, including timestamp, tool used, and target VM. This creates an audit trail and aids in correlating with SIEM alerts.
5. **Cleanup**: After each simulation, check all VMs for residual artifacts (scheduled tasks, registry keys, dropped files) and revert snapshots as needed.

---

## Reporting Vulnerabilities in This Repository

If you discover a security issue in a script, configuration template, or documentation in this repository (for example, hardcoded credentials in an example config), please open a GitHub Issue describing the issue — **do not include the actual secret value** in the issue.
