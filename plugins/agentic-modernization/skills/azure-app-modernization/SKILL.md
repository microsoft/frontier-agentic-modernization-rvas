---
name: azure-app-modernization
description: "Architecture-first Azure modernization for existing applications supplied as source code, documentation, UI assets, or database artifacts. Use for recovering functional requirements, incumbent product and visual-design authority, user-interface surfaces, current architecture and integrations, interviewing stakeholders, comparing Azure-native target architectures, estimating target and migration costs, and planning a migration before implementation, including on-premises, cross-cloud, and already-Azure estates. Produces an assessment, specification, editable diagrams, target architecture, cost estimate, migration plan, and conditional product/design context for existing UIs. Ends with a reconciled planning-package handoff; isolated SDK/SKU upgrades, deployment, troubleshooting, greenfield design, and standalone AI-feature design use other workflows."
---

# Azure App Modernization

Recover what the application does before deciding how to modernize it. Treat the current behavior, stakeholder intent, target architecture, and migration path as distinct decisions.

## Package and boundary

Create these files under `docs/modernization/`:

- `assessment.md` — evidence, current behavior, integrations, data, and coverage gaps.
- `specification.md` — confirmed requirements, intentional changes, and acceptance criteria.
- `strategy-matrix.md` — component dispositions and architecture alternatives.
- `target-architecture.md` — selected Azure design, decisions, and capability evidence.
- `cost-estimate.md` — mandatory target, migration, coexistence, and steady-state cost model with assumptions and pricing status.
- `current-state.drawio` — current context, components, and data/integration flows.
- `target-architecture.drawio` — target components, deployment boundaries, and migration/coexistence flow.
- `migration-plan.md` — dependency-ordered migration, validation, cutover, and rollback plan.

When an existing user interface is in scope, the bounded UI-recovery branch may also create or update:

- `PRODUCT.md` — durable incumbent product truth recovered through Impeccable.
- `DESIGN.md` — incumbent visual-system authority recovered through Impeccable scan/document mode.
- `.impeccable/design.json` — machine-readable extensions corresponding to `DESIGN.md`.
- `.impeccable/surfaces/` — confirmed briefs only for surfaces intentionally changed by the selected strategy, when the installed Impeccable workflow persists them.

**Planning-only boundary:** change only this package, relevant domain records (`CONTEXT.md`, `docs/adr/`), and the conditional UI-recovery artifacts above. Keep application source, manifests/lockfiles, tests, assets, databases, IaC, CI/CD workflow files, cloud resources, and deployments unchanged. Do not enable Impeccable hooks/live mode, configure implementation preferences, or create critique/runtime state during planning. Treat assessment tools as evidence sources; use only explicitly read-only modes. Inspection does not authorize running unknown repository code, restoring dumps, publishing issues, or sending confidential inputs to a remote analyzer.

Write in clear technical English. Reuse the project's domain vocabulary and distinguish observed behavior from desired behavior.

## Resume from evidence

| Evidence | Next action |
|---|---|
| Inputs/scope unclear, assessment gaps open, or baseline confirmation missing | Discover and interview |
| A later user turn confirmed the baseline and architecture-changing constraints | Compare strategies and target options |
| Options exist but target selection/delegation is unresolved | Present the answerable decision frontier and wait |
| Target selected or explicitly delegated within confirmed constraints | Specify the architecture and migration plan |
| Package ready but bounded pricing has not run | Run the cost-estimation consultation, reconcile, and complete the package |
| Reconciled package complete | Hand off and stop; request acceptance only when the user or governance process explicitly requires it |
| Material evidence, scope, requirement, or target changed | Preserve decision history; return to the affected gate |

The initial request, silence, batch execution, and the agent's own summary are not confirmation of an unresolved baseline or target decision. Record each decision gate's status and the exact baseline/revision it covers. Do not turn ordinary package completion into a confirmation gate.

Use `Ready for review` as the reconciled package status unless explicit acceptance was requested and obtained. `Awaiting approval`, `ready for approval`, and equivalent blocking states are inappropriate for ordinary completion because they recreate a confirmation gate the user did not ask for.

## 1. Discover and interview

Read [discovery-quality.md](references/discovery-quality.md) before inspecting the estate or framing questions.

1. **Scope:** identify the application boundary, supplied inputs, business goal, and any existing assessment/plan. For a narrow service operation or unrelated request, read [specialist-routing.md](references/specialist-routing.md) and route before creating a package.
2. **Inspect:** deeply inspect all in-scope components and evidence lanes. Trace critical journeys through executable code, data, integrations, and user-interface surfaces, and maintain a coverage ledger so no reachable component is omitted or reduced to representative sampling.
3. **UI branch:** when a user interface is in scope, read [ui-design-recovery.md](references/ui-design-recovery.md). Inventory its surfaces and technology, then load `impeccable` for bounded `init` and `document` capabilities as needed. Recover product/design authority without editing application code or redesigning preserved surfaces.
4. **Recover:** write the current behavior and architecture in `assessment.md`, with evidence IDs, source locations, confidence, contradictions, and stable surface IDs. Recover actors, user stories, business rules, permissions, layouts, states, responsive behavior, and failure paths before proposing a replacement.
5. **Data branch:** when schemas, migrations, dumps, or database-backed logic are present, read [database-artifact-protocol.md](references/database-artifact-protocol.md) before opening or classifying them.
6. **Resolve:** interview only for decisions that evidence cannot answer. Load `grilling` for frontier-based rounds and `domain-modeling` when terminology needs a domain record. Give recommended answers and explain their consequences; wait for each answerable round.
7. **Confirm:** present the baseline, modernization scope, preservation/change commitments, recovered product/design authority, constraints, evidence gaps, and explicit deferrals. Request confirmation before selecting the target architecture.

**Complete when:** every in-scope component, critical journey, and UI surface is accounted for or explicitly marked unassessed; incumbent product/design authority is recovered or its absence has an accepted owner/deferral; target-sensitive findings are traced to a disposition or owned validation; architecture-changing unknowns are resolved or bounded by accepted deferrals; and a later user turn confirms the baseline.

## 2. Compare modernization strategies

Read [modernization-patterns/README.md](references/modernization-patterns/README.md) before classifying components or proposing Azure targets.

1. **Disposition:** evaluate retain, retire, replace, rehost, replatform, refactor, rearchitect, and rebuild per workload/component and UI surface. Separate migration strategy from compute/data-service selection. For UI, distinguish preservation/replatforming from intentional refinement, redesign, replacement, or retirement.
2. **Compose:** present a recommended target and meaningful alternatives as coherent whole-system options. Include a lower-change option when feasible. A monolith with managed services is a valid candidate; a diagram of microservices is not proof of independent ownership.
3. **Verify:** read [microsoft-learn-evidence.md](references/microsoft-learn-evidence.md) before asserting runtime support, compatibility, availability, cost, networking, identity, or recovery capabilities. Mark unverified choices provisional.
4. **Select:** record the comparison in `strategy-matrix.md`; ask for target selection unless the user explicitly delegated that choice within the confirmed constraints. Return trade-offs outside that delegation to the interview.

**Complete when:** every in-scope component and every `SURF-` entry has an applicable disposition, each viable option accounts for its dependencies and NFRs, and the target choice is confirmed or explicitly delegated. Block a firm selection when an unknown could make it infeasible.

## 3. Specify architecture and migration

1. **Specify:** read [specification-quality.md](references/specification-quality.md). Write `specification.md` with stable requirement/acceptance/surface IDs and explicit preserve/change/retire decisions. Use Impeccable `shape` only for selected surfaces whose approved strategy intentionally changes their experience; a technical replatform inherits the incumbent product and design authority.
2. **Architect:** read [architecture-quality.md](references/architecture-quality.md). Write `target-architecture.md`, including identities, trust boundaries, ingress/egress, data ownership, operations, rejected alternatives, and the mandatory cost-estimation handoff.
3. **Plan:** read [migration-plan-quality.md](references/migration-plan-quality.md). Write `migration-plan.md` with waves, prerequisites, coexistence, data transition, validation, cutover, rollback limits, and handoff owners.
4. **Estimate:** read [cost-estimation-handoff.md](references/cost-estimation-handoff.md), then load `cost-estimation` as a bounded pricing consultation. Write `cost-estimate.md` for every selected target and execute the applicable retail or negotiated pricing steps before final reconciliation. The modernization document contract remains authoritative: merge specialist pricing evidence and calculations into its required sections rather than substituting a shorter specialist report. Ask only for the minimum missing details needed to disambiguate meters, preferably in one consolidated cost-input round. Preserve measured, confirmed, and assumed values separately; show verified scenario totals when pricing succeeds and explicit attempted-source/tool blockers instead of zeroes or invented totals when it does not.
5. **Delivery automation:** when GitHub Actions is selected or proposed, read [github-actions-quality.md](references/github-actions-quality.md). Record the test/build/deploy blueprint in `migration-plan.md` and identity/trust boundaries in `target-architecture.md`; leave workflow authoring to delivery.
6. **Diagram:** load `cloud-architecture-diagram` to author the editable current/target views. Apply the structural and rendered review contract in the architecture reference; disclose missing review evidence.
7. **Reconcile:** check all package files against the confirmed baseline and selected target, including cost calculations and pricing evidence. Read [specialist-routing.md](references/specialist-routing.md) for bounded design consultations or later delivery owners. Mark the package exactly `Ready for review` and hand it off without asking for confirmation unless the user explicitly requested an approval decision or an unresolved material decision truly requires their choice. Do not describe ordinary completion as `Awaiting approval` or `Ready for approval`. If explicit package acceptance is required, ask once after all eight artifacts are complete; never reopen approval merely because pricing was deferred until after handoff.

**Complete when:** the package passes its reference checklists, stable IDs link evidence through requirements to components/waves/validation, the bounded pricing consultation has completed or recorded a concrete blocker, and package status is `Ready for review` or explicitly accepted.

## 4. Hand off and stop

Record the package revision, any explicit acceptance, and unresolved non-blocking decisions. Report artifact paths, review limitations, prerequisites, and the next delivery owners without invoking their execution workflows. Always report `cost-estimate.md`, its pricing status, pricing evidence or attempted-tool blocker, and unresolved measurement or commercial inputs; name `cost-estimation` as the owner for future refreshes or negotiated-rate completion, not as a substitute for the pricing attempt required during package construction.

**Complete when:** the handoff states `architecture and migration planning only; implementation not started`. Approval, "continue", or an original request to implement does not start code changes, execution-ready ticket generation, resource provisioning, or migration within this skill.
