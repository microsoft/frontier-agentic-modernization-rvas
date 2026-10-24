# Agentic Modernization

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Microsoft field technical teams, customer developers, and coaches using a
hands-on hackathon to assess and modernize an application. Participants choose
a delivery route and follow its challenges; coaches facilitate and review
observable evidence.

## Product Purpose

Help teams choose the right modernization route for the change their application
needs, then complete an evidence-backed workflow:

- **Replatform & refactor:** modernize existing code and move to managed Azure
  platforms while preserving core behavior. Success is a running modernized
  Azure application.
- **Rearchitect & rebuild:** address business workflows, architecture, coupling,
  or technology changes beyond a runtime upgrade. Success is one validated
  end-to-end slice, not an entire application rewrite.

## Positioning

Combine guided sample tracks, customer-owned application workflows, presenter
demos, and coach guidance in one hackathon resource. Route by the intended
change, not by programming language. Discovery can recommend a smaller refactor
instead of a rebuild; strategies may differ by component or delivery wave.

## Operating Context

Participants select a route, check prerequisites, and work through Markdown
challenges displayed in the site's shared drawer. Coach solutions and
facilitation guidance support review; presenter demos use the same drawer.

The upgrade route uses GitHub Copilot Modernization tooling. The rebuild route
uses the Agentic Modernization plugin for discovery and planning, followed by a
separate bounded delivery session, validation, and operational handoff.

Customer application work belongs in the customer's own application repository,
not this tooling repository. Access and ownership must be authorized. The full
rebuild path is scoped for two days; planning alone is not a completed rebuild.

## Capabilities and Constraints

- Preserve both delivery routes, the Java, .NET Framework, and .NET 8 sample
  tracks, the customer upgrade track, presenter demos, and coach guidance.
- Preserve the distinction between CLI-led upgrades and plugin-led rebuilds.
- Keep the existing static GitHub Pages architecture: `web/index.html`, CSS and
  JavaScript in `web/assets/`, and Markdown content under `Student/` and `Coach/`.
  `make build` assembles `_site/`; `_site/` is generated output, not the source
  of product or visual truth.
- Preserve challenge navigation, the shared content drawer, and access to
  prerequisite, architecture, setup, solution, and facilitation material.
- Sample Azure architectures are references, not required architectures for
  customer-owned applications.
- Runtime targets, tool commands, prerequisites, and delivery timings must stay
  grounded in the corresponding maintained guides rather than become permanent
  marketing promises.
- Do not invent customer claims, metrics, testimonials, or delivery guarantees.

## Brand Commitments

Preserve the **Agentic Modernization** name and the **RVAP** (Real Value
Acceleration Program) / **RVAS** (Real Value Acceleration Solution) identity.
The supplied RVAP brand kit is binding for future visual work.

The existing layout, colors, and styling are the incumbent baseline, not a
request for redesign. Preserve them during scoped refinements unless a later
request explicitly authorizes a change. This product record does not establish
a replacement visual system.

Delivery-route wayfinding uses Microsoft Blue for **Replatform & refactor** and
RVAP Purple for **Rearchitect & rebuild**, consistently across navigation,
previews, challenges, demos, coach material, and the reading drawer. Language
and phase labels do not introduce competing route colors. Route names and text
labels remain available independently of color. Site-specific route tokens and
overrides live in `web/assets/css/routes.css`; do not modify the shared shell
to implement this mapping.

Brand authority and implementation references:

- `.agents/skills/rvap-brand/references/brand-tokens.md`: kit-derived identity,
  naming, typography, color roles, and logo usage guidance.
- `.agents/skills/rvap-brand/assets/`: supplied stylesheet and logo assets.
- `web/assets/css/brand.css`: site brand tokens.
- `web/assets/css/shell.css`: shared RVAS shell; its header identifies the
  upstream source and directs changes to be made upstream rather than by
  independently restyling a copy.
- `web/index.html` and `web/assets/img/`: current site-specific presentation and
  deployed logo assets.

Use practical, technically credible, outcome-oriented language. Preserve the
distinctions between Build, Innovate, and Scale, and between an observed result
and a proposed outcome. Any conflict between kit guidance and the current
implementation remains a decision for explicitly scoped visual work; init does
not silently reconcile it.

## Evidence on Hand

- `README.md`: route selection, learning objectives, sample applications,
  customer selection criteria, and rebuild outcomes.
- `Student/dotnet/`, `Student/java/`, and `Student/net8/`: sample upgrade
  challenges for ContosoUniversity, PhotoAlbum, and eShopOnWeb.
- `Student/customer/Challenge-00.md`: customer-owned application upgrade path.
- `Student/rebuild/`: rebuild milestones, setup, and supporting-skill guidance.
- `Student/sample-architecture.md`: sample architecture and service references.
- `Coach/`: solutions, facilitation material, and review guidance.
- `Coach/demo/java/guide.md` and `Coach/demo/dotnet/guide.md`: presenter-led
  walkthroughs; the .NET presenter workflow requires Windows with PowerShell 7.
- `plugins/agentic-modernization/`: the rebuild route's plugin implementation
  and supporting documentation.
- `Makefile` and `.github/workflows/gh-pages.yml`: static assembly, validation
  entry points, and publishing configuration.

These assets demonstrate the available learning and delivery workflows; they
are not evidence of customer outcomes or guaranteed modernization results.

## Product Principles

1. Route by the application's intended change, not its language or a preferred
   tool.
2. Preserve observed behavior where required, and validate intentional changes
   with explicit acceptance evidence.
3. Keep scope achievable: one validated rebuild slice is more valuable than an
   unverified promise of a complete rewrite.
4. Keep participant, presenter, and coach material connected while preserving
   their distinct jobs.
5. Favor technically credible, reusable delivery guidance over unsupported
   claims.

The homepage compares the two routes once, with equal weight for their purpose,
tooling, and distinct outcomes. Each route links directly to its first customer
challenge, with sample tracks and rebuild milestones available as secondary
links. Navigation provides shortcuts to the routes and demos rather than
repeating the introduction. Keep sample-specific runtime and service details in
their tracks rather than presenting them as requirements for both routes.

All homepage sections use the shared shell's content width and gutters.
Typography is sized by role: hero, section heading, card heading, body, and
supporting text. Sections do not introduce their own heading or body scales.

## Open Decisions

No product-specific accessibility standard or additional inclusion requirements
were confirmed during initialization. This is not permission to remove existing
accessibility behavior.
