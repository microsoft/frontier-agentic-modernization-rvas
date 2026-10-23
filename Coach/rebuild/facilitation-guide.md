# Rebuild Route: Facilitation Guide

**Coach material.** [Coach home](../README.md) |
[Scoring rubric](scoring-rubric.md)

## Event overview and agenda

This route is architecture-first work on a real customer-owned application.
Do not teach it as "the CLI upgrade workflow with a different app". The customer
brings a business/architectural challenge; a rebuild is a possible strategy, not
a foregone conclusion. Java/.NET are not prerequisites.

Use two days for all seven milestones. Suggested active challenge time is
525 minutes, including package/implementation review challenges, plus breaks,
discussion, and environment troubleshooting.
A four-hour session can aim for setup, the complete planning conversation, and
an initial package review if scope and tools are ready. This is a timebox, not
a guarantee: record incomplete planning honestly and continue later. It is not
a completed rebuild.
Confirm the format and slice with the customer before the event.

| Day | Focus | Pacing |
| --- | --- | --- |
| 1 morning | 00 preparation, 01 complete discovery/planning workflow | Stakeholders attend questions and baseline/target decisions |
| 1 afternoon | 02 package review, 03 implementation handoff | Break after planning; challenge the output before scoping delivery |
| 2 morning | 04 bounded slice | Working journey rather than whole-estate scaffolding |
| 2 afternoon | 05 reviews, 06 rehearsal and handoff | Break before independent review; end with evidence demo |

Use the [participant setup guide](../../Student/rebuild/setup.md) before the event.
Provided plugin bundles three skills, including the complete diagram package.
Install supporting profiles in the application repository, not the workshop repo.
Do not install duplicate diagram copies. Check renderer availability separately.

## Challenge 00: Preparation (30 minutes)

Coach toward a business outcome and one tractable journey. Confirm repository
access, evidence owners, scope, and stakeholder attendance. Missing build access
can be a planning gap but must be resolved before executable slice validation.
If the challenge is only an isolated runtime upgrade, redirect to
[Upgrade your application](../../Student/customer/Challenge-00.md).

Watch for copying customer code into this tooling repo or installing every Azure
skill indiscriminately. A customer-owned public repository is not inherently
invalid; ownership and authorized use matter, not repository visibility.

## Challenge 01: Complete discovery and planning (150 minutes)

The team starts `azure-app-modernization` once. Its analysis, interview rounds,
baseline confirmation, strategy comparison/selection, and eight-document package
are one interactive workflow. Documents can appear progressively; do not ask
teams to stop after assessment or invoke the skill again for each document.

Coach participants on supplying evidence and making decisions, not manually
orchestrating internal phases. Trace permissions, side effects, failures, and
UI authority. Do not accept absent evidence as proof of no dependency. Confirm
the baseline before selecting a target, and record selection or bounded delegation.

The skill also consults the diagram and cost specialists within this workflow.
Check that handoff includes all eight artifacts, pricing status/attempted-source
blockers, diagrams/review limitations, and migration waves. Ordinary completion is
`Ready for review`; do not add an unsolicited final approval gate.

If the timebox expires, record the current phase and unresolved decisions.
Narrow scope only with stakeholder agreement; do not skip decision gates or
claim complete coverage. The planning skill stops after its package handoff,
even when the original request said "implement".

## Challenge 02: Review and challenge the package (45 minutes)

Review the already generated package, not another generation stage. Trace a
critical journey from source through requirements, architecture, and migration
waves. Challenge unjustified microservices, Kubernetes, engine swaps, or UI
redesign. Check lower-change options, official target evidence, cost assumptions,
write ownership, coexistence, and recovery.

A concrete pricing-tool blocker is an honest limitation; skipping the pricing
attempt is not. Request targeted corrections in the existing planning workflow
and reconcile affected artifacts. Reopen only material decisions affected by new
evidence, with their owners, rather than restarting discovery unnecessarily.
Record the reviewed revision and each finding's disposition/owner.

The bundled diagram offline tests validate structure/assets, not visual approval.
Render and independently review when tooling is available. Record any missing
review and required governance exception. Formal package acceptance applies only
when required by the customer's governance.

## Challenge 03: Prepare the implementation handoff (30 minutes)

Use the reviewed package to bound one end-to-end slice, acceptance IDs,
dependencies, preserve/change commitments, write ownership, and recovery limits.
Check the existing safe build/test baseline, fixtures, tools, access, and
pre-existing failures. A planning evidence gap can become a delivery blocker.
Do not fix code or provision resources as a readiness shortcut.

Require a handoff that another team member can understand without guessing:
package revision, selected slice, acceptance/validation evidence, prerequisites,
UI/domain authority, delivery owner, and excluded actions. Keep unresolved
blockers visible. No new document-generation phase or automatic implementation
is needed here.

Challenge 04 starts a separate delivery session with `azure-app-rebuild`.

## Challenge 04: Slice (150 minutes)

Require package revision, scope, acceptance IDs, and a safe runnable baseline.
Forbid accidental expansion to "finish the entire application". Check preserved
business/UI contracts. Data adapters or routing seams need clear write ownership.

Do not invoke upstream `implement` unattended; it includes a commit step.
Our delivery skill does not commit or operate cloud resources by default.
For a blocked team, reduce the slice only with explicit scope/acceptance changes.
For an ahead team, strengthen failure-path and compatibility evidence before
starting another wave.

## Challenge 05: Reviews (60 minutes)

Completeness first, security separately. Require actual validation output and
finding dispositions. Missing independent tooling gets a named human owner,
not a pass. Resolve defects and rerun affected tests. Keep accepted risks distinct
from fixed findings.

## Challenge 06: Operations (60 minutes)

Only perform authorized non-production actions. Without an environment, score a
clearly labeled tabletop result separately from a live rehearsal. Ask how target
writes are reconciled during rollback; "switch DNS back" is not sufficient.
End with the slice demo, acceptance ledger, next-wave prerequisites, and owners.

## Common stuck points and pivots

| Stuck point | Coaching response |
| --- | --- |
| Team expects planning to edit source | Point to the explicit planning stop and separate delivery skill |
| Team restarts the skill for each document | Challenge 01 generates the full package in one workflow; 02 reviews it and 03 prepares delivery |
| Legacy app will not run | Continue bounded static discovery; resolve or own the runtime blocker before delivery |
| Existing UI is replaced with generic screens | Return to product/design authority and approved surface dispositions |
| Diagram XML passes but no rendering exists | Record structural pass only; assign visual review |
| Agent invents cost totals | Require pricing evidence or attempted-source/tool blocker |
| All event time spent analyzing the entire portfolio | Confirm a smaller application boundary with the stakeholder |
