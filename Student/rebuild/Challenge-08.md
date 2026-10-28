**[Home](../../README.md)** | [Previous](Challenge-07.md)

# Challenge 08: Run and Deploy the App to Azure

**Estimated Time:** 60 minutes
**Difficulty:** Expert

## Introduction

Deploy with the provided Azure infrastructure, then test the journey at its
Azure endpoint.

## Prerequisites

- Challenge 07 complete with no deployment-blocking findings.
- The documented local build/run/test commands and sanitized fixtures.
- Coach-provided Azure infrastructure and runbook, including parameters,
  outputs, deployment, recovery, and cleanup instructions.
- Access to the agreed non-production subscription, resource group, and region.

## Description

### Run locally and check the infrastructure contract

Start with the package, handoff, review results, and infrastructure files:

```text
Prepare the reviewed rebuild slice for Azure deployment. Read
docs/modernization/delivery-slice.md, target-architecture.md, cost-estimate.md,
migration-plan.md, and the provided infrastructure/runbook at [path, revision].
```

Use coach-provided infrastructure for the selected target, not the Java/.NET
sample Terraform by default. There is no universal rebuild module in this repo.
Missing infrastructure blocks this activity.

### Deploy to Azure

Review the commands and environment, then start deployment:

```text
Deploy this reviewed slice using the provided infrastructure and runbook.
Authorized scope: subscription [ID], resource group [name], region [region],
non-production environment [name]. Use parameters [reviewed file/path] and
artifact [revision/tag]. Execute only the reviewed commands for that scope.
```

## Success Criteria

- [ ] The slice builds, tests, and runs locally.
- [ ] Infrastructure matches the target, app configuration, and identity needs.
- [ ] The agreed Azure deployment succeeds; its revision, journey, integrations, health, and telemetry are verified.
- [ ] The handoff covers recovery limits, remaining work, costs, operations, and cleanup ownership.

## Hints

<details><summary>Hint 1: Compare contracts before deploying</summary>
Compare app and infrastructure ports, configuration, probes, and identity.
</details>

<details><summary>Hint 2: Verify outside the build environment</summary>
Test the Azure endpoint with its actual dependencies, not only the local app.
</details>

<details><summary>Hint 3: Check writes during recovery</summary>
Explain how recovery handles writes accepted only by the new system.
</details>

## Learning Resources

- [Safe deployment practices](https://learn.microsoft.com/azure/well-architected/operational-excellence/safe-deployments)
- [Disaster recovery strategy](https://learn.microsoft.com/azure/well-architected/reliability/disaster-recovery)

## Advanced Challenge (Optional)

Run a safe non-production failure/recovery rehearsal and demonstrate the
decision using telemetry, not just the healthy path.
