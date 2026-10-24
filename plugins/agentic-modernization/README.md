# Agentic Modernization plugin

Use this plugin for changes to existing applications that go beyond a runtime upgrade.
Follow the [participant setup guide](../../Student/rebuild/setup.md) in the
**application repository**, not this tooling repository.

| Skill | Scope | End state |
| --- | --- | --- |
| `azure-app-modernization` | Recover behavior and constraints, compare strategies, design Azure targets and migration waves | Eight reconciled planning artifacts, `Ready for review`; implementation not started |
| `azure-app-rebuild` | Separately requested implementation of one reviewed wave or vertical slice | Working changes with acceptance evidence, gaps, and review results |
| `cloud-architecture-diagram` | Bundled editable diagram authoring, assets, and review checks | Current/target diagrams with explicit structural, visual, and independent review status |

Planning produces `assessment.md`, `specification.md`, `strategy-matrix.md`,
`target-architecture.md`, `cost-estimate.md`, `current-state.drawio`,
`target-architecture.drawio`, and `migration-plan.md` under `docs/modernization/`.
An existing UI can also require `PRODUCT.md`, `DESIGN.md`, and
`.impeccable/design.json`. Framework replacement does not authorize UI redesign.

Confirm the baseline and choose a target before proceeding. Final package
acceptance is required only when the user or their governance process requests it.
Completing or accepting the plan, or saying "continue", does not start implementation.
Start `azure-app-rebuild` separately with a defined scope.

Challenge 01 covers the full planning workflow and package handoff.
Challenge 02 reviews and corrects that output; Challenge 03 prepares the
implementation handoff. Do not run planning three times to generate separate
parts of the package.

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
