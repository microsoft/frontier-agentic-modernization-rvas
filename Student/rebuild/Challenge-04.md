**[Home](../../README.md)** | [Previous](Challenge-03.md) | [Next](Challenge-05.md)

# Challenge 04: Rebuild the Application

**Estimated Time:** 150 minutes

## Introduction

Build and test the complete application from the reviewed package.

## Prerequisites

- Challenge 03 completed with a reviewed package and chosen workflow.
- Any required governance acceptance is recorded.
- A working build/test baseline and the chosen workflow's skills.

## Description

Start a **new delivery session** in the application repository using `/clear`.
Reselect **Claude Opus 5.5** with `/model`. Attach the nine planning files,
source/tests, UI/domain context, and any framework artifacts. Provide the
package revision, chosen workflow, and baseline commands/results from 03.
Run only your chosen path below.

### A. Direct implementation from the documents

Select `azure-app-rebuild` explicitly, then send:

```text
Use azure-app-rebuild to implement the complete application defined by the
reviewed docs/modernization/ package at [revision].
Delivery scope: complete application, covering all required workflows and
acceptance IDs [IDs]. Implement in dependency-ordered increments and keep
coverage of every required workflow. Read the reviewed package and current
source/tests before editing; report material drift. Do not mark the rebuild
complete after implementing only one journey.
```

### B. Matt Pocock: implement the spec and tickets

Use the local spec and ticket paths prepared in Challenge 03:

```text
/implement-spec
Implement [local spec path] and its tickets at [ticket directory], using the
reviewed docs/modernization/ package at [revision] as the scope and authority.
Cover all required workflows; completing one ticket is not a completed rebuild.
Reconcile them with current source. Keep original acceptance IDs, architecture,
UI commitments, data ownership, and cost constraints authoritative.

Use Claude Opus 5.5 for implementation subagents too.
Use at most 2 concurrently active subagents in total, scheduling only ready work.
```

Unlike the direct path, this prompt permits local Git commits and merges.
Review that permission before sending.

### C. Spec Kit: implement the prepared tasks

Confirm the active feature directory is the one prepared in Challenge 03:

```text
/speckit-implement
Implement only this feature's reviewed tasks, using the docs/modernization/
package at [revision] as the authority. Implement all
required workflows in the agreed app. Preserve original
acceptance IDs, chosen target stack, contracts, data ownership, and UI scope.
Run the documented build/tests with sanitized data. Fix related failures and
record actual evidence. Do not commit, deploy, provision, migrate production
data, or add features outside the agreed app.
```

```text
/speckit-converge
Compare the implementation with the feature spec, plan, tasks, and original
modernization acceptance IDs. Record remaining in-scope gaps as tasks;
do not broaden the feature or claim checks passed without execution.
```

Repeat `/speckit-implement` and `/speckit-converge` until **`Converged`**, or
record what blocks completion. All paths still need the app review in Challenge
05. Deployment comes later.

## Success Criteria

- [ ] The chosen workflow uses the reviewed package and Claude Opus 5.5; Matt's path stays within two concurrent subagents.
- [ ] The complete app builds and runs, with tests for all required workflows and important failure/compatibility paths.
- [ ] Required contracts and UI behavior still work; drift and existing failures are recorded.
- [ ] Results distinguish completed work from gaps or blockers.

## Learning Resources

- [Testing in the Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/operational-excellence/testing-strategy)
- [Anti-corruption Layer pattern](https://learn.microsoft.com/azure/architecture/patterns/anti-corruption-layer)

## Advanced Challenge (Optional)

If the migration plan requires coexistence, demonstrate the rebuilt app
running alongside the incumbent without ambiguous write ownership.
