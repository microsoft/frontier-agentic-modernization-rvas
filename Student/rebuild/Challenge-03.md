**[Home](../../README.md)** | [Previous](Challenge-02.md) | [Next](Challenge-04.md)

# Challenge 03: Choose the Implementation Workflow

**Estimated Time:** 45 minutes
**Difficulty:** Medium

## Introduction

Choose one journey to build, how you will test it, and which implementation
workflow you will use.

## Prerequisites

- Challenge 02 completed with a reviewed package revision.
- Someone can resolve scope, access, and test-data questions.
- Implementation supporting skills and **Claude Opus 5.5** are available.

## Description

### Select the model and one workflow

Use `/model` in CLI or the VS Code model picker to select **Claude Opus 5.5**
for Challenges 03-04, including tickets/tasks. If unavailable, ask the coach
to resolve access.

Choose **one** workflow. All three use the reviewed package:

| Workflow | Choose it when | Prepare now | Implement in Challenge 04 |
| --- | --- | --- | --- |
| Direct from the documents | One small slice needs little extra coordination | Package and bounded handoff | Explicit prompt with `azure-app-rebuild` |
| Matt Pocock skills | You want a spec and dependency-linked tickets with bounded parallel delivery | `/setup-matt-pocock-skills`, `/to-spec`, `/to-tickets` | `/implement-spec`, with up to two concurrent subagents |
| Spec Kit | You want constitution, feature specification, plan, and task artifacts | Constitution, specify, clarify as needed, plan, tasks; optional analyze | `/speckit-implement`, then `/speckit-converge` until `Converged` |

Install your choice using the [setup guide](setup.md) and
[supporting profiles](supporting-skills.md). Use Matt or Spec Kit directly,
not inside `azure-app-rebuild`.

### Prepare the shared handoff

Select one end-to-end slice or migration wave you can demonstrate during the
event. Use this prompt to capture its scope and build/test baseline in
`docs/modernization/delivery-slice.md`:

```text
Read the reviewed docs/modernization/ package at [revision] and current source.
Prepare delivery-slice.md for only [journey/wave], covering acceptance IDs [IDs].
Record the selected workflow [direct / Matt Pocock / Spec Kit], target stack,
dependencies, preserved contracts and UI, intentional changes, data/write
ownership, recovery limits, safe fixtures, and exact build/run/test commands.
Check the existing baseline and record actual output and pre-existing failures.
List unresolved prerequisites and owners. Identify the provided Azure
infrastructure location/revision and its deployment contract, or record that
handoff as missing. Do not change application code or run cloud operations.
```

Include relevant source/tests, UI/domain context, and any required acceptance
record. Resolve blocking prerequisites before coding.

### Prepare your chosen workflow

**Direct:** proceed to Challenge 04.

**Matt Pocock:** run setup once with **local Markdown** tracking. Review any
repository-instruction changes, then run each skill separately:

```text
/setup-matt-pocock-skills
Configure local Markdown tracking for this rebuild slice. Reuse existing domain
records and repository instructions. Do not create remote issues or PRs.
```

```text
/to-spec
Read all eight reviewed artifacts in docs/modernization/ and delivery-slice.md
at [revision]. Elaborate ONLY that slice into the configured local spec.
Reuse the recovered requirements and acceptance IDs, selected architecture,
cost constraints, migration dependencies, and UI authority. Do not rediscover
the application or invent a replacement architecture. Include failure paths,
test seams, compatibility boundaries, and out-of-scope work. Flag contradictions
for a targeted package correction. Do not implement yet.
```

```text
/to-tickets
Read [generated local spec path] and docs/modernization/delivery-slice.md.
Create demoable vertical-slice tickets for only this spec, with genuine blocking
edges and links to original acceptance IDs. Include tests and integration
validation. Show the breakdown for our review before writing the local tickets.
Do not publish remote issues, start implementation, or expand to later waves.
```

**Spec Kit:** initialize it using the setup guide, then run these commands
separately. Use the installed equivalent if your host shows dotted names such
as `/speckit.specify`. Clarify only unresolved questions; analyze is optional.
Finish with implement and converge in [Challenge 04](Challenge-04.md).

```text
/speckit-constitution
Read repository instructions and the reviewed docs/modernization/ package.
Capture agreed principles: preserve in-scope requirements and public contracts,
honor the chosen architecture and data ownership, use sanitized fixtures,
validate acceptance with tests, and stay within delivery-slice.md.
Do not invent standards or change settled architecture decisions.
```

```text
/speckit-specify
Read docs/modernization/specification.md, assessment.md, migration-plan.md,
and delivery-slice.md at [revision]. Elaborate only the selected journey into
this feature's spec, retaining original requirement and acceptance IDs.
Use existing discovery evidence and stakeholder answers, not a new greenfield
brief. Preserve permissions, failure paths, contracts, and approved UI scope.
```

```text
/speckit-clarify
Resolve only material gaps in this slice. Reuse the reviewed package's decisions.
If a conflict changes scope or architecture, return it to the team rather than
silently overriding the package.
```

```text
/speckit-plan
Read target-architecture.md, strategy-matrix.md, cost-estimate.md, both diagrams,
migration-plan.md, and delivery-slice.md in docs/modernization/.
Elaborate the selected target stack [stack] into an implementation plan for
this feature. Preserve Azure service choices, identity and data boundaries,
cost constraints, UI authority, and the provided infrastructure contract.
Link decisions and validation back to the original acceptance IDs.
```

```text
/speckit-tasks
Generate dependency-ordered implementation and test tasks for this feature only.
Map tasks to original acceptance IDs and include end-to-end integration checks.
Leave deployment execution to Challenge 08.
```

Optional consistency check:

```text
/speckit-analyze
Check feature spec, plan, and tasks against each other AND the reviewed
docs/modernization/ package and delivery-slice.md. Report scope drift, missing
acceptance coverage, contradictions, and unsafe dependency ordering.
```

Correct inconsistencies and add generated spec/ticket paths or the active
Spec Kit feature directory to `delivery-slice.md`. Take these into a new
delivery session in Challenge 04.

## Success Criteria

- [ ] Claude Opus 5.5 and one workflow are selected.
- [ ] The handoff identifies the package revision, slice, acceptance IDs, dependencies, preservation decisions, and data/recovery limits.
- [ ] Baseline results, safe fixtures, existing failures, and blockers are recorded; implementation has not started.
- [ ] Generated specs/tickets/tasks use the reviewed package and retain acceptance-ID links.

## Learning Resources

- [Azure pricing overview](https://azure.microsoft.com/pricing/)
- [Safe deployment practices](https://learn.microsoft.com/azure/well-architected/operational-excellence/safe-deployments)

## Advanced Challenge (Optional)

Have another team member explain the slice and its validation approach using
only the prepared handoff. Resolve any ambiguity they find.
