**[Home](../../README.md)** | [Setup and usage](setup.md) | [Next](Challenge-01.md)

# Challenge 00: Prepare Your Application and Challenge

**Estimated Time:** 30 minutes
**Difficulty:** Easy

## Introduction

Bring an application you own and want to rearchitect and rebuild completely.
The rebuilt app may use a different language, framework, or technology stack.
Start by understanding the existing app; choose the target during planning.

## Prerequisites

- An application your team or organization owns, with source access and permission to rebuild it.
- A business/product stakeholder and someone who understands the application.
- The tools and profile selections in the [setup guide](setup.md).

## Description

Choose an application small enough to rebuild and validate within the event.
The goal is the complete application, not a single improved user journey.
Choose a smaller app if necessary rather than quietly dropping functionality.

Write a short brief: what the app does, why you want to rebuild it, its users
and workflows, integrations and data, what must stay or change, and who decides.
Include any reasons to change the stack, but leave the target choice to planning.
Use this prompt to structure the brief:

```text
Help me prepare a rebuild brief for [application]. Use the source and evidence
I provide to summarize its users, workflows, integrations, data, required
functionality, desired changes, constraints, and decision-makers.
Ask about missing business context and record build/run gaps.
Keep stack preferences as inputs to planning, not target decisions.
Do not edit application code or begin implementation.
```

For a runtime-only change, use the
[upgrade route](../customer/Challenge-00.md).

Work in the application repository. Follow the [setup guide](setup.md) to install
the plugin and relevant [supporting skills](supporting-skills.md).
Bring source, run notes, contracts, and sanitized database/UI evidence.
Note missing evidence and build/run gaps.

Confirm **Claude Opus 5.5** access for implementation and non-production Azure
access for deployment. After target selection, the coach provides matching
infrastructure and a runbook for Challenge 08; the upgrade samples may not fit.

This route does not require the Modernization CLI, Java, or .NET.

## Success Criteria

- [ ] The team owns the application and can access its source and explain its behavior.
- [ ] The brief defines the complete app to rebuild, required functionality, desired changes, constraints, and decision-makers.
- [ ] The app is small enough for the event; any stack preferences are inputs to planning, not assumed decisions.
- [ ] The host finds `azure-app-modernization`, `azure-app-rebuild`, `cloud-architecture-diagram`, and selected supporting skills.
- [ ] Evidence and build/run gaps are noted; inputs contain no secrets or production rows.

## Learning Resources

- [Copilot CLI plugins](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference)
- [VS Code agent plugins](https://code.visualstudio.com/docs/agent-customization/agent-plugins)

## Advanced Challenge (Optional)

Identify the business rule or integration most likely to be lost in a rewrite
and how you will verify it in the rebuilt app.
