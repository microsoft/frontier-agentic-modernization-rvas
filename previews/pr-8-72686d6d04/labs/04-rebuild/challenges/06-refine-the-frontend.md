---
title: Refine the Frontend with Impeccable
summary: Refine the frontend with scoped, checked improvements.
phase: Build
group: Build
tags:
- frontend
- impeccable
highlight: false
---

# Module 06: Refine the Frontend with Impeccable

> **Duration:** ~60 minutes | **Phase:** Build

## Objective

Improve the frontend without changing its business behavior. If the app has no UI, record **not applicable: no UI** and continue to Module 07. Use `/impeccable extract` afterward to consolidate repeated tokens and components; that step is optional.

## Prerequisites

- Module 05 completed with a working, reviewed application.
- The Existing UI supporting profile is installed and `/impeccable` is discoverable.
- A running local app with sanitized content, relevant routes and files, `PRODUCT.md`, `DESIGN.md`, and agreed UI changes.

## Step 1: Shape the scoped improvement

Open a new frontend session with the reviewed package, design context, and target route. Run these commands in agent chat, using the installed names.

```text
/impeccable shape
Shape a frontend refinement for [route/surface ID] in our rebuilt application.
Read PRODUCT.md, DESIGN.md, the reviewed modernization specification,
and target architecture. Inspect the running screen and
current components. Primary user/task: [user and task].

Improve hierarchy, task clarity, responsive behavior, and visual coherence.
Preserve business rules, permissions, content, working interactions, and brand.
Change only the screens approved for refinement; ask before changing a screen
marked for preservation or replacing its visual identity.
Cover loading, empty, error, success, permission-denied, and long-content states.
Return a design brief for confirmation; do not write application code yet.
```

Answer the design questions and confirm the brief. **Shape does not write UI code.**

## Step 2: Implement the brief

Request implementation separately:

```text
Implement the confirmed Impeccable brief for [route/surface ID].
Keep the established design system and functional acceptance criteria.
Use existing components/tokens where appropriate. Run the app and inspect
the rendered result at narrow and wide viewports and relevant UI states.
Run the affected tests/build and report actual checks and remaining gaps.
```

## Step 3: Check layout, then color

Use these passes for layout or color issues identified in the brief. Run them separately and inspect the result before moving on. If a pass finds no issue, record that result with rendered evidence. Do not make cosmetic changes just to complete a command.

```text
/impeccable layout
Refine [route and source files] using the confirmed brief. Make the primary
task obvious, group related controls, improve spacing rhythm and density,
and make the layout work at narrow, intermediate, and wide sizes.
Preserve identity, behavior, semantic reading order, and keyboard focus order.
Check realistic long content, empty/error states, overflow, and zoom.
Implement the scoped improvements and verify the rendered result.
```

```text
/impeccable colorize
Refine [route and source files] within our confirmed brand and DESIGN.md.
Use color deliberately for primary actions, selection, focus, status, and
hierarchy, not arbitrary decoration. Preserve semantic meanings and themes.
Check contrast and provide non-color cues for important states. Implement
the improvements and verify the rendered states; do not replace the brand.
```

Favor clear tasks over decoration; colorize need not add more color. Use other commands for specific problems:

| Problem or goal | Command | Guidance |
| --- | --- | --- |
| Unclear hierarchy or task flow | `/impeccable critique` | Review before choosing a fix |
| Accessibility, responsive, or performance gaps | `/impeccable audit` | Find and fix defects |
| Weak typography | `/impeccable typeset` | Improve hierarchy and reading comfort |
| Confusing labels or errors | `/impeccable clarify` | Improve copy without changing meaning |
| Fragile error/empty states | `/impeccable harden` | Handle edge cases |
| Small-screen problems | `/impeccable adapt` | Test the task at target sizes |
| Final inconsistencies | `/impeccable polish` | Finish after layout and color are settled |

## Step 4: Audit and review

Finish with `/impeccable audit`; use `/impeccable polish` for remaining inconsistencies. Fix findings and rerun functional checks. Save before and after views and the inspected states and sizes, including evidence for any no-change decision.

Run `/review` on the frontend changes before the security session.

## Checkpoint

Before moving on, confirm:

- [ ] The brief defines the surface, task, design context, and changes, or you recorded that no UI applies.
- [ ] Confirmed improvements are implemented; layout and color findings are resolved or a no-change decision is supported by rendered evidence.
- [ ] Narrow and wide layouts, relevant states, keyboard use, and contrast are checked; gaps are noted.
- [ ] Functional tests still pass and frontend changes are reviewed.

## Reflect

- Optional: use `/impeccable extract` to consolidate repeated tokens and components after the refinement, without changing unrelated surfaces.

## What You Learned

- Shape a frontend brief before writing UI code.
- Run layout and color passes and verify the rendered result.
- Preserve business rules, permissions and brand while improving the UI.

## Key Takeaway

> Confirm a scoped brief first, then change only the screens it approves.

## Learn more

- [Impeccable commands and skill](https://github.com/pbakaus/impeccable)
- [Impeccable shape reference](https://github.com/pbakaus/impeccable/blob/5cb95eea9c96479f57afe0732a45470d30183326/.github/skills/impeccable/reference/shape.md)

## Troubleshooting

| Symptom | Fix |
|---|---|
| Impeccable shape stops without code | Confirm the brief, then send the separate implementation request. |
| Existing UI is replaced with generic screens | Return to the product and design owner and the approved surface dispositions. |
| A pass finds no issue | Record a no-change decision with rendered evidence instead of making cosmetic edits. |
| The app is headless | Record **not applicable: no UI** and continue to Module 07. |

**Next:** [Module 07: Review security and fix findings](07-security-review-and-fixes.md)
