# Rebuild route: setup and usage

[Home](../../README.md) | [Challenge 00](Challenge-00.md) |
[Supporting skills](supporting-skills.md)

**Work in your application repository**, not this tooling repo.
For runtime-only upgrades, use the
[CLI customer route](../customer/Challenge-00.md) instead.

## Prepare the application workspace

Bring source, build/run notes, contracts, sanitized database/UI evidence, and
a stakeholder who can answer business questions. No production data or credentials.

| Need | Tools or access |
| --- | --- |
| Agent workspace | Git and GitHub Copilot CLI or VS Code with Copilot |
| Supporting-skill installation | Node.js 22.20.0+ and npx |
| Diagrams | Python 3.10+ plus the diagram skill's packages and renderer |
| Implementation | **Claude Opus 5.5**, target build/run tools, and a working baseline |
| Deployment | Azure CLI, non-production Azure permissions, and coach-provided target infrastructure/runbook |

Planning needs no Azure access. Note missing build tools, but resolve them before
implementation. Before Challenge 08, obtain the infrastructure location/revision,
inputs, outputs, commands, recovery limits, and cleanup owner. The sample-track
infrastructure may not fit your target.

## Install provided plugin

In GitHub Copilot CLI:

```bash
copilot plugin marketplace add microsoft/frontier-agentic-modernization-rvas
copilot plugin install agentic-modernization@agentic-modernization
copilot plugin list
```

The plugin must be published first. Before publication, maintainers use
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

Search Extensions for `@agentPlugins`, install **Agentic Modernization**, and
enable it in the application workspace. CLI and VS Code installations are separate.

## Install supporting skills separately

Use the [profile commands](supporting-skills.md): **Planning essentials**,
**Existing UI** if applicable, and **Implementation support** before delivery.
Add **Matt Pocock workflow** only for that path. Install target specialists only
when needed; Spec Kit setup is below.

The plugin already includes the planning/rebuild skills,
`cloud-architecture-diagram`, and Microsoft Learn MCP. Do not duplicate the
diagram skill. Verify availability with `/skills` and `/mcp` in CLI, or
**Chat: Configure Skills** and the MCP list in VS Code. Reload if needed.

## Start architecture-first planning

Select `azure-app-modernization` using the name shown by your host and send the
[Challenge 01 prompt](Challenge-01.md). Stay in one conversation through questions,
baseline confirmation, target selection, and package completion.

The workflow produces eight artifacts under `docs/modernization/`: `assessment.md`,
`specification.md`, `strategy-matrix.md`, `target-architecture.md`,
`cost-estimate.md`, `current-state.drawio`, `target-architecture.drawio`, and
`migration-plan.md`. UI recovery may also write `PRODUCT.md`, `DESIGN.md`, and
`.impeccable/design.json`.

Planning ends at **Ready for review**, with **architecture and migration planning only; implementation
not started**. Formal acceptance is needed only if your team requires it.
Note missing pricing or diagram reviews and who will complete them.

## Sessions and implementation choices

| Challenge | Student action |
| --- | --- |
| [01](Challenge-01.md) | Run the provided discovery skill for functional specs, architecture, costs, diagrams, and migration planning |
| [02](Challenge-02.md) | Analyze the package and request targeted corrections |
| [03](Challenge-03.md) | Select Opus 5.5, bound one slice, and choose direct, Matt Pocock, or Spec Kit |
| [04](Challenge-04.md) | Start a fresh delivery session and run the selected implementation prompt |
| [05](Challenge-05.md) | Run `/review`, check specification coverage, and implement missing behavior |
| [06](Challenge-06.md) | Refine an applicable frontend with Impeccable shape, implementation, layout, and colorize |
| [07](Challenge-07.md) | Run `/security-review`, fix findings, and recheck |
| [08](Challenge-08.md) | Run locally, deploy with provided Azure infrastructure, and validate the deployed journey |

Select **Claude Opus 5.5** with `/model` or the VS Code picker in 03 and again
in the new delivery session. All three workflows use the reviewed package.
Choose one; do not stack their orchestrators.

### Direct from the documents

Use `azure-app-rebuild` and the Challenge 04 prompt. No ticket framework or
upstream `implement` skill is needed; this path does not commit automatically.

### Matt Pocock workflow

Use the Challenge 03 prompts for `/setup-matt-pocock-skills`, `/to-spec`, and
`/to-tickets`, then `/implement-spec` in 04. Local Markdown tracking stores specs
at `.scratch/<feature>/spec.md` and tickets under `.scratch/<feature>/issues/`.

This path uses worktrees, local commits, and merges, but no pushes or remote
publication. Keep **at most two subagents active**, with Opus 5.5 for implementation
subagents. Start from a clean or isolated baseline without discarding existing work.

### Spec Kit setup

For this path only, install Python 3.11+ and uv, then run:

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v1.2.3
specify version
```

If already installed, check the version and follow upstream upgrade instructions.
Before initialization, commit or back up current work and inspect `.specify/`
and Copilot customization files. Conflicting managed files can be replaced:

```bash
specify init --here --force --integration copilot
git diff --stat
```

Inspect the full diff. Skip initialization if already configured.
Challenge 03 turns the reviewed package into a constitution, feature spec, plan,
and tasks; analysis is optional. In 04, repeat `/speckit-implement` and
`/speckit-converge` until **`Converged`**.

Copilot skills use names such as `/speckit-specify` and `/speckit-plan`.
If your host shows dotted names such as `/speckit.specify`, use that equivalent.
Run each separately in agent chat, not the terminal.

## Continue through the challenges

The challenges contain the prompts and checks. In 03, prepare
`docs/modernization/delivery-slice.md`; take it, the reviewed package, and relevant
source/tests and UI/domain context into the new session in 04.

Keep app review, frontend work, and security separate. If `/review` or
`/security-review` is unavailable, use an equivalent read-only review and a
named reviewer. Impeccable shape produces a brief; request implementation after
confirming it. Challenge 08 requires an actual Azure deployment, explicitly
authorized for the agreed environment.

## Update or remove

```bash
copilot plugin update agentic-modernization
copilot plugin uninstall agentic-modernization
```

In VS Code, use its update/uninstall actions. Update supporting skills separately,
reviewing pins and local changes before reinstalling. Uninstalling the plugin
leaves application documents and project-local skills intact.

## Official references

- [Copilot CLI plugin reference](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference)
- [VS Code agent plugins](https://code.visualstudio.com/docs/agent-customization/agent-plugins)
- [Supporting-skills installer](https://github.com/vercel-labs/skills)
- [Matt Pocock engineering skills](https://github.com/mattpocock/skills/tree/5beb35b040e3de97e54fa9e386d7e42d15c295c2/skills/engineering)
- [Spec Kit v1.2.3](https://github.com/github/spec-kit/tree/v1.2.3)
- [Spec Kit existing-project setup](https://github.github.io/spec-kit/guides/existing-projects.html)
- [Spec Kit integration command names](https://github.github.io/spec-kit/integrations/cli.html#command-invocation)
