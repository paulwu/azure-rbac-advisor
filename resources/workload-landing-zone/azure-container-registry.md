# Azure Container Registry (ACR)

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.ContainerRegistry` |
| **Resource Type** | `Microsoft.ContainerRegistry/registries` |
| **Azure Portal Category** | Containers > Container Registries |
| **Landing Zone Context** | Workload Landing Zone |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/container-registry/container-registry-intro) |
| **Pricing** | [ACR Pricing](https://azure.microsoft.com/pricing/details/container-registry/) |
| **SLA** | [99.9%](https://azure.microsoft.com/support/legal/sla/container-registry/) |

## Overview

Azure Container Registry is a managed, private Docker-compatible container registry. In a Workload Landing Zone it stores container images and Helm charts used by AKS clusters, App Service containers, and Azure Container Instances. ACR splits management-plane operations (registry settings) from data-plane operations (image push/pull).

## Least-Privilege RBAC Reference

> ACR has dedicated image-level roles (`AcrPull`, `AcrPush`, `AcrDelete`) separate from management-plane roles. Always assign the narrowest image role to application identities.

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a Container Registry | Resource Group | `Contributor` | No ACR-specific management-plane role exists; `Contributor` scoped to the RG is the minimum. |
| Push a container image | Registry | `AcrPush` | Allows push (and pull) of images. Required for CI/CD pipelines. |
| Import an image from another registry | Registry | `AcrPush` + `Contributor` (for import API) | `az acr import` requires both image write permission and management-plane access. |
| Create a geo-replication | Registry | `Contributor` | |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Modify registry settings (SKU, public access, network rules) | Registry | `Contributor` | |
| Update geo-replication settings | Registry | `Contributor` | |
| Configure webhooks | Registry | `Contributor` | |
| Configure tasks (ACR Tasks for image build) | Registry | `Contributor` | ACR Tasks build images from source code on triggers. |
| Overwrite/update an image tag | Registry | `AcrPush` | Pushing a new image with the same tag overwrites the existing one. |
| Sign an image | Registry | `AcrImageSigner` | Used with Docker Content Trust or Notary v2 for supply chain security. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a specific image/tag | Registry | `AcrDelete` | Removes individual image manifests and tags. |
| Delete a repository | Registry | `AcrDelete` | Removes all tags and manifests in a repository. |
| Delete the Container Registry | Resource Group | `Contributor` | |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Pull a container image (application/cluster) | Registry | `AcrPull` | Minimum role for read-only image access. Assign to AKS kubelet identity, App Service managed identity, etc. |
| Enable admin account | Registry | `Contributor` | Admin account provides username/password access — disable in production; use Entra ID roles instead. |
| Configure Private Endpoint | Registry + VNet | `Contributor` + `Network Contributor` | Disable public access and use Private Endpoint in production. |
| Configure network firewall rules | Registry | `Contributor` | Allows/blocks access by IP range or VNet service endpoint. |
| Configure quarantine policy | Registry | `AcrQuarantineWriter` | Marks images as quarantined pending security scan. `AcrQuarantineReader` for read-only access. |
| Configure retention policy | Registry | `Contributor` | Auto-purges untagged manifests after a retention period. |
| Configure Diagnostic Settings | Registry | `Monitoring Contributor` | |
| View registry logs and metrics | Registry | `Reader` | |

## Data Plane Role Summary

| Role | Push Images | Pull Images | Delete Images | Sign Images | Quarantine |
|---|---|---|---|---|---|
| `AcrPush` | ✅ | ✅ | ❌ | ❌ | ❌ |
| `AcrPull` | ❌ | ✅ | ❌ | ❌ | ❌ |
| `AcrDelete` | ❌ | ❌ | ✅ | ❌ | ❌ |
| `AcrImageSigner` | ❌ | ❌ | ❌ | ✅ | ❌ |
| `AcrQuarantineWriter` | ❌ | ❌ | ❌ | ❌ | ✅ (write) |
| `AcrQuarantineReader` | ❌ | ❌ | ❌ | ❌ | ✅ (read) |

## Common Assignment Patterns

| Principal | Role | Scope | Purpose |
|---|---|---|---|
| AKS kubelet managed identity | `AcrPull` | Registry | Pull images for running pods |
| CI/CD Service Principal | `AcrPush` | Registry | Push built images |
| Security scanner identity | `AcrPull` + `AcrDelete` | Registry | Scan and remove vulnerable images |
| App Service managed identity | `AcrPull` | Registry | Pull container images for web apps |
| Image signer identity | `AcrImageSigner` | Registry | Sign images as part of supply chain |

## Notes / Considerations

- **Disable the admin account** in production — it provides static credentials that cannot be audited per-user. Use Entra ID roles exclusively.
- **`AcrPull`** is the minimum role for any service pulling images — assign to managed identities rather than using admin credentials.
- **Premium SKU** is required for Private Endpoints, geo-replication, and content trust.
- **ACR Tasks** can be used for vulnerability scanning and automated base image updates — the task identity needs `AcrPush` on the destination registry.
- For **multi-registry** scenarios (dev/staging/prod), grant `AcrPull` on production registries only to production workloads.

## Related Resources

- [Azure Kubernetes Service](./azure-kubernetes-service.md) — Primary consumer of ACR images
- [Private DNS Zones](../platform-landing-zone/private-dns-zones.md) — `privatelink.azurecr.io`
- [Spoke Virtual Network](./spoke-virtual-network.md) — Private endpoint connectivity
