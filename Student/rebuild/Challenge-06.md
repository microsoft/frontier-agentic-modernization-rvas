**[Home](../../README.md)** | [Previous](Challenge-05.md)

# Challenge 06: Rehearse Operations and Hand Off

**Estimated Time:** 60 minutes
**Difficulty:** Expert

## Introduction

A safe modernization needs a plan for operation and recovery. The event can
validate that plan for a bounded slice without promising a production cutover.

## Prerequisites

- Challenge 05 results and unresolved prerequisites are visible.
- An authorized non-production environment, or an explicitly limited tabletop scope.

## Description

Establish the slice's build/test/deploy blueprint, observability, identities,
artifact promotion, and recovery responsibilities. Use the chosen Azure target,
not a mandatory container platform.

If environment access and explicit operational authorization are available,
rehearse deployment and rollback with safe data. Otherwise conduct a tabletop
exercise and identify the missing live checks; do not claim a deployment passed.
Production data migration is outside this event's default scope.

Hand off the implemented slice, acceptance evidence, review decisions, cost
assumptions, remaining waves, and owners. Distinguish routing rollback from data
reconciliation when the new system has accepted writes.

## Success Criteria

- [ ] Build/test/deploy responsibilities and observability signals are documented for the slice.
- [ ] Rehearsal evidence identifies environment, authorization, result, and recovery limits, or explicitly states tabletop-only.
- [ ] Data/write ownership and rollback/reconciliation boundaries are explained.
- [ ] Outstanding checks and subsequent waves have prerequisites and owners.
- [ ] The team demonstrates the completed slice and honestly reports remaining work.

## Hints

<details><summary>Hint 1: Focus on the operator</summary>
Describe how someone detects a failed journey and decides whether to recover.
</details>

<details><summary>Hint 2: Separate artifact from execution</summary>
A workflow file or deployment manifest is not a successful release.
</details>

<details><summary>Hint 3: Check writes during coexistence</summary>
Explain what happens to writes accepted only by the target before proposing
traffic reversal as rollback.
</details>

## Learning Resources

- [Safe deployment practices](https://learn.microsoft.com/azure/well-architected/operational-excellence/safe-deployments)
- [Disaster recovery strategy](https://learn.microsoft.com/azure/well-architected/reliability/disaster-recovery)

## Advanced Challenge (Optional)

Run a non-production failure rehearsal and use telemetry to demonstrate the
recovery decision, not just the healthy path.
