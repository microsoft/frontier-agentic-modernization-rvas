---
title: Review Security and Fix Findings
summary: Review security, fix findings and re-check.
phase: Harden
group: Deliver
tags:
- security
highlight: false
---

# Module 07: Review Security and Fix Findings

> **Duration:** ~45 minutes | **Phase:** Harden

## Objective

Review the app you intend to deploy, including frontend changes. Fix and recheck security findings before deployment.

## Prerequisites

- Module 05 complete and Module 06 complete or recorded as not applicable.
- The full app rebuild diff, reviewed architecture and trust boundaries, tests, and safe data.
- Copilot CLI `/security-review`, or an equivalent independent security reviewer.

## Step 1: Run the security review

In Copilot CLI, run:

```text
/security-review the complete rebuilt application from [base
revision] through [current revision], including uncommitted frontend changes
and related configuration. Read the reviewed docs/modernization/ specification
and target architecture's identities, trust boundaries, and data ownership.
```

In VS Code, use security review or a named independent reviewer with the same scope. Include committed work from Matt's integration branch, not just uncommitted edits.

## Step 2: Fix the findings

Select **Fix all issues** when the review offers follow-up actions, or send:

```text
Fix all confirmed security findings from this review, highest severity first.
Keep fixes scoped to the agreed app and preserve functional/UI behavior.
Do not deploy yet.
```

## Step 3: Recheck

Rerun `/security-review`, verify the original findings, and recheck affected workflows. Test relevant denied paths with synthetic identities.

Agree with the stakeholders which confirmed findings block deployment. Record the decision and owner for unresolved findings, and resolve blockers before Module 08. An assigned owner alone does not make a finding acceptable.

## Checkpoint

Before moving on, confirm:

- [ ] The review covers the complete app rebuild, including frontend and configuration.
- [ ] Findings include severity, location, evidence, and fix status; unresolved items have owners.
- [ ] Fixes are rechecked, and relevant tests, build and affected workflows pass.
- [ ] No deployment blocker remains; unavailable checks are listed.

## Reflect

- Can you show a security regression test failing on the pre-fix revision and passing after the fix, in an isolated test environment?

## What You Learned

- Run a security review over the full base-to-head rebuild diff.
- Fix findings by severity and recheck them.
- Decide which findings block deployment.

## Key Takeaway

> Review and recheck the whole rebuild, committed work included, before anything deploys.

## Learn more

- [Security checklist](https://learn.microsoft.com/azure/well-architected/security/checklist)
- [Copilot CLI reference](https://docs.github.com/en/copilot/reference/cli-command-reference)

## Troubleshooting

| Symptom | Fix |
|---|---|
| Security review sees an empty working tree | Request the full committed base-to-head rebuild diff as well. |
| `/security-review` is unavailable | Use a named independent reviewer with the same scope. |
| Denied paths are untested | Use synthetic identities to test the relevant denied paths. |

**Next:** [Module 08: Run and deploy the app to Azure](08-run-and-deploy.md)
