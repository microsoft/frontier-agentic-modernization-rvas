**[Home](../../README.md)** | [Previous](Challenge-00.md) | [Next](Challenge-02.md)

# Challenge 01: Run Discovery and Modernization Planning

**Estimated Time:** 150 minutes

## Introduction

Use the provided skill to recover what the application does, choose an Azure
target, estimate costs, and plan the migration. Supply evidence and answer the
business questions the code cannot resolve.

## Prerequisites

- Challenge 00 completed and discovery participants available.
- Planning essentials and, for UI applications, the existing-UI supporting profile.
- Bundled diagram tooling and cost-estimation prerequisites are available, or
  their concrete blockers are identified.

## Description

### Start the provided skill

Select `azure-app-modernization` in slash completion using its displayed name,
then send:

```text
/azure-app-modernization Recover the functional specification of this complete
application and plan its modernization to Azure.
```

### Answer the decision rounds

Stay in this conversation through discovery, questions, baseline confirmation,
and target selection. Confirm what must stay, change, or retire, including UI
behavior. Resolve differences between the code and stakeholder expectations.
Compare a lower-change option before choosing a rebuild.

The skill then produces the nine files listed in the [setup guide](setup.md)
under `docs/modernization/`, consulting diagram and cost-estimation skills as
needed. Do not restart it for each document.

Keep this session planning-only: no application edits or execution of scripts
you have not reviewed.
Note missing evidence, pricing failures, and checks that could not run.
Static inspection does not prove performance or migration duration. If time
runs out, save the current phase and open decisions.

## Success Criteria

- [ ] Stakeholders confirmed the baseline and chose a target or explicitly delegated the choice.
- [ ] All nine files cover the agreed scope, with evidence and gaps identified.
- [ ] Costs show pricing sources and assumptions, or the specific blocker to obtaining prices; diagrams identify completed reviews; migration waves follow dependencies.
- [ ] The package is **Ready for review** and states "architecture and migration planning only; implementation not started".

## Learning Resources

- [Azure architecture design principles](https://learn.microsoft.com/azure/architecture/guide/design-principles/)
- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)

## Advanced Challenge (Optional)

Explain which stakeholder answer most changed the recommended strategy and trace
that decision through the resulting package.
