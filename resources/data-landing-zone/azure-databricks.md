# Azure Databricks

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.Databricks` |
| **Resource Type** | `Microsoft.Databricks/workspaces` |
| **Azure Portal Category** | Analytics > Azure Databricks |
| **Landing Zone Context** | Data Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/databricks/) |
| **Pricing** | [Databricks Pricing](https://azure.microsoft.com/pricing/details/databricks/) |
| **SLA** | [99.95%](https://azure.microsoft.com/support/legal/sla/databricks/) |

## Overview

Azure Databricks is a managed Apache Spark analytics platform. In a Data Landing Zone it is used for large-scale data transformation, machine learning, and data engineering workloads. Databricks has its own workspace-level RBAC system separate from Azure RBAC.

> **Important**: Azure RBAC controls workspace provisioning. Databricks workspace operations (notebooks, clusters, jobs) use **Databricks RBAC** (workspace-level access control lists managed within the Databricks platform).

## Least-Privilege RBAC Reference

---

### Azure RBAC — Workspace Management

#### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create Databricks Workspace | Resource Group | `Contributor` | Creates the workspace and the managed resource group (`databricks-rg-*`). No Databricks-specific Azure RBAC role exists for workspace creation. |
| Deploy VNet-injected workspace | Resource Group + VNet | `Contributor` + `Network Contributor` | VNet injection requires delegation of the VNet subnets to Databricks. |

#### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Upgrade workspace tier (Standard → Premium) | Workspace resource | `Contributor` | Premium tier required for Unity Catalog, SCIM, and advanced security features. |
| Modify workspace network settings | Workspace resource | `Contributor` | Some settings cannot be changed after creation. |
| Enable Private Link (No Public IP / NPIP) | Workspace resource | `Contributor` + `Network Contributor` | |

#### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete Databricks Workspace | Resource Group | `Contributor` | Also deletes the managed resource group. |

#### ⚙️ Configure (Azure RBAC)

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Access workspace (any user) | Workspace resource | `Contributor` or `Reader` | Both grant access to open the workspace URL; Databricks RBAC controls what they can do inside. |
| Configure Diagnostic Settings | Workspace resource | `Monitoring Contributor` | Sends workspace audit logs to Log Analytics. |
| Configure Customer-Managed Keys | Workspace + Key Vault | `Contributor` + `Key Vault Crypto Service Encryption User` | CMK for workspace storage encryption. |

---

### Databricks RBAC — Workspace Operations

> Databricks RBAC is managed within the Databricks workspace. The following are the primary Databricks permission levels:

#### Cluster Permissions

| Permission | Can Do |
|---|---|
| `Can Manage` | Create, edit, delete, start, terminate cluster; manage permissions |
| `Can Restart` | Start and restart an existing cluster |
| `Can Attach To` | Attach notebooks and run code on the cluster |

#### Notebook Permissions

| Permission | Can Do |
|---|---|
| `Can Manage` | Read, edit, delete, run, change permissions |
| `Can Run` | Run (but not edit) the notebook |
| `Can Edit` | Read and edit the notebook |
| `Can Read` | Read only |

#### Job Permissions

| Permission | Can Do |
|---|---|
| `Can Manage` | View, edit, delete, trigger job; manage permissions |
| `Can Manage Run` | Trigger and cancel job runs; view run results |
| `Can View` | View job definition and run results |

#### SQL Warehouse Permissions

| Permission | Can Do |
|---|---|
| `Can Manage` | Start, stop, edit, delete warehouse; manage permissions |
| `Can Monitor` | View warehouse metrics and queries |
| `Can Use` | Execute queries against the warehouse |

#### Unity Catalog (Metastore) — Recommended for Production

| Unity Catalog Privilege | Scope | Description |
|---|---|---|
| `USE CATALOG` | Catalog | Required to use any object in the catalog |
| `USE SCHEMA` | Schema | Required to use any object in the schema |
| `SELECT` | Table / View | Read table data |
| `MODIFY` | Table | Insert, update, delete table data |
| `CREATE TABLE` | Schema | Create new tables |
| `ALL PRIVILEGES` | Any object | Full access — avoid for application identities |

---

## Databricks Workspace Admin vs User

| Role | Manage Workspace Settings | Create Clusters | Run Notebooks | Manage Users |
|---|---|---|---|---|
| Workspace Admin | ✅ | ✅ | ✅ | ✅ |
| Regular User | ❌ | With cluster permission | With notebook permission | ❌ |

## Notes / Considerations

- **Azure RBAC `Contributor`** on the workspace only grants the ability to open the workspace URL — all workspace actions are controlled by Databricks RBAC.
- **Unity Catalog** (Premium tier) is the recommended governance layer for data access control, replacing legacy Hive Metastore. Assign catalog/schema/table-level privileges rather than giving users direct storage access.
- **Databricks Workload Identity** via Azure Managed Identity or Service Principal is the recommended pattern for accessing ADLS Gen2 — configure via **Instance Profiles** (AWS) or **Azure Service Principal** / **Managed Identity** credentials in Databricks Secrets.
- **Databricks Secrets** (backed by Azure Key Vault via Secret Scope) is the recommended way to store credentials — never hardcode credentials in notebooks.
- **VNet injection** is strongly recommended in Data Landing Zones for network isolation and Private Endpoint connectivity to data sources.
- Disable **cluster creation for regular users** — require approval workflow or pre-defined cluster policies for cost control.

## Related Resources

- [Azure Data Lake Storage Gen2](./azure-data-lake-storage-gen2.md) — Primary data source for Databricks
- [Azure Key Vault](../workload-landing-zone/azure-key-vault.md) — Databricks Secret Scope backend
- [Microsoft Purview](./microsoft-purview.md) — Lineage and catalog integration with Databricks
