# Migration plan contract

Read before writing `migration-plan.md`. Describe the future delivery path; do not execute it or turn it into runnable scripts/tickets.

## Required structure

```markdown
# Application migration plan
## Status, scope, and planning boundary
## Source and target baselines
## Workstreams, owners, and prerequisites
## Dependency map and migration waves
## Behavior and integration transition
## UI reconstruction and design handoff
## Data migration and coexistence
## Testing, build, and deployment automation
## Validation and acceptance gates
## Cutover, rollback, and reconciliation
## Operations, hypercare, and decommissioning
## Risks, assumptions, and estimates
## Deferrals and delivery handoff
## Package status and handoff
```

## Prerequisites and waves

List landing-zone/identity/network/security prerequisites, traced `CR-` runtime/code compatibility remediation, owner approvals, tooling/access, test data, operational skills, delivery-automation readiness, capacity/region evidence, and delivery responsibilities. Explicitly distinguish existing estate from net-new requirements.

| Wave | Components / strategies | Prerequisites | Contract/data transition | Acceptance gate | Owner / rollback boundary |
|---|---|---|---|---|---|
| W-001 | Named components | Dependency IDs | Compatible transition | AC- IDs | Owner; source remains authoritative |

Group tightly coupled dependencies together or specify a tested bridge. Explain the critical path and which independent work can proceed concurrently. Use non-production rehearsal before production when applicable. Every wave ends with a measurable gate and a rollback/reconciliation boundary.

Sequence by dependencies, business criticality, risk, and delivery capacity rather than alphabetically. Include milestone/decision gates and contingency work; effort/cost ranges need explicit assumptions and owners, not invented precision.

## Behavior, integration, and data

Link preservation/intentional changes to specification IDs. Plan external contract versioning, routing/DNS/service discovery, identity continuity, partner approval, asynchronous semantics, and hybrid connectivity during coexistence.

For UI work, map every `SURF-` disposition to its wave, target technology, coexistence boundary, characterization/parity evidence, and delivery owner. Require delivery to consume `PRODUCT.md`, `DESIGN.md`, `.impeccable/design.json`, confirmed surface briefs, and UI acceptance IDs when present. Preserve/replatform surfaces retain incumbent layouts and conventions; refine/redesign/replace surfaces require their approved change/brief evidence. Name delivery-time Impeccable critique, audit, harden, and polish gates without running them during planning.

For data, identify object/schema conversion, role/grant mapping, bulk transfer, backfill, incremental synchronization, drift control, validation, retention, and encryption/access ownership. Record source/target write authority per phase.

Select offline versus online/CDC approaches only with verified source/target/tool compatibility and change-rate/downtime assumptions. Carry dump-only assessment limitations into prerequisites for sizing, duration, final schema, and parity validation.

## Delivery automation

Record the selected CI/CD platform, discovered commands/checks, release artifact contract, environment/approval boundaries, and implementation owner. If GitHub Actions is selected or proposed, apply [github-actions-quality.md](github-actions-quality.md) to the blueprint. For another platform, retain its equivalent controls and identify any transition work. Keep runnable workflow files and repository/cloud settings outside this planning package.

## Validation and go/no-go

Plan functional parity/intentional-change testing, API/event/schema compatibility, authorization, connectivity, performance against the baseline, failure/retry/idempotency, observability, backup/restore, UAT, and data reconciliation.

Define each check's owner, environment, measurable pass/fail threshold or deferred measurement, and requirement/acceptance IDs. Identify the authorized go/no-go and rollback decision maker. Treat missing target-sensitive metrics as prerequisites, not completed tests.

## Cutover and rollback

Describe rehearsal, change freeze, initial/final synchronization, source write freeze or controlled routing, validation, traffic switch, monitoring, communication, and decision checkpoints.

For each step, state entry/exit conditions, owner, expected interruption assumptions, abort triggers, and rollback actions as a plan. Include failure modes for partial switch, dual writes, delayed events, auth/session continuity, and integration outages.

After the target accepts writes, traffic reversal alone is not a complete rollback. Define reconciliation/reverse synchronization, compatibility windows, or a forward-recovery point of no return. Preserve source fallback only for a justified retention window with data/security ownership.

## Operations and risks

Plan runbooks, alerts, support handoff, hypercare, training, acceptance sign-off, source decommission gates, retained data/access obligations, and evidence retention. Decommission only after business/data/operations acceptance and rollback window closure.

| Risk ID | Evidence / uncertainty | Probability / impact | Treatment | Owner | Gate / closure evidence |
|---|---|---|---|---|---|

Separate measured estimates from assumption-based scenarios. Include migration effort/spend, coexistence, steady-state operations, licensing, and skills gaps where relevant. Cost estimates remain provisional without verified price and usage inputs.

For every selected target, apply [cost-estimation-handoff.md](cost-estimation-handoff.md). Record phase duration, source/target overlap, temporary services, and active environments; link those wave IDs and durations from `cost-estimate.md` so one-time, coexistence, and steady-state costs remain traceable.

## Completion check

Every component and UI-surface disposition has a delivery/retention/decommission path. Every wave has prerequisites, owner, validation, and rollback/reconciliation rules. Critical unknowns block a firm execution recommendation; accepted deferrals identify the future decision gate.

Record the package revision and status `Ready for review`, or explicit acceptance when the user or governance process requested it, with scope `architecture and migration planning only; implementation not started`. Name downstream delivery owners and their required inputs without invoking execution. Do not require a confirmation turn merely to finish the requested planning package.

Do not use `Awaiting approval`, `Ready for approval`, or an approval checklist as the default terminal state. Those labels imply a blocked interaction and are reserved for a genuinely requested formal acceptance process.
