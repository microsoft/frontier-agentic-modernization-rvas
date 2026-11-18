---
title: Review the Modernization Package
summary: Review the package against evidence and correct it.
phase: Plan
group: Plan
tags:
- review
highlight: false
---

# Module 02: Review the Modernization Package

> **Duration:** ~45 minutes | **Phase:** Plan

## Objective

Check the generated package against the real application before using it to build. Look for missing rules, unsupported assumptions, and unnecessary complexity, then correct the package.

## Prerequisites

- Module 01 completed with the full planning package handed off.
- Source evidence and decision owners are available to check the package.

## Step 1: Analyze the complete package

Open the nine files alongside the source. Check all required workflows and trace a critical journey in detail from source through requirements, architecture, and migration waves. Question unnecessary services or redesign, and check lower-change options, official Azure evidence, costs, write ownership, and recovery.

Send this in a review conversation:

```text
Analyze docs/modernization/ against the source and stakeholder decisions from
Module 01. This is a package review, not implementation.

Check coverage of every required workflow. Trace a critical journey in detail
from source evidence through requirement/acceptance
IDs, preserve/change/retire decisions, architecture responsibilities, migration
waves, and validation. Find missing functionality, contradictions, unsupported
service claims, unnecessary complexity, and data/UI compatibility gaps.

Question the architecture alternatives and explain why the selected target
fits better than a lower-change option. Check cost drivers, load assumptions,
pricing evidence/status, migration/coexistence costs, and recovery limits.
Inspect both editable diagrams; distinguish structural from rendered review.

Return a findings table with artifact/section, evidence, impact, proposed
correction, and decision owner. Do not change files yet. Recommend an
implementation order for the complete app and identify blocking prerequisites.
```

## Step 2: Correct and reconcile

Discuss the findings with stakeholders, then return to the planning conversation. Correct affected files without restarting discovery. Reopen decisions only when new evidence changes them.

```text
Apply these package-review corrections: [findings and agreed decisions].
Use this evidence: [source references or stakeholder answers].
Reconcile affected requirements, architecture, infrastructure plan, diagrams, costs, and migration
waves. Preserve settled decisions. If a correction changes the baseline or
target materially, ask only for that affected decision before proceeding.
Report the reviewed package revision and remaining blockers with owners.
Keep application code unchanged.
```

## Step 3: Record the reviewed revision

Save the reviewed revision and the unresolved findings with owners.

> **Note:** Diagram tests prove structure and assets, not visual quality. Render and independently review the diagrams where possible, and note missing checks. Obtain formal acceptance or exceptions only when your governance requires them.

## Checkpoint

Before moving on, confirm:

- [ ] All required workflows are covered; a critical journey links source evidence to requirements, architecture, and migration waves in detail.
- [ ] The review covers behavior/UI, alternatives, Azure evidence, costs, and recovery.
- [ ] Diagram reviews state whether the file structure was checked, the rendered diagram was inspected, and a separate reviewer checked it; missing checks are recorded.
- [ ] Corrections are consistent across files; the reviewed revision and unresolved findings have named owners.

## Reflect

- Which assumption carried the most risk? Ask an independent reviewer to test it and record whether the finding changed or confirmed the package.

## What You Learned

- Trace a critical journey from source evidence to migration waves.
- Test a plan's strategy, cost and recovery assumptions against evidence.
- Apply targeted corrections without restarting discovery.

## Key Takeaway

> Review the plan against the source before any code depends on it.

## Learn more

- [Azure Architecture Center](https://learn.microsoft.com/azure/architecture/)
- [Strangler Fig pattern](https://learn.microsoft.com/azure/architecture/patterns/strangler-fig)

## Troubleshooting

| Symptom | Fix |
|---|---|
| Review turns into discovery again | Correct only the affected files. Reopen a decision only when new evidence changes it. |
| Diagram files pass tests but look wrong | Tests prove structure only. Render the diagram and review it visually. |
| Findings have no owner | Assign a decision owner to each finding before moving on. |

**Next:** [Module 03: Choose the implementation workflow](03-choose-the-workflow.md)
