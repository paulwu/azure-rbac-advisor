# Azure AI Foundry (formerly Azure AI Studio)

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.MachineLearningServices` |
| **Resource Types** | `Microsoft.MachineLearningServices/workspaces` (kind: `Hub` or `Project`) |
| **Azure Portal Category** | AI + Machine Learning > Azure AI Foundry |
| **Landing Zone Context** | AI Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/ai-studio/what-is-ai-studio) |
| **Pricing** | Billed by underlying services (OpenAI, AI Services, Compute) |
| **SLA** | Covered by underlying AML / AI Services SLAs |

## Overview

Azure AI Foundry (previously Azure AI Studio) is a unified platform for building, evaluating, and deploying generative AI applications. It introduces a **Hub + Project** model: a **Hub** provides shared connectivity and resource governance; **Projects** are workspaces for individual teams or applications that inherit hub connectivity. In an AI Landing Zone, the Hub centralizes access to Azure OpenAI, AI Services, AI Search, and compute.

## Hub + Project Model

```
AI Landing Zone Subscription
└── AI Foundry Hub (shared resource)
    ├── Connected Resources: OpenAI, AI Services, AI Search, Key Vault, Storage
    ├── Project A (Team / App 1)
    └── Project B (Team / App 2)
```

## Least-Privilege RBAC Reference

> AI Foundry uses Azure RBAC roles. The Hub and each Project are separate `Microsoft.MachineLearningServices/workspaces` resources with independent role assignments.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create AI Foundry Hub | Resource Group | `Contributor` | Creates a Hub workspace and linked resources (Storage, Key Vault, ACR, App Insights). |
| Create AI Foundry Project | Hub | `Azure AI Developer` (on hub) | Projects inherit hub connectivity. Hub admin can delegate project creation. |
| Connect Azure OpenAI to Hub | Hub | `Contributor` (Hub) + `Cognitive Services Contributor` (OpenAI resource) | Adds OpenAI as a hub connection. |
| Connect AI Search to Hub | Hub | `Contributor` (Hub) + `Search Service Contributor` (Search resource) | |
| Deploy a model in AI Foundry (model catalog) | Project | `Azure AI Developer` | Deploy base or fine-tuned models via the AI Foundry model catalog. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Update hub network settings | Hub | `Contributor` | |
| Modify project settings | Project | `Azure AI Developer` | |
| Update model deployments | Project | `Azure AI Developer` | |
| Update prompt flow | Project | `Azure AI Developer` | |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a Project | Hub | `Contributor` (Hub) | |
| Delete an AI Foundry Hub | Resource Group | `Contributor` | Deletes hub and all projects. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Use AI Foundry (build prompt flows, run evaluations) | Project | `Azure AI Developer` | Core role for AI developers working within a project. |
| Manage hub-level settings and projects | Hub | `Azure AI Administrator` | Hub-level administration including managing connections and project creation. |
| Read project contents (view-only) | Project | `Reader` | View prompt flows, evaluations, and deployments. |
| Submit inference requests via project endpoint | Project | `Azure AI User` | Minimum role for invoking deployed model endpoints within a project. |
| Configure Private Endpoint for Hub | Hub + VNet | `Contributor` + `Network Contributor` | |
| Configure Diagnostic Settings | Hub or Project | `Monitoring Contributor` | |

## AI Foundry Role Summary

| Role | Create Projects | Author Prompt Flows | Deploy Models | Admin Hub | Inference Only |
|---|---|---|---|---|---|
| `Azure AI Administrator` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `Azure AI Developer` | ✅ (in hub) | ✅ | ✅ | ❌ | ✅ |
| `Azure AI User` | ❌ | ❌ | ❌ | ❌ | ✅ |
| `Reader` | ❌ | ❌ | ❌ | ❌ | ❌ |

## Hub Managed Identity — Required Roles on Connected Resources

| Connected Resource | Role Required | Purpose |
|---|---|---|
| Azure OpenAI | `Cognitive Services OpenAI Contributor` | Deploy models, invoke APIs |
| Azure AI Search | `Search Index Data Contributor` | Create/query indexes for RAG |
| Azure Storage | `Storage Blob Data Contributor` | Read/write project data |
| Azure Key Vault | `Key Vault Secrets User` | Read connection secrets |
| Azure Container Registry | `AcrPull` | Pull environment images |

## Notes / Considerations

- **`Azure AI Developer`** is the primary role for generative AI application builders — includes the ability to create projects, author prompt flows, run evaluations, and deploy models.
- **`Azure AI Administrator`** manages the Hub centrally — assigns connections, approves projects, and controls network configuration.
- **Hub vs Project scope**: Connections defined at the Hub level are available to all projects; project-level connections are scoped to that project only.
- **Managed Virtual Network** for the Hub (recommended) creates an isolated network for all hub compute and connections — set to `Allow Internet Outbound` or `Allow Only Approved Outbound` based on policy.
- **Prompt flow** in AI Foundry uses the project's connected compute (serverless or Azure ML compute) — no additional RBAC needed beyond `Azure AI Developer` for compute usage.
- The AI Foundry roles (`Azure AI Administrator`, `Azure AI Developer`, `Azure AI User`) are relatively new as of 2024 — verify they are available in your region/subscription.

## Related Resources

- [Azure OpenAI](./azure-openai.md) — LLM model serving connected to AI Foundry
- [Azure AI Search](./azure-ai-search.md) — RAG knowledge base connected to AI Foundry
- [Azure Machine Learning](./azure-machine-learning.md) — Underlying platform; AI Foundry Hub is an AML workspace kind
- [Azure Key Vault](../workload-landing-zone/azure-key-vault.md) — Storing connection secrets for the Hub
