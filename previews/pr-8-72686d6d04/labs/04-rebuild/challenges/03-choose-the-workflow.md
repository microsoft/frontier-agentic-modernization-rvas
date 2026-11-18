---
title: Choose the Implementation Workflow
summary: Choose the implementation workflow and check readiness.
phase: Plan
group: Plan
tags:
- workflow
- opus
highlight: false
---

# Module 03: Choose the Implementation Workflow

> **Duration:** ~45 minutes | **Phase:** Plan

## Objective

Choose how to implement and validate the complete application from the reviewed package, check that implementation can start, and prepare the chosen workflow. The 45 minutes assume the tools are installed.

## Prerequisites

- Module 02 completed with a reviewed package revision.
- Someone can resolve scope, access, and test-data questions.
- Implementation supporting skills and **Claude Opus 5.5** are available.

## Step 1: Select the model and one workflow

Use `/model` in the CLI or the VS Code model picker to select **Claude Opus 5.5** for Modules 03-04, including tickets and tasks. If it is unavailable, ask the infrastructure owner to resolve access.

Choose **one** workflow. All three use the reviewed package, and direct delivery is a valid choice.

| Workflow | Choose it when | Prepare now | Implement in Module 04 |
| --- | --- | --- | --- |
| Direct from the documents | The small app needs little extra coordination | Reviewed package and working baseline | Explicit prompt with `azure-app-rebuild` |
| Matt Pocock skills | A spec and dependency-linked tickets with bounded parallel delivery | `/setup-matt-pocock-skills`, `/to-spec`, `/to-tickets` | `/implement-spec`, with up to two concurrent subagents |
| Spec Kit | Constitution, feature specification, plan, and task artifacts | Constitution, specify, clarify as needed, plan, tasks; optional analyze | `/speckit-implement`, then `/speckit-converge` until `Converged` |

Install the chosen workflow using the [setup guide](../setup.md) and [supporting profiles](../supporting-skills.md). Use Matt or Spec Kit directly, not inside `azure-app-rebuild`.

## Step 2: Check implementation readiness

Use the reviewed package as the authority for scope, acceptance, architecture, and data and recovery decisions. Check that implementation can start:

```text
Read the reviewed docs/modernization/ package at [revision] and current source.
Delivery scope: complete application [name]. Selected workflow:
[direct / Matt Pocock / Spec Kit]. Use the package's acceptance criteria,
target stack, preserved behavior, data ownership, and recovery limits.
Check the reviewed build/run/test commands with safe fixtures. Report commands,
actual output, pre-existing failures, and blocking prerequisites with owners.
Identify the provided Azure infrastructure location/revision and required
inputs/outputs, or report what is missing.
Do not create another planning summary, change app code, or run cloud operations.
```

Check baseline output, fixtures, access, existing failures, and blockers without editing application code or provisioning resources. Resolve blocking prerequisites before coding.

Keep the commands, results, and chosen workflow available for the new session in Module 04. Pass the package revision, baseline commands and results, and any framework artifact paths into that session. Write no extra summary document.

## Step 3: Prepare the chosen workflow

**Direct:** proceed to Module 04.

**Matt Pocock:** run setup once with **local Markdown** tracking. Review any repository-instruction changes, then run each skill separately:

```text
/setup-matt-pocock-skills
Configure local Markdown tracking for this complete-app rebuild. Reuse existing
domain records and repository instructions. Do not create remote issues or PRs.
```

```text
/to-spec
Read all nine reviewed artifacts in docs/modernization/ at [revision].
Elaborate the complete agreed application into the local spec.
Reuse the recovered requirements and acceptance IDs, selected architecture,
cost constraints, migration dependencies, and agreed UI behavior/design.
Do not rediscover the application or invent a replacement architecture. Include
failure paths, where tests can isolate dependencies, compatibility boundaries,
and excluded work. Flag contradictions for a targeted package correction.
Do not implement yet.
```

```text
/to-tickets
Read [generated local spec path] and the reviewed docs/modernization/ package
at [revision].
Create demonstrable end-to-end tickets covering the complete app. Record which
tickets must finish before others and link original acceptance IDs. Include
tests and integration validation. Show the breakdown for our review before
writing the local tickets. Do not publish remote issues, start implementation,
or add features outside the agreed app.
```

**Spec Kit:** initialize it using the setup guide, then run these commands separately. Use the installed equivalent if your host shows dotted names such as `/speckit.specify`. Clarify only unresolved questions; analyze is optional. Finish with implement and converge in [Module 04](04-rebuild-the-app.md).

```text
/speckit-constitution
Read repository instructions and the reviewed docs/modernization/ package.
Capture agreed principles: preserve in-scope requirements and public contracts,
honor the chosen architecture and data ownership, use sanitized fixtures,
validate acceptance with tests, and stay within the package's agreed app scope.
Do not invent standards or change settled architecture decisions.
```

```text
/speckit-specify
Read docs/modernization/specification.md, assessment.md, and migration-plan.md
at [revision]. Specify the complete agreed application
for this rebuild feature, retaining original requirement and acceptance IDs.
Use existing discovery evidence and stakeholder answers, not a new greenfield
brief. Preserve permissions, failure paths, contracts, and approved UI scope.
```

```text
/speckit-clarify
Resolve only material gaps in this app's rebuild. Reuse the reviewed package's
decisions.
If a conflict changes scope or architecture, return it to the stakeholders rather than
silently overriding the package.
```

```text
/speckit-plan
Read target-architecture.md, infrastructure-plan.md, strategy-matrix.md,
cost-estimate.md, both diagrams, and migration-plan.md in docs/modernization/.
Elaborate the selected target stack [stack] into an implementation plan for
this feature. Preserve Azure service choices, identity and data boundaries,
cost constraints, agreed UI behavior/design, and the provided infrastructure
contract.
Link decisions and validation back to the original acceptance IDs.
```

```text
/speckit-tasks
Generate dependency-ordered implementation and test tasks for the complete
application defined by this rebuild feature.
Map tasks to original acceptance IDs and include end-to-end integration checks.
Leave deployment execution to Module 08.
```

Optional consistency check:

```text
/speckit-analyze
Check feature spec, plan, and tasks against each other AND the reviewed
docs/modernization/ package. Report scope drift, missing
acceptance coverage, contradictions, and unsafe dependency ordering.
```

Correct inconsistencies. Provide the generated spec and ticket paths, or the active Spec Kit feature directory, when starting Module 04.

## Checkpoint

Before moving on, confirm:

- [ ] Claude Opus 5.5 and one workflow are selected.
- [ ] Implementation uses the reviewed package revision and its complete-app scope, acceptance criteria, dependencies, and preservation decisions.
- [ ] Baseline results, safe fixtures, existing failures, and blockers are recorded; implementation has not started.
- [ ] Generated specs, tickets, or tasks use the reviewed package and retain acceptance-ID links.

## Reflect

- Could someone else identify the app's scope, acceptance checks, and implementation starting point from the reviewed package and your chosen workflow? Resolve any ambiguity they would find.

## What You Learned

- Choose between direct, Matt Pocock and Spec Kit delivery.
- Check a baseline before implementation starts.
- Turn a reviewed package into specs, tickets or tasks that keep acceptance-ID links.

## Key Takeaway

> Pick one workflow and let the reviewed package stay the authority for scope.

## Learn more

- [Workflow setup and commands](../setup.md#sessions-and-implementation-choices)
- [Implementation skill profiles](../supporting-skills.md#implementation-support)

## Troubleshooting

| Symptom | Fix |
|---|---|
| Discovery restarts for the delivery framework | Module 01 generated the package and Module 02 reviewed it. Prepare the agreed complete-app implementation from it. |
| Opus 5.5 is not available | Ask the infrastructure owner to resolve model access. |
| Baseline commands fail | Record pre-existing failures and blockers with owners. Resolve blockers before coding. |
| A spec or plan contradicts the package | Return the contradiction to the package as a targeted correction. |

**Next:** [Module 04: Rebuild the application](04-rebuild-the-app.md)
