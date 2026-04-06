# Contributing to SOC Log Analysis Detection Lab

Thank you for your interest in contributing! This project is a community-driven SOC lab and welcomes contributions of all kinds — new attack simulations, detection rules, investigation case studies, documentation improvements, and bug fixes.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Branch Naming](#branch-naming)
- [Commit Messages](#commit-messages)
- [Pull Request Guidelines](#pull-request-guidelines)
- [Directory Conventions](#directory-conventions)
- [Documentation Standards](#documentation-standards)

---

## Code of Conduct

By participating in this project you agree to abide by the [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.

---

## How to Contribute

1. **Fork** the repository and create a branch from `main`.
2. **Make your changes** following the conventions below.
3. **Test** any scripts or detection rules before submitting.
4. **Open a Pull Request** with a clear description of what you changed and why.

---

## Branch Naming

Use descriptive, hyphen-separated branch names with a category prefix:

| Prefix | Use for |
|---|---|
| `feat/` | New features or content |
| `fix/` | Bug fixes or corrections |
| `docs/` | Documentation-only changes |
| `detection/` | New or updated detection rules |
| `sim/` | New attack simulation scenarios |

**Examples:**

```
feat/add-mimikatz-simulation
detection/sigma-rule-lateral-movement
docs/improve-lab-setup-guide
```

---

## Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <short summary>
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples:**

```
feat(detections): add Sigma rule for credential dumping
docs(lab-setup): update pfSense installation steps
fix(screenshots): remove duplicate images
```

---

## Pull Request Guidelines

- Keep PRs focused — one topic per PR.
- Fill in the PR description template completely.
- Reference any related issues with `Closes #<issue-number>`.
- Ensure all Markdown files render correctly before submitting.
- Do **not** include sensitive data (IP addresses, credentials, personal information).

---

## Directory Conventions

| Directory | What belongs here |
|---|---|
| `lab-setup/` | Setup notes per component (one subfolder per VM/tool) |
| `attack-simulations/` | Documented attack scenarios with reproduction steps |
| `detections/` | SIEM queries, Sigma rules, detection write-ups |
| `investigation-cases/` | End-to-end incident investigation walkthroughs |
| `reports/` | Report templates and completed SOC reports |
| `screenshots/` | Screenshots supporting documentation (no raw logs) |
| `docs/` | General documentation and guides |

---

## Documentation Standards

- Use **Markdown** (`.md`) for all documentation files.
- Name files in lowercase with hyphens: `my-file-name.md`.
- Include a top-level `# Heading` in every file.
- Use relative links when referencing other files in the repo.
- Do not commit log files, PCAP files over 5 MB, or binary executables.
