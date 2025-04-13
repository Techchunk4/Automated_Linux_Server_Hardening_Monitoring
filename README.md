
# 🚀 Automated Linux Server Hardening & Monitoring

[![GitHub Actions](https://img.shields.io/github/actions/workflow/status/Techchunk4/Automated_Linux_Server_Hardening_Monitoring/ci.yml?branch=main)](https://github.com/Techchunk4/Automated_Linux_Server_Hardening_Monitoring/actions)
[![License](https://img.shields.io/github/license/Techchunk4/Automated_Linux_Server_Hardening_Monitoring)](LICENSE)
[![Shell](https://img.shields.io/badge/Shell-Bash-blue)](https://www.gnu.org/software/bash/)

> **Production-Grade System Hardening** with CIS Benchmarks, Lynis Auditing, and Observability

---

## 📌 Overview

A fully automated Linux server hardening toolkit that enforces **CIS Benchmarks**, performs security audits with **Lynis**, and integrates with **Prometheus/Grafana** for compliance monitoring.  
Designed for **DevOps/SRE teams** to maintain secure, auditable systems at scale.

---

## ✨ Key Features

✅ **CIS Benchmark Compliance** – Auto-remediates 100+ security controls (SSH, filesystem, kernel params)  
✅ **Lynis Integration** – Scheduled audits with scores tracked in Elasticsearch  
✅ **Observability** – Grafana dashboards for real-time compliance status  
✅ **Infrastructure-as-Code** – Deploy via Ansible or standalone Bash  
✅ **GitOps-Ready** – All configurations versioned in Git, CI/CD pipeline included  

---

## 🛠️ Tech Stack

| Category       | Tools                                                |
|----------------|------------------------------------------------------|
| Automation     | Bash, Ansible                                        |
| Security       | Lynis, CIS-CAT, AppArmor                             |
| Monitoring     | Prometheus, Grafana, ELK Stack (for audit logs)      |
| Orchestration  | systemd (timers), cron                               |
| CI/CD          | GitHub Actions (TFLint, ShellCheck)                  |

---

## ⚡ Quick Start

### Prerequisites
- Linux server (Ubuntu 22.04 / RHEL 9 recommended)
- `sudo` privileges
- Docker (optional, for ELK stack)

### 1. Clone & Deploy

```bash
git clone https://github.com/Techchunk4/Automated_Linux_Server_Hardening_Monitoring
cd Automated_Linux_Server_Hardening_Monitoring

# Run the hardening script (Bash)
sudo ./scripts/harden.sh --level=2  # CIS Level 2 hardening

# Or deploy with Ansible (for multi-server setups)
ansible-playbook playbooks/harden.yml -i inventory.ini
```

### 2. Verify Compliance

```bash
# Run Lynis audit
sudo ./audit/run_lynis.sh

# Check Prometheus metrics (after setup)
curl http://localhost:9090/metrics | grep "cis_benchmark"
```

---

## 📂 Directory Structure

```bash
.
├── ansible/                   # Ansible playbooks for large-scale deployment
│   ├── roles/
│   └── inventory.ini
├── audit/                     # Security auditing tools
│   ├── run_lynis.sh
│   └── cis_controls.yml
├── monitoring/                # Observability configs
│   ├── prometheus/
│   └── grafana/dashboards/
├── scripts/
│   ├── harden.sh              # Main hardening script
│   └── kernel_tuner.sh
├── .github/workflows/
│   └── ci.yml                 # ShellCheck + Lynis test
└── README.md
```

---

## 📊 Monitoring & Reporting

### 🧭 Grafana Dashboard
Track real-time compliance scores  
📢 Alerts via Slack/Email if benchmarks degrade

### 📦 ELK Stack Integration

```bash
# Ship Lynis logs to Elasticsearch (optional)
sudo ./audit/ship_logs.sh --target=elk
```

---

## 🤝 Contribution Guidelines

- Fork → Patch → Push → Pull Request (Use Conventional Commits)
- **Testing:**
  - Run `shellcheck` on scripts
  - Validate with `lynis --auditor "Abdelkader"`
- **Docs:** Update `docs/adr/` for major changes (Architecture Decision Records)

---

## 📜 License

**MIT © 2025 Abdelkader** — DevOps/SRE Portfolio

---

## 💡 Why This Stands Out in 2025

- ✅ **Production-Ready**: Designed for enterprise-scale deployments  
- 🔍 **Observability-First**: Metrics + logs for audit trails  
- 🧩 **GitOps Compliance**: All configs are version-controlled  