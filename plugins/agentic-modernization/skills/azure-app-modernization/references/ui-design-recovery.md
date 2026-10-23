# User-interface and design recovery contract

Read when the confirmed application boundary contains a user-facing interface. Recover what the product and interface already are before selecting a replacement technology.

## Planning outputs

UI recovery has three distinct authorities:

| Authority | Planning record |
|---|---|
| Product purpose, users, vocabulary, brand commitments, and durable constraints | `PRODUCT.md` |
| Visual system, tokens, typography, spacing, shapes, components, and conventions | `DESIGN.md` and `.impeccable/design.json` |
| Actual routes, layouts, journeys, states, responsive behavior, and dependencies | `assessment.md` with stable `SURF-` IDs |

One record cannot substitute for another. A design system does not describe every screen, and a screen inventory does not establish durable product truth.

## Safety boundary

Use Impeccable as a bounded discovery specialist. Permit only durable product/design-context outputs named by the parent skill. Keep application source, styles, assets, manifests, dependencies, tests, CSP, hooks, live configuration, critique history, and generated implementation unchanged.

Use source inspection, supplied screenshots, existing design artifacts, and an already-running application when safely available. Do not install dependencies, start unknown code, or change repository configuration merely to render the UI. Record missing rendered evidence and its consequence.

If `impeccable` is unavailable, do not install it automatically or imitate its completed artifacts. Continue the static surface inventory, record product/design recovery as a gap, and ask the user to install it or accept a named deferral before baseline confirmation.

## 1. Inventory the UI estate

Identify every UI application, rendering boundary, route family, shared shell, component library, theme/token source, asset set, build entry point, and frontend/backend contract. Account for server-rendered templates, native clients, administrative tools, embedded widgets, and separately deployed frontends.

For each meaningful surface, assign a stable `SURF-` ID and record:

- Route or entry point, user, job, and criticality.
- Layout topology, navigation relationship, and shared shell/components.
- Inputs, outputs, APIs/events, identity/permission behavior, and system of record.
- Loading, empty, error, success, permission, overflow, and recovery states.
- Minimum, typical, and maximum content/data ranges when evidenced.
- Responsive transformations, supported device classes, keyboard behavior, and accessibility evidence.
- Existing tests, screenshots, supplied rendered evidence, and source locations.
- Confidence, contradiction, visual/runtime evidence gaps, and validation owner.

Preserve source observations separately from desired improvements. A known visual or accessibility defect remains a finding until an owner decides whether to preserve or fix it.

## 2. Recover product authority

Inspect any existing `PRODUCT.md` before invoking Impeccable.

- **Current file:** use it as evidence and ask only about material gaps or contradictions.
- **Missing file:** load `impeccable` and use its `init` capability to recover durable product truth from repository evidence plus focused stakeholder confirmation.
- **Stale or competing files:** preserve both sources, identify the authority conflict, and ask before updating.

Keep `init` bounded to `PRODUCT.md`. Skip implementation-time build-path, live-mode, hook, CSP, and source-configuration branches. Record undecided product facts rather than inventing them.

`PRODUCT.md` is complete for modernization when it establishes the platform, users, purpose, operating context, capabilities/constraints, binding brand commitments, evidence on hand, and material open decisions needed to judge preservation or change.

## 3. Recover incumbent visual authority

Inspect any existing `DESIGN.md`, token/theme files, global styles, component primitives, representative screens, and supplied screenshots.

Classify the incumbent UI:

- **Coherent:** repeated tokens, typography, layout, shapes, components, and interaction conventions form a recognizable system.
- **Fragmented:** local conventions exist but conflict materially across surfaces.
- **Absent/minimal:** evidence does not support a reusable visual authority.

Then:

- **Coherent and `DESIGN.md` missing:** load `impeccable` and use `document` in scan mode to write `DESIGN.md` and `.impeccable/design.json`.
- **Existing `DESIGN.md`:** compare it with the implementation. Refresh, merge, or preserve it only after explicit confirmation; never silently overwrite it.
- **Fragmented:** document the observed systems and conflicts in `assessment.md`. Do not synthesize a falsely coherent design authority without stakeholder selection.
- **Absent/minimal:** record that the future UI needs an intentional design-system decision. Do not create a generic seed during current-state recovery.

Qualitative language that code cannot prove requires stakeholder confirmation. Exact tokens, component APIs, and observed responsive rules remain evidence-backed.

## 4. Confirm the UI baseline

Present:

- UI applications, surface inventory, critical journeys, and assessed coverage.
- Product authority and open product decisions.
- Visual authority classification and recovered artifacts.
- Layout, component, state, responsive, accessibility, and rendered-evidence gaps.
- Existing defects awaiting preserve/fix decisions.
- Proposed surface-level preservation/change scope.

Baseline confirmation covers the named revisions of `assessment.md`, `PRODUCT.md`, and `DESIGN.md` when present. Later changes to any authority reopen affected requirements and strategy decisions.

## 5. Classify future surface disposition

During strategy comparison, give each `SURF-` entry one explicit disposition:

| Disposition | Meaning |
|---|---|
| Preserve | Keep behavior and experience unchanged |
| Replatform | Change implementation technology while preserving the experience |
| Refine | Correct approved usability, accessibility, responsive, or consistency findings |
| Redesign | Preserve product truth and required behavior while intentionally replacing interaction/visual direction |
| Replace | Build a different approved experience for the capability |
| Retire | Remove the surface and account for affected journeys/contracts |

A framework migration is not a redesign by default. Preserve incumbent layouts, vocabulary, states, responsive behavior, and design conventions unless the confirmed specification authorizes a change.

After target selection, use Impeccable `shape` only for refine/redesign/replace surfaces whose experience remains materially open. Record the confirmed brief in the specification and, when the installed workflow supports durable surface briefs, under `.impeccable/surfaces/`. Preserve/replatform surfaces inherit `PRODUCT.md`, `DESIGN.md`, and the surface inventory without a new visual-world exercise.

## 6. Trace to specification and delivery

Map every `SURF-` ID to:

- `FR-`, `TR-`, `NFR-`, and `AC-` IDs.
- Preserve/change/retire decision and owner.
- Target frontend/component responsibility.
- Migration wave and coexistence boundary.
- Required characterization, interaction, accessibility, responsive, and visual-parity evidence.
- Delivery-time Impeccable capability: implement against recovered authority, critique, audit, harden, or polish.

The migration plan names the downstream implementation owner and requires delivery to read `PRODUCT.md`, `DESIGN.md`, `.impeccable/design.json`, confirmed surface briefs, and the approved package before changing UI code.

## Completion check

Every UI application and meaningful surface is inventoried or explicitly unassessed. Product and visual authority are recovered, classified, or deferred with an owner. Every surface has a future disposition and traceability to requirements, architecture, wave, and validation. No application code or implementation-time Impeccable state changed during recovery.
