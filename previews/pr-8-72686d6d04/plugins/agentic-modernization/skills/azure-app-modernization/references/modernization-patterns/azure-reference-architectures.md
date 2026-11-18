# Azure reference-architecture catalog

Read while composing whole-system target options. Each entry is a proven Microsoft **reference architecture**: start every option from the closest one (or a named composition), then record each **deviation** and its reason. A recommendation anchored to a reference architecture is easier for the user to evaluate, and its documented trade-offs are already reviewed. (Unrelated to the confirmed current-state baseline from discovery.)

The catalog seeds suggestions; it does not replace evidence. Verify the current Architecture Center page through [microsoft-learn-evidence.md](../microsoft-learn-evidence.md) before citing its components or guarantees, because Architecture Center pages are revised and merged.

## Workload reference architectures

| ID | Reference architecture | Fits when | Watch for | Source |
|---|---|---|---|---|
| `RA-WEB-BASIC` | Basic web application (App Service + managed database) | Low-criticality or non-production web/API; learning path toward the zone-redundant baseline | Not zone-redundant; public endpoints by default. Rarely the production recommendation | [Basic web application](https://learn.microsoft.com/azure/architecture/web-apps/app-service/architectures/basic-web-app) |
| `RA-WEB-ZR` | Baseline highly available zone-redundant App Service web application | Production web app/API or modular monolith on a supported managed runtime; replatform with limited code change. The former Reliable Web App guidance redirects here | Needs VNet integration, private endpoints, Application Gateway/WAF, Key Vault, zone-capable SKUs and region; session/file state must be externalized | [Baseline zone-redundant web app](https://learn.microsoft.com/azure/architecture/web-apps/app-service/architectures/baseline-zone-redundant) |
| `RA-WQW` | Web-Queue-Worker style | Web front end plus long-running or retryable background work (exports, notifications, batch) | Idempotency, poison messages, and queue ordering become explicit requirements | [Web-Queue-Worker](https://learn.microsoft.com/azure/architecture/guide/architecture-styles/web-queue-worker) |
| `RA-ACA-MS` | Microservices on Azure Container Apps (optionally with Dapr) | Containerized services or workers that deploy independently and need scale-to-zero/jobs, without a Kubernetes control-plane requirement | Independent ownership must already exist; shared transactions or a shared schema argue for a modular monolith instead | [Container Apps microservices](https://learn.microsoft.com/azure/architecture/example-scenario/serverless/microservices-with-container-apps), [with Dapr](https://learn.microsoft.com/azure/architecture/example-scenario/serverless/microservices-with-container-apps-dapr) |
| `RA-AKS` | AKS baseline cluster (and AKS microservices) | Explicit Kubernetes needs: custom operators, service mesh, node-level control, existing platform team and skills | Highest operating burden; name the requirement no simpler platform meets | [AKS baseline](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks/baseline-aks), [AKS microservices](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks-microservices/aks-microservices) |
| `RA-EVENT` | Event-driven / serverless (Functions with Event Grid, Service Bus, or Event Hubs) | Bounded event, scheduled, or integration work with variable load | Execution limits, cold start, plan networking support, at-least-once delivery | [Event-driven style](https://learn.microsoft.com/azure/architecture/guide/architecture-styles/event-driven) |
| `RA-INTEGRATION` | Message broker and events for enterprise integration (Service Bus, Event Grid, Logic Apps, API Management) | Partner/system integration hub, file or message exchange, contract mediation | Connector licensing, contract versioning, ownership of mediation logic | [Message broker and events](https://learn.microsoft.com/azure/architecture/example-scenario/integration/queues-events) |
| `RA-VM` | Azure Virtual Machines baseline | OS-bound or unsupported runtimes; deadline-driven rehost as an interim step | Retains patching/OS burden; pair with a future disposition and reason | [VM baseline](https://learn.microsoft.com/azure/architecture/virtual-machines/baseline) |
| `RA-NTIER` | N-tier style on managed services | Layered line-of-business app where tiers map cleanly onto managed compute and data | Avoid preserving tiers that exist only for legacy hosting reasons | [N-tier style](https://learn.microsoft.com/azure/architecture/guide/architecture-styles/n-tier) |

Static front ends compose with any entry through Static Web Apps or storage/CDN families (see the compute signals in [README.md](README.md)). Use the [compute decision tree](https://learn.microsoft.com/azure/architecture/guide/technology-choices/compute-decision-tree) when no row fits.

## Platform foundation

Every option lands in an [Azure landing zone](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/): reuse the enterprise's existing platform (subscriptions, hub network, DNS, policy, identity) when one exists, and record unknown platform facts as prerequisites rather than inventing a topology. The workload entries above assume a landing zone; say which platform services the option consumes and who owns them.

## Composing options

1. Map each whole-system option to one primary reference architecture plus any composed entries (for example `RA-WEB-ZR` + `RA-WQW` + `RA-INTEGRATION`).
2. List **deviations**: each component, SKU family, network, or identity choice that differs from the reference architecture, with the evidence or constraint that forces it.
3. Keep the lower-change option anchored to a reference architecture too (often `RA-WEB-ZR` or `RA-VM`), so the user compares reference architectures rather than one against an ad hoc design.
4. Name the recommended option and why it best fits the confirmed outcomes, NFRs, skills, and operating model.

Record `RA-` IDs and deviations in `strategy-matrix.md` and carry the selected one into `target-architecture.md`.
