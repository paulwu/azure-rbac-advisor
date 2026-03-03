# Azure Bot Service

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.BotService` |
| **Resource Types** | `Microsoft.BotService/botServices`, `Microsoft.BotService/botServices/channels` |
| **Azure Portal Category** | AI + Machine Learning > Bot Services |
| **Landing Zone Context** | AI Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/bot-service/bot-service-overview) |
| **Pricing** | [Bot Service Pricing](https://azure.microsoft.com/pricing/details/bot-service/) |
| **SLA** | [99.9%](https://azure.microsoft.com/support/legal/sla/bot-service/) |

## Overview

Azure Bot Service provides a managed framework for building, deploying, and managing conversational AI bots. In an AI Landing Zone, bots connect Azure OpenAI or AI Services to end-user channels (Teams, Web Chat, Direct Line, Telephony). The bot logic is typically hosted on Azure App Service or Azure Functions.

## Least-Privilege RBAC Reference

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a Bot Service resource | Resource Group | `Contributor` | No Bot Service-specific management-plane role exists. |
| Create / register a channel (Teams, Web Chat, etc.) | Bot Service | `Contributor` | Channels are child resources of the bot. |
| Register bot application (Entra ID app registration) | Entra ID | **Application Administrator** (Entra ID role) | Bot requires an Entra ID app registration for authentication. This is an Entra ID admin action. |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Update bot settings (display name, endpoint URL) | Bot Service | `Contributor` | The messaging endpoint URL points to the App Service/Function hosting the bot logic. |
| Update channel configuration | Bot Service | `Contributor` | |
| Update bot application credentials | Bot Service + Entra ID | `Contributor` + Application Administrator | Rotating app secrets requires Entra ID admin role. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a channel | Bot Service | `Contributor` | |
| Delete a Bot Service | Resource Group | `Contributor` | The Entra ID app registration is not automatically deleted — clean up separately. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Configure Direct Line / Web Chat secret | Bot Service | `Contributor` | |
| Configure Diagnostic Settings | Bot Service | `Monitoring Contributor` | |
| Configure bot endpoint authentication | App Service | `Website Contributor` | The hosting layer (App Service/Functions) is configured separately. |
| View bot analytics | Bot Service | `Reader` | |

## Notes / Considerations

- **`Contributor`** scoped to the resource group is the minimum for all Bot Service operations — no purpose-built role exists.
- The **Entra ID App Registration** for the bot requires **Application Administrator** (Entra ID role) or **Cloud Application Administrator** — this is not an Azure RBAC operation.
- **Bot logic** is hosted separately (App Service, Functions) and requires its own RBAC configuration — see [App Service](../workload-landing-zone/app-service.md).
- **Teams bot deployment** requires additional Microsoft Teams admin consent for the bot application.
- For **production bots**, enable **Application Insights** and configure alerts for failed message deliveries and latency spikes.

## Related Resources

- [Azure OpenAI](./azure-openai.md) — LLM backend for conversational AI
- [App Service](../workload-landing-zone/app-service.md) — Hosting for bot logic
- [Azure AI Services](./azure-ai-services.md) — Language Understanding, Speech for bot NLU
