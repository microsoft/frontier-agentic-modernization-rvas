---
title: Upgrade a Customer Application
summary: Upgrade a real customer-owned application with the Modernization CLI.
phase: Customer
group: Customer
tags:
- customer
- modernization-cli
highlight: true
---

# Module 00: Upgrade a Customer Application

> **Duration:** ~480 minutes | **Phase:** Customer

## Objective

Choose a representative customer-owned application, then apply the modernization workflow from the .NET and Java labs to it end to end. This is the replatform and refactor route using the Modernization CLI. If the application needs substantial architecture or business-workflow changes, use the [rearchitect and rebuild route](../../04-rebuild/challenges/00-prepare-your-application.md) instead. Do not install the rebuild plugin just to follow this module.

Do not choose the portfolio's most complex or most critical application. Its risk and scope can consume the whole day. Choose a medium-complexity app you can build, assess, and containerize in one working day.

## Prerequisites

- Access to the customer repository and a way to build it locally.
- The shared [prerequisites](../../../README.md) and the [labs guide](../../README.md) for Azure requirements.
- The module titles you follow in Step 2: .NET modules 01 Assess the legacy app, 02 Modernize the app, 03 Containerize and deploy ([labs/02-dotnet](../../02-dotnet/challenges/01-assess-the-legacy-app.md)), and the Java equivalents in [labs/01-java](../../01-java/challenges/01-assess-the-legacy-app.md).

## Step 1: Select an application

Choose **one application** from the customer's portfolio. It must be a **real customer-owned codebase**, not a sample substituted for customer work. Repository visibility does not determine ownership: a public customer repository is valid with authorized access. The application should be:

- **Medium complexity**: multi-layer, with an external database and at least one legacy dependency worth replacing (for example an old messaging technology, local file storage, or an end-of-life runtime).
- **Not the most critical or most complex** application in the portfolio.

Avoid:

- A greenfield or already-modern app (no meaningful migration work).
- A microservices platform with 15+ services (too complex for one session).
- An app nobody can explain (business decisions will be blocked).

Include business and product stakeholders in the selection before delivery starts. If no application is ready, stop and prepare one with the customer. Confirm repository access, build instructions, and Docker tooling before you start.

Write a brief justification: why you chose the application, what makes it a good candidate, and why it is not the most complex or most critical app in the portfolio.

## Step 2: Run the readiness checks

Check readiness before assessment. If the application does not build locally, you cannot proceed.

- [ ] The chosen application and upgrade scenario are supported by the installed Modernization tooling.
- [ ] The source code is available and the repository is accessible to everyone who needs it. Everyone can clone it without someone else's credentials.
- [ ] The application builds locally. Warnings are fine; a complete build failure is not.
- [ ] Docker and container tooling are available: `docker info` returns without error.
- [ ] Someone you work with understands what the application does.

If a check fails, triage it: a 10-minute fix (install a missing SDK, set an env var) or a multi-hour blocker (database behind an inaccessible VPN, broken monorepo). For a multi-hour blocker, pick a different application. If the application fails to build, resolve that first: the tool needs a buildable project to produce meaningful results.

## Step 3: Assess and modernize

1. Run `modernize assess` on the application folder and review the report. Summarize the top findings.
2. Run `modernize plan create` to generate a migration plan that targets a modern runtime and a container platform (AKS or ACA).
3. Run `modernize plan execute` to apply the plan.
4. Resolve remaining issues with GitHub Copilot Chat.
5. Containerize the application, producing the Dockerfiles, Kubernetes or ACA manifests, and other deployment artifacts needed to run it. Deploy it to Azure.
6. Introduce a testing and validation approach the customer's team can keep using on future modernization work.
7. Build Bicep or Terraform templates and a GitHub Actions or Azure DevOps pipeline to automate the deployment.

Before containerizing, replace any hard-coded secrets in config with environment variables or Azure Key Vault references.

## Checkpoint

- [ ] A written justification for the selected application exists.
- [ ] An assessment report from `modernize assess` exists, with the top findings summarized.
- [ ] The application builds and runs on a modern target runtime (for example .NET 10 or Java 25).
- [ ] The application is containerized and deployed to Azure.

## Reflect

- What was the single hardest migration issue in this codebase that the automated tools could not resolve, and how did you solve it?

## What You Learned

- Select a customer application that is representative and tractable.
- Verify readiness (repo access, local build, container tooling) before assessment.
- Apply the Modernization CLI workflow to a real codebase and deploy it to Azure.

## Key Takeaway

> A medium-complexity application you can build and explain beats the most critical one you cannot finish.

## Learn more

- [GitHub Copilot Modernization assessment overview](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/overview)
- [Azure Container Apps overview](https://learn.microsoft.com/azure/container-apps/overview)
- [Azure Kubernetes Service overview](https://learn.microsoft.com/azure/aks/intro-kubernetes)

## Troubleshooting

| Symptom | Fix |
|---|---|
| Build fails before assessment | Triage the build error. Fix a missing dependency or config value. For a multi-hour structural issue, pick a different app. |
| Assessment produces no findings | Likely a build failure or a near-modern app. Check the assessment logs; if the app is already modern, pick a more representative target. |
| Nobody understands the app | Pick an app someone you work with understands well enough to make architectural decisions. |
| Secrets hard-coded in config | Replace them with environment variables or Azure Key Vault references before containerizing. |
