**[Home](../../README.md)** | [Previous](Challenge-05.md) | [Next](Challenge-07.md)

# Challenge 06: Refine the Frontend with Impeccable

**Estimated Time:** 60 minutes

## Introduction

Improve the frontend without changing its business behavior. If the app has
no UI, record **not applicable: no UI** and continue to Challenge 07.

## Prerequisites

- Challenge 05 completed with a working, reviewed application.
- The Existing UI supporting profile is installed and `/impeccable` is discoverable.
- A running local app with sanitized content, relevant routes/files,
  `PRODUCT.md`, `DESIGN.md`, and agreed UI changes.

## Description

### Shape the scoped improvement

Open a new frontend session with the handoff, requirements, design context, and
target route. Run these commands in agent chat, using the installed names.

```text
/impeccable shape
Shape a frontend refinement for [route/surface ID] in our rebuilt application.
Read PRODUCT.md, DESIGN.md, the reviewed modernization specification,
target architecture, and rebuild-handoff.md. Inspect the running screen and
current components. Primary user/task: [user and task].

Improve hierarchy, task clarity, responsive behavior, and visual coherence.
Preserve business rules, permissions, content, working interactions, and brand.
Change only the screens approved for refinement; ask before changing a screen
marked for preservation or replacing its visual identity.
Cover loading, empty, error, success, permission-denied, and long-content states.
Return a design brief for confirmation; do not write application code yet.
```

Answer the design questions and confirm the brief. **Shape does not write UI
code.** Request implementation separately:

```text
Implement the confirmed Impeccable brief for [route/surface ID].
Keep the established design system and functional acceptance criteria.
Use existing components/tokens where appropriate. Run the app and inspect
the rendered result at narrow and wide viewports and relevant UI states.
Run the affected tests/build and report actual checks and remaining gaps.
```

### Check layout, then color

Use these passes for layout or color issues identified in the brief. Run them
separately and inspect the result before moving on. If a pass finds no issue,
record that result; do not make cosmetic changes just to complete a command.

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

Favor clear tasks over decoration; colorize need not add more color.
Use other commands for specific problems:

| Problem or goal | Command | Guidance |
| --- | --- | --- |
| Unclear hierarchy or task flow | `/impeccable critique` | Review before choosing a fix |
| Accessibility, responsive, or performance gaps | `/impeccable audit` | Find and fix defects |
| Weak typography | `/impeccable typeset` | Improve hierarchy and reading comfort |
| Confusing labels or errors | `/impeccable clarify` | Improve copy without changing meaning |
| Fragile error/empty states | `/impeccable harden` | Handle edge cases |
| Small-screen problems | `/impeccable adapt` | Test the task at target sizes |
| Final inconsistencies | `/impeccable polish` | Finish after layout and color are settled |

Finish with `/impeccable audit`; use `/impeccable polish` for remaining
inconsistencies. Fix findings and rerun functional checks. Save before/after
views and inspected states/sizes, including evidence for any no-change decision.
Run `/review` on frontend changes before the security session.

## Success Criteria

- [ ] The brief defines the surface, task, design context, and changes, or the team records that no UI applies.
- [ ] Confirmed improvements are implemented; layout/color findings are resolved or a no-change decision is supported by rendered evidence.
- [ ] Narrow/wide layouts, relevant states, keyboard use, and contrast are checked; gaps are noted.
- [ ] Functional tests still pass and frontend changes are reviewed.

## Learning Resources

- [Impeccable commands and skill](https://github.com/pbakaus/impeccable)
- [Impeccable shape reference](https://github.com/pbakaus/impeccable/blob/5cb95eea9c96479f57afe0732a45470d30183326/.github/skills/impeccable/reference/shape.md)

## Advanced Challenge (Optional)

Use `/impeccable extract` to consolidate repeated tokens/components after the
refinement, without changing unrelated surfaces.
