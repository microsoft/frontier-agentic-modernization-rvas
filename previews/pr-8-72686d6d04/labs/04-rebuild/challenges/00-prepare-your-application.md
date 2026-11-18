---
title: Prepare Your Application
summary: Pick a complete app, the rebuild brief and decision owners.
phase: Prepare
group: Prepare
tags:
- preparation
highlight: false
---

# Module 00: Prepare Your Application

> **Duration:** ~30 minutes | **Phase:** Prepare

## Objective

Prepare an application you own for a complete rebuild and write the rebuild brief. The target language, framework, or stack may change after discovery.

## Prerequisites

- An application you or your organization own, with source access and permission to rebuild it.
- A business or product stakeholder and someone who understands the application.
- The tools and profile selections in the [setup guide](../setup.md).

## Step 1: Choose the application

Choose an application small enough to rebuild and validate within the lab. Rebuild all required functionality. If the app is too large, choose a smaller one rather than dropping required workflows.

Keep application work in its own repository. Authorized ownership matters, not whether the repository is public or private.

For a runtime-only change, use the [upgrade route](../../05-customer/challenges/00-upgrade-a-customer-app.md) instead.

## Step 2: Install the plugin and supporting skills

Follow the [setup guide](../setup.md) to install the plugin and the relevant [supporting skills](../supporting-skills.md). Supply source, run notes, contracts, and sanitized database and UI evidence. Record anything unavailable.

This route does not require the Modernization CLI, Java, or .NET.

## Step 3: Confirm model and Azure access

Confirm **Claude Opus 5.5** access for implementation and non-production Azure access for deployment. After target selection, prepare matching infrastructure and a runbook for Module 08. The upgrade samples may not fit.

## Step 4: Write the rebuild brief

Work in the application repository. Use this prompt:

```text
Help me prepare a complete-app rebuild brief for [application]. Use the source
and evidence I provide to summarize its users, workflows, integrations, data, required
functionality, desired changes, constraints, and decision-makers.
Ask about missing business context and record build/run gaps.
Keep stack preferences as inputs to planning, not target decisions.
Do not edit application code or begin implementation.
```

Answer the questions it raises. Confirm the complete-app boundary, repository access, evidence, and stakeholder availability. Missing build tools can wait during planning but must be resolved before coding.

## Checkpoint

Before moving on, confirm:

- [ ] You own the application and can access its source and explain its behavior.
- [ ] The brief defines the complete app to rebuild, required functionality, desired changes, constraints, and decision-makers.
- [ ] The app is small enough for the lab; any stack preferences are inputs to planning, not assumed decisions.
- [ ] The host finds `azure-app-modernization`, `azure-app-rebuild`, `cloud-architecture-diagram`, and the selected supporting skills.
- [ ] Evidence and build/run gaps are noted; inputs contain no secrets or production rows.

## Reflect

- Which business rule or integration is most likely to be lost in a rewrite, and how will you verify it in the rebuilt app?

## What You Learned

- Scope an application for a complete rebuild.
- Write a rebuild brief that keeps stack preferences separate from target decisions.
- Check that the plugin and supporting skills are available in your host.

## Key Takeaway

> A complete rebuild starts with a bounded app, a written brief and named decision owners.

## Learn more

- [Copilot CLI plugins](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference)
- [VS Code agent plugins](https://code.visualstudio.com/docs/agent-customization/agent-plugins)

## Troubleshooting

| Symptom | Fix |
|---|---|
| The app is too large to rebuild in the lab | Agree a smaller application boundary. Keep every required workflow of the smaller app. |
| The change is runtime-only | Use [Upgrade your application](../../05-customer/challenges/00-upgrade-a-customer-app.md). |
| The host does not list the plugin skills | Repeat the plugin install in the [setup guide](../setup.md) and restart the host. |

**Next:** [Module 01: Run discovery and modernization planning](01-discovery-and-planning.md)
