# Bounded independent critique

Read this contract after structural validation and the rendering attempt. It
owns the independent review gate for generated and edited diagrams.

## Critic input

Launch one read-only reviewer. Give it:

- the exact `.drawio` path;
- every local PNG or SVG export path;
- renderer and export status;
- confirmed architecture facts and assumptions;
- page names and the declared purpose of each page;
- any supporting architecture record needed to check meaning.

The reviewer inspects only the approved local artifacts. It makes no edits and
does not access cloud accounts.

## Critique

Ask for a page-by-page report that cites exact labels or cell IDs. Classify each
finding as:

- **Blocking:** the diagram can cause an incorrect implementation, security
  assumption, data-flow interpretation, or approval decision.
- **Material:** the diagram is meaningfully ambiguous, inconsistent, or hard to
  read.
- **Cosmetic:** the issue does not change architecture meaning and has little
  effect on readability.

The critique is **exhaustive before it is selective**. Account for every check
below as **passed**, **finding**, **non-applicable**, or **blocked**. Diminishing
returns controls repair churn and cosmetic commentary; it is not permission to
stop before the semantic and cross-page checks are accounted for.

The critique covers:

### Semantic integrity

- Every important edge has the correct caller, direction, target, and label.
- Source-to-ingestion, request-to-service, response-to-caller, and
  identity-token flows follow the confirmed facts.
- Actors use a visible channel or application boundary. They do not appear to
  access stores, queues, models, or managed services directly.
- A model or agent proposes tool intent. Trusted application code owns
  authorization and execution unless the confirmed platform explicitly owns it.
- Retrieval, deterministic calculation, business action, approval, and
  persistence remain distinct responsibilities.
- Human review has a visible interaction surface, authorization path, and state
  transition when review is part of the journey.
- A link to an external user experience does not imply bypassing that system's
  independent authentication or authorization.
- Trust and product boundaries match actual responsibility rather than visual
  convenience.

### Cross-page consistency

- Repeated components keep one canonical name and responsibility.
- Repeated flows keep the same semantic direction and authorization owner.
- Logical components map to deployment resources without changing ownership.
- Repeated entities show a page-specific concern. Repeated meaning is reported
  as duplication.
- Page detail matches its declared purpose. Content that belongs to another page
  is reported when it obscures the current view.
- Facts, assumptions, and deferrals agree with the supporting architecture
  record.

### Visual integrity

- Nodes, containers, icons, labels, and legends do not overlap.
- Connectors do not cross nodes or text, stack without meaning, or obscure
  direction.
- Labels are attached, readable, and unclipped.
- Spacing, alignment, hierarchy, anchors, and flow direction are consistent.
- Grouping, service placement, icons, and trust boundaries are not misleading.
- The rendered output and source XML agree.

When rendering is unavailable, review XML, geometry, labels, routing, semantics,
and cross-page consistency. Record pixel-level visual review as unavailable.

## Report structure

Use this structure:

1. **Gate result:** passed, failed, or blocked.
2. **Coverage:** one compact table that accounts for semantic integrity,
   cross-page consistency, and visual integrity.
3. **Findings:** blocking, material, then cosmetic, with page and exact
   labels/cell IDs.
4. **Page summary:** one result per page.
5. **Repair and recheck:** repairs performed, targeted recheck result, or why no
   recheck occurred.
6. **Stop reason and limitations:** repair-pass count, residual findings,
   renderer status, and unavailable evidence.

## Repair and recheck

Repair every blocking finding and each material finding that affects meaning or
readability. Cosmetic findings do not justify a repair cycle by themselves.

After repair:

1. Rerun structural validation.
2. Re-export affected pages when rendering is available.
3. Send one targeted follow-up to the same reviewer. Include the original
   findings, changed artifact paths, and affected pages. Ask only whether those
   findings are resolved and whether a repair introduced a new blocking defect.

Use the same reviewer because retained context makes the recheck comparative.
Do not launch a new reviewer to search for fresh preferences.

Stop when:

- no blocking or material finding remains; or
- two repair passes have completed.

At the stop, verify that every critique category has a recorded status. Then
record the critique result, repairs, recheck result, residual findings, renderer
limitation, and stop reason. An unresolved blocking finding prevents a passed
review. An unavailable reviewer leaves the independent gate blocked.
