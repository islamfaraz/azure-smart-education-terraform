# 📚 Azure Smart Education Hub

> **An AI-powered education platform enabling personalized learning, real-time collaboration, and intelligent content discovery — bridging the education gap for underserved communities worldwide.**

[![Build Status](https://dev.azure.com/your-org/smart-education/_apis/build/status/smart-education-ci?branchName=main)](https://dev.azure.com/your-org/smart-education/_build)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![IaC: Terraform](https://img.shields.io/badge/IaC-Terraform-purple.svg)](https://www.terraform.io/)

---

## 🌍 Why This Project?

Over 260 million children worldwide lack access to quality education. This platform provides:

- **AI-Powered Content Translation** — Real-time translation of courses into 100+ languages via Cognitive Services
- **Intelligent Course Search** — Full-text semantic search across courses, materials, and community Q&A
- **Real-Time Virtual Classrooms** — Live collaboration via SignalR (whiteboard, chat, screen sharing)
- **Adaptive Learning Paths** — AI-driven personalized learning recommendations
- **Global CDN Delivery** — Course content delivered at low-latency worldwide
- **Session Caching** — Lightning-fast content loading via Redis Cache

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                       Azure Smart Education Hub                              │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌───────────┐     ┌──────────────┐     ┌────────────────┐                   │
│  │  Students  │────▶│  Azure CDN   │────▶│  App Service   │                  │
│  │  Teachers  │     │  (Global     │     │  (.NET 8)      │                  │
│  │  Admins    │     │   Edge)      │     │  Linux P1v3    │                  │
│  └───────────┘     └──────────────┘     └───────┬────────┘                  │
│                                                  │                           │
│                           ┌──────────────────────┼──────────────┐            │
│                           │         │            │              │            │
│                           ▼         ▼            ▼              ▼            │
│                  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│                  │ Azure    │ │ Azure    │ │ Azure    │ │ Azure    │        │
│                  │ SQL DB   │ │ Redis    │ │ Cognitive│ │ Search   │        │
│                  │ (Data)   │ │ (Cache)  │ │ Services │ │ (Index)  │        │
│                  └──────────┘ └──────────┘ └──────────┘ └──────────┘        │
│                                                                              │
│                  ┌──────────────────────┐                                    │
│                  │  Azure SignalR       │ ◄── Real-time Collaboration        │
│                  │  (Live Classrooms)   │     Whiteboard, Chat, Notify       │
│                  └──────────────────────┘                                    │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
Student / Teacher
       │
       ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Azure CDN   │────▶│  App Service │────▶│  Azure SQL   │
│  (Cached     │     │  (API +      │     │  (Courses,   │
│   Content)   │     │   Web App)   │     │   Progress,  │
└──────────────┘     └──────┬───────┘     │   Users)     │
                            │             └──────────────┘
                ┌───────────┼───────────┐
                │           │           │
                ▼           ▼           ▼
       ┌──────────┐ ┌──────────┐ ┌──────────┐
       │ Cognitive │ │  Redis   │ │  Search  │
       │ Services  │ │  Cache   │ │  Service │
       │ (AI/NLP)  │ │ (Session)│ │ (Courses)│
       └──────────┘ └──────────┘ └──────────┘
                                      │
              ┌───────────────────────┘
              ▼
       ┌──────────────┐
       │   SignalR     │ ◄── WebSocket connections
       │   (Real-time  │     for live classrooms
       │    Events)    │
       └──────────────┘
```

---

## 📁 Repository Structure

```
azure-smart-education-terraform/
├── 📄 README.md
├── infra/
│   ├── providers.tf                        # Azure provider + remote state config
│   ├── variables.tf                        # Input variables
│   ├── main.tf                             # Orchestrator — all modules
│   ├── outputs.tf                          # Stack outputs
│   ├── environments/
│   │   ├── dev.tfvars                      # Dev environment values
│   │   ├── staging.tfvars                  # Staging environment values
│   │   └── prod.tfvars                     # Production environment values
│   └── modules/
│       ├── appservice/main.tf              # App Service + autoscale
│       ├── cdn/main.tf                     # CDN profile + endpoint
│       ├── cognitive/main.tf               # Cognitive Services (AI)
│       ├── redis/main.tf                   # Redis Cache
│       ├── search/main.tf                  # Cognitive Search
│       ├── signalr/main.tf                 # SignalR Service
│       └── sql/main.tf                     # SQL Server + Database
└── pipelines/
    ├── ci-build.yaml                       # CI: fmt, validate, plan, upload
    └── cd-release.yaml                     # CD: download, apply per env
```

---

## 🔧 Infrastructure Components

| Resource | Purpose | DEV SKU | PROD SKU |
|----------|---------|---------|----------|
| **App Service** | Web App + API | B1, Linux | P1v3, Autoscale 2-10 |
| **Azure SQL** | Courses, users, progress | Basic, 2 GB | S2, 50 GB, 35-day backup |
| **Cognitive Services** | Translation, text analytics | F0 (Free) | S0 (Standard) |
| **Redis Cache** | Session + content cache | Basic C0 | Premium P1 |
| **Cognitive Search** | Course full-text search | Free | Standard, 2 replicas |
| **SignalR** | Real-time classrooms | Free F1 | Standard S1, capacity 2 |
| **CDN** | Global content delivery | Standard | Standard, HTTPS enforced |

---

## 🗄️ Terraform State Management

State is stored remotely on Azure Storage Account:

```
Storage Account:  stterraformstate
Container:        tfstate
State Files:
  ├── smart-education-dev.tfstate
  ├── smart-education-staging.tfstate
  └── smart-education-prod.tfstate
```

### Setup State Backend

```bash
# Create the state storage (one-time setup)
az group create --name rg-terraform-state --location eastus2

az storage account create \
  --name stterraformstate \
  --resource-group rg-terraform-state \
  --sku Standard_LRS \
  --encryption-services blob

az storage container create \
  --name tfstate \
  --account-name stterraformstate
```

---

## 🚀 CI/CD Pipeline

### Build Pipeline (CI) — `ci-build.yaml`

```
┌────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────────┐
│  Push  │──▶│  Format  │──▶│  Init &  │──▶│  Plan    │──▶│  Upload to   │
│  main  │   │  Check   │   │ Validate │   │  3 Envs  │   │  Storage     │
└────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────────┘
```

### Release Pipeline (CD) — `cd-release.yaml`

```
┌───────────┐     ┌───────────────┐     ┌───────────────┐     ┌───────────────┐
│  CI Build │────▶│  TF Apply     │────▶│  TF Apply     │────▶│  TF Apply     │
│  Trigger  │     │  DEV (auto)   │     │  STAGING      │     │  PROD         │
│           │     │               │     │  (auto)       │     │  (approval)   │
└───────────┘     └───────────────┘     └───────────────┘     └───────────────┘
                        │                      │                      │
                  Download from          Download from          Download from
                  Azure Storage          Azure Storage          Azure Storage
                        │                      │                      │
                  tf init + apply        tf init + apply        tf plan + apply
                  (dev.tfstate)          (staging.tfstate)      (prod.tfstate)
```

---

## 🛠️ Getting Started

### Prerequisites

- Terraform ≥ 1.5.0
- Azure CLI ≥ 2.50
- Azure subscription
- Azure DevOps organization

### Local Deployment

```bash
cd infra

# Initialize with remote state
terraform init

# Plan for dev
terraform plan -var-file="environments/dev.tfvars"

# Apply to dev
terraform apply -var-file="environments/dev.tfvars"

# Destroy dev (when done)
terraform destroy -var-file="environments/dev.tfvars"
```

---

## 🔐 Security

- **TLS 1.2 minimum** on all services
- **HTTPS only** enforced on App Service + CDN
- **FTP disabled** on App Service
- **Azure AD authentication** on SQL Server
- **Managed Identity** on App Service
- **Non-SSL port disabled** on Redis
- **Sensitive outputs** marked in Terraform

---

## 📝 License

MIT License — see [LICENSE](LICENSE) for details.
