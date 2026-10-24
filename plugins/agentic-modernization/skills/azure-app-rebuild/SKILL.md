---
name: azure-app-rebuild
description: "Implement one explicitly scoped wave or vertical slice from a reviewed existing-application modernization package. Use for a separately requested rearchitecture or rebuild after functional discovery and target selection, preserving requirements, external contracts, data ownership, and incumbent UI authority. Not for initial assessment, isolated runtime upgrades, greenfield design, automatic deployment, or production data migration."
disable-model-invocation: true
---

# Azure App Rebuild

Implement a bounded part of the customer's selected modernization strategy in
their application repository. This is a separate delivery workflow, never an
automatic continuation of `azure-app-modernization`.

## 1. Reconcile the delivery contract

Read the current repository instructions and the complete package under
`docs/modernization/`: `assessment.md`, `specification.md`, `strategy-matrix.md`,
`target-architecture.md`, `cost-estimate.md`, `current-state.drawio`,
`target-architecture.drawio`, and `migration-plan.md`. Inspect the source, tests,
manifests, data contracts, deployment configuration, domain records, and relevant
UI authority. Discover available supporting skills instead of assuming installation.

Require an explicitly requested wave or vertical slice with acceptance IDs,
preserve/change/retire decisions, prerequisites, and validation evidence expected
at completion. If scope is absent, propose a small end-to-end slice and obtain a
decision before editing. A reviewed package need not carry formal approval unless
the customer's governance requires it. Check any required acceptance record.

Compare current source with the confirmed baseline and selected target. Identify
stale evidence, missing artifacts, contradictions, and unresolved feasibility
blockers. Stop affected implementation and return material architecture changes
to planning; do not invent a target, acceptance criteria, or approval.

Readiness for static planning is not readiness to execute: establish a repeatable
build/test approach, safe fixtures, and required local access for this slice.
Record pre-existing failures separately. Do not execute unknown scripts, restore
database backups, or use production credentials simply to establish a baseline.

## 2. Implement the smallest complete slice

Follow migration-wave dependency order. Use existing patterns and preserve all
behavior and contracts not explicitly changed by the specification. Keep unrelated
components untouched. Use `codebase-design`, `tdd`, or `diagnosing-bugs` for bounded
support when installed, without granting those skills broader scope.

For UI work, load `impeccable` when available and use `PRODUCT.md`, `DESIGN.md`,
`.impeccable/design.json`, and confirmed `SURF-` dispositions as authority. New
frontend technology does not authorize redesign. Report missing design evidence
before changing affected surfaces.

For data/integration changes, preserve write ownership, ordering, idempotency,
compatibility, coexistence, and rollback/reconciliation boundaries from the plan.
Use synthetic or sanitized data. Author migration/IaC/CI files only when in the
requested slice; generating them does not authorize running them.

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

Review implementation completeness against requirements, wave dependencies, data
and UI commitments, and directly related documentation. Use the host's code-review
workflow or installed `code-review` skill, then resolve findings and rerun affected
checks. Run a separate security review after completeness findings are resolved
or explicitly accepted. If independent review or runtime tooling is unavailable,
name the missing review/check and its owner; do not claim it passed.

## 4. Hand off and stop

Report the package revision and implemented wave, changed files, acceptance IDs
with pass/fail/blocked evidence, review findings and disposition, pre-existing
failures, remaining prerequisites, and rollback/reconciliation readiness.
Distinguish local validation from deployment or production readiness.

A blocked criterion means the slice is incomplete or explicitly partial, not done.
Do not advance to the next wave automatically. Use `handoff` when available to
preserve context for the next session. Leave commits and operational execution
to separately authorized actions.
