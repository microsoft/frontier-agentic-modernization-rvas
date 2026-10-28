**[Home](../../README.md)** | [Previous](Challenge-02.md) | [Next](Challenge-04.md)

# Challenge 03: Choose the Implementation Workflow

**Estimated Time:** 45 minutes

## Introduction

Choose how to implement and validate the complete application from the reviewed
package.

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
| Direct from the documents | The small app needs little extra coordination | Package and rebuild handoff | Explicit prompt with `azure-app-rebuild` |
| Matt Pocock skills | You want a spec and dependency-linked tickets with bounded parallel delivery | `/setup-matt-pocock-skills`, `/to-spec`, `/to-tickets` | `/implement-spec`, with up to two concurrent subagents |
| Spec Kit | You want constitution, feature specification, plan, and task artifacts | Constitution, specify, clarify as needed, plan, tasks; optional analyze | `/speckit-implement`, then `/speckit-converge` until `Converged` |

Install your choice using the [setup guide](setup.md) and
[supporting profiles](supporting-skills.md). Use Matt or Spec Kit directly,
not inside `azure-app-rebuild`.

### Prepare the shared handoff

Capture the complete app's scope and build/test baseline in
`docs/modernization/rebuild-handoff.md`:

```text
Read the reviewed docs/modernization/ package at [revision] and current source.
Prepare rebuild-handoff.md for the complete application [name], covering all
required workflows and acceptance IDs [IDs].
Organize the handoff into:
- Scope: workflow [direct / Matt Pocock / Spec Kit], target stack, dependencies,
  preserved contracts/UI, and intentional changes.
- Validation: source/test paths, exact build/run/test commands, safe fixtures,
  actual baseline output, and pre-existing failures.
- Data and recovery: write ownership and recovery limits.
- Deployment: provided infrastructure location/revision and required inputs/
  outputs, or the missing handoff and owner.
List unresolved prerequisites and owners. Do not change application code or
run cloud operations.
```

Include relevant source/tests, UI/domain context, and any required acceptance
record. Resolve blocking prerequisites before coding.

### Prepare your chosen workflow

**Direct:** proceed to Challenge 04.

**Matt Pocock:** run setup once with **local Markdown** tracking. Review any
repository-instruction changes, then run each skill separately:

```text
/setup-matt-pocock-skills
Configure local Markdown tracking for this complete-app rebuild. Reuse existing
domain records and repository instructions. Do not create remote issues or PRs.
```

```text
/to-spec
Read all nine reviewed artifacts in docs/modernization/ and rebuild-handoff.md
at [revision]. Elaborate the complete agreed application into the local spec.
Reuse the recovered requirements and acceptance IDs, selected architecture,
cost constraints, migration dependencies, and agreed UI behavior/design.
Do not rediscover the application or invent a replacement architecture. Include
failure paths, where tests can isolate dependencies, compatibility boundaries,
and excluded work. Flag contradictions for a targeted package correction.
Do not implement yet.
```

```text
/to-tickets
Read [generated local spec path] and docs/modernization/rebuild-handoff.md.
Create demonstrable end-to-end tickets covering the complete app. Record which
tickets must finish before others and link original acceptance IDs. Include
tests and integration validation. Show the breakdown for our review before
writing the local tickets. Do not publish remote issues, start implementation,
or add features outside the agreed app.
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
validate acceptance with tests, and stay within rebuild-handoff.md.
Do not invent standards or change settled architecture decisions.
```

```text
/speckit-specify
Read docs/modernization/specification.md, assessment.md, migration-plan.md,
and rebuild-handoff.md at [revision]. Specify the complete agreed application
for this rebuild feature, retaining original requirement and acceptance IDs.
Use existing discovery evidence and stakeholder answers, not a new greenfield
brief. Preserve permissions, failure paths, contracts, and approved UI scope.
```

```text
/speckit-clarify
Resolve only material gaps in this app's rebuild. Reuse the reviewed package's
decisions.
If a conflict changes scope or architecture, return it to the team rather than
silently overriding the package.
```

```text
/speckit-plan
Read target-architecture.md, infrastructure-plan.md, strategy-matrix.md,
cost-estimate.md, both diagrams, migration-plan.md, and rebuild-handoff.md
in docs/modernization/.
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
Leave deployment execution to Challenge 08.
```

Optional consistency check:

```text
/speckit-analyze
Check feature spec, plan, and tasks against each other AND the reviewed
docs/modernization/ package and rebuild-handoff.md. Report scope drift, missing
acceptance coverage, contradictions, and unsafe dependency ordering.
```

Correct inconsistencies and add generated spec/ticket paths or the active
Spec Kit feature directory to `rebuild-handoff.md`. Take these into a new
delivery session in Challenge 04.

## Success Criteria

- [ ] Claude Opus 5.5 and one workflow are selected.
- [ ] The handoff covers the complete app, package revision, acceptance IDs, dependencies, preservation decisions, and data/recovery limits.
- [ ] Baseline results, safe fixtures, existing failures, and blockers are recorded; implementation has not started.
- [ ] Generated specs/tickets/tasks use the reviewed package and retain acceptance-ID links.

## Learning Resources

- [Workflow setup and commands](setup.md#sessions-and-implementation-choices)
- [Implementation skill profiles](supporting-skills.md#implementation-support)

## Advanced Challenge (Optional)

Have another team member explain the app's rebuild and validation approach using
only the prepared handoff. Resolve any ambiguity they find.
