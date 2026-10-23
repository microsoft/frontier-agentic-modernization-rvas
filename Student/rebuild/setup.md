# Rebuild route: setup and usage

[Home](../../README.md) | [Challenge 00](Challenge-00.md) |
[Supporting skills](supporting-skills.md)

**Work in your existing application repository.** This repository distributes
skills and challenges; it is not the destination for customer source code.
Choose this route for architectural or business challenges beyond an isolated
runtime upgrade. For compatibility-first upgrades, use the
[CLI customer route](../customer/Challenge-00.md) instead.

## Prepare the application workspace

Bring source, build/run notes, relevant contracts, sanitized schema/data evidence,
and a business/product stakeholder who can resolve behavior and scope decisions.
Identify one tractable business journey and the challenge it needs to address.
Do not bring production data, credentials, or unrestricted database backups.

Use Git and a supported GitHub Copilot CLI or VS Code with Copilot access.
Supporting-skill installation also requires Node.js 22.20.0+ and npx.
Python 3.10+ is needed for the diagram tooling; inspect its requirements and
renderer setup before use. Azure access is not needed merely to inspect source
or write a plan. Delivery tools and cloud permissions depend on the chosen target.

A missing build environment can be an explicit planning evidence gap, but it
blocks claims of executable validation. Establish a runnable baseline before
implementing a slice.

## Install provided plugin

In GitHub Copilot CLI:

```bash
copilot plugin marketplace add microsoft/frontier-agentic-modernization-rvas
copilot plugin install agentic-modernization@agentic-modernization
copilot plugin list
```

These commands require the plugin files to have been published to the repository.
Before publication, maintainers use the local marketplace checks in
[Contributing](../../CONTRIBUTING.md).

In VS Code, add this marketplace to your existing settings without replacing
other entries:

```json
{
  "chat.plugins.enabled": true,
  "chat.plugins.marketplaces": [
    "microsoft/frontier-agentic-modernization-rvas"
  ]
}
```

Open Extensions, search for `@agentPlugins`, and install **Agentic Modernization**.
Enable it in the application workspace. Manage the plugin in the host where you
installed it; do not assume CLI installation installs it in VS Code too.

## Install supporting skills separately

Use the exact [profile commands](supporting-skills.md):
**Planning essentials** first, **Existing UI** when applicable, then
**Implementation support** before delivery. Target-specific specialists are
optional, not a request to install every Azure skill.

The plugin bundles our planning and rebuild skills, `cloud-architecture-diagram`
with its assets and scripts, and public Microsoft Learn documentation MCP.
Do not install another copy of the diagram skill. The plugin does not install the
other upstream supporting skills or grant
Azure access. Use `/skills` and `/mcp` in CLI, or **Chat: Configure Skills** and
the MCP server list in VS Code, to verify availability. Reload if necessary.

## Start architecture-first planning

Select `azure-app-modernization` in your host's skill picker/slash completion.
Names may be host-qualified; use the displayed name. Provide a brief such as:

```text
Assess this existing application for Azure modernization. Our challenge is
[business outcome or architectural constraint]. Inspect source and supporting
evidence before interviewing us. Recover critical journeys and contracts,
compare a lower-change option with rearchitecture or rebuild, and plan before
changing code. Preserve existing UI behavior unless we explicitly select changes.
```

**Challenge 01 is one complete planning workflow**, not a sequence of separate
document-generation tasks. Stay in the conversation through analysis, questions,
baseline confirmation, and target selection or bounded delegation. The skill
pauses for those decisions and may draft documents progressively; it then
reconciles the complete package before handing off. You do not need to invoke
the skill again for each document or stop after the assessment.

The workflow produces eight artifacts under `docs/modernization/`: `assessment.md`,
`specification.md`, `strategy-matrix.md`, `target-architecture.md`,
`cost-estimate.md`, `current-state.drawio`, `target-architecture.drawio`, and
`migration-plan.md`. UI recovery may also write `PRODUCT.md`, `DESIGN.md`, and
`.impeccable/design.json`.

Ordinary completion is **Ready for review**. Formal package acceptance is
required only when requested by your team or governance process. Missing pricing,
diagram rendering, or independent review must have an honest status and owner.
Planning ends with **architecture and migration planning only; implementation
not started**. Neither acceptance nor "continue" starts a rebuild.

## Review the package and prepare delivery

In **Challenge 02**, review the complete package against source evidence and
stakeholder decisions. Check functional/UI preservation, strategy alternatives,
Azure evidence, costs, diagrams, migration waves, and recovery assumptions.
Request targeted corrections in the existing planning workflow. Material new
evidence reopens the affected decision; do not regenerate everything blindly.
Record the reviewed revision and unresolved findings/owners.

In **Challenge 03**, select one bounded end-to-end slice from that reviewed
package. Identify acceptance IDs, dependencies, preserved contracts, data/UI
boundaries, and validation evidence. Check the existing safe build/test baseline
and delivery prerequisites; report blockers without changing application code.
Prepare the handoff below, but do not start implementation yet.

## Start a separate rebuild session

In **Challenge 04**, use the handoff prepared in Challenge 03. Open a new session,
attach the eight reviewed planning artifacts, current source/tests, domain
decisions, UI authority, and any required acceptance record. Identify the package
revision, slice, acceptance IDs, readiness evidence, and excluded actions.
Select `azure-app-rebuild`
explicitly; it is a user-invoked delivery skill.

```text
Implement only [wave or vertical slice] from the reviewed modernization package
at [revision]. Its acceptance IDs are [IDs]. Reconcile the package with current
source before editing and report material drift. Preserve all behavior, external
contracts, data ownership, and UI surfaces not explicitly changed by the plan.
Validate each in-scope criterion and report pass/fail/blocked evidence.
Do not commit, provision, deploy, or migrate production data in this session.
```

The rebuild skill uses focused supporting skills, not the upstream `implement`
skill with its automatic commit step. It stops after the requested slice.
Implementation-completeness and security reviews are separate checks; record
findings, resolve them, and rerun affected tests. If a reviewer/tool is missing,
assign the gap rather than claiming a pass.

In CLI, the review entry points are `/review` and `/security-review`. In VS Code,
use the available review tools or a separate read-only review conversation and
named human reviewer. Do not assume slash commands are identical across hosts.

## Update or remove

```bash
copilot plugin update agentic-modernization
copilot plugin uninstall agentic-modernization
```

VS Code users use its plugin update/uninstall actions instead. Supporting-skill
copies have a separate lifecycle; review their source pins and existing copies
before reinstalling. Removing the plugin does not remove customer artifacts or
project-local supporting skills.

## Official references

- [Copilot CLI plugin reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference)
- [VS Code agent plugins](https://code.visualstudio.com/docs/agent-customization/agent-plugins)
- [Supporting-skills installer](https://github.com/vercel-labs/skills)
