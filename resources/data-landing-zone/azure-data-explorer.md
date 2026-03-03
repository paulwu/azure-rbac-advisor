# Azure Data Explorer (Kusto)

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.Kusto` |
| **Resource Types** | `Microsoft.Kusto/clusters`, `Microsoft.Kusto/clusters/databases` |
| **Azure Portal Category** | Analytics > Azure Data Explorer Clusters |
| **Landing Zone Context** | Data Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/data-explorer/data-explorer-overview) |
| **Pricing** | [ADX Pricing](https://azure.microsoft.com/pricing/details/data-explorer/) |
| **SLA** | [99.9%](https://azure.microsoft.com/support/legal/sla/azure-data-explorer/) |

## Overview

Azure Data Explorer (ADX / Kusto) is a fast, fully managed analytics service for real-time analysis of large volumes of data — log analytics, time-series, IoT telemetry, and security data. In a Data Landing Zone it is used for interactive exploration of high-volume telemetry and log data using Kusto Query Language (KQL).

## Least-Privilege RBAC Reference

> ADX has two RBAC layers: **Azure RBAC** (cluster/database provisioning) and **Kusto RBAC** (database and table-level access managed within ADX itself).

---

### Azure RBAC — Cluster Management

#### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create ADX Cluster | Resource Group | `Contributor` | No ADX-specific management-plane role. |
| Create a Database | Cluster | `Contributor` | `Microsoft.Kusto/clusters/databases/write`. |

#### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Scale cluster (add/remove instances) | Cluster | `Contributor` | |
| Upgrade cluster SKU | Cluster | `Contributor` | |
| Configure streaming ingestion | Cluster | `Contributor` | |
| Enable Purview integration | Cluster | `Contributor` | |

#### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete Database | Cluster | `Contributor` | All data in the database is deleted. |
| Delete Cluster | Resource Group | `Contributor` | |

#### ⚙️ Configure (Azure RBAC)

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Configure Private Endpoint | Cluster + VNet | `Contributor` + `Network Contributor` | |
| Configure Diagnostic Settings | Cluster | `Monitoring Contributor` | |
| Configure Managed Identity | Cluster | `Contributor` | For external storage ingestion. |

---

### Kusto RBAC — Database Operations

> Kusto RBAC roles are assigned within ADX using `.add` commands or the Azure portal. Principal types: Entra ID users, groups, or service principals.

#### Database-Level Roles

| Kusto Role | Permissions |
|---|---|
| `AllDatabasesAdmin` | Full admin over all databases in the cluster (cluster-level role) |
| `AllDatabasesViewer` | Read all databases in the cluster (cluster-level role) |
| `Admin` | Full control over the database (create tables, manage policies, ingest, query) |
| `User` | Create tables, run queries, ingest data |
| `Ingestor` | Ingest data into existing tables only |
| `Viewer` | Query (read) all tables in the database |
| `Monitor` | View database metadata and diagnostics |
| `UnrestrictedViewer` | Query all tables, bypassing row-level security policies |

#### Table-Level Roles

| Kusto Role | Permissions |
|---|---|
| `Admin` | Full control over the table |
| `Ingestor` | Ingest data into the table |
| `Viewer` | Query the table |

#### Operations by Role

| Operation | Minimum Kusto Role |
|---|---|
| Query a database | `Viewer` (database) or `Viewer` (table) |
| Ingest data into tables | `Ingestor` (database or table) |
| Create/alter tables and functions | `User` (database) |
| Manage database policies (retention, caching) | `Admin` (database) |
| Grant/revoke database roles | `Admin` (database) |
| Full cluster administration | `AllDatabasesAdmin` (cluster) |

## Notes / Considerations

- **`AllDatabasesAdmin`** at cluster level is highly privileged — assign only to cluster administrators, not application identities.
- For **application ingestion**, assign `Ingestor` at the table or database level — this is narrower than `User`.
- For **application querying**, assign `Viewer` at the specific table level rather than the database level for least privilege.
- **External tables** (over ADLS Gen2) require the cluster's managed identity to have `Storage Blob Data Reader` on the storage account.
- **Continuous export** to ADLS Gen2 requires `Storage Blob Data Contributor` on the destination.
- ADX supports **Row-Level Security** (preview) policies for fine-grained row filtering — requires `Admin` to configure.

## Related Resources

- [Azure Data Lake Storage Gen2](./azure-data-lake-storage-gen2.md) — External table and export target
- [Azure Monitor](../platform-landing-zone/azure-monitor.md) — ADX is the backend for Azure Monitor Logs (Log Analytics) at scale
- [Microsoft Purview](./microsoft-purview.md) — Catalog integration for ADX databases
