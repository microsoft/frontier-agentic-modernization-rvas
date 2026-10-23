# Discovery and baseline contract

Read before investigating the application. Discovery establishes current behavior and desired outcomes separately so modernization does not accidentally redefine the product.

## Assessment structure

Write `assessment.md` with these sections:

```markdown
# Application modernization assessment
## Status and assessment scope
## Modernization drivers and value hypotheses
## Business purpose, actors, and critical journeys
## User interface and design authority
## Evidence and coverage ledger
## Functional inventory and business rules
## Code readiness and remediation findings
## Current architecture and deployment
## Integrations and dependency map
## Data estate and ownership
## Security and operations
## Constraints, findings, and contradictions
## Interview decisions and deferrals
## Confirmed baseline
```

Draft this record during discovery; final target design waits for baseline confirmation.

## Assessment depth

Perform a deep assessment of the entire in-scope estate. Inspect every deployable, executable entry point, critical journey, user-interface surface, authorization boundary, durable write, scheduled/background process, external call, shared-state dependency, deployment path, and target-sensitive dependency available in the supplied evidence.

Representative journey tracing establishes behavior depth; it does not replace component coverage. Continue until every reachable in-scope component and evidence lane has been inspected. Use coverage gaps only for evidence that is missing, inaccessible, unsupported, or explicitly outside the confirmed boundary, and record the consequence and next owner for each gap.

## Modernization value hypotheses

Keep the value case lightweight and traceable:

| Driver / current pain | Expected benefit | Measure and baseline evidence | Owner / validation point |
|---|---|---|---|
| Unsupported runtime or high platform toil | Supported operation with lower maintenance burden | Current support state and operating effort; target measured later | Named owner / option selection |

Use confirmed business outcomes and observed pain. Mark missing baselines as measurement prerequisites rather than inventing savings, ROI, or delivery improvements. Route detailed price or TCO work to the cost specialist.

## Evidence and coverage

Inventory all in-scope repositories, nested manifests, independently deployed processes, shared libraries, jobs, databases, infrastructure definitions, pipelines, and supplied documents. A root without a manifest does not imply no application.

When a user interface exists, read [ui-design-recovery.md](ui-design-recovery.md). Account for every UI application, route family, shared shell, component/design system, and meaningful surface. `PRODUCT.md` and `DESIGN.md` are recovered authorities; stable `SURF-` entries in this assessment capture actual layouts, journeys, states, responsive behavior, and dependencies.

For delivery evidence, inspect current workflow/pipeline files and invoked scripts. Record actual build/test commands, triggers, required checks, artifacts, runner/environment access, identities, and approval gates. Distinguish absent automation from uninspected scope; GitHub Actions adoption is a decision, not a default.

Use an evidence ledger:

| ID | Component/journey | Evidence location | Observation | Confidence | Limitation |
|---|---|---|---|---|---|
| E-001 | Order submission | `src/orders/...:line-range` | Observed state transition | High | Runtime path not exercised |

Cite file/line ranges, configuration keys, or report sections. Record repository revision and report capture date when available; use a local-working-tree label when no commit exists. Keep secrets and row values out of the ledger.

Use a coverage ledger:

| Boundary | Mode | Inspected evidence | Unassessed paths | Consequence / next owner |
|---|---|---|---|---|
| Payment integration | Deep | Caller, adapter, config | Partner behavior unavailable | Contract validation before wave 2 |

Assessment mode is deep for the confirmed application boundary. Exclude generated/build/vendor output only when it is non-authoritative; account for code generation and external modules whose behavior matters. Carry unavoidable unassessed scope into risks and validation rather than labeling it complete.

Separate:

- **Observed:** executable code/configuration or supplied measurement supports the claim.
- **Confirmed:** stakeholder explicitly validated an intent or decision; this is not a substitute for code evidence.
- **Inferred:** plausible interpretation, with supporting evidence and an alternative explanation.
- **Unknown:** evidence is missing or contradictory; never convert this to "none".
- **Deferred:** unresolved item with owner, decision point, and architectural/migration impact.

For high-impact contradictions, keep both sources, identify which represents deployed behavior if possible, and ask the owner to settle intent. Source code describes behavior, not proof that the behavior is correct or should survive.

## Functional recovery

For each business capability, record actors, journey entry/exit, preconditions, data inputs/outputs, business rules, state changes, permissions, failure/retry behavior, integrations, and evidence. Trace at least the critical happy path and consequential error/authorization paths through actual callers, services, persistence, and side effects.

Recover a user story from a traced behavior, not from a method name. Stored procedures, triggers, scheduled jobs, and report logic can own business rules absent from application code. Read the database protocol for those branches.

Label legacy behavior **preserve**, **change**, or **retire**, with a decision owner. Default to preserving an observed contract pending stakeholder confirmation; do not silently preserve a known defect or improve a business rule.

Map integration contracts: producer/consumer, protocol, authentication, data shape/version, call direction, sync/async semantics, timeout/retry/idempotency, ordering, failure owner, environment, and system of record. Mark values unknown when configuration does not establish them.

## Code readiness and remediation findings

Record source-level findings that could change a target choice or migration wave in `assessment.md`, keeping the package at eight artifacts.

| ID | Component / evidence | Finding | Candidate target affected | Disposition / remediation | Effort confidence | Validation / owner |
|---|---|---|---|---|---|---|
| CR-001 | Source location | Target-sensitive behavior or dependency | Named option or target family | Blocker, remediate, retain, replace, or verify | Evidence-based range or unknown | Check and decision owner |

Inspect, when evidenced:

- Runtime, framework, SDK, package, and operating-system compatibility.
- Native libraries, platform APIs, local files, sessions, caches, and in-memory coordination.
- Configuration, secrets, certificates, identities, and environment assumptions.
- Build reproducibility, generated code, deployment packaging, and startup behavior.
- Background work, concurrency, transactions, retries, idempotency, and ordering.
- Existing tests and the characterization/contract tests needed to preserve recovered behavior.
- Dependency security or licensing findings already present in supplied reports; route a standalone security audit separately.

Classify a finding against a named candidate target. Trace material `CR-` findings into component dispositions, prerequisites, migration waves, and validation gates. Automated assessment output is evidence, not a completed remediation plan.

## Technical and operational recovery

Capture runtime/framework/version, dependency inventory, native/OS coupling, local files and sessions, transactions, background work, shared stores, cache semantics, deployment topology, CI/CD, identities, network boundaries, observability, backup/restore, and operational ownership.

Separate runtime facts from requirements: a configured timeout is not a confirmed latency SLO; an index is not proof of production query load; a Dockerfile is not proof of deployability.

Use existing read-only assessment reports where supplied. Record tool/version, scope, capture date, and limitations. Tool output supports findings; a score does not replace journey reconstruction or owner validation.

## Interview frontier

The frontier is the set of unresolved architecture-changing decisions whose prerequisites are settled. Investigate repository facts first, then ask the whole answerable frontier in one recommended round and wait. Questions depending on an unsettled answer belong to a later round.

Work outward from:

1. Business outcome, owners, criticality, preservation/change scope, and measurable success.
2. Users/journeys, external obligations, undocumented rules, and systems of record.
3. Scale, latency, availability, RTO/RPO, retention, budget, and constraints on change.
4. Enterprise identity, landing zone, network, residency, compliance, operations, and skills.
5. Migration deadline constraints, maintenance/blackout windows, downtime, coexistence, freeze, rollback authority, and go/no-go criteria.

Do not ask for facts already established from evidence. Ask whether observed settings meet the desired outcome when that intent remains unknown.

Give a recommended answer with rationale and alternatives. Avoid forcing an architecture through a binary question such as "do you want microservices?" Capture explicit delegation scope; recommendations are not consent.

When a target-relevant metric is missing, obtain a bounded accepted assumption or defer measurement with an owner. A deferral that could invalidate the target blocks firm selection.

## Shared-understanding gate

Present:

- Application boundary, actors, critical journeys, and business outcomes.
- Modernization drivers, value hypotheses, and missing measurement baselines.
- Current functional/technical/integration/data baseline and assessed coverage.
- Target-sensitive code readiness findings and their dispositions or validation owners.
- Behavior to preserve, intentionally change, or retire.
- UI surface dispositions, recovered product/design authority, and visual/runtime evidence limitations.
- Measurable NFRs and enterprise/migration constraints.
- Evidence conflicts, assumptions, accepted deferrals, and blocking unknowns.
- Decisions/delegations and what confirmation authorizes: target comparison and planning only.

Record status `Draft - awaiting baseline confirmation` until a later user turn explicitly confirms this record. Store the confirmed revision and confirmation evidence in `assessment.md`. Reopen affected decisions when new evidence materially changes the baseline.

## Completion check

Every reachable in-scope component, evidence lane, and critical journey has been inspected. Each unavoidable coverage gap names its evidence limitation, consequence, and next owner. Every material code-readiness finding has a disposition or owned validation. Every architecture-changing decision is answered, delegated within bounds, or accepted as a deferral. The baseline is explicitly confirmed; no code observation is mislabeled stakeholder intent.
