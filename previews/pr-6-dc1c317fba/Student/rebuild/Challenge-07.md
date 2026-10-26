**[Home](../../README.md)** | [Previous](Challenge-06.md) | [Next](Challenge-08.md)

# Challenge 07: Review Security and Fix Findings

**Estimated Time:** 45 minutes
**Difficulty:** Hard

## Introduction

Review the app you intend to deploy, including frontend changes. Fix and recheck
security findings before deployment.

## Prerequisites

- Challenge 05 complete and Challenge 06 complete or recorded as not applicable.
- The full slice diff, reviewed architecture/trust boundaries, tests, and safe data.
- Copilot CLI `/security-review`, or an equivalent independent security reviewer.

## Description

### Run the security review

In Copilot CLI, run:

```text
/security-review
```

The command covers staged and unstaged changes. Use this prompt to include
committed work as well:

```text
Run a read-only security review of the complete rebuilt slice from [base
revision] through [current revision], including uncommitted frontend changes
and related configuration. Read docs/modernization/delivery-slice.md and the
target architecture's identities, trust boundaries, and data ownership.

Inspect authentication/authorization, input and output handling, injection,
data isolation, file/upload paths, secrets, dependency risks, and deployment
configuration relevant to the slice. Check failure and coexistence paths.
Report actionable findings with severity, file/lines, evidence, impact, and
recommended fix. Separate confirmed findings from assumptions or checks that
could not run. Do not modify code during review.
```

In VS Code, use security review or a named independent reviewer with the same scope.

### Fix and recheck

Select **Fix all issues** when the review offers follow-up actions, or send:

```text
Fix all confirmed security findings from this review, highest severity first.
Keep fixes scoped to the rebuilt slice and preserve functional/UI behavior.
Add regression tests for the exploitable paths where practical. Do not disable
authentication, validation, security tests, or permission controls to pass.
Rerun affected tests/build and report evidence for each fix. Record any finding
that needs a design decision with its owner; do not silently mark it resolved.
Do not deploy yet.
```

Rerun `/security-review`, verify the original findings, and recheck the journey.
Assign unresolved findings to an owner. Resolve deployment blockers before 08.

## Success Criteria

- [ ] Review covers the full slice, including frontend and configuration.
- [ ] Findings include severity, location, evidence, and fix status; unresolved items have owners.
- [ ] Fixes are rechecked, and relevant tests/build and the journey pass.
- [ ] No deployment blocker remains; unavailable checks are listed.

## Hints

<details><summary>Hint 1: Check the review range</summary>
Include committed work from Matt's integration branch, not just uncommitted edits.
</details>

<details><summary>Hint 2: Test denied access too</summary>
Use synthetic identities to test relevant denied paths.
</details>

<details><summary>Hint 3: Verify the original issue</summary>
Rerun the check that exposed each finding.
</details>

## Learning Resources

- [Security design review](https://learn.microsoft.com/azure/well-architected/security/design-review)
- [Copilot CLI reference](https://docs.github.com/en/copilot/reference/cli-command-reference)

## Advanced Challenge (Optional)

Demonstrate a security regression test failing on the pre-fix revision and passing
after the fix, using an isolated test environment.
