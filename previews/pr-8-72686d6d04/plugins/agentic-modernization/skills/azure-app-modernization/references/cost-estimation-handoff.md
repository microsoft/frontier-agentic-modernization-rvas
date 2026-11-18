# Cost estimate and handoff contract

Read for every selected target. Create `cost-estimate.md` whether or not the user explicitly asks for pricing. Cost estimation is part of package construction, not a post-approval follow-up: build the meter-ready model, load `cost-estimation`, and execute every pricing step that the available evidence supports before final handoff. When pricing is blocked, preserve the attempted source/tool, resource model, scenarios, assumptions, and missing inputs instead of inventing usage or point prices.

## Required document

Use this structure:

```markdown
# Modernization cost estimate
## Status, scope, and architecture revision
## Estimate basis and pricing evidence
## Resource and usage model
## Migration and coexistence phases
## Scenario calculations and totals
## Sensitivity and cost drivers
## Assumptions, exclusions, and unresolved inputs
## Cost-estimation handoff
```

Retain this structure after invoking `cost-estimation`. The specialist supplies pricing evidence and calculations; it does not replace the modernization document with a standalone short-form estimate. Populate migration/coexistence phases and the handoff/update section even when their monetary totals remain blocked.

Set status to one of:

- `Provisional - pricing inputs incomplete`;
- `Pricing attempted - source or tool unavailable`;
- `Scenario estimate - retail prices verified`;
- `Scenario estimate - negotiated prices verified`.

Never represent a missing amount as zero. Use `Not calculated` with the blocking input, owner, and decision gate.

## Estimate basis

Record:

| Field | Required content |
|---|---|
| Architecture revision | Selected target revision and package status |
| Currency and billing basis | Currency; retail, EA, MCA, or unresolved |
| Regions | Primary, secondary/DR, and unresolved residency constraints |
| Environments | Named environments, counts, and operating schedules |
| Estimate period | Monthly/annual or another requested planning period |
| Price evidence | Source, retrieval date, price type, and verification status; otherwise `Pending` |

Inventory each billable target or platform prerequisite, using the same component IDs and resource list as the `IAC-` inventory in `infrastructure-plan.md`:

| Architecture ID | Azure service / pricing model | Region | Environment / quantity | Low / expected / high usage | Unit price / source | Period cost / status | Evidence / owner |
|---|---|---|---|---|---|---|---|
| Stable component ID | Service plus selected or candidate tier | Named or unresolved | Count, replicas, and schedule | Meter-aligned quantities with units | Verified price or `Pending` | Calculation or `Not calculated` | Measurement, requirement, or assumption ID |

Capture the drivers that can materially affect the selected service: compute shape and active time, autoscale floor/expected/ceiling, storage and growth, operations or requests, data transfer and egress, backup/retention, observability ingestion/retention, availability/DR duplication, licenses, and private networking or platform dependencies. Use only applicable drivers; do not populate irrelevant fields.

Map known values to evidence. For an unknown, name the owner, measurement method, and decision gate. Keep candidate tiers separate when unresolved because the pricing workflow must not silently choose among plausible meters.

In `target-architecture.md`, retain `## Cost-estimation handoff` as a concise pointer to `cost-estimate.md`, its status, architecture IDs, and architecture decisions that still block pricing. Keep detailed quantities and calculations in `cost-estimate.md`.

## Pricing execution before handoff

Load `cost-estimation` as a bounded consultation after the selected target and migration phases are priceable enough to identify meters. This consultation is analysis inside the planning boundary; it does not provision resources or authorize implementation.

1. Distinguish hypothetical target pricing from forecasting an existing Azure billing scope.
2. For each meter-ready line, use the pricing workflow to retrieve retail prices. Preserve product, SKU, meter, region, currency, price type, unit, retrieval date, and source.
3. When negotiated pricing is requested and the billing scope is available, run the applicable EA/MCA price-sheet workflow and keep negotiated values separate from retail values.
4. If a meter is ambiguous, ask only for the minimum missing detail needed to choose among plausible meters. Consolidate independent missing details into one cost-input round before final reconciliation; this is not a package-approval prompt.
5. If required workload, region, currency, SKU/tier, billing scope, or pricing tooling is unavailable, do not make a non-specific handoff. Record the exact blocked lines, attempted source/tool when an attempt was possible, owner, and completion gate.

Do not declare the package complete with a merely meter-ready handoff when enough inputs exist to retrieve prices. Conversely, do not query a meaningless meter when a required discriminator is genuinely absent.

## Migration cost phases

In `migration-plan.md`, make duration and overlap priceable. Reproduce the resulting cost scenarios in `cost-estimate.md`:

| Phase / waves | Duration basis | Source resources retained | Target resources active | Temporary services / transfer | Evidence / owner |
|---|---|---|---|---|---|
| Named phase or wave IDs | Measured, assumed range, or prerequisite | Components still billed | Environments and scale active | Replication, transfer, tooling, or hypercare | Assumption and validation owner |

Separate:

- one-time migration spend;
- temporary source/target coexistence;
- steady-state target operation;
- licenses, support, or delivery effort when relevant.

Duration without evidence remains a range or prerequisite. Do not turn an architecture package into a precise business case by assumption.

## Scenario calculations

Show low, expected, and high scenarios when uncertainty materially changes spend. For each calculated line preserve service/product, SKU or pricing model, region, meter/unit, price type, currency, unit price, quantity, formula, and period cost.

Summarize separately:

- one-time migration;
- temporary coexistence by duration;
- monthly and annual steady-state target operation;
- optional DR, licenses, support, and delivery effort when included.

Label retail and negotiated values separately. Totals combine only one currency and one clearly stated price basis.

## Completion and future pricing

Before final package handoff, apply `cost-estimation` to the selected target using hypothetical pricing for undeployed resources. Existing-scope forecasting remains a separate comparison based on Azure billing history. After handoff, `cost-estimation` owns refreshes when measurements, architecture revisions, negotiated rates, or prices change. Package status is `Ready for review` unless explicit acceptance was requested and obtained; incomplete pricing lines are cost blockers, not a reason to reopen package approval.

`cost-estimate.md` exists and names the architecture revision. Every billable component and shared platform prerequisite is represented or explicitly excluded. Every material usage value is measured, stakeholder-confirmed, or visibly provisional with an owner and gate. Migration overlap can be calculated by phase. Every meter-ready line has dated price evidence or a concrete pricing-attempt blocker. Calculated totals are traceable to dated price evidence; blocked totals say `Not calculated`. The package contains no unsupported SKU choice, point price, savings claim, or exact total.
