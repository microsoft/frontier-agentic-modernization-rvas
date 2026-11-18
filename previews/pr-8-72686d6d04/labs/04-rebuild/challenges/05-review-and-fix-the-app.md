---
title: Review the App and Implement Missing Behavior
summary: Review the app and implement missing behavior.
phase: Build
group: Build
tags:
- review
highlight: false
---

# Module 05: Review the App and Implement Missing Behavior

> **Duration:** ~60 minutes | **Phase:** Build

## Objective

Review the code and running application against the specification, then implement what is missing.

## Prerequisites

- Module 04 has an implemented application and recorded test results.
- The reviewed package, implementation diff, and review tools or human reviewers.

## Step 1: Review the implementation

In Copilot CLI, run:

```text
/review the complete rebuilt application against the reviewed
docs/modernization/ specification and architecture, and [framework spec/tickets/tasks,
if used]. Cover all rebuild changes from [base revision] to [current revision],
plus uncommitted changes, not just the last edit. Identify required workflows
that are missing entirely, not only defects in changed files.
```

If `/review` is unavailable in VS Code, use code review and a separate read-only conversation with the same prompt. Framework reviews do not replace this review.

## Step 2: Exercise every workflow

Run the app and exercise every required workflow with sanitized fixtures, including relevant permission and failure paths. Record pass, fail or blocked results against the acceptance IDs and add failures to the review findings.

## Step 3: Implement the findings

Check the findings, then send:

```text
Implement the missing in-scope behavior and defects identified by the app review:
[findings and acceptance IDs]. Keep the reviewed architecture and agreed app scope.
Add focused regression tests that fail without the fixes. Run the relevant
tests, build, and affected end-to-end workflows with sanitized data. Update acceptance
evidence and framework tickets/tasks. Report fixed, unresolved, and blocked
items separately. Do not add new features, deploy, or migrate production data.
```

## Step 4: Review the fixes

Run `/review` on the fixes and recheck acceptance. Resolve missing in-scope behavior before frontend refinement in Module 06 and security review in Module 07.

## Checkpoint

Before moving on, confirm:

- [ ] Every in-scope acceptance ID has actual pass, fail or blocked results.
- [ ] The review records its scope, reviewer, findings, and outcomes.
- [ ] Missing behavior is implemented, tested, and reviewed.
- [ ] Remaining risks or unavailable checks have owners; deployment is still pending.

## What You Learned

- Review a complete rebuild, including workflows missing entirely.
- Keep an acceptance ledger of pass, fail and blocked results.
- Fix findings with regression tests that fail without the fix.

## Key Takeaway

> Review the whole rebuilt app against the specification, not just the last edit.

## Learn more

- [Copilot CLI reference](https://docs.github.com/en/copilot/reference/cli-command-reference)
- [Operational excellence checklist](https://learn.microsoft.com/azure/well-architected/operational-excellence/checklist)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `/review` only covers the last edit | Name the base and current revisions in the prompt and include uncommitted changes. |
| `/review` is unavailable in VS Code | Use code review and a separate read-only conversation with the same prompt. |
| A required workflow is missing entirely | Add it to the findings and implement it in Step 3. |

**Next:** [Module 06: Refine the frontend with Impeccable](06-refine-the-frontend.md)
