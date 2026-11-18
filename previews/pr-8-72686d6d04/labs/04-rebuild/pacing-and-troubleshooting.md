# Rebuild Lab: Pacing and Troubleshooting

[Labs home](../README.md) | [Self-check](self-check.md)

## Overview and pacing

Start with the customer's business or architecture problem, not a preferred
rewrite or stack. Java/.NET are not prerequisites.

Allow about two days: **645 minutes** of modules plus breaks and troubleshooting.
Four prepared hours can reach planning and an initial package review,
not a completed rebuild. Before you start, choose an application small enough
to rebuild completely; completing one journey is not a completed rebuild.

| Session | Focus | Pacing |
| --- | --- | --- |
| 1 (morning) | 00 preparation, 01 complete discovery/planning workflow | Have stakeholders available for questions and baseline/target decisions |
| 1 (afternoon) | 02 package review, 03 workflow choice and readiness | Question the output; select Opus 5.5 and prepare the complete-app implementation |
| 2 (morning) | 04 complete-app rebuild, 05 app review and fixes | All required workflows, acceptance checks, then missing behavior |
| 2 (afternoon) | 06 frontend, 07 security fixes, 08 Azure deployment | Skip 06 only for headless apps; end with the deployed application |

Follow the [setup guide](setup.md) before you start.
Confirm skills, diagram rendering, Opus 5.5, and the chosen framework in the
application repository. The plugin already bundles the diagram skill.
Use the supplied prompts and make the scope, architecture, and product
decisions yourself.

After target selection, prepare matching infrastructure and a runbook before 08.
Include location/revision, Azure scope, parameters, runtime/configuration,
identity, outputs, deploy/test/recovery commands, and cleanup ownership.
Check the app contract in 03-04. Sample-track Terraform is not a universal
rebuild module.

## Per-module notes

Timings are in the module table in the [lab README](README.md). Tips and troubleshooting for each module are in its **Troubleshooting** section in the [lab modules](challenges/).

## If you get stuck

| Symptom | What to do |
| --- | --- |
| Planning is expected to edit source | Point to the explicit planning stop and separate delivery skill |
| Discovery restarts for the delivery framework | Module 01 generates the package; 02 reviews it; 03 prepares the agreed complete-app implementation |
| Matt's path starts too many agents | Use the explicit two-concurrent-subagent cap, including merger/review agents |
| Impeccable shape stops without code | Confirm the brief, then send the separate implementation request |
| Security review sees an empty working tree | Request the full committed base-to-head rebuild diff too |
| Infrastructure does not match the chosen target | Resolve the infrastructure contract; do not switch platforms or claim deployment |
| Legacy app will not run | Continue bounded static discovery; resolve or own the runtime blocker before delivery |
| Existing UI is replaced with generic screens | Return to the product/design owner and approved surface dispositions |
| Diagram XML passes but no rendering exists | Record structural pass only; do a visual review |
| Agent invents cost totals | Require pricing evidence or attempted-source/tool blocker |
| All your time goes to analyzing the entire portfolio | Agree a smaller application boundary with the stakeholder |
