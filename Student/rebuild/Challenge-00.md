**[Home](../../README.md)** | [Setup and usage](setup.md) | [Next](Challenge-01.md)

# Challenge 00: Prepare Your Application and Challenge

**Estimated Time:** 30 minutes
**Difficulty:** Easy

## Introduction

An old runtime is not always the main problem. Your application might be hard to
change, tightly coupled to another system, or unable to support a new business
workflow. Bring that challenge, not a predetermined replacement architecture.

## Prerequisites

- Customer-owned source and permission to work with it in the chosen workspace.
- A business/product stakeholder and someone who understands the application.
- The tools and profile selections in the [setup guide](setup.md).

## Description

Choose one customer application and a business journey you can reasonably improve
in the available time. Explain the desired outcome, current friction, known
constraints, and who decides what must be preserved. Establish that this is
architecture-first work, not merely a runtime upgrade. Use the [upgrade route](../customer/Challenge-00.md)
if that better fits.

Work in the application repository. Make the plugin's three bundled skills and
the relevant [supporting skills](supporting-skills.md) discoverable. Prepare source,
operating notes, contracts, and sanitized database/UI evidence. Record unavailable
evidence rather than blocking all static planning or pretending it is complete.

Do not install the Modernization CLI solely for this route. A rebuild may target
any application stack supported by the evidence; Java/.NET are not entry requirements.

## Success Criteria

- [ ] A short brief names the customer challenge, bounded journey, desired outcome, and decision owners.
- [ ] The team explains why it selected rebuild discovery rather than a CLI-only upgrade.
- [ ] The host discovers `azure-app-modernization`, `azure-app-rebuild`, and `cloud-architecture-diagram`, plus the selected supporting skills.
- [ ] Evidence availability and build/run gaps are recorded; no secrets or production rows are included.

## Hints

<details><summary>Hint 1: Start with value</summary>
Ask which user outcome is difficult today and what would prove it improved.
</details>

<details><summary>Hint 2: Bound the work</summary>
One end-to-end journey is more useful than a promise to replace the entire estate.
</details>

<details><summary>Hint 3: Check the workspace</summary>
The plugin is tooling. The source and generated modernization package belong in
the customer's application repository. Use the setup guide's discovery checks.
</details>

## Learning Resources

- [Copilot CLI plugins](https://docs.github.com/en/copilot/reference/copilot-cli-reference/cli-plugin-reference)
- [VS Code agent plugins](https://code.visualstudio.com/docs/agent-customization/agent-plugins)

## Advanced Challenge (Optional)

Identify an adjacent journey that must remain unchanged and a stakeholder who can
verify it throughout the event.
