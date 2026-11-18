# Infrastructure plan contract

Read after the target is selected, before writing `infrastructure-plan.md`. The plan is the infrastructure **blueprint** a later delivery phase renders into code in the user's chosen IaC tool, so delivery builds the application *and* its infrastructure from one reconciled package. Describe what to build and how it is organized; leave `.tf`, `.bicep`, `.bicepparam`, state backends, and deployments to delivery.

## IaC tool decision

The IaC tool (Terraform or Bicep) is the user's decision. Ask for it in the same round as target selection, with a recommendation:

| Signal | Leans toward |
|---|---|
| Existing IaC in the estate, an enterprise standard, or a platform team's landing-zone code | The incumbent tool; switching needs an explicit reason |
| Non-Azure providers in the same deployment (GitHub, DNS, monitoring SaaS) or multi-cloud estate | Terraform |
| Azure-only workload, wish to avoid managing a state file, day-zero access to new Azure resource API versions | Bicep |
| Team skills and existing CI/CD tasks | The tool the delivery team already operates |

Both tools consume [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/) (AVM); prefer AVM resource/pattern modules over hand-written modules. See [Comparing Terraform and Bicep](https://learn.microsoft.com/azure/developer/terraform/comparing-terraform-and-bicep) for evidence.

Present the recommendation and wait for the user's answer. Record the recommendation, rationale, the user's choice, and the turn that made it. The tool does not change the architecture, only how delivery renders it, so an unanswered tool question does not block the package: write the tool-neutral sections, set `IaC tool: pending user decision (recommended: <tool>)`, mark tool-specific sections pending, and repeat the question at handoff. Never fill the choice yourself, even when asked to "just pick".

## Required structure

```markdown
# Infrastructure plan
## Status, scope, and IaC tool decision
## Existing IaC and platform ownership
## Resource inventory
## Module and repository layout
## Environments, parameters, and naming
## Identity, RBAC, and secrets
## Networking and private connectivity
## State, deployment scopes, and ordering
## Policy, tagging, and guardrails
## Validation and promotion
## Deferrals and delivery handoff
```

## Existing IaC and platform ownership

Summarize what discovery found: tool, version constraints, module sources, state/back-end location, coverage, drift indicators, and owners. Split the estate into **platform layer** (landing zone, hub network, private DNS zones, shared Log Analytics, policy) and **workload layer** (resources this application owns). Reference platform resources as existing inputs; plan only what the workload owns unless the user confirmed the platform is in scope. An empty repository is not proof that no platform IaC exists.

## Resource inventory

One row per Azure resource the target needs:

| IaC ID | Resource type | Component ID | Module (AVM or custom + reason) | Layer / owner | Environment variation | Wave | Lifecycle |
|---|---|---|---|---|---|---|---|
| `IAC-001` | `Microsoft.Web/sites` | `CMP-API` | AVM `web/site` | Workload / app team | Zone redundancy in prod only | `W-001` | Steady state |

Every target-architecture component that maps to Azure resources has rows, or is marked platform-provided or externally owned. Flag temporary migration/coexistence resources (DMS, sync, hybrid connectivity, staging slots) with their decommission wave. Use the same component IDs and resource list as `cost-estimate.md`; a resource priced but not provisioned, or provisioned but not priced, is a reconciliation defect.

## Layout, environments, and naming

Describe the intended repository layout as a directory tree (folders and file roles, no resource code), the module boundaries, and how environments differ (dev/test/prod parameters, SKU tiers, zone redundancy, private access). Define naming and tagging conventions, reusing enterprise conventions when known. Keep secrets and environment-specific values out of the plan; name their source (Key Vault, pipeline variables, platform outputs).

## Identity, networking, and guardrails

- **Identity/RBAC:** managed identities per workload component, role assignments with least-privilege scope, deployment identity (workload identity federation for CI/CD), and who may grant roles.
- **Networking:** VNets/subnets or platform-supplied spokes, private endpoints and DNS zone linkage, ingress/egress, and which parts the platform team must deliver first.
- **Guardrails:** Azure Policy assignments the workload must satisfy, required tags, locks, diagnostic settings, and backup/retention configuration.

## Tool-specific sections

Fill the branch for the chosen tool; keep both outlines short when the choice is pending.

**Terraform:** provider set (`azurerm`, `azapi`, others) and version-constraint policy; remote state on Azure Storage with locking, one state per environment and layer, state access identity, and handling of sensitive values in state; root-module per layer/environment; AVM registry modules (`Azure/avm-res-*`); `plan` review and `apply` authority.

**Bicep:** target scopes (resource group, subscription, management group) per layer; `.bicepparam` file per environment; AVM registry modules (`br/public:avm/res/...`); whether deployment stacks manage lifecycle and deny settings; `what-if` review and deployment authority.

Verify version, provider, and feature claims through [microsoft-learn-evidence.md](microsoft-learn-evidence.md); mark unverified ones provisional.

## Ordering and validation

Map deployment order to migration waves: platform prerequisites first, then shared workload resources, then per-wave components, then decommission of temporary resources. For each step, state dependencies, the owner, and the rollback/teardown boundary.

Plan validation that delivery will run: format/lint/validate, policy compliance, `terraform plan` or Bicep `what-if` review before apply, drift detection, and promotion between environments. When GitHub Actions is selected, link the infrastructure row of the blueprint in `migration-plan.md` rather than duplicating it.

## Completion check

Every Azure resource in the target has an `IAC-` row traced to a component, owner, and wave; platform-owned inputs are named rather than invented; identity, networking, state/scope, and validation sections are complete for the chosen tool or explicitly pending the user's tool decision; the resource list matches `cost-estimate.md`; and no runnable IaC, state backend, or deployment was created.
