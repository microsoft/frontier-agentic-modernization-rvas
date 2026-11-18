---
title: Rebuild the Application
summary: Rebuild the complete application with the chosen workflow.
phase: Build
group: Build
tags:
- implementation
highlight: true
---

# Module 04: Rebuild the Application

> **Duration:** ~150 minutes | **Phase:** Build

## Objective

Build and test the complete application from the reviewed package, using the workflow you chose in Module 03.

## Prerequisites

- Module 03 completed with a reviewed package and chosen workflow.
- Any required governance acceptance is recorded.
- A working build/test baseline and the chosen workflow's skills.

## Step 1: Start a new delivery session

Start a new delivery session in the application repository with `/clear`. Reselect **Claude Opus 5.5** with `/model`. Attach the nine planning files, source and tests, UI and domain context, and any framework artifacts. Provide the package revision, chosen workflow, and baseline commands and results from Module 03.

Run only your chosen path below (Step 2, 3 or 4). Do not run `azure-app-rebuild` on top of Matt or Spec Kit.

## Step 2: A. Direct implementation from the documents

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

## Step 3: B. Matt Pocock: implement the spec and tickets

Use the local spec and ticket paths prepared in Module 03:

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

Unlike the direct path, this prompt permits local Git commits and merges. It does not permit pushes or remote issues and PRs. Review that permission before sending.

Enforce **two concurrent subagents in total**, including merge, exploration, review, and fix agents. Respect dependencies and existing user work.

## Step 4: C. Spec Kit: implement the prepared tasks

Confirm the active feature directory is the one prepared in Module 03:

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

Repeat `/speckit-implement` and `/speckit-converge` until **`Converged`**, or record what blocks completion.

## Step 5: Record results

Keep the agreed app scope and the preserved business and UI behavior. Adapters need clear write ownership. Direct and Spec Kit paths do not authorize commits. Cloud execution waits until Module 08.

If blocked, record incomplete workflows and blockers honestly. Do not silently redefine the app as one journey. If you finish early, strengthen failure-path and compatibility tests before adding work.

All paths still need the app review in Module 05. Deploy in Module 08.

## Checkpoint

Before moving on, confirm:

- [ ] The chosen workflow uses the reviewed package and Claude Opus 5.5; Matt's path stays within two concurrent subagents.
- [ ] The complete app builds and runs, with tests for all required workflows and important failure and compatibility paths.
- [ ] Required contracts and UI behavior still work; drift and existing failures are recorded.
- [ ] Results distinguish completed work from gaps or blockers.

## Reflect

- If the migration plan requires coexistence, can you run the rebuilt app alongside the incumbent without ambiguous write ownership?

## What You Learned

- Implement a complete app from a reviewed package with one of three workflows.
- Bound parallel agent work with a subagent cap.
- Report completed work, gaps and blockers separately.

## Key Takeaway

> A rebuild is complete when every required workflow works, not when one journey does.

## Learn more

- [Testing in the Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/operational-excellence/testing)
- [Anti-corruption Layer pattern](https://learn.microsoft.com/azure/architecture/patterns/anti-corruption-layer)

## Troubleshooting

| Symptom | Fix |
|---|---|
| Matt's path starts too many agents | Use the explicit two-concurrent-subagent cap, including merger and review agents. |
| `azure-app-rebuild` runs on top of Matt or Spec Kit | Start a new session and run only the matching path. |
| Only one journey is implemented | Do not mark the rebuild complete. Continue with the remaining required workflows or record them as blockers. |

**Next:** [Module 05: Review the app and implement missing behavior](05-review-and-fix-the-app.md)
