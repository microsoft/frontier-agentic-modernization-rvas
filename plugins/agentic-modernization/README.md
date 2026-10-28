# Agentic Modernization plugin

Use this plugin for changes to existing applications that go beyond a runtime upgrade.
Follow the [participant setup guide](../../Student/rebuild/setup.md) in the
**application repository**, not this tooling repository.

| Skill | Scope | End state |
| --- | --- | --- |
| `azure-app-modernization` | Recover behavior and constraints, compare strategies, design Azure targets and migration waves | Nine reconciled planning artifacts, `Ready for review`; implementation not started |
| `azure-app-rebuild` | Separately requested complete app, migration wave, or vertical slice; incremental implementation within that scope | Requested scope validated with acceptance coverage, gaps, and review results |
| `cloud-architecture-diagram` | Bundled editable diagram authoring, assets, and review checks | Current/target diagrams with explicit structural, visual, and independent review status |

Planning produces `assessment.md`, `specification.md`, `strategy-matrix.md`,
`target-architecture.md`, `infrastructure-plan.md`, `cost-estimate.md`, `current-state.drawio`,
`target-architecture.drawio`, and `migration-plan.md` under `docs/modernization/`.
An existing UI can also require `PRODUCT.md`, `DESIGN.md`, and
`.impeccable/design.json`. Framework replacement does not authorize UI redesign.

Confirm the baseline and choose a target before proceeding. Final package
acceptance is required only when the user or their governance process requests it.
Completing or accepting the plan, or saying "continue", does not start implementation.
Start delivery separately with a defined scope: `azure-app-rebuild` for direct
implementation, or the participant guide's Matt Pocock or Spec Kit alternative.

Challenge 01 covers the full planning workflow and package handoff.
Challenge 02 reviews and corrects that output; Challenge 03 prepares the
implementation handoff and chosen framework's artifacts. Do not run planning
three times to generate separate parts of the package. The student route chooses
a small app to rebuild completely; the direct path explicitly requests complete-app
scope and implements it in increments, validating every required workflow.
Challenge 04 implements that app; 05 reviews it and fixes missing behavior; 06 refines an applicable
frontend with Impeccable; 07 reviews/fixes security; 08 deploys with the provided
target-specific Azure infrastructure. The student guides contain explicit prompts.

The bundled Microsoft Learn MCP server retrieves public documentation; it grants
no Azure access. Supporting skills are installed separately from their public
upstream repositories. See the [profile inventory](../../scripts/supporting-skills.json)
and [generated commands](../../Student/rebuild/supporting-skills.md).
Report missing tools, pricing evidence, rendering, or independent review.
Installation alone does not show that these operations succeeded.

The [source snapshot](source-snapshot.json) records the planning and diagram origins.
The diagram skill is bundled for distribution with its scripts, assets, tests,
and [source/asset terms](skills/cloud-architecture-diagram/references/REFERENCE.md).
The repository MIT license does not replace those asset terms. Other upstream
supporting skills are not bundled. Evaluation fixtures are synthetic test inputs
for coaches and maintainers, not substitutes for the customer application.

Maintainers: see [Contributing](../../CONTRIBUTING.md). Do not copy the
accelerator's installed third-party skills or ignored evaluation workspaces here.
