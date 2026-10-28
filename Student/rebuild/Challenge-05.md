**[Home](../../README.md)** | [Previous](Challenge-04.md) | [Next](Challenge-06.md)

# Challenge 05: Review the App and Implement Missing Behavior

**Estimated Time:** 60 minutes

## Introduction

Review the code and running application against the specification, then implement
what is missing.

## Prerequisites

- Challenge 04 has an implemented application and recorded test results.
- The reviewed package, implementation diff, and review tools or human reviewers.

## Description

### Review the implementation

In Copilot CLI, run:

```text
/review the complete rebuilt application against the reviewed
docs/modernization/ specification and architecture, and [framework spec/tickets/tasks,
if used]. Cover all rebuild changes from [base revision] to [current revision],
plus uncommitted changes, not just the last edit. Identify required workflows
that are missing entirely, not only defects in changed files.
```

If `/review` is unavailable in VS Code, use code review and a separate read-only
conversation with the same prompt.

Run the app and exercise every required workflow with sanitized fixtures,
including relevant permission and failure paths. Record pass/fail/blocked
results against the acceptance IDs and add failures to the review findings.

### Implement the findings

Check the findings, then send:

```text
Implement the missing in-scope behavior and defects identified by the app review:
[findings and acceptance IDs]. Keep the reviewed architecture and agreed app scope.
Add focused regression tests that fail without the fixes. Run the relevant
tests, build, and affected end-to-end workflows with sanitized data. Update acceptance
evidence and framework tickets/tasks. Report fixed, unresolved, and blocked
items separately. Do not add new features, deploy, or migrate production data.
```

Run `/review` on the fixes and recheck acceptance. Resolve missing in-scope
behavior before frontend refinement in 06 and security review in 07.

## Success Criteria

- [ ] Every in-scope acceptance ID has actual pass/fail/blocked results.
- [ ] The review records its scope, reviewer, findings, and outcomes.
- [ ] Missing behavior is implemented, tested, and reviewed.
- [ ] Remaining risks or unavailable checks have owners; deployment is still pending.

## Learning Resources

- [Copilot CLI reference](https://docs.github.com/en/copilot/reference/cli-command-reference)
- [Operational excellence design review](https://learn.microsoft.com/azure/well-architected/operational-excellence/design-review)
