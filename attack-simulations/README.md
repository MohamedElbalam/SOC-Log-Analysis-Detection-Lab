# Attack Simulations

This directory documents the attack scenarios executed in the lab. Each simulation includes the objective, tools used, reproduction steps, and expected log artifacts.

---

## Structure

Each attack scenario lives in its own subfolder or Markdown file following this template:

```
attack-simulations/
└── <attack-name>/
    ├── README.md        ← Scenario description and steps
    └── screenshots/     ← Supporting evidence
```

---

## Scenario Template

When adding a new attack simulation, include the following sections:

### Objective
What adversary behavior is being simulated? (Reference MITRE ATT&CK technique if applicable.)

### Tools / Commands
List the tools and key commands used.

### Reproduction Steps
Numbered, step-by-step instructions to reproduce the attack.

### Expected Log Artifacts
What events or IOCs should appear in the SIEM?

### Detection Reference
Link to the corresponding detection rule in [`detections/`](../detections/).

---

## Planned Simulations

| # | Scenario | MITRE Technique | Status |
|---|---|---|---|
| 1 | Credential dumping with Mimikatz | T1003.001 | Planned |
| 2 | PowerShell encoded command execution | T1059.001 | Planned |
| 3 | Process injection | T1055 | Planned |
| 4 | Lateral movement via PsExec | T1021.002 | Planned |
| 5 | C2 beacon simulation | T1071 | Planned |

---

> **Note:** All simulations are performed on isolated lab VMs. Never run these techniques on systems you do not own or have explicit permission to test.
