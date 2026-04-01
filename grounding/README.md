# Azure Landing Zone RBAC Reference

This directory contains per-resource RBAC reference cards for the four Azure Landing Zone archetypes. Each file documents the **least-privileged role(s)** required to Create, Edit, Delete, and Configure the resource, plus granular sub-resource breakdowns where applicable (e.g., Azure Storage Blob vs. File vs. Queue vs. Table).

## Structure

```
grounding/
├── platform-landing-zone/    # Core platform services (managed by Platform/Cloud team)
├── workload-landing-zone/    # Application workload services (managed by App teams)
├── data-landing-zone/        # Data platform services (managed by Data/Analytics teams)
└── ai-landing-zone/          # AI/ML services (managed by AI/Data Science teams)
```

## Landing Zone Descriptions

| Landing Zone | Purpose | Typical Owner |
|---|---|---|
| **Platform** | Shared connectivity, identity, governance, and management services | Cloud Platform / Ops team |
| **Workload** | Application-specific infrastructure within a governed subscription | Application / Dev team |
| **Data** | Data ingestion, processing, storage, and governance services | Data Engineering / Analytics team |
| **AI** | Machine learning, generative AI, and cognitive services | AI / Data Science team |

## How to Read a Resource File

Each resource file follows this structure:

- **Resource Metadata** — Azure resource type, provider, documentation links
- **Overview** — Short description of the resource's role in the landing zone
- **Least-Privilege RBAC Reference** — Tables for Create / Edit / Delete / Configure operations
  - 🟢 **Create** — Permissions needed to provision the resource
  - 🟡 **Edit / Update** — Permissions needed to modify the resource
  - 🔴 **Delete** — Permissions needed to remove the resource
  - ⚙️ **Configure** — Permissions needed for operational configuration (settings, policies, integration)
- **Sub-Resource Permissions** — Where applicable (e.g., Storage blobs vs. files vs. queues)
- **Notes / Considerations** — Gotchas, scope recommendations, Managed Identity patterns

## General Principles

1. **Prefer resource-scoped assignments** over subscription or management-group scope whenever the workload boundary is known.
2. **Separate management plane from data plane** — e.g., `Storage Account Contributor` manages the account; `Storage Blob Data Contributor` manages the data.
3. **Avoid `Owner` and `Contributor` at broad scopes** — use purpose-built roles (e.g., `Key Vault Secrets Officer`, `AcrPush`) wherever they exist.
4. **Use Managed Identities** for service-to-service access instead of credentials or shared keys.
5. **Document custom role justification** when no built-in role satisfies least-privilege requirements.

## Role Reference Quick Links

- [Azure built-in roles](https://learn.microsoft.com/azure/role-based-access-control/built-in-roles)
- [Azure RBAC best practices](https://learn.microsoft.com/azure/role-based-access-control/best-practices)
- [Cloud Adoption Framework — Azure Landing Zones](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/)
