**[Home](../../README.md)** | [Previous](Challenge-03.md) | [Next](Challenge-05.md)

# Challenge 04: Rebuild One Working Slice

**Estimated Time:** 150 minutes
**Difficulty:** Hard

## Introduction

The first rebuild milestone is a small, working end-to-end capability, not a
repository full of generated scaffolding. The reviewed package is the contract.

## Prerequisites

- Challenge 03 completed with the reviewed package, bounded-slice handoff, and readiness evidence.
- Any required governance acceptance is recorded.
- A repeatable safe build/test baseline and implementation supporting skills.

## Description

Start a **new delivery session** and explicitly select `azure-app-rebuild` using
the handoff in the [setup guide](setup.md). Identify the package revision, bounded
slice, and acceptance IDs. Compare the source with the plan before editing.
Revisit the affected planning decision if they differ materially.

Implement the slice in dependency order. Preserve external behavior, contracts,
data ownership, and UI surfaces unless the specification intentionally changes
them. Validate the changed journey and important failure paths with synthetic or
sanitized data. Keep unrelated application areas untouched.

No automatic commits, resource provisioning, deployment, or production migration
are part of this challenge. A partial or blocked slice must be reported as such.

## Success Criteria

- [ ] The delivery session identifies the package revision, slice, and acceptance IDs.
- [ ] Source/plan reconciliation and pre-existing failures are recorded.
- [ ] One end-to-end slice builds and runs in the agreed safe environment.
- [ ] Focused tests demonstrate its acceptance and relevant failure/compatibility paths.
- [ ] Preserved contracts and UI behavior have evidence, or named validation gaps.
- [ ] Remaining work is explicit; no broader migration or operational action is implied.

## Hints

<details><summary>Hint 1: Make it end to end</summary>
Choose a journey whose outcome can be observed, not just a layer or a directory.
</details>

<details><summary>Hint 2: Guard existing behavior</summary>
A new framework or service is not permission to change business semantics.
</details>

<details><summary>Hint 3: Keep scope controlled</summary>
Use the plugin's rebuild entry point rather than an unattended generic
implementation skill. Resolve a material plan contradiction before coding around it.
</details>

## Learning Resources

- [Testing in the Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/operational-excellence/testing-strategy)
- [Anti-corruption Layer pattern](https://learn.microsoft.com/azure/architecture/patterns/anti-corruption-layer)

## Advanced Challenge (Optional)

Demonstrate the slice coexisting with the incumbent implementation without
ambiguous write ownership.
