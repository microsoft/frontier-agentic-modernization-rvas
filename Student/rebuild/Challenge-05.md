**[Home](../../README.md)** | [Previous](Challenge-04.md) | [Next](Challenge-06.md)

# Challenge 05: Review the App and Implement Missing Behavior

**Estimated Time:** 60 minutes
**Difficulty:** Hard

## Introduction

Review the code and running journey against the specification, then implement
what is missing.

## Prerequisites

- Challenge 04 has an implemented slice and recorded test results.
- The reviewed package, implementation diff, and review tools or human reviewers.

## Description

### Review the implementation

In Copilot CLI, run:

```text
/review
```

Include the full slice diff, even if already committed. Then check specification
coverage with this prompt:

```text
Review the implemented slice against docs/modernization/delivery-slice.md,
the reviewed specification and architecture, and [framework spec/tickets/tasks,
if used]. Cover the full slice diff from [base revision] to [current revision],
plus uncommitted changes, not just the last edit.

Trace every acceptance ID to code, actual test output, and the running journey.
Find missing business rules, permissions, failure handling, compatibility,
data/UI behavior, and integration work. Do not count mocks or scaffolding as a
working capability. Return findings with requirement IDs, evidence, and impact.
Keep this review read-only; identify checks that could not run.
```

If `/review` is unavailable in VS Code, use code review and a separate read-only
conversation with the same prompt.

### Implement the findings

Check the findings, then send:

```text
Implement the missing in-scope behavior and defects identified by the app review:
[findings and acceptance IDs]. Keep the reviewed architecture and slice boundary.
Add focused regression tests that fail without the fixes. Run the relevant
tests, build, and the end-to-end journey with sanitized data. Update acceptance
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

## Hints

<details><summary>Hint 1: Trace the promise</summary>
Read the specification next to the diff and validation output.
</details>

<details><summary>Hint 2: Keep reviews distinct</summary>
Check missing functionality here; security review follows in Challenge 07.
</details>

<details><summary>Hint 3: Use your host's tools</summary>
If independent review tools are unavailable, use a named human reviewer.
</details>

## Learning Resources

- [Copilot CLI reference](https://docs.github.com/en/copilot/reference/cli-command-reference)
- [Operational excellence design review](https://learn.microsoft.com/azure/well-architected/operational-excellence/design-review)

## Advanced Challenge (Optional)

Add a regression test for the highest-impact finding and demonstrate that it
fails against the pre-fix implementation.
