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

Build, test, and run the app locally with sanitized data. Exercise the agreed
journey and relevant failure paths. Compare app requirements with the provided
infrastructure: artifact/runtime, startup command, ports, health probes, config
names, identity/roles, data services, networking, and infrastructure outputs.

Fix in-scope application packaging/configuration mismatches and rerun checks.
If the infrastructure contradicts the selected target, report the mismatch for
a targeted correction rather than inventing another platform. Show exact
deployment commands, parameters, cost implications, and recovery limits from
the runbook. Do not execute cloud changes until we confirm the environment.
```

Use coach-provided infrastructure for the selected target, not the Java/.NET
sample Terraform by default. There is no universal rebuild module in this repo.
Missing infrastructure blocks this activity.

### Deploy to the agreed Azure environment

Review the commands and environment, then authorize deployment:

```text
Deploy this reviewed slice using the provided infrastructure and runbook.
Authorized scope: subscription [ID], resource group [name], region [region],
non-production environment [name]. Use parameters [reviewed file/path] and
artifact [revision/tag]. Execute only the reviewed commands for that scope.

Use the selected architecture's identity and secret-handling approach. Do not
embed credentials in source or logs, alter unrelated resources, or migrate
production data. Record actual command results and deployed artifact revision.
If a command fails, diagnose it and propose the smallest correction; do not
switch platforms or widen permissions to make deployment pass.
```

### Verify the deployed journey and hand off

```text
Verify the deployed slice at [Azure endpoint]. Check health/readiness, the
critical business journey, relevant denied/error paths, data persistence,
service connectivity, and telemetry with sanitized data.
Show actual request/test output and relevant logs without exposing secrets.
Demonstrate the runbook's non-production rollback/recovery check where safe;
distinguish routing rollback from reconciling target-only writes.

Record endpoint, artifact revision, environment, acceptance evidence, review
dispositions, cost assumptions, known limits, remaining waves, and operations
owner. State the exact cleanup procedure and owner; do not delete resources
without a separate explicit request.
```

Completion requires a live non-production deployment, not a tabletop exercise.
Production cutover and data migration are out of scope.

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
