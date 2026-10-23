**[Home](../../README.md)** | [Previous](Challenge-01.md) | [Next](Challenge-03.md)

# Challenge 02: Review and Challenge the Modernization Package

**Estimated Time:** 45 minutes
**Difficulty:** Hard

## Introduction

An AI-generated package can look coherent while missing an important rule,
overstating evidence, or recommending unnecessary complexity. Your task is to
challenge the completed output against the real application before treating it
as a delivery contract.

## Prerequisites

- Challenge 01 completed with the full planning package handed off.
- Source evidence and decision owners are available to check the package.

## Description

Review the package generated in Challenge 01; this is not another generation
phase. Trace critical journeys from source evidence through requirements,
component/UI dispositions, the selected architecture, and migration waves.
Check that preserved contracts and intentional changes match stakeholder answers.

Challenge the strategy comparison, including a lower-change option where feasible.
Check official evidence for claims that depend on the target, cost assumptions
and pricing status, integration/data ownership, coexistence, and recovery limits.
Open the editable diagrams and distinguish structural, rendered, and independent review.

Record discrepancies and request targeted corrections in the existing planning
workflow. Material new evidence reopens only the affected baseline or target
decision; it does not justify silently replacing the architecture or rerunning
everything from scratch. Reconcile changed artifacts before handing off a
specific reviewed revision.

Formal package acceptance is only required when your governance requests it.
An unresolved blocker or missing review must remain visible with an owner; do
not label the package implementation-ready merely because all files exist.

## Success Criteria

- [ ] A reviewed journey traces source evidence through stable requirement/acceptance IDs, architecture responsibilities, and migration waves.
- [ ] Review findings cover behavior/UI preservation, strategy alternatives, official target evidence, costs, and recovery assumptions.
- [ ] Both editable diagrams have honest structural, rendered, and independent review statuses.
- [ ] Findings are corrected or have a recorded decision and owner; affected artifacts and decision records are consistent.
- [ ] The reviewed package revision and any required acceptance are recorded, with remaining delivery blockers visible.

## Hints

<details><summary>Hint 1: Challenge a real promise</summary>
Choose an important business rule and verify that the package preserves or
intentionally changes it, rather than reviewing prose in isolation.
</details>

<details><summary>Hint 2: Test assumptions</summary>
Ask what proves a service is compatible, a cost is priced, or a rollback can
reconcile writes. Missing evidence is not a verified answer.
</details>

<details><summary>Hint 3: Request bounded corrections</summary>
Give the planning workflow the finding and evidence. Reopen material decisions
with their owners, then reconcile the affected documents instead of regenerating blindly.
</details>

## Learning Resources

- [Azure Architecture Center](https://learn.microsoft.com/azure/architecture/)
- [Strangler Fig pattern](https://learn.microsoft.com/azure/architecture/patterns/strangler-fig)

## Advanced Challenge (Optional)

Have an independent reviewer challenge the highest-risk assumption and record
how the finding changed, or confirmed, the package.
