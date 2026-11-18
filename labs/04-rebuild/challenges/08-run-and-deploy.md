---
title: Run and Deploy the App to Azure
summary: Run the app locally and deploy it to Azure.
phase: Deliver
group: Deliver
tags:
- azure
- deployment
highlight: false
---

# Module 08: Run and Deploy the App to Azure

> **Duration:** ~60 minutes | **Phase:** Deliver

## Objective

Deploy with the provided Azure infrastructure, then test the application at its Azure endpoint.

## Prerequisites

- Module 07 complete with no deployment-blocking findings.
- The documented local build/run/test commands and sanitized fixtures.
- Provided Azure infrastructure and runbook, including parameters, outputs, deployment, recovery, and cleanup instructions.
- Access to the agreed non-production subscription, resource group, and region.

## Step 1: Run locally and check the infrastructure contract

Use provided infrastructure for the selected target, not the Java/.NET sample Terraform by default. There is no universal rebuild module in this repo. Missing infrastructure blocks this module.

Run this readiness check before authorizing deployment:

```text
Check deployment readiness for the complete rebuilt application. Read
docs/modernization/specification.md, target-architecture.md, infrastructure-plan.md,
cost-estimate.md, migration-plan.md, and the provided infrastructure/runbook
at [path, revision].
Run the reviewed local build/test/start commands with sanitized fixtures.
Check every required workflow. Compare the app's ports, configuration,
health probes, identities, and dependency endpoints with the infrastructure.
Report actual results and blocking mismatches. Do not deploy or provision yet.
```

## Step 2: Deploy to Azure

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

## Step 3: Verify and hand off

Require a working Azure endpoint, persistence and integrations, telemetry, and recovery checks. A discussion alone is not a completed deployment. Check all required workflows, not just one successful demo.

Explain how recovery handles writes accepted only by the new system. Finish with the demo, results, remaining work, and operations and cleanup owners.

## Checkpoint

Before moving on, confirm:

- [ ] The complete app builds, tests, and runs locally.
- [ ] Infrastructure matches the target, app configuration, and identity needs.
- [ ] The Azure deployment succeeds; all required workflows, persistence and integrations, and runbook-defined health and telemetry checks pass for the recorded revision.
- [ ] The handoff covers recovery limits, remaining work, costs, operations, and cleanup ownership.

## Reflect

- Can you run a safe non-production failure and recovery rehearsal and justify the decision with telemetry, not just the healthy path? This is optional.

## What You Learned

- Check an app against an infrastructure contract before deploying.
- Deploy to an authorized non-production scope with reviewed commands.
- Verify the Azure endpoint with acceptance, health and telemetry evidence.

## Key Takeaway

> A deployment is complete when the Azure endpoint passes every required workflow, not when the commands finish.

## Learn more

- [Safe deployment practices](https://learn.microsoft.com/azure/well-architected/operational-excellence/safe-deployments)
- [Disaster recovery strategy](https://learn.microsoft.com/azure/well-architected/reliability/disaster-recovery)

## Troubleshooting

| Symptom | Fix |
|---|---|
| Infrastructure does not match the chosen target | Resolve the infrastructure contract. Do not switch platforms or claim deployment. |
| No telemetry or health signal | Report the missing signal rather than claiming success. |
| Recovery plan ignores new writes | Explain how writes accepted only by the new system are handled. |

