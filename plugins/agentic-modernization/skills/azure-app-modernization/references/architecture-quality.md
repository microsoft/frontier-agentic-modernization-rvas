# Target architecture and diagram contract

Read before writing `target-architecture.md` or authoring diagrams.

## Architecture record

```markdown
# Azure target architecture
## Status, scope, and selected option
## Current-to-target component map
## Azure components and responsibilities
## Integration and data flow
## Identity, security, and trust boundaries
## Landing zone, networking, and deployment topology
## Operations and Well-Architected trade-offs
## Cost-estimation handoff
## Decisions and rejected alternatives
## Microsoft Learn evidence
## Diagram review
## Assumptions, deferrals, and implementation boundary
```

Identify every retained, replaced, retired, or changed component. Map source responsibility, target responsibility, strategy, requirements, owner, and migration wave. Distinguish application resources from platform prerequisites and externally owned systems.

For each major choice, record rationale and a meaningful rejected alternative; link authoritative ADRs rather than duplicating their narratives. Document selected-option confirmation/delegation and provisional decisions.

## Design coverage

- **Function and integration:** map critical journeys and preserved/changed contracts; show sync/async boundaries, versioning, failure/retry/idempotency, routing, and system-of-record ownership.
- **Data:** map stores, ownership, transactional/consistency boundaries, migrations/backfill/synchronization, and coexistence. State exactly which side owns writes in each phase.
- **Identity/security:** show end-user/service identities, authorization, managed identity or credential handling, secrets, encryption, trust boundaries, residency, and external connectivity.
- **Platform:** reuse known enterprise landing-zone/network/governance facts. An empty repository is not proof of no enterprise estate. Defer platform unknowns rather than creating an invented subscription/network topology.
- **Deployment:** separate environments, ingress/egress, private/public access, DNS/discovery, CI/CD trust/artifact boundaries and identities, platform/application ownership, and required read-only capacity/region checks. Link the detailed delivery blueprint in the migration plan.
- **Operations:** cover Reliability, Security, Cost Optimization, Operational Excellence, and Performance Efficiency. Explain trade-offs, operating burden, scale/capacity assumptions, monitoring/traces/alerts, backups, recovery, release and support ownership.

Verify capabilities and support through the evidence contract. Avoid fixed SKUs or point-price claims without workload measurements, region/billing assumptions, and dated verification.

For every selected target, read [cost-estimation-handoff.md](cost-estimation-handoff.md). Keep the authoritative quantities, pricing evidence, and calculations in `cost-estimate.md`; use the architecture section to link that document, its status, stable component IDs, and unresolved architecture decisions. Cost estimation is part of architecture completeness even when the user did not explicitly request pricing.

## Editable diagrams

Use `cloud-architecture-diagram` within the planning boundary.

`current-state.drawio` contains:

1. Context and actors, including external systems.
2. Components and deployment/data boundaries.
3. Critical integration/data flows; mark inferred or unassessed paths.

`target-architecture.drawio` contains:

1. Target components and owned responsibilities.
2. Deployment/trust boundaries, identities, environments, ingress/egress, and operations.
3. Migration/coexistence flow: wave transitions, routing, synchronization, write ownership, cutover, and rollback/reconciliation boundary.

Use the same component names and stable IDs as the records. Make assessed scope and provisional elements visible. A current-state diagram is not a target recommendation; keep the two baselines distinct.

## Review and exceptions

For each diagram page:

1. Parse/validate the draw.io structure and inspect geometry, connectors, labels, containment, and component consistency.
2. Render and inspect the page visually when tooling permits.
3. Obtain independent page review when available.
4. Record pass/fail/unavailable for structural, rendered, and independent review separately, with evidence.

Repair substantive errors and recheck affected pages. After two unsuccessful repair passes, report the unresolved issue instead of claiming completion. If rendering or independent review is unavailable, preserve the editable file, state the unverified checks, and assign the review owner. Ask for explicit exception acceptance only when the user or governance process requires that decision; do not create a confirmation turn solely to acknowledge an unperformed check. Acceptance does not turn an unperformed check into a pass.

## Completion check

Every in-scope responsibility and confirmed NFR has an architecture home or explicit retained/excluded disposition. Records, diagrams, and strategy agree. Requirements, security/data boundaries, operations, migration interfaces, and the cost-estimation handoff are complete or explicitly deferred without masking a feasibility blocker.
