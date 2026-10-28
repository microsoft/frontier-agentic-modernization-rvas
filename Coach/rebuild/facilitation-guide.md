# Rebuild Route: Facilitation Guide

**Coach material.** [Coach home](../README.md) |
[Scoring rubric](scoring-rubric.md)

## Event overview and agenda

Start with the customer's business or architecture problem, not a preferred
rewrite or stack. Java/.NET are not prerequisites.

Allow two days: **645 minutes** of challenges plus breaks and troubleshooting.
A prepared four-hour session can aim for planning and an initial package review,
not a completed rebuild. Choose an application small enough to rebuild completely
before the event; completing one journey is not completion.

| Day | Focus | Pacing |
| --- | --- | --- |
| 1 morning | 00 preparation, 01 complete discovery/planning workflow | Stakeholders attend questions and baseline/target decisions |
| 1 afternoon | 02 package review, 03 workflow choice and handoff | Challenge the output; select Opus 5.5 and prepare the complete-app implementation |
| 2 morning | 04 complete-app rebuild, 05 app review and fixes | All required workflows, acceptance checks, then missing behavior |
| 2 afternoon | 06 frontend, 07 security fixes, 08 Azure deployment | Skip 06 only for headless apps; end with the deployed application |

Use the [participant setup guide](../../Student/rebuild/setup.md) before the event.
Confirm skills, diagram rendering, Opus 5.5, and the chosen framework in the
application repository. The plugin already bundles the diagram skill.
Students use the supplied prompts and make the scope, architecture, and product
decisions themselves.

After target selection, provide matching infrastructure and a runbook before 08.
Include location/revision, Azure scope, parameters, runtime/configuration,
identity, outputs, deploy/test/recovery commands, and cleanup ownership.
Check the app contract in 03-04. Sample-track Terraform is not a universal
rebuild module.

## Challenge 00: Preparation (30 minutes)

Confirm the complete-app boundary, repository access, evidence, and stakeholder attendance.
Missing build tools may wait during planning, but must be resolved before coding.
For runtime-only work, redirect to
[Upgrade your application](../../Student/customer/Challenge-00.md).

Keep application work in its own repo. Authorized customer ownership matters,
not whether that repo is public or private.

## Challenge 01: Complete discovery and planning (150 minutes)

Run `azure-app-modernization` once through discovery, stakeholder questions,
baseline confirmation, target selection, and the nine-file package. It consults
diagram and cost skills itself; do not restart it for each file.

Check permissions, failures, side effects, and existing UI behavior. Missing
evidence is a gap, not proof of no dependency. Confirm the baseline before
choosing or delegating the target.

Require a pricing attempt, diagram review status, and migration waves.
Completion is `Ready for review`; no extra approval gate unless required.
The skill stops before implementation. If time runs out, save the phase and
open decisions; change scope only with the stakeholder.

## Challenge 02: Review and challenge the package (45 minutes)

Check all required workflows and trace a critical journey in detail from source
through requirements, architecture, and migration waves. Challenge unnecessary services or redesign, and check lower-change
options, official Azure evidence, costs, write ownership, and recovery.

Correct affected files without restarting discovery. Reopen decisions only
when new evidence changes them. Save the reviewed revision and unresolved findings
with owners. Diagram tests prove structure/assets, not visual quality; render
and independently review where possible, noting missing checks. Obtain formal
acceptance or exceptions only when the customer's governance requires them.

## Challenge 03: Choose the implementation workflow (45 minutes)

Use **Claude Opus 5.5** via `/model` or the VS Code picker. Choose one path;
all use the reviewed package, and direct delivery is a valid choice.

| Path | Check before implementation |
| --- | --- |
| Direct | `azure-app-rebuild` prompt and explicit complete-app handoff, implemented incrementally |
| Matt Pocock | Local Markdown setup, `to-spec`, `to-tickets`, acceptance-ID links, and real dependencies |
| Spec Kit | Constitution, spec, plan, tasks; clarify as needed and optionally analyze. Implement/converge in 04 until `Converged` |

Check baseline output, fixtures, access, existing failures, and blockers without
editing application code or provisioning resources. The 45 minutes assumes
tools are installed.

In `docs/modernization/rebuild-handoff.md`, capture revision, complete-app scope, acceptance IDs,
dependencies, preserved behavior/UI, write ownership, recovery limits, generated
artifact paths, delivery owner, and excluded actions. Another teammate should
be able to start from it.

## Challenge 04: Rebuild the app (150 minutes)

Start a new session, reselect Opus 5.5, and use the matching A/B/C prompt.
Do not stack `azure-app-rebuild` over Matt/Spec Kit. Keep the agreed app boundary and
preserved business/UI behavior; adapters need clear write ownership.

Matt's `implement-spec` permits local commits/worktree merges, not pushes or
remote issues/PRs. Enforce **two concurrent subagents total**, including merge,
exploration, review, and fix agents. Implementation subagents use Opus 5.5.
Respect dependencies and existing user work. Direct/Spec Kit do not authorize
commits; cloud execution waits until 08.

For blocked teams, record incomplete workflows and blockers honestly; do not
silently redefine the app as one journey. For teams ahead, strengthen failure-path
and compatibility tests before adding work.

## Challenge 05: App review and missing behavior (60 minutes)

Run `/review` and the completeness prompt against the complete app, including
committed changes. Exercise every required workflow against the specification, fix
omissions, rerun checks, and review fixes. Framework reviews do not replace this.

## Challenge 06: Frontend refinement (60 minutes)

Skip as N/A for headless apps. Otherwise start a frontend session with the
running route, surface IDs, and product/design context. Use `/impeccable shape`,
confirm the brief, and request implementation; shape writes no UI code.
Use `/impeccable layout` and `/impeccable colorize` for identified issues, then
inspect rendered states. Accept a justified no-change result rather than cosmetic churn.
Preserve business rules, permissions, brand, and unchanged surfaces.
Use audit/polish as needed and review the UI diff.

## Challenge 07: Security review and fixes (45 minutes)

Run `/security-review` after frontend changes, including committed work.
Check fixes, regression results, and re-review. If tooling is missing, use a named
reviewer. Resolve deployment blockers before 08.

## Challenge 08: Run and deploy to Azure (60 minutes)

Check local execution and infrastructure compatibility, then use the deployment
prompt to authorize the agreed non-production scope. Require a working Azure
endpoint, persistence/integrations, telemetry, and recovery checks.
A tabletop is not a completed deployment. Require evidence for all required
workflows, not just one happy-path demo. Ask how recovery handles target-only
writes, and end with the demo, results, remaining work, operations and cleanup owners.

## Common stuck points and pivots

| Stuck point | Coaching response |
| --- | --- |
| Team expects planning to edit source | Point to the explicit planning stop and separate delivery skill |
| Team restarts discovery for the delivery framework | Challenge 01 generates the package; 02 reviews it; 03 prepares the agreed complete-app implementation |
| Matt's path starts too many agents | Use the explicit two-concurrent-subagent cap, including merger/review agents |
| Impeccable shape stops without code | Confirm the brief, then send the separate implementation request |
| Security review sees an empty working tree | Request the full committed base-to-head rebuild diff too |
| Infrastructure does not match the chosen target | Resolve the provided infrastructure contract; do not switch platforms or claim deployment |
| Legacy app will not run | Continue bounded static discovery; resolve or own the runtime blocker before delivery |
| Existing UI is replaced with generic screens | Return to product/design authority and approved surface dispositions |
| Diagram XML passes but no rendering exists | Record structural pass only; assign visual review |
| Agent invents cost totals | Require pricing evidence or attempted-source/tool blocker |
| All event time spent analyzing the entire portfolio | Confirm a smaller application boundary with the stakeholder |
