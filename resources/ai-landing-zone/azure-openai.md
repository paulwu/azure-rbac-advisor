# Azure OpenAI Service

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.CognitiveServices` |
| **Resource Type** | `Microsoft.CognitiveServices/accounts` (kind: `OpenAI`) |
| **Azure Portal Category** | AI + Machine Learning > Azure OpenAI |
| **Landing Zone Context** | AI Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/ai-services/openai/overview) |
| **Pricing** | [Azure OpenAI Pricing](https://azure.microsoft.com/pricing/details/cognitive-services/openai-service/) |
| **SLA** | [99.9%](https://azure.microsoft.com/support/legal/sla/cognitive-services/) |

## Overview

Azure OpenAI Service provides access to OpenAI's powerful language models (GPT-4, GPT-4o, DALL-E, Whisper, text-embedding) via REST APIs with Azure enterprise security, compliance, and networking controls. In an AI Landing Zone it is the core model serving layer for generative AI applications.

## Least-Privilege RBAC Reference

> Azure OpenAI separates **management plane** (deploy models, configure resource) from **data plane** (make API inference calls). Use dedicated data-plane roles for application identities.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create Azure OpenAI Resource | Resource Group | `Cognitive Services Contributor` | Access requires approved subscription (request via Azure portal). |
| Deploy a model (GPT-4, embeddings, etc.) | OpenAI Resource | `Cognitive Services OpenAI Contributor` | Model deployments are managed within the resource. Requires quota allocation. |
| Create a fine-tuned model | OpenAI Resource | `Cognitive Services OpenAI Contributor` | Fine-tuning uploads training data and creates a custom model. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Modify model deployment (scale, version upgrade) | OpenAI Resource | `Cognitive Services OpenAI Contributor` | |
| Update content filter policy | OpenAI Resource | `Cognitive Services OpenAI Contributor` | Content filters are configured per deployment. |
| Modify resource network settings | OpenAI Resource | `Cognitive Services Contributor` | |
| Update fine-tuning job | OpenAI Resource | `Cognitive Services OpenAI Contributor` | |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a model deployment | OpenAI Resource | `Cognitive Services OpenAI Contributor` | Frees up quota capacity. |
| Delete fine-tuned model | OpenAI Resource | `Cognitive Services OpenAI Contributor` | |
| Delete Azure OpenAI Resource | Resource Group | `Cognitive Services Contributor` | |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Make inference API calls (chat, completions, embeddings) | OpenAI Resource | `Cognitive Services OpenAI User` | Minimum role for application inference. Allows API calls but not management. |
| Make inference API calls (including fine-tuned models) | OpenAI Resource | `Cognitive Services OpenAI User` | |
| Manage deployments + make API calls | OpenAI Resource | `Cognitive Services OpenAI Contributor` | Combined role for MLOps pipelines that both deploy and test models. |
| Read resource keys (API key auth) | OpenAI Resource | `Cognitive Services Contributor` | Listing keys grants equivalent data plane access — use Entra ID auth instead. |
| Configure Private Endpoint | OpenAI Resource + VNet | `Cognitive Services Contributor` + `Network Contributor` | Disable public access in production AI Landing Zones. |
| Configure Diagnostic Settings | OpenAI Resource | `Monitoring Contributor` | Captures API request/response metadata (not content). |
| Configure content filters | OpenAI Resource | `Cognitive Services OpenAI Contributor` | |

## Data Plane Role Summary

| Role | Inference API Calls | Deploy Models | Fine-Tune Models | Manage Content Filters |
|---|---|---|---|---|
| `Cognitive Services OpenAI Contributor` | ✅ | ✅ | ✅ | ✅ |
| `Cognitive Services OpenAI User` | ✅ | ❌ | ❌ | ❌ |

## Common Assignment Patterns

| Principal | Role | Scope | Purpose |
|---|---|---|---|
| Application managed identity | `Cognitive Services OpenAI User` | OpenAI Resource | Application inference (chat, embeddings) |
| AI Platform team / MLOps SP | `Cognitive Services OpenAI Contributor` | OpenAI Resource | Deploy and manage model versions |
| Developer (portal access) | `Cognitive Services OpenAI Contributor` | OpenAI Resource | Use Azure OpenAI Studio for testing |
| Monitoring identity | `Reader` | OpenAI Resource | View deployment configuration and metrics |

## Notes / Considerations

- **Disable API key authentication** (`disableLocalAuth: true`) and require Entra ID token auth (`Authorization: Bearer <token>`) for all production clients — eliminates key rotation risk.
- **`Cognitive Services OpenAI User`** is the minimum role for application inference — never use `Contributor` or `Owner` for application identities.
- **Private Endpoint** should be configured in AI Landing Zones with public network access disabled to prevent unauthorized API access.
- **Content filters** (Azure AI Content Safety) are applied per deployment — configure to block harmful content categories based on compliance requirements.
- **Token quotas** (TPM — Tokens Per Minute) are managed at the model deployment level by `Cognitive Services OpenAI Contributor`.
- **Azure OpenAI On Your Data** (RAG with Azure AI Search) requires the OpenAI resource's managed identity to have `Search Index Data Reader` on the AI Search resource.
- Models are deployed at the resource level (not separately licensed) — quota is managed per subscription/region.

## Related Resources

- [Azure AI Search](./azure-ai-search.md) — RAG (Retrieval Augmented Generation) with OpenAI
- [Grounding with Bing Search](./grounding-with-bing-search.md) — Web grounding for real-time information in LLM responses
- [Azure AI Document Intelligence](./azure-ai-document-intelligence.md) — Document extraction for RAG pipelines
- [Azure Machine Learning](./azure-machine-learning.md) — Fine-tuning orchestration
- [Private DNS Zones](../platform-landing-zone/private-dns-zones.md) — `privatelink.openai.azure.com`
- [Azure Key Vault](../workload-landing-zone/azure-key-vault.md) — Storing OpenAI endpoint URLs and fallback keys
