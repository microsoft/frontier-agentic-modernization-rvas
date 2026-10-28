**[Home](../../README.md)** | [Previous](Challenge-06.md) | [Next](Challenge-08.md)

# Challenge 07: Review Security and Fix Findings

**Estimated Time:** 45 minutes

## Introduction

Review the app you intend to deploy, including frontend changes. Fix and recheck
security findings before deployment.

## Prerequisites

- Challenge 05 complete and Challenge 06 complete or recorded as not applicable.
- The full app rebuild diff, reviewed architecture/trust boundaries, tests, and safe data.
- Copilot CLI `/security-review`, or an equivalent independent security reviewer.

## Description

### Run the security review

In Copilot CLI, run:

```text
/security-review the complete rebuilt application from [base
revision] through [current revision], including uncommitted frontend changes
and related configuration. Read docs/modernization/rebuild-handoff.md and the
target architecture's identities, trust boundaries, and data ownership.
```

In VS Code, use security review or a named independent reviewer with the same scope.

### Fix and recheck

Select **Fix all issues** when the review offers follow-up actions, or send:

```text
Fix all confirmed security findings from this review, highest severity first.
Keep fixes scoped to the agreed app and preserve functional/UI behavior.
Do not deploy yet.
```

Rerun `/security-review`, verify the original findings, and recheck affected
workflows. Agree with the coach which confirmed findings block deployment.
Record the decision and owner for unresolved findings; resolve blockers before
08. An assigned owner alone does not make a finding acceptable.

## Success Criteria

- [ ] Review covers the complete app rebuild, including frontend and configuration.
- [ ] Findings include severity, location, evidence, and fix status; unresolved items have owners.
- [ ] Fixes are rechecked, and relevant tests/build and affected workflows pass.
- [ ] No deployment blocker remains; unavailable checks are listed.

## Hints

<details><summary>Hint 1: Check the review range</summary>
Include committed work from Matt's integration branch, not just uncommitted edits.
</details>

<details><summary>Hint 2: Test denied access too</summary>
Use synthetic identities to test relevant denied paths.
</details>

## Learning Resources

- [Security design review](https://learn.microsoft.com/azure/well-architected/security/design-review)
- [Copilot CLI reference](https://docs.github.com/en/copilot/reference/cli-command-reference)

## Advanced Challenge (Optional)

Demonstrate a security regression test failing on the pre-fix revision and passing
after the fix, using an isolated test environment.
