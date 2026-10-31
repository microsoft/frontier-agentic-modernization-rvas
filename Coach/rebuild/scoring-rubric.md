# Rebuild Route: Scoring Rubric

[Facilitation guide](facilitation-guide.md) | [Coach home](../README.md)

## Evaluation criteria

Score each milestone **Done (2)**, **Partially Done (1)**, or **Not Done (0)**.
Done requires evidence for all applicable criteria; recording a blocker is not a pass.
Each spot check should take under two minutes with the evidence open.

| Challenge | Verification | Expected evidence |
| --- | --- | --- |
| 00 | Read the brief and inspect host skills | Complete app small enough for the event, decision owners, route rationale, three bundled skills and chosen supporting profiles |
| 01 | List `docs/modernization/` and inspect the conversation/handoff | Complete nine-artifact package from one planning workflow, stakeholder decisions, pricing/review statuses, explicit planning stop |
| 02 | Inspect workflow coverage, trace a critical journey, and read review findings | Evidence/requirement/wave links, challenged strategy/cost/recovery assumptions, targeted corrections, reviewed revision |
| 03 | Ask a teammate to identify the chosen workflow and implementation starting point | Opus 5.5, reviewed package revision, complete-app scope, baseline, acceptance IDs, framework artifacts derived from the package, infrastructure contract/gaps |
| 04 | Run documented checks and inspect evidence for all required workflows | Chosen path, complete application, current-source reconciliation, passing checks; Matt's path stays within two concurrent subagents |
| 05 | Inspect `/review`, completeness findings, and fix output | Full rebuild diff, acceptance ledger, missing behavior implemented, regression checks and re-review |
| 06 | Inspect confirmed brief and rendered before/after views | Approved improvements, layout/color findings resolved or justified no-change result, responsive/state checks, functional regression evidence; N/A only for no UI |
| 07 | Inspect security findings, fixes, and re-review | Complete-app scope, dispositions, regression evidence, no deployment blockers |
| 08 | Exercise Azure endpoint and inspect deployment/handoff | Complete non-production app using provided infrastructure, acceptance/health/telemetry evidence, recovery and cleanup owners |

## Verification examples

In the **application repository**, list package artifacts:

```bash
ls docs/modernization/
git diff --stat
```

Look for `assessment.md`, `specification.md`, `strategy-matrix.md`,
`target-architecture.md`, `infrastructure-plan.md`, `cost-estimate.md`, `current-state.drawio`,
`target-architecture.drawio`, and `migration-plan.md`. UI context may live elsewhere.
Check content, not just filenames. Planning changes stay within the skill's
document scope; implementation changes stay within the agreed app boundary.

Use the application's documented test commands and actual output. Do not run
unknown scripts or production migrations to score a challenge.
For a headless app, mark 06 **not applicable** and exclude it from the denominator.

## Overall scoring

With a UI, the maximum is **18 points**; without a UI it is **16 points**.
Report earned/applicable points. Completed delivery requires all agreed app acceptance criteria,
app/security reviews, and a working Azure deployment, regardless of score.

Planning-only attendance covers 00-02, with a maximum of 6 points.
Including delivery preparation in 03 raises that maximum to 8.
Neither is a completed rebuild. Discussing deployment in 08 without executing it
earns at most partial credit.

## Advanced challenges

Award up to 2 separate bonus points for demonstrated incumbent/target coexistence
with unambiguous write ownership or a non-production failure/recovery rehearsal.
Bonus work cannot cancel a failed acceptance criterion or missing security review.
