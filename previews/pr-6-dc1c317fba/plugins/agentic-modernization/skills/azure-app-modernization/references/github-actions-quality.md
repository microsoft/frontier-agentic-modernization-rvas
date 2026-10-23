# GitHub Actions delivery design

Read when GitHub Actions is the selected or proposed delivery platform. Define how later delivery work will implement testing, build, and deployment workflows; this skill writes the design in the modernization package, not executable `.github/workflows/` files.

## Discover the delivery baseline

Inspect existing workflows, build/test scripts, manifests/lockfiles, Dockerfiles, IaC, deployment configuration, and release notes. Record:

- Components and actual working directories, build/test commands, toolchain versions, and reproducibility constraints.
- Triggers, required checks, reusable workflows, environment gates, permissions, identity, and artifact handoffs.
- Unit/integration/contract/end-to-end test coverage, test-data needs, dependencies, and known gaps.
- Existing GitHub organization policies, repository visibility/plan, runner access, approval owners, and release ownership.

Use repository commands as evidence, not a generic language template. Missing scripts/tests are implementation prerequisites, not invented passing checks. If another CI system exists, compare retain/bridge/replace; GitHub Actions does not require an immediate CI migration.

## Record the implementation blueprint

Put delivery trust boundaries and identities in `target-architecture.md`. Put the detailed blueprint in `migration-plan.md` under `## Testing, build, and deployment automation`; link it rather than duplicating stage tables.

| Stage / intended workflow | Trigger and trusted revision | Commands / inputs | Output / provenance | Gate and acceptance IDs | Identity / runner / owner |
|---|---|---|---|---|---|
| PR validation | Proposed commit | Observed checks or named gaps | Test reports | Required checks | Unprivileged isolated runner |
| Release build | Protected, accepted source revision | Reproducible build | Package/image plus source/run/digest | Tests and artifact verification | Narrow publishing identity |
| Non-production deployment | Approved artifact identity | Target-specific deployment | Deployment record and smoke results | Parity/contract checks | Environment-scoped identity |
| Production promotion | Accepted artifact and change approval | Promote the same artifact | Release/evidence record | Go/no-go and environment gate | Production-scoped identity |
| Recovery | Authorized incident/change decision | Named prior artifact plus data recovery | Recovery/reconciliation evidence | Health/data validation | Separate authority |

For each intended file, name its future path, component/workdir, dependencies (`needs` concept), trigger, job permissions, runner, environment, timeout, concurrency policy, failure/rollback policy, required checks, and implementation owner. Use descriptive stage graphs/tables rather than runnable YAML or an invented SHA/version.

An illustrative logical split is future `ci.yml` for PR checks, `release.yml` for a trusted build/publish, and `deploy.yml` for promotion of a named artifact. Consolidate jobs or use reusable workflows when that fits the estate; verify cross-workflow trust and permissions rather than treating a filename as an isolation boundary.

Record unresolved platform, runner, or approval decisions with owner, decision point, and impact. Keep the package at eight artifacts; the blueprint is an input to a separate workflow-authoring task.

## Testing and build patterns

- **PR checks:** formatting/lint, static/type checks, unit tests, build validation, and relevant contract/integration tests. Use isolated services and sanitized/synthetic data; production credentials are not test fixtures.
- **Compatibility gates:** test preserved API/event/data/authorization contracts and intentional changes against requirement/acceptance IDs. Add regression tests for recovered legacy business rules.
- **Matrix builds:** use only evidenced compatibility variants; avoid speculative OS/runtime combinations. Name required-check aggregation for monorepos, path filters, and skipped jobs so branch rules do not leave a required check permanently pending.
- **Reproducible release:** resolve locked dependencies/toolchains, run required tests, and publish the resulting package/image once from a trusted source revision.
- **Artifact promotion:** identify the exact source commit, workflow/run, artifact, and checksum/image digest. Promote that artifact across environments; separate environment configuration from application build. Mutable tags such as `latest` are not release identities.
- **Cache:** cache dependencies for speed with scoped keys; keep secrets out. A cache is not a deployable artifact or an integrity guarantee.
- **Supply chain:** plan dependency/image scanning, SBOM/provenance/attestation generation and verification where required. Verify feature availability for the repository/plan and record equivalent controls if unavailable.

Artifact download is not a trust check. A release consuming another workflow's output must validate the producer's repository, event/ref, successful conclusion, source revision, run identity, and artifact digest. Never promote arbitrary fork-PR artifacts into a privileged deployment.

## Trust and identity rules

- Run untrusted PR code without deployment credentials, cloud tokens, write permissions, or access to production/private-network runners. Separate PR CI from trusted publishing/deployment.
- Prefer `pull_request` for ordinary PR validation. Privileged `pull_request_target`/`workflow_run` orchestration must not execute untrusted checked-out code or treat incoming artifacts as trusted executables. If proposed, require explicit threat-boundary justification and verification.
- Specify least-privilege `GITHUB_TOKEN` permissions by job. Give Azure deployment jobs `id-token: write` only where OIDC is needed; similarly isolate any attestation identity in a trusted build job. Permission to request an OIDC token is not Azure authorization.
- Prefer Azure workload identity federation over long-lived Azure credentials. Plan Entra application/service-principal or supported managed-identity trust, actual issuer/subject/audience claims, environment binding, and minimal resource-scoped Azure RBAC. Verify the repository's actual OIDC subject format; do not hard-code an example subject as universally valid.
- Separate non-production and production identities/permissions. Record where client/tenant/subscription identifiers and environment configuration live without embedding values or creating trust/RBAC assignments.
- Pin external actions and reusable workflows to verified full commit SHAs at implementation, and pin container/tool dependencies appropriately. Define update ownership; do not invent pins or assume documentation examples are current releases.
- Treat PR titles, branch names, workflow inputs, and artifact contents as untrusted data. Pass values through safely handled environment/arguments rather than interpolating them into shell commands.
- Protect workflow changes with repository review/ownership controls. Scope runner groups and clean/ephemeral runner lifecycles; untrusted jobs do not share privileged hosts. Define cache trust domains and verify event-specific read/write scope; a PR-restored cache is not trusted source or an executable release artifact.

## Environment and runner patterns

Use environment-scoped deployment gates, allowed refs, review/separation-of-duties, and secrets/configuration boundaries. Verify reviewer/protection-rule availability for the actual GitHub plan and visibility. If unavailable, define an enforceable reviewed release/manual authorization alternative; do not describe an unavailable UI feature as configured.

Private endpoints require an evidenced runner connectivity design, including DNS, routing/firewall, tool support, identity, and isolation. A GitHub-hosted runner is not automatically able to reach a private target. Container-based runners are not automatically able to perform nested Docker builds.

Set bounded timeouts and concurrency per stage. Superseding PR checks may be cancelable; a production deployment or database migration requires serialization and a deliberate cancellation/recovery policy. Do not cancel an in-flight production change just to start a newer commit. Verify queue semantics instead of assuming all pending releases are retained.

## Target deployment patterns

| Target | Later authoring pattern | Verify before promising it |
|---|---|---|
| App Service | Deploy a built package or fixed container; optional staging/slot promotion and health check | Runtime/OS, remote-build behavior, identity, slot/SKU support, networking, rollback |
| Container Apps | Deploy an already-published image; validate revision and optionally shift traffic | Image identity/pull permissions, revision mode, health/traffic controls, data compatibility |
| AKS | Promote image digests with reviewed manifests/Helm configuration and rollout checks | Cluster/RBAC access, private runner connectivity, namespace scope, rollout/data recovery |
| Functions | Deploy the tested package for the selected runtime/hosting plan | Packaging/build mode, identity, plan-specific deployment/slot support |
| Infrastructure | Separate validation and reviewed Bicep what-if/Terraform plan from authorized deployment/apply | State/backend access, preview permissions/limitations, drift, sensitive plan storage, change authority |
| Database | Dedicated reviewed schema/data migration stage with application-version compatibility | Tool/engine support, exclusive execution, write ownership, rehearsal, backup/reconciliation |

These are option patterns, not capability guarantees or action-version recommendations. Verify current target/action behavior and enterprise tooling before selecting a concrete implementation.

## Deployment, cutover, and recovery

Non-production promotion must exercise functional parity, contract, auth, smoke, and relevant integration/performance checks. Protect production promotion with the accepted artifact identity, change approval, migration-wave prerequisites, and go/no-go owner.

Design database changes separately from application rollout. Specify expansion/backfill/contraction ordering, compatible app/schema versions, exclusive migration execution, and reviewed schema change reports where supported. Avoid applying the same destructive migration from every app instance.

Store release/deployment records, artifact retention, test results, and relevant audit/provenance evidence. Plan health checks, bounded rollout/traffic changes, monitoring, failure signaling, and rollback authority. Successful workflow status alone is not business/data acceptance.

Rollback refers to both the application artifact/configuration and data state. Re-deploying a previous image, swapping a slot, or reversing DNS does not recover target-only writes or undo an incompatible schema change; link to the migration plan's reconciliation/forward-recovery design.

## Authoring handoff and completion

The blueprint is ready when every component has test/build/deploy coverage or an owned gap, each stage has a trust/artifact/environment boundary, required checks and production gates are enforceable, and target-specific/database recovery prerequisites are explicit.

Hand off the selected blueprint, verified sources, artifact contract, owners, acceptance IDs, and unresolved prerequisites to later workflow implementation. State that workflow files, Azure federation/RBAC, repository/environment settings, and deployments have not been created or changed.

## Primary references

Guidance checked against these sources on 2026-10-06. Recheck capability- and policy-sensitive details when selecting or authoring a workflow.

- [GitHub Actions secure use](https://docs.github.com/en/actions/reference/security/secure-use) — permissions, pinning, untrusted inputs and privileged triggers.
- [Azure OIDC federation](https://docs.github.com/en/actions/how-tos/secure-your-work/security-harden-deployments/oidc-in-azure) and [OIDC claims](https://docs.github.com/en/actions/reference/security/oidc) — actual trust claims and token permissions.
- [GitHub deployment environments](https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments) — approvals, protections, and plan/visibility restrictions.
- [Concurrency control](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency) — cancel/queue behavior.
- [Dependency caching](https://docs.github.com/en/actions/reference/workflows-and-actions/dependency-caching) and [artifact attestations](https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations) — cache scope and provenance.
- [Azure GitHub Actions authentication](https://learn.microsoft.com/azure/developer/github/connect-from-azure-openid-connect) — federation options and Azure identity.
- [App Service deployment](https://learn.microsoft.com/azure/app-service/deploy-github-actions), [Container Apps deployment](https://learn.microsoft.com/azure/container-apps/github-actions), [AKS actions](https://learn.microsoft.com/azure/aks/kubernetes-action), and [Functions deployment](https://learn.microsoft.com/en-us/azure/azure-functions/functions-how-to-github-actions) — verify the selected target.
- [Private-network runners in Container Apps jobs](https://learn.microsoft.com/azure/container-apps/tutorial-ci-cd-runners-jobs) — connectivity and runner constraints.
- [Bicep what-if](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-what-if) and [Terraform setup](https://github.com/hashicorp/setup-terraform) — infrastructure preview/plan mechanics, not automatic apply approval.
- [SQL project automation](https://learn.microsoft.com/sql/tools/sql-database-projects/sql-projects-automation?view=sql-server-ver17) — database artifact, change report, and approval pattern; verify equivalents for other engines/tools.
