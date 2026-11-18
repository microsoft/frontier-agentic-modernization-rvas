---
title: Run Discovery and Modernization Planning
summary: Run the discovery and planning workflow and generate the modernization package.
phase: Plan
group: Plan
tags:
- discovery
- planning
highlight: true
---

# Module 01: Run Discovery and Modernization Planning

> **Duration:** ~150 minutes | **Phase:** Plan

## Objective

Use the provided skill to recover what the application does, choose an Azure target, estimate costs, and plan the migration. Supply evidence and answer the business questions the code cannot resolve. The result is the nine-file modernization package.

## Prerequisites

- Module 00 completed, with a stakeholder available for questions.
- Planning essentials and, for UI applications, the existing-UI supporting profile.
- Bundled diagram tooling and cost-estimation prerequisites are available, or their concrete blockers are identified.

## Step 1: Start the provided skill

Select `azure-app-modernization` in slash completion using its displayed name, then send:

```text
/azure-app-modernization Recover the functional specification of this complete
application and plan its modernization to Azure.
```

Run the skill once through discovery, stakeholder questions, baseline confirmation, target selection, and the nine-file package. It consults the diagram and cost skills itself, so do not restart it for each document.

## Step 2: Answer the decision rounds

Stay in this conversation until the target is selected.

- Confirm what must stay, change, or retire, including UI behavior.
- Resolve differences between the code and stakeholder expectations.
- Compare a lower-change option before choosing a rebuild.
- Confirm the baseline before choosing or delegating the target.

Check permissions, failures, side effects, and existing UI behavior. Missing evidence is a gap, not proof of no dependency.

## Step 3: Collect the package

The skill produces the nine files listed in the [setup guide](../setup.md) under `docs/modernization/`. Require a pricing attempt, a diagram review status, and migration waves that follow dependencies.

Keep this session planning-only: no application edits and no execution of scripts you have not reviewed. Note missing evidence, pricing failures, and checks that could not run. Static inspection does not prove performance or migration duration.

If time runs out, save the current phase and open decisions. Change scope only with the stakeholder.

> **Note:** Completion is `Ready for review`. The skill stops before implementation, and no extra approval gate is needed unless your organization requires one.

## Checkpoint

Before moving on, confirm:

- [ ] Stakeholders confirmed the baseline and chose a target or explicitly delegated the choice.
- [ ] All nine files cover the agreed scope, with evidence and gaps identified.
- [ ] Costs show pricing sources and assumptions, or the specific blocker to obtaining prices; diagrams identify completed reviews; migration waves follow dependencies.
- [ ] The package is **Ready for review** and states "architecture and migration planning only; implementation not started".

## Reflect

- Which stakeholder answer most changed the recommended strategy? Trace that decision through the resulting package.

## What You Learned

- Run one discovery and planning workflow from evidence to a nine-file package.
- Separate confirmed baseline facts from evidence gaps.
- Keep planning separate from implementation.

## Key Takeaway

> One planning conversation, anchored in stakeholder decisions, produces a package the rest of the rebuild can trust.

## Learn more

- [Azure architecture design principles](https://learn.microsoft.com/azure/architecture/guide/design-principles/)
- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)

## Troubleshooting

| Symptom | Fix |
|---|---|
| Planning starts editing source | Stop it and restate the planning-only boundary. Implementation uses a separate skill in Module 04. |
| The skill restarts discovery for each file | Stay in one conversation. The skill consults diagram and cost skills itself. |
| Cost totals have no source | Require pricing evidence or the attempted source and the tool blocker. |
| Time runs out | Save the current phase and open decisions. |

**Next:** [Module 02: Review the modernization package](02-review-the-package.md)
