# Functional and technical specification contract

Read before writing `specification.md`. This is a confirmed modernization baseline, not an inferred product redesign.

## Required structure

```markdown
# Modernization specification
## Status and confirmed baseline
## Outcomes, scope, and exclusions
## Actors and critical journeys
## Functional requirements and business rules
## Preserved, changed, and retired behavior
## User interface and experience requirements
## Integration and data contracts
## Technical requirements
## Non-functional requirements
## Acceptance and parity criteria
## Traceability
## Assumptions, deferrals, and decision history
```

Record status `Draft - planning package` while work is in progress and `Ready for review` when reconciled, plus the baseline revision, target-selection evidence, and scope `architecture and migration planning only`. Record explicit acceptance when requested, but do not make routine package completion depend on an extra approval turn.

Do not label a completed package `Awaiting approval` or `Ready for approval` unless the user explicitly asked for a formal acceptance gate.

## Requirement quality

Use stable IDs: `FR-` for behavior, `TR-` for technical obligations, `NFR-` for quality constraints, and `AC-` for acceptance. Preserve IDs across revisions; supersede explicitly instead of renumbering unchanged requirements.

Each requirement has a statement, owner, evidence/confirmation, preserve/change/retire classification, and acceptance IDs. Write user stories with an actor, outcome, and business reason; add testable inputs, outputs, preconditions, state changes, validation, permissions, and failure behavior.

For UI-bearing capabilities, map stable `SURF-` IDs to the applicable requirements and acceptance criteria. Specify layout/interaction preservation, intentional experience changes, meaningful states and content ranges, responsive behavior, keyboard/accessibility obligations, terminology, component/design-system authority, and visual-parity evidence. A target framework change does not authorize redesign.

Separate:

- Observed legacy behavior awaiting validation.
- Confirmed behavior to preserve, including external compatibility.
- Intentional functional change with explicit owner approval.
- Retired capability with dependency/data-retention obligations.

Record errors/defects as findings pending a preserve/fix decision. Implementation convenience is not authorization to alter business logic, identity, event timing, transaction boundaries, or data semantics.

## Technical and NFR coverage

Cover target runtime/OS and library constraints, contracts/versions, identity/authentication/authorization, data ownership/mapping, transaction/consistency, connectivity, deployment/operating model, and observability.

For NFRs cover scale, latency, throughput, availability, recovery, retention, security/residency, accessibility when relevant, budget, and migration downtime. State a measurement method and target when confirmed. Mark missing thresholds as deferred; do not invent numbers or infer SLOs from configuration.

## Acceptance and traceability

Define functional parity, intentional-change acceptance, UI layout/state/responsive/design-system parity, contract/schema compatibility, authorization, accessibility, failure/retry, operational readiness, data reconciliation, performance, recovery, and cutover go/no-go checks to the level justified by evidence.

| Evidence / decision | Requirement IDs | Acceptance IDs | Target responsibility | Migration wave / validation gate |
|---|---|---|---|---|
| E-001 / confirmed intent | FR-001 | AC-001 | Component name | W-001 / parity gate |

Every requirement maps to an acceptance criterion and an architecture/wave responsibility, or an explicit reason it is retained outside migration scope. Every new component or migration phase maps back to requirements/risks; unexplained infrastructure is scope drift.

## Completion check

All critical journeys, integration/data contracts, and intentional changes are covered. Requirements, acceptance, architecture, and migration traceability agree; unresolved decisions have an owner, decision point, and impact. No inferred business rule is presented as confirmed scope.
