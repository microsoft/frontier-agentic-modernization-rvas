# Specialist routing and delivery boundary

Read for narrow entry requests, bounded design consultations, or handoff. Route by intent and requested action, not just source platform or a product keyword.

## Entry routing

| Intent | Route |
|---|---|
| Architecture and migration planning for an existing application, including cross-cloud or already-Azure | Keep this skill; use specialist evidence for component details |
| Isolated Azure tier/SKU/SDK upgrade or supported cloud-to-cloud code conversion | Discover an available upgrade/migration workflow; name it without starting it here |
| Existing deployment or troubleshooting, with architecture already chosen | Available deployment/diagnostics workflow |
| Enterprise infrastructure topology without application modernization | `azure-enterprise-infra-planner` |
| Cost forecasting without architecture discovery | `cost-estimation` |
| Greenfield or standalone new AI feature design | An available architecture-first application/AI design workflow; if absent, say so |
| Pure database migration/execution without application assessment | Available database assessment/migration workflow; explain that this skill is application planning |

Do not redirect a whole-estate plan merely because a component comes from AWS, already runs on Azure, or contains AI. Conversely, an isolated operation does not need a full modernization package.

## Bounded design consultation

| Branch | Available specialist to check |
|---|---|
| Enterprise identity/network/landing zone | `azure-enterprise-infra-planner` |
| Kubernetes target requirements and operations | `azure-kubernetes` |
| Application OAuth/Entra design | `entra-app-registration` |
| Price scenarios for candidate resources or a selected target | Maintain mandatory `cost-estimate.md` through the [cost estimate contract](cost-estimation-handoff.md) and invoke `cost-estimation` as a bounded consultation before final package handoff |
| Editable current/target architecture diagrams | `cloud-architecture-diagram` |
| Existing UI product/design recovery and changed-surface shaping | `impeccable` |
| Missing specialist | `discover-azure-skills` |

Consult only within the planning boundary. A specialist may normally generate IaC, configure resources, or edit UI source; narrow its task to analysis/design and prevent those execution branches. For Impeccable, apply [ui-design-recovery.md](ui-design-recovery.md): permit durable product/design authority and confirmed changed-surface briefs, but no application edits, hooks, live mode, critique runtime, or implementation configuration. Discover availability before claiming a specialist is installed.

AppCAT, Azure Migrate, and existing modernization assessment reports can provide evidence. Verify current tool scope/privacy/mutation behavior before suggesting a read-only run. Do not automatically install tools, create assessment projects, publish issues, or upload code.

## Handoff

For a separately requested application rebuild wave, name the plugin's
`azure-app-rebuild` skill as the delivery entry point. Do not invoke it from this
planning workflow. The user opens a separate delivery session and identifies a
reviewed package revision and bounded wave or vertical slice. Formal package
acceptance is required only when the user or governance process requires it.

Name delivery owners/workflows and the approved inputs they need: specification, target architecture, strategy, migration plan, unresolved prerequisites, and review evidence.

For future target-cost refreshes, hand off `cost-estimate.md`, the package revision, meter-ready resource/usage model, migration phase overlap, existing pricing evidence, and unresolved measurement owners. The initial bounded pricing attempt already occurs during package construction. An undeployed target uses hypothetical pricing; existing Azure spend forecasting is a separate comparison.

For GitHub Actions, include the migration plan's test/build/deploy blueprint, artifact and environment contracts, identity/runner prerequisites, and acceptance gates. Name an available workflow-authoring owner; do not create workflow YAML or change repository/environment/federation settings during planning.

State `architecture and migration planning only; implementation not started`. Approval does not start specialist implementation, ticket generation, provision/deploy, or migration. The user starts the next workflow separately.
