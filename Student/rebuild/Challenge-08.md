**[Home](../../README.md)** | [Previous](Challenge-07.md)

# Challenge 08: Run and Deploy the App to Azure

**Estimated Time:** 60 minutes

## Introduction

Deploy with the provided Azure infrastructure, then test the application at its
Azure endpoint.

## Prerequisites

- Challenge 07 complete with no deployment-blocking findings.
- The documented local build/run/test commands and sanitized fixtures.
- Coach-provided Azure infrastructure and runbook, including parameters,
  outputs, deployment, recovery, and cleanup instructions.
- Access to the agreed non-production subscription, resource group, and region.

## Description

### Run locally and check the infrastructure contract

Use coach-provided infrastructure for the selected target, not the Java/.NET
sample Terraform by default. There is no universal rebuild module in this repo.
Missing infrastructure blocks this activity.

Run this readiness check before authorizing deployment:

```text
Check deployment readiness for the complete rebuilt application. Read
docs/modernization/rebuild-handoff.md, target-architecture.md,
infrastructure-plan.md, cost-estimate.md, migration-plan.md, and the provided
infrastructure/runbook at [path, revision].
Run the reviewed local build/test/start commands with sanitized fixtures.
Check every required workflow. Compare the app's ports, configuration,
health probes, identities, and dependency endpoints with the infrastructure.
Report actual results and blocking mismatches. Do not deploy or provision yet.
```

### Deploy to Azure

Resolve readiness blockers, then review the commands and authorize deployment:

```text
Deploy the complete reviewed application using the provided infrastructure
and runbook.
Authorized scope: subscription [ID], resource group [name], region [region],
non-production environment [name]. Use parameters [reviewed file/path] and
artifact [revision/tag]. Execute only the reviewed commands for that scope.
At the Azure endpoint, run the agreed acceptance checks for all required
workflows, including persistence and integrations, using sanitized fixtures.
Check the runbook's health endpoint and expected logs/telemetry; report missing
signals or unavailable checks rather than claiming success.
Return the deployed revision, URL, pass/fail/blocked evidence, recovery limits,
remaining costs/work, and operations/cleanup owners.
```

## Success Criteria

- [ ] The complete app builds, tests, and runs locally.
- [ ] Infrastructure matches the target, app configuration, and identity needs.
- [ ] The Azure deployment succeeds; all required workflows, persistence/integrations, and runbook-defined health/telemetry checks pass for the recorded revision.
- [ ] The handoff covers recovery limits, remaining work, costs, operations, and cleanup ownership.

## Hints

<details><summary>Hint 1: Check writes during recovery</summary>
Explain how recovery handles writes accepted only by the new system.
</details>

## Learning Resources

- [Safe deployment practices](https://learn.microsoft.com/azure/well-architected/operational-excellence/safe-deployments)
- [Disaster recovery strategy](https://learn.microsoft.com/azure/well-architected/reliability/disaster-recovery)

## Advanced Challenge (Optional)

Run a safe non-production failure/recovery rehearsal and demonstrate the
decision using telemetry, not just the healthy path.
