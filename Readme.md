# Kubernetes Infrastructure Project

This repository contains configuration files and automation scripts for deploying a **complete Kubernetes infrastructure** with monitoring, logging, alerting, and deployment tools.

---

## 🚀 Project Overview
This project provides a ready-to-use Kubernetes setup, including:
- **Monitoring & Alerting:** Prometheus, Grafana, cAdvisor, and AlertManager
- **Load Balancing & Ingress:** MetalLB and NGINX Ingress Controller
- **Infrastructure as Code (IaC):** Terraform configurations
- **Automation Scripts:** Bash scripts for cluster setup
- **Application Deployment:** Web application deployment files
- **Utility Scripts:** Python scripts for additional tooling

---

## 📂 Project Structure

### 🔍 **Monitoring & Alerting Stack**
| Directory          | Description |
|-------------------|-------------|
| `Prometheus/`      | Prometheus monitoring system configuration |
| `Grafana/`         | Grafana dashboards and configurations (Enterprise v11.3.0 for ARM64) |
| `cadvisor/`        | Container monitoring (cAdvisor) with `cadvisor-deployment.yaml` |
| `alert/`           | AlertManager configurations including alert rules and deployment specs |

### 🌐 **Networking & Load Balancing**
| Directory          | Description |
|-------------------|-------------|
| `metallb/`        | MetalLB configuration for bare-metal load balancing (includes `ip_pool.yaml`) |
| `nginx/`          | NGINX configuration files |
| `nginx-ingress/`  | NGINX Ingress Controller configuration |

### ⚙️ **Automation & Infrastructure**
| Directory          | Description |
|-------------------|-------------|
| `BashScript/`     | Cluster setup scripts for master and worker nodes |
| `Terraform/`      | Infrastructure as Code (IaC) configurations using Terraform |
| `Python Script/`  | Utility Python scripts |

### 📦 **Application Deployment**
| Directory          | Description |
|-------------------|-------------|
| `webapp/`         | Web application deployment files |

---

## 🛠️ Getting Started

### ✅ **Prerequisites**
Ensure you have the following installed:
- Kubernetes Cluster
- `kubectl` CLI tool
- Terraform (for Infrastructure as Code deployments)
- Python 3.x (for utility scripts)

### 🚀 **Setup Instructions**
#### 1️⃣ Set Up the Master Node
```bash
cd BashScript
./MasterAccount.sh
./MasterSetup.sh
```
#### 2️⃣ Configure Worker Nodes
```bash
cd BashScript
./Worker1Account.sh  # For first worker node
./Worker2Account.sh  # For second worker node
./WorkerSetup.sh
```
#### 3️⃣ Deploy Monitoring Stack
- Apply Prometheus configurations from `Prometheus/`
- Install Grafana from the provided `.deb` package
- Set up AlertManager using files in `alert/`

#### 4️⃣ Set Up Load Balancing & Ingress
- Apply MetalLB configurations from `metallb/`
- Deploy NGINX Ingress Controller

---

Happy coding! 🚀

