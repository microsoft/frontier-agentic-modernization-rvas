---
name: azure-app-rebuild
description: "Implement an explicitly scoped complete application, migration wave, or vertical slice from a reviewed existing-application modernization package. Use for a separately requested rearchitecture or rebuild after functional discovery and target selection, preserving requirements, external contracts, data ownership, and incumbent UI authority. Implement incrementally and verify the full requested scope before reporting completion. Not for initial assessment, isolated runtime upgrades, greenfield design, automatic deployment, or production data migration."
disable-model-invocation: true
---

# Azure App Rebuild

Implement the customer's explicitly requested application, wave, or slice in
their application repository. A complete-app rebuild is a supported delivery
scope, not a requirement to rewrite everything in one pass. This is a separate
delivery workflow, never an automatic continuation of `azure-app-modernization`.

## 1. Reconcile the delivery contract

Read the current repository instructions and the complete package under
`docs/modernization/`: `assessment.md`, `specification.md`, `strategy-matrix.md`,
`target-architecture.md`, `infrastructure-plan.md`, `cost-estimate.md`,
`current-state.drawio`, `target-architecture.drawio`, and `migration-plan.md`.
Inspect the source, tests,
manifests, data contracts, deployment configuration, domain records, and relevant
UI authority. Discover available supporting skills instead of assuming installation.

Require an explicit delivery scope: **complete application**, **migration wave**,
or **vertical slice**, with its boundary, acceptance IDs, preserve/change/retire
decisions, prerequisites, and expected validation evidence. Use the reviewed
package and explicit delivery request directly; do not require another summary
or handoff document. If scope is missing or ambiguous, obtain a decision before editing;
do not assume either an unrestricted rewrite or a single-slice outcome.
A reviewed package need not carry formal approval unless the customer's
governance requires it. Check any required acceptance record.

For complete-app scope, account for every required workflow, integration, and
applicable UI surface in the reviewed specification. Track coverage in existing
task/test records or the response, linking workflows to acceptance IDs,
implementation work, tests/checks, and pass/fail/blocked evidence.
Resolve gaps in required behavior or acceptance
criteria with the decision owner rather than inventing criteria or silently
dropping workflows. An intentional retirement needs a recorded package decision.

Compare current source with the confirmed baseline and selected target. Identify
stale evidence, missing artifacts, contradictions, and unresolved feasibility
blockers. Stop affected implementation and return material architecture changes
to planning; do not invent a target, acceptance criteria, or approval.

Readiness for static planning is not readiness to execute: establish a repeatable
build/test approach, safe fixtures, and required local access for the requested
scope.
Record pre-existing failures separately. Do not execute unknown scripts, restore
database backups, or use production credentials simply to establish a baseline.

## 2. Implement incrementally within the agreed scope

Break the agreed scope into testable end-to-end increments and follow the
reviewed dependency order. For complete-app delivery, continue through the
increments inside that scope while prerequisites hold; a working first journey
is a checkpoint, not completion. Do not require a new scope decision for each
already-agreed increment, or stop after one merely because it works.
For a wave or slice request, keep later waves and unrelated workflows out of scope.
Material blockers or architecture changes still require the affected work to stop.

Use existing patterns and preserve all behavior and contracts not explicitly
changed by the specification. Keep unrelated
components untouched. Use `codebase-design`, `tdd`, or `diagnosing-bugs` for bounded
support when installed, without granting those skills broader scope.

For UI work, load `impeccable` when available and use `PRODUCT.md`, `DESIGN.md`,
`.impeccable/design.json`, and confirmed `SURF-` dispositions as authority. New
frontend technology does not authorize redesign. Report missing design evidence
before changing affected surfaces.

For data/integration changes, preserve write ownership, ordering, idempotency,
compatibility, coexistence, and rollback/reconciliation boundaries from the plan.
Use synthetic or sanitized data. Author migration/IaC/CI files only when in the
agreed scope; generating them does not authorize running them. Use
`infrastructure-plan.md` to reconcile the app's configuration, identity, and
dependency needs with the provided infrastructure contract.

Do not use the upstream `implement` skill as an unattended wrapper: its contract
includes committing work. Do not commit, publish issues, provision resources,
deploy, migrate production data, or change repository/cloud settings without
explicit authorization for that action in this delivery session. Tool permission
prompts and repository controls remain in force.

## 3. Validate and review

Add focused tests for changed behavior, including important failure and
compatibility paths. Run the smallest relevant existing checks, expanding to
integration/build checks as needed. Verify every in-scope acceptance criterion
with actual output; a generated test or workflow file is not a passed check.

For complete-app scope, reconcile workflow coverage against the full reviewed
specification, including workflows absent from the implementation diff. Exercise
the app's required workflows and integrations with safe fixtures; record
unavailable checks as blocked. Passing one journey, a build, or an increment's
tests does not establish whole-app completion.

Review implementation completeness against requirements, wave dependencies, data
and UI commitments, and directly related documentation. Use the host's code-review
workflow or installed `code-review` skill, then resolve findings and rerun affected
checks. Run a separate security review after completeness findings are resolved
or explicitly accepted. If independent review or runtime tooling is unavailable,
name the missing review/check and its owner; do not claim it passed.

## 4. Report results and stop

Report the package revision, requested delivery scope, completed increments,
changed files, acceptance IDs with pass/fail/blocked evidence, review findings
and disposition, pre-existing
failures, remaining prerequisites, and rollback/reconciliation readiness.
Distinguish local validation from deployment or production readiness.

A failed, blocked, or uncovered required criterion means the requested scope is
incomplete or explicitly partial, not done. For a complete-app request, report
remaining workflows and blockers even when several increments are finished.
Do not silently relabel partial delivery as a smaller successful scope.
Stop at the agreed app/wave/slice boundary; do not advance to an unrequested wave
or expand the application. Leave commits and operational execution to
separately authorized actions.
