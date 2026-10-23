**[Home](../../README.md)** | [Previous](Challenge-00.md) | [Next](Challenge-02.md)

# Challenge 01: Run Discovery and Modernization Planning

**Estimated Time:** 150 minutes
**Difficulty:** Hard

## Introduction

A useful modernization plan starts with what the application does, not a
replacement stack. Your role is to provide evidence, answer the questions only
stakeholders can resolve, and make informed decisions while the skill creates
the complete planning package.

## Prerequisites

- Challenge 00 completed and discovery participants available.
- Planning essentials and, for UI applications, the existing-UI supporting profile.
- Bundled diagram tooling and cost-estimation prerequisites are available, or
  their concrete blockers are identified.

## Description

Start `azure-app-modernization` once using your application brief and the
[setup guide](setup.md). Work through its analysis, stakeholder questions,
baseline confirmation, and target comparison/selection in the same planning
conversation. These are internal phases, not separate skill invocations or
document-generation challenges. The conversation may take multiple turns and
pause for decisions.

Help the skill recover actors, journeys, rules, permissions, failures,
integrations, data, and current architecture. For UI applications, preserve
product/design authority and the behavior of meaningful UI surfaces unless
changes are explicitly selected. Resolve contradictions between observed behavior
and stakeholder intent. Compare lower-change options with deeper refactoring or
rebuild before choosing a target.

Continue through specification, Azure architecture, costs, editable diagrams,
and migration waves until the skill hands off the complete eight-artifact
package under `docs/modernization/`. Documents may be drafted progressively;
you do not generate each one in a separate exercise. The skill consults the
bundled diagram and installed cost-estimation skills within this workflow.

Do not change application code or execute unknown scripts. Static inspection
does not prove runtime performance or migration duration. Mark missing evidence,
pricing-tool blockers, and review limitations honestly. If the timebox expires
before handoff, record the current phase and unresolved decisions rather than
claiming a complete package.

## Success Criteria

- [ ] The planning conversation records stakeholder answers, baseline confirmation, and target selection or bounded delegation.
- [ ] All eight artifacts listed in the [setup guide](setup.md) exist in the handed-off package and cover the agreed application scope.
- [ ] Evidence supports the recovered behavior, integrations, data, and applicable UI authority; unknowns and contradictions are explicit.
- [ ] The package includes a pricing attempt/status, current and target diagrams with honest review statuses, and dependency-ordered migration waves.
- [ ] The handoff is marked **Ready for review** and states "architecture and migration planning only; implementation not started".

## Hints

<details><summary>Hint 1: Supply context, not a predetermined answer</summary>
Explain the business challenge and preservation constraints. Let evidence and
stakeholder decisions drive the target.
</details>

<details><summary>Hint 2: Stay in the planning conversation</summary>
Baseline confirmation and target selection are pauses inside one workflow.
Answer them rather than restarting the skill for the next document.
</details>

<details><summary>Hint 3: Check the handoff boundary</summary>
Expect eight artifacts, including costs and both editable diagrams. Report a
partial result honestly; do not force a target decision or claim missing checks passed.
</details>

## Learning Resources

- [Azure architecture design principles](https://learn.microsoft.com/azure/architecture/guide/design-principles/)
- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)

## Advanced Challenge (Optional)

Explain which stakeholder answer most changed the recommended strategy and trace
that decision through the resulting package.
