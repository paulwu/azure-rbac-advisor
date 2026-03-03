# Hub Virtual Network

## Resource Metadata

| Property | Value |
|---|---|
| **Resource Provider** | `Microsoft.Network` |
| **Resource Types** | `Microsoft.Network/virtualNetworks`, `Microsoft.Network/virtualNetworkPeerings`, `Microsoft.Network/routeTables`, `Microsoft.Network/networkSecurityGroups` |
| **Azure Portal Category** | Networking > Virtual Networks |
| **Landing Zone Context** | Platform Landing Zone (Hub) |
| **Documentation** | [Microsoft Docs](https://learn.microsoft.com/azure/virtual-network/virtual-networks-overview) |
| **Pricing** | [VNet Pricing](https://azure.microsoft.com/pricing/details/virtual-network/) |
| **SLA** | [99.9%](https://azure.microsoft.com/support/legal/sla/virtual-network/) |

## Overview

The Hub Virtual Network is the central connectivity point in a Hub-Spoke topology. It hosts shared network services (Azure Firewall, VPN/ExpressRoute Gateway, Azure Bastion, Private DNS Resolver) and connects to spoke VNets via peering. In the Platform Landing Zone, the hub VNet is managed by the platform team and spoke VNets are peered in by workload teams.

## Least-Privilege RBAC Reference

### 🟢 Create

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Create a Virtual Network | Resource Group | `Network Contributor` | Creates the VNet, subnets, and associated resources. |
| Create a VNet Peering (from hub to spoke) | Hub VNet resource | `Network Contributor` | Requires `Network Contributor` on **both** the hub VNet (platform team) and the spoke VNet (workload team) to establish bidirectional peering. |
| Create a Route Table | Resource Group | `Network Contributor` | |
| Associate Route Table with subnet | Subnet (within VNet) | `Network Contributor` on the VNet | |
| Create a Network Security Group | Resource Group | `Network Contributor` | |
| Associate NSG with subnet | Subnet (within VNet) | `Network Contributor` on the VNet | |

### 🟡 Edit / Update

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Add/modify subnets | VNet | `Network Contributor` | |
| Modify address space | VNet | `Network Contributor` | Cannot reduce address space while resources are deployed in affected subnets. |
| Update route table entries (UDR) | Route Table resource | `Network Contributor` | |
| Modify DNS server settings | VNet | `Network Contributor` | |
| Update VNet Peering settings (allow gateway transit, use remote gateways) | VNet Peering resource | `Network Contributor` | Must update both sides of the peering. |

### 🔴 Delete

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delete a VNet | Resource Group | `Network Contributor` | All subnets must be empty (no connected resources) before deletion. |
| Delete a VNet Peering | VNet Peering resource | `Network Contributor` | Deleting one side leaves the other side in a disconnected state. |
| Delete a Subnet | VNet | `Network Contributor` | Subnet must be empty. |
| Delete a Route Table | Resource Group | `Network Contributor` | Must be disassociated from all subnets first. |

### ⚙️ Configure

| Operation | Scope | Least-Privileged Role | Notes |
|---|---|---|---|
| Delegate a subnet to a service (e.g., App Service, Azure Firewall) | VNet | `Network Contributor` | |
| Enable DDoS Protection Standard | VNet | `Network Contributor` + DDoS Plan assignment | DDoS Protection Plan is a separate resource (`Microsoft.Network/ddosProtectionPlans`). |
| Configure service endpoints on subnet | VNet | `Network Contributor` | |
| Configure VNet diagnostic settings | VNet | `Monitoring Contributor` | Sends flow logs and traffic analytics to Log Analytics / Storage. |
| Configure Network Watcher | Subscription | `Network Contributor` | Network Watcher is auto-created per region. |
| View effective routes / security rules | VM NIC resource | `Reader` on NIC + `Network Contributor` | Troubleshooting tools require read access to the NIC and associated network resources. |

## Hub-Spoke Peering — Role Delegation Pattern

In Enterprise-scale Landing Zones, workload teams provision spoke VNets in their own subscriptions. A common pattern is:

| Actor | Scope | Role |
|---|---|---|
| Platform team | Hub VNet | `Network Contributor` |
| Workload team | Spoke VNet | `Network Contributor` |
| Platform automation | Both subscriptions | `Network Contributor` (via Managed Identity or Service Principal) |

> **Tip**: Use Azure Policy (`DeployIfNotExists`) with a managed identity to automatically peer new spoke VNets to the hub — the policy assignment's managed identity needs `Network Contributor` on both hub and spoke.

## Notes / Considerations

- **Subnet delegation** to services (e.g., `Microsoft.Web/serverFarms` for App Service Integration) is irreversible; the subnet becomes exclusively owned by that service.
- **VNet peering is non-transitive** — traffic between two spokes must pass through the hub (via Azure Firewall or NVA) unless spokes are also peered to each other.
- **`Network Contributor`** at subscription scope is broadly privileged — prefer scoping to the specific resource group containing the hub VNet.
- Flow logs require a **Storage Account** and optionally a **Log Analytics Workspace**; configure using `Traffic Analytics` within Network Watcher.

## Related Resources

- [Azure Firewall](./azure-firewall.md) — Deployed in the hub for centralized traffic inspection
- [VPN / ExpressRoute Gateway](./vpn-expressroute-gateway.md) — Provides on-premises connectivity
- [Azure Bastion](./azure-bastion.md) — Deployed in the hub's `AzureBastionSubnet`
- [Private DNS Zones](./private-dns-zones.md) — Linked to the hub VNet for private endpoint resolution
