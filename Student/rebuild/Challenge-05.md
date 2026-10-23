**[Home](../../README.md)** | [Previous](Challenge-04.md) | [Next](Challenge-06.md)

# Challenge 05: Validate Completeness and Security

**Estimated Time:** 60 minutes
**Difficulty:** Hard

## Introduction

A passing build proves less than a working business journey. Independent reviews
need to distinguish missing functionality from security findings and both from
checks that could not run.

## Prerequisites

- Challenge 04 has an implemented slice and recorded test results.
- The reviewed package, implementation diff, and review tools or human reviewers.

## Description

Review implementation completeness against the package, including requirement IDs,
wave order, acceptance evidence, data boundaries, UI preservation, tests, and
related documentation. Resolve or explicitly accept those findings before a
separate security review.

Examine identity, authorization, input validation, data isolation, secrets,
dependency/configuration risks, and coexistence paths in the security review.
Resolve findings and rerun affected tests. Record reviewer/tool gaps with owners.
Neither a generated test file nor a missing reviewer counts as a passed check.

## Success Criteria

- [ ] Every in-scope acceptance ID has pass/fail/blocked evidence tied to actual output.
- [ ] A completeness review identifies its scope, reviewer, findings, and disposition.
- [ ] A separate security review has findings/disposition or a named outstanding review owner.
- [ ] Fixed findings have rerun validation evidence; accepted risks identify a decision owner.
- [ ] The team distinguishes slice completion from deployment or production readiness.

## Hints

<details><summary>Hint 1: Trace the promise</summary>
Read the specification next to the diff and validation output.
</details>

<details><summary>Hint 2: Keep reviews distinct</summary>
A completeness review can find missing acceptance work without being a security
assessment.
</details>

<details><summary>Hint 3: Use your host's tools</summary>
The setup guide names CLI review commands and VS Code alternatives. Use a named
human reviewer when independent tooling is unavailable.
</details>

## Learning Resources

- [Security design review](https://learn.microsoft.com/azure/well-architected/security/design-review)
- [Operational excellence design review](https://learn.microsoft.com/azure/well-architected/operational-excellence/design-review)

## Advanced Challenge (Optional)

Add a regression test for the highest-impact finding and demonstrate that it
fails against the pre-fix implementation.
