**[Home](../../README.md)** | [Previous](Challenge-03.md) | [Next](Challenge-05.md)

# Challenge 04: Rebuild One Working Slice

**Estimated Time:** 150 minutes
**Difficulty:** Hard

## Introduction

Build and test one end-to-end journey from the reviewed package.

## Prerequisites

- Challenge 03 completed with the reviewed package and slice handoff.
- Any required governance acceptance is recorded.
- A working build/test baseline and the chosen workflow's skills.

## Description

Start a **new delivery session** in the application repository using `/clear`.
Reselect **Claude Opus 5.5** with `/model`. Attach
`docs/modernization/delivery-slice.md`, the eight planning files, source/tests,
UI/domain context, and framework artifacts. Run only your chosen path below.

### A. Direct implementation from the documents

Select `azure-app-rebuild` explicitly, then send:

```text
Use azure-app-rebuild to implement only the slice in
docs/modernization/delivery-slice.md from package revision [revision].
Acceptance IDs: [IDs]. Read the entire reviewed modernization package and
current source/tests before editing; report material drift.
```

### B. Matt Pocock: implement the spec and tickets

Use the local spec and ticket paths prepared in Challenge 03:

```text
/implement-spec
Implement [local spec path] and its tickets at [ticket directory], bounded by
docs/modernization/delivery-slice.md and reviewed package revision [revision].
Reconcile them with current source. Keep original acceptance IDs, architecture,
UI commitments, data ownership, and cost constraints authoritative.

Use Claude Opus 5.5 for implementation subagents too.
At every scheduling round, spin up up to 2 subagents for ready work; never exceed
2 concurrently active subagents in total.
```

Unlike the direct path, this prompt permits local Git commits and merges.
Review that permission before sending.

### C. Spec Kit: implement the prepared tasks

Confirm the active feature directory is the one recorded in the handoff:

```text
/speckit-implement
Implement only this feature's reviewed tasks, using the docs/modernization/
package at [revision] and delivery-slice.md as the authority. Preserve original
acceptance IDs, chosen target stack, contracts, data ownership, and UI scope.
Run the documented build/tests with sanitized data. Fix related failures and
record actual evidence. Do not commit, deploy, provision, migrate production
data, or implement later waves.
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
- [ ] The slice builds and runs, with tests for acceptance, failure, and compatibility paths.
- [ ] Required contracts and UI behavior still work; drift and existing failures are recorded.
- [ ] Results distinguish completed work from gaps or blockers.

## Hints

<details><summary>Hint 1: Make it end to end</summary>
Demonstrate the user's outcome, not just generated files.
</details>

<details><summary>Hint 2: Guard existing behavior</summary>
A new framework does not change the business rules.
</details>

<details><summary>Hint 3: Keep scope controlled</summary>
Resolve plan contradictions before coding; tickets do not override the package.
</details>

## Learning Resources

- [Testing in the Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/operational-excellence/testing-strategy)
- [Anti-corruption Layer pattern](https://learn.microsoft.com/azure/architecture/patterns/anti-corruption-layer)

## Advanced Challenge (Optional)

Demonstrate the slice coexisting with the incumbent implementation without
ambiguous write ownership.
