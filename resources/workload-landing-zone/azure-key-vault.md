# Azure Key Vault (Workload)

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.KeyVault` |
| **Resource Type** | `Microsoft.KeyVault/vaults` |
| **Azure Portal Category** | Key Vault |
| **Landing Zone Context** | Workload Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/key-vault/general/overview) |
| **Pricing** | [Key Vault Pricing](https://azure.microsoft.com/pricing/details/key-vault/) |
| **SLA** | [99.99%](https://azure.microsoft.com/support/legal/sla/key-vault/) |

## Overview

In a Workload Landing Zone, each application typically has its own dedicated Key Vault for storing application secrets, API keys, connection strings, TLS certificates, and encryption keys. This provides workload isolation — a compromise in one application's vault does not affect others.

> **Note**: For platform-level Key Vault usage (e.g., CMK for platform resources, shared TLS certificates), see [Platform Landing Zone — Key Vault](../platform-landing-zone/azure-key-vault.md). The RBAC model is identical; this file emphasizes workload-specific patterns.

## Least-Privilege RBAC Reference

> This guide uses the **Azure RBAC** authorization model (recommended over legacy Vault Access Policies).

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a Key Vault | Resource Group | `Key Vault Contributor` | Management-plane only. Does NOT grant access to vault contents. |
| Add a secret (e.g., connection string) | Key Vault | `Key Vault Secrets Officer` | |
| Add a key | Key Vault | `Key Vault Crypto Officer` | |
| Add a certificate | Key Vault | `Key Vault Certificates Officer` | |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Update vault network rules / firewall | Key Vault | `Key Vault Contributor` | Management-plane setting. |
| Rotate a secret (create new version) | Key Vault | `Key Vault Secrets Officer` | Configure auto-rotation via Event Grid + Azure Functions or built-in rotation. |
| Rotate a key | Key Vault | `Key Vault Crypto Officer` | Built-in rotation policy is configurable within Key Vault. |
| Update certificate policy | Key Vault | `Key Vault Certificates Officer` | |
| Enable/disable a secret version | Key Vault | `Key Vault Secrets Officer` | |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a secret version | Key Vault | `Key Vault Secrets Officer` | Soft-deleted version is recoverable within the retention period. |
| Purge a soft-deleted secret | Key Vault | `Key Vault Secrets Officer` | Permanently removes the secret version. |
| Delete a key | Key Vault | `Key Vault Crypto Officer` | |
| Delete a certificate | Key Vault | `Key Vault Certificates Officer` | |
| Delete the Key Vault | Resource Group | `Key Vault Contributor` | Soft-deleted vault recoverable within retention period. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Read a secret (application access) | Key Vault | `Key Vault Secrets User` | Minimum role for reading secret values. Use on the app's managed identity. |
| Use a key for crypto operations (app) | Key Vault | `Key Vault Crypto User` | Encrypt/decrypt/sign/verify — does NOT allow key management. |
| Wrap/unwrap key (CMK for services) | Key Vault | `Key Vault Crypto Service Encryption User` | Grant to managed identities of services using CMK (SQL, Storage, etc.). |
| Configure Diagnostic Settings | Key Vault | `Key Vault Contributor` + `Monitoring Contributor` | Enable audit logging of all key/secret/certificate access. |
| Grant role assignments on vault | Key Vault | `Owner` or `User Access Administrator` | Required for delegating data-plane roles. |

## Workload Application Pattern

Typical role assignments for a workload application:

| Principal | Role | Scope | Purpose |
|---|---|---|---|
| App managed identity | `Key Vault Secrets User` | Key Vault | Read application secrets |
| App managed identity | `Key Vault Crypto User` | Key Vault | Encryption operations (if needed) |
| Developer (break-glass) | `Key Vault Secrets Officer` | Key Vault | Manage secrets during development |
| CI/CD Service Principal | `Key Vault Secrets Officer` | Key Vault | Deploy/rotate secrets via pipeline |
| Security team | `Key Vault Reader` | Key Vault | Audit vault metadata |

## Data Plane Role Summary

| Role | Secrets | Keys | Certificates |
|---|---|---|---|
| `Key Vault Administrator` | Full | Full | Full |
| `Key Vault Secrets Officer` | Full CRUD | — | — |
| `Key Vault Secrets User` | Read value only | — | — |
| `Key Vault Crypto Officer` | — | Full CRUD + Use | — |
| `Key Vault Crypto User` | — | Use (no management) | — |
| `Key Vault Crypto Service Encryption User` | — | Wrap/Unwrap only | — |
| `Key Vault Certificates Officer` | — | — | Full CRUD |
| `Key Vault Reader` | List/read metadata | List/read metadata | List/read metadata |

## Notes / Considerations

- **One Key Vault per workload/application** is the recommended pattern — provides blast radius containment and clear ownership.
- **Soft-delete** (14–90 day retention) and **Purge Protection** (prevents purge during retention period) should always be enabled in production.
- **Key Vault Firewall** should be configured to allow access only from the workload's VNet via Private Endpoint or service endpoint.
- **Secret rotation** should be automated using Event Grid notifications + Azure Functions or the built-in Key Vault rotation feature for supported services (Storage, SQL).
- Application code should use **Key Vault References** in App Service/Functions or the **Azure SDK DefaultAzureCredential** pattern — never store vault credentials in code.

## Related Resources

- [App Service](./app-service.md) — Key Vault References for app settings
- [Azure SQL Database](./azure-sql-database.md) — CMK for TDE
- [Azure Storage Account](./azure-storage-account.md) — CMK for storage encryption
- [Private DNS Zones](../platform-landing-zone/private-dns-zones.md) — `privatelink.vaultcore.azure.net`
