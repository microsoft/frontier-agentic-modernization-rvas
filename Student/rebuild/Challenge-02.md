**[Home](../../README.md)** | [Previous](Challenge-01.md) | [Next](Challenge-03.md)

# Challenge 02: Review and Challenge the Modernization Package

**Estimated Time:** 45 minutes
**Difficulty:** Hard

## Introduction

Check the generated package against the real application before using it to
build. Look for missing rules, unsupported assumptions, and unnecessary complexity.

## Prerequisites

- Challenge 01 completed with the full planning package handed off.
- Source evidence and decision owners are available to check the package.

## Description

### Analyze the complete package

Open the eight files alongside the source. Send this in a review conversation:

```text
Analyze docs/modernization/ against the source and stakeholder decisions from
Challenge 01. This is a package review, not implementation.

Trace our critical journey from source evidence through requirement/acceptance
IDs, preserve/change/retire decisions, architecture responsibilities, migration
waves, and validation. Find missing functionality, contradictions, unsupported
service claims, unnecessary complexity, and data/UI compatibility gaps.

Challenge the architecture alternatives and explain why the selected target
fits better than a lower-change option. Check cost drivers, load assumptions,
pricing evidence/status, migration/coexistence costs, and recovery limits.
Inspect both editable diagrams; distinguish structural from rendered review.

Return a findings table with artifact/section, evidence, impact, proposed
correction, and decision owner. Do not change files yet. Recommend one
demonstrable implementation slice and identify prerequisites that could block it.
```

### Correct and reconcile

Discuss the findings with the team, then return to the planning conversation:

```text
Apply these package-review corrections: [findings and agreed decisions].
Use this evidence: [source references or stakeholder answers].
Reconcile affected requirements, architecture, diagrams, costs, and migration
waves. Preserve settled decisions. If a correction changes the baseline or
target materially, ask only for that affected decision before proceeding.
Report the reviewed package revision and remaining blockers with owners.
Keep application code unchanged.
```

## Success Criteria

- [ ] One journey links source evidence to requirements, architecture, and migration waves.
- [ ] The review covers behavior/UI, alternatives, Azure evidence, costs, and recovery.
- [ ] Diagram reviews distinguish structural, rendered, and independent checks.
- [ ] Corrections are consistent across files; the reviewed revision and unresolved findings have named owners. Obtain formal acceptance only if required.

## Learning Resources

- [Azure Architecture Center](https://learn.microsoft.com/azure/architecture/)
- [Strangler Fig pattern](https://learn.microsoft.com/azure/architecture/patterns/strangler-fig)

## Advanced Challenge (Optional)

Have an independent reviewer challenge the highest-risk assumption and record
how the finding changed, or confirmed, the package.
