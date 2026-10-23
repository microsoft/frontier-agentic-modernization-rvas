**[Home](../../README.md)** | [Previous](Challenge-02.md) | [Next](Challenge-04.md)

# Challenge 03: Prepare the Implementation Handoff

**Estimated Time:** 30 minutes
**Difficulty:** Medium

## Introduction

A reviewed plan is not yet a bounded implementation request. Before coding,
the delivery team needs to know exactly which journey it will change, which
requirements it must preserve, and how it will demonstrate success.

## Prerequisites

- Challenge 02 completed with a specific reviewed package revision.
- A delivery owner and the people who can resolve slice prerequisites are available.
- Implementation supporting skills are discoverable before the delivery session.

## Description

Use the reviewed package from Challenge 02 to select one end-to-end slice or
migration wave that can be demonstrated within the event. You are preparing
delivery inputs, not generating the planning documents again.

Identify its acceptance IDs, dependencies, intentional changes, preserved
contracts/UI surfaces, data/write ownership, and rollback/reconciliation
boundaries. Establish what evidence will prove the slice works, including
important failure and compatibility paths.

Check readiness in an agreed safe environment using reviewed, documented
build/test commands. Record pre-existing failures, access/tool gaps, and
sanitized fixtures. Resolve prerequisites before implementation; if a blocker
remains, label the slice blocked rather than claiming delivery readiness.
Do not edit application code or provision resources to force this check to pass.

Prepare the handoff described in the [setup guide](setup.md): the package
revision, bounded scope, acceptance IDs, current source/tests, relevant UI/domain
authority, and any required acceptance record. Agree which actions are excluded.
Start a separate `azure-app-rebuild` session only in Challenge 04; planning
completion or acceptance does not start implementation automatically.

## Success Criteria

- [ ] A handoff identifies the reviewed package revision, one bounded slice/wave, acceptance IDs, and delivery owner.
- [ ] Scope records dependencies, preserved behavior/contracts/UI, intentional changes, and data/recovery boundaries.
- [ ] Existing build/test baseline output, safe fixtures, and pre-existing failures or validation gaps are recorded.
- [ ] Slice prerequisites are resolved or have explicit blockers and owners; readiness is not overstated.
- [ ] The separate-session handoff is prepared with required evidence and excluded actions; implementation has not started.

## Hints

<details><summary>Hint 1: Choose a demonstrable outcome</summary>
A complete user journey is more useful than a list of layers to scaffold.
</details>

<details><summary>Hint 2: Check the slice's prerequisites</summary>
A well-written package can still depend on unavailable access, test data,
runtime tooling, or an unresolved write-ownership decision.
</details>

<details><summary>Hint 3: Make the next session self-contained</summary>
Use the setup guide's handoff contract. The delivery session should not need to
guess the reviewed revision, acceptance IDs, or authorization boundaries.
</details>

## Learning Resources

- [Azure pricing overview](https://azure.microsoft.com/pricing/)
- [Safe deployment practices](https://learn.microsoft.com/azure/well-architected/operational-excellence/safe-deployments)

## Advanced Challenge (Optional)

Have another team member explain the slice and its validation approach using
only the prepared handoff. Resolve any ambiguity they find.
