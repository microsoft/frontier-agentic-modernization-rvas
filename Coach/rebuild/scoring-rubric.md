# Rebuild Route: Scoring Rubric

[Facilitation guide](facilitation-guide.md) | [Coach home](../README.md)

## Evaluation criteria

Score each milestone **Done (2)**, **Partially Done (1)**, or **Not Done (0)**.
Done requires observable evidence for every applicable participant criterion.
Named blockers count as partial outcomes, not automatic passes.
Each spot check below should take under two minutes once the evidence is open.

| Challenge | Verification | Expected evidence |
| --- | --- | --- |
| 00 | Read the brief and inspect host skills | Customer journey, decision owners, route rationale, three bundled skills and chosen supporting profiles |
| 01 | List `docs/modernization/` and inspect the conversation/handoff | Complete eight-artifact package from one planning workflow, stakeholder decisions, pricing/review statuses, explicit planning stop |
| 02 | Trace one journey across the package and inspect review findings | Evidence/requirement/wave links, challenged strategy/cost/recovery assumptions, targeted corrections, reviewed revision |
| 03 | Ask a teammate to explain the prepared delivery handoff | Bounded slice, acceptance IDs, dependencies, preserved contracts/UI/data, safe baseline output, prerequisites/owners and excluded actions |
| 04 | Run the documented targeted build/test command and demonstrate one journey | Current-source reconciliation, bounded slice, passing relevant checks, compatibility evidence |
| 05 | Read acceptance ledger and both review records | Actual pass/fail/blocked output, distinct completeness/security findings and disposition |
| 06 | Inspect rehearsal record and next-wave handoff | Live environment/result or explicit tabletop limitation, recovery boundaries and owners |

## Verification examples

In the **application repository**, list package artifacts:

```bash
ls docs/modernization/
git diff --stat
```

Expect `assessment.md`, `specification.md`, `strategy-matrix.md`,
`target-architecture.md`, `cost-estimate.md`, `current-state.drawio`,
`target-architecture.drawio`, and `migration-plan.md`. UI authority can live
outside that directory. A filename check alone does not establish content quality.
During planning, diff changes should stay within the planning skill's artifact
boundary. During delivery, changes should map to the requested slice.

Challenge 01 produces the full package; do not score assessment, strategy,
and architecture as three separate skill runs. Challenge 02 scores critical
review and correction of that output. Challenge 03 scores a usable, bounded
delivery handoff. A documented unresolved prerequisite is honest handoff evidence,
but the team must not claim the slice is ready to implement while it remains blocked.

Use the customer's documented test command rather than inventing a universal
build command. Require actual output and environment details. Do not run unknown
scripts or production migrations as a scoring shortcut.

## Overall scoring

- **12-14:** Strong bounded modernization delivery with explicit remaining work.
- **8-11:** Useful progress; identify incomplete acceptance and operating evidence.
- **0-7:** Planning or delivery remains substantially incomplete; hand off blockers.

Planning-only attendance is evaluated against 00-03, with a maximum of 8 points,
and must not be described as a completed rebuild. A tabletop-only 06 is partial
for operational validation even when its documentation is strong.

## Advanced challenges

Award up to 2 separate bonus points for demonstrated incumbent/target coexistence
with unambiguous write ownership or a non-production failure/recovery rehearsal.
Bonus work cannot cancel a failed acceptance criterion or missing security review.
