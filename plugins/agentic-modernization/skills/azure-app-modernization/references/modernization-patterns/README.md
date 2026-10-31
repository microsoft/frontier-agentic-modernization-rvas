# Modernization strategy and Azure option selection

Read after baseline confirmation, before comparing strategies or services. Use evidence and constraints to select a path; Azure-native does not imply containers, Kubernetes, microservices, or a new database engine.

## Component dispositions

Use explicit names rather than relying on an ambiguous "6/7/8 Rs" label:

| Strategy | Meaning | Main decision signal |
|---|---|---|
| Retain | Keep the component in its existing environment for now | Migration cost/risk exceeds benefit or dependency cannot move |
| Retire | Remove the capability/component | Owner confirms it is no longer needed; retention/dependency obligations handled |
| Replace | Adopt a product/SaaS alternative | Fit, integration, data exit, and vendor constraints justify replacement |
| Rehost | Move largely unchanged to compatible infrastructure | Deadline/compatibility dominates; accepts remaining operational burden |
| Replatform | Move to a managed platform with limited adaptation | Runtime/data compatibility and reduced operations justify changes |
| Refactor | Change implementation while retaining core behavior/structure | Specific coupling, support, or NFR gaps need code changes |
| Rearchitect | Change boundaries or interaction/data topology | Business/NFR drivers justify a different system structure |
| Rebuild | Reimplement a capability from confirmed requirements | Existing implementation cannot economically meet the target |

Strategies may differ across components and waves. Retain/rehost can be an interim step, with a separate future disposition and reason. Treat rebuild and replacement as business-product decisions, not automatic technical upgrades.

## Strategy matrix contract

Write `strategy-matrix.md` with:

```markdown
# Modernization strategy comparison
## Confirmed constraints and decision criteria
## Component dispositions
## Whole-system target options
## Trade-offs and rejected alternatives
## Reference architectures and deviations
## Selected target and user-selection evidence
## Prerequisites, uncertainties, and validation
```

Each component row includes source evidence, relevant `CR-` code-readiness findings, strategy candidates, preferred disposition, meaningful rejected candidate, behavior/contract impact, prerequisite, risk, and owner.

Apply hard feasibility constraints before rankings. An unsupported runtime, missing residency requirement, or unresolved data dependency is not offset by a high cost score. Use qualitative trade-offs unless stakeholder-approved weights and evidenced metrics justify scoring; avoid invented precision.

Anchor each option to a reference architecture from [azure-reference-architectures.md](azure-reference-architectures.md) and list its deviations. Compare two or more feasible whole-system options when they differ materially. If only one is feasible, explain the rejected paths instead of manufacturing an alternative. Include a lower-change option when feasible and show why the recommendation earns its added migration/operating cost.

Evaluate every option on business outcomes, functional parity, NFRs, support/compatibility, integrations/data, security/residency, operating model, migration risk/reversibility, skills, and cost assumptions.

## Compute signals

These are candidate families, not verified compatibility guarantees:

| Workload signal | Candidates to investigate | Distinguishing questions |
|---|---|---|
| Web app/API with supported managed runtime | App Service, Container Apps | OS/native dependencies, deployment model, networking, session/file state |
| Containers/services or workers | Container Apps, AKS, App Service containers | Orchestration needs, scaling, jobs, control-plane/operations burden |
| Bounded event/scheduled work | Functions, Container Apps Jobs | Duration, concurrency, triggers, native/runtime constraints, recovery |
| Explicit Kubernetes/control-plane requirements | AKS, alternate managed compute | Which required feature cannot a simpler platform supply? Who operates it? |
| OS-bound legacy service | Compatible VM/rehost, refactor/replatform | What couples to the OS? Is an interim rehost justified? |
| Static frontend | Static Web Apps, storage/CDN families | Authentication, routing, SSR/API needs, publishing model |

Trace local state, filesystem writes, session affinity, service discovery, background processing, and startup behavior before calling a component stateless or deployable.

## Data and integration signals

Start from semantics and compatibility, not a source-to-target name substitution:

- Relational stores: compare compatible Azure SQL and managed PostgreSQL/MySQL families or a compatible VM where engine/OS features require it.
- Document/key-value stores: investigate Cosmos DB or other compatible offerings only against actual query, consistency, transaction, and partition needs.
- Cache: distinguish disposable acceleration from durable/authoritative state.
- Commands/work queues, event notifications, and event streams: compare Service Bus, Event Grid, and Event Hubs against delivery, ordering, replay, and consumer needs.
- Orchestration/integration: compare application code, Durable Functions, and Logic Apps against state, connectors, duration, and ownership.

Keep synchronous/asynchronous changes explicit in the specification. A shared database is evidence of coupling, not evidence that each table should become a microservice.

## Migration pattern selection

- **Compatibility-first replatform:** preserve external contracts while adapting runtime/configuration/state.
- **Strangler/legacy wrapping:** route selected capabilities through an adapter and migrate ownership incrementally; define routing, identity, data ownership, and reconciliation.
- **Anti-corruption layer:** isolate mismatched contracts or data semantics during coexistence.
- **Event-driven transition:** introduce messaging only when asynchronous behavior is acceptable; plan idempotency, retry, ordering, and failure ownership.
- **Phased data migration:** evolve schemas/contracts compatibly with explicit write ownership and validation.
- **Coordinated cutover:** use when components cannot safely coexist; justify the downtime/rollback budget.

Prefer the simplest pattern meeting confirmed outcomes. A dual-write or multi-master proposal needs failure/reconciliation design; "zero downtime" needs measured constraints and rehearsal evidence.

## Selection gate

Present the recommended coherent option with its reference architecture, the alternatives, changed behavior, trade-offs, evidence gaps, and costs as assumptions/ranges, together with the IaC tool recommendation. The user selects the target; record their choice, the turn that made it, accepted constraints, and blockers. When the user asks you to choose, restate the recommendation and ask them to confirm it. Unresolved feasibility blockers prevent a firm selected-target claim.
