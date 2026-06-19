# Coach Guide – What The Hack: GitHub Copilot App Modernization

> ⚠️ **COACHES ONLY — Do not share this folder with attendees during the event.** Content here contains solutions, hints, and coaching notes.

## Overview

This hack is designed for squads of 3–5 people. It covers two parallel modernization tracks:

| Track | Application | Legacy Stack | Target Stack |
|---|---|---|---|
| Java | PhotoAlbum | Spring Boot 2.7 / Java 8 / Oracle DB | Spring Boot 3.x / Java 21 / PostgreSQL + Azure Blob |
| .NET | ContosoUniversity | .NET Framework 4.8 / ASP.NET MVC 5 / MSMQ | .NET 10 / ASP.NET Core / Azure Service Bus + Blob |

Challenges 02 and 03 are designed to be parallelized within a squad — some members take Java, others take .NET. Both tracks converge in Challenge 03 (deployment).

---

## Coach Notes Index

Per-challenge coach notes (hints, common pitfalls, mini-lecture talking points) live in
per-track subfolders. Use these during the event — **do not share with attendees**.

### .NET Track

| Challenge | Title | Coach Notes |
|-----------|-------|-------------|
| 00 | Prerequisites | [dotnet/Solution-00.md](./dotnet/Solution-00.md) |
| 01 | Assess the Legacy Application | [dotnet/Solution-01.md](./dotnet/Solution-01.md) |
| 02 | Modernize the Application | [dotnet/Solution-02.md](./dotnet/Solution-02.md) |
| 03 | Containerize & Deploy | [dotnet/Solution-03.md](./dotnet/Solution-03.md) |
| 04 | Migrate the Database | [dotnet/Solution-04.md](./dotnet/Solution-04.md) |
| 05 | Observe & Secure | [dotnet/Solution-05.md](./dotnet/Solution-05.md) |
| 06 | Infuse AI *(stretch)* | [dotnet/Solution-06.md](./dotnet/Solution-06.md) |

### Java Track

| Challenge | Title | Coach Notes |
|-----------|-------|-------------|
| 00 | Prerequisites | [java/Solution-00.md](./java/Solution-00.md) |
| 01 | Assess the Legacy Application | [java/Solution-01.md](./java/Solution-01.md) |
| 02 | Modernize the Application | [java/Solution-02.md](./java/Solution-02.md) |
| 03 | Containerize & Deploy | [java/Solution-03.md](./java/Solution-03.md) |
| 04 | Migrate the Database | [java/Solution-04.md](./java/Solution-04.md) |
| 05 | Observe & Secure | [java/Solution-05.md](./java/Solution-05.md) |
| 06 | Infuse AI *(stretch)* | [java/Solution-06.md](./java/Solution-06.md) |

---

## Azure Requirements

| Resource | Requirement |
|----------|-------------|
| **Role** | Contributor on the subscription (Owner required only if creating new resource groups with RBAC assignments) |
| **Region** | Any region with Azure Container Apps, Azure Database for PostgreSQL, Azure SQL, and Azure Service Bus — `eastus` or `westeurope` recommended |
| **Azure Container Apps** | At least 1 environment per squad; Consumption plan is sufficient |
| **Azure SQL / PostgreSQL** | Basic or Burstable SKU sufficient for the hack |
| **Azure Service Bus** | Standard tier (required for topics; Basic does not support them) |
| **Azure Blob Storage** | Standard LRS |
| **Azure OpenAI** *(Challenge 06)* | `gpt-4.1-mini` deployment; must be requested in advance if quota is not pre-allocated |

Resource providers to verify are registered before the event:

```bash
for ns in Microsoft.App Microsoft.ContainerRegistry Microsoft.DBforPostgreSQL \
           Microsoft.Sql Microsoft.ServiceBus Microsoft.Storage \
           Microsoft.CognitiveServices; do
  az provider register --namespace $ns
  echo "Registered: $ns"
done
```

---

## Event Logistics

### Full-Day Event (Recommended — ~8 hours)

| Time | Activity |
|---|---|
| 09:00 – 09:30 | Welcome, introductions, hack overview presentation |
| 09:30 – 10:00 | Challenge 00 — Prerequisites |
| 10:00 – 10:30 | Mini-lecture: What is GitHub Copilot Modernization? (demo the TUI) |
| 10:30 – 11:00 | Challenge 01 — Assessment |
| 11:00 – 11:15 | Debrief: discuss assessment results, split squad into Java/.NET tracks |
| 11:15 – 13:00 | Challenge 02 — Modernize the application (per track) |
| 13:00 – 14:00 | Lunch break |
| 14:00 – 15:30 | Continue Challenge 02 |
| 15:30 – 16:30 | Challenge 03 — Deploy to Azure |
| 16:30 – 17:15 | Challenge 04 — Migrate the Database to Azure |
| 17:15 – 17:45 | Challenge 05 — Observe & Secure |
| 17:45 – 18:00 | Challenge 06 *(stretch, optional)* — Infuse AI |
| 18:00 – 18:30 | Wrap-up, retrospective, demo |

### 2-Day Event

| Day | Time | Challenges | Focus |
|-----|------|-----------|-------|
| Day 1 | AM | Ch 00–01 | Prerequisites, Assessment, mini-lectures |
| Day 1 | PM | Ch 02 | Modernize (Java and .NET in parallel) |
| Day 2 | AM | Ch 03–04 | Containerize & Deploy, Database Migration |
| Day 2 | PM | Ch 05–06 | Observe & Secure, AI stretch *(optional)* |

> **Tip:** The 2-day format gives squads breathing room on Challenge 02, which is the
> most complex and often needs more time than a full-day event allows.

### Half-Day Event (4 hours — abbreviated)

Focus on Challenges 00–02 only. Challenges 03–05 become homework or async exercises.

| Time | Activity |
|---|---|
| 09:00 – 09:30 | Welcome + hack overview |
| 09:30 – 09:45 | Challenge 00 — Prerequisites (verify only; pre-install tools before the event) |
| 09:45 – 10:15 | Mini-lecture + Challenge 01 — Assessment |
| 10:15 – 12:30 | Challenge 02 — Modernize (core migration only, skip optional services) |
| 12:30 – 13:00 | Demo, retrospective, and next steps guidance |

---

## Squad Size

- **Ideal:** 3–5 people
- **Minimum:** 2 people (one per track in Challenge 02)
- **Maximum:** 5 people (assign roles: Java lead, .NET lead, infra lead, tester, documentarian)

---

## Coaching Philosophy

1. **Don't give away answers.** When a team is stuck, ask guiding questions:
   - "What does the assessment report say about that dependency?"
   - "Have you checked the `modernize plan create` output for a suggested goal?"
   - "Is the submodule initialised? What does `git submodule status` show?"

2. **Use coach notes for yourself, not for participants.** Show CLI output and error messages
   — not the commands to fix them — unless a team is truly blocked and time is running out.

3. **Let teams choose their path.** The `modernize` VS Code extension and the CLI produce
   equivalent results. Both paths are valid; coach whichever the team chooses.

4. **Timebox each challenge.** Suggested max times:
   - Ch 00: 30 min | Ch 01: 30 min | Ch 02: 2–3 hours | Ch 03: 45 min
   - Ch 04: 45 min | Ch 05: 30 min | Ch 06: 30 min *(stretch)*

5. **The AI challenge (06) is optional.** Azure OpenAI quota issues should not block the
   core track. Teams without quota can read the challenge and discuss the architecture.

---

## Common Issues Across All Challenges

| Issue | Resolution |
|---|---|
| `gh auth status` fails | Run `gh auth login` and complete browser OAuth flow |
| Submodules empty after clone | Run `git submodule update --init --recursive` |
| Docker not running | Ensure Docker Desktop is started before any `docker-compose` or Dev Container commands |
| `modernize` command not found | Re-run the install script; ensure `~/.local/bin` is on `PATH`: `export PATH="$HOME/.local/bin:$PATH"` |
| Azure CLI not logged in | Run `az login` |
| `modernize assess` hangs | Check `gh auth status` — the tool requires an active GitHub session |
| Terraform fails on `az login` | Ensure `ARM_USE_CLI=true` is set or run `az login` before `terraform apply` |

---

## Student Resources & Fallback Guidance

Attendees receive the sample applications via Git submodules. If submodule initialisation
fails or is taking too long, coaches can provide the apps directly:

```bash
# Recover a broken or missing submodule
git submodule update --init --recursive --force

# Verify submodule content is present
ls Student/Resources/dotnet/dotnet-migration-copilot-samples/ContosoUniversity/
ls Student/Resources/java/PhotoAlbum-Java/
```

If the Dev Container is not working, attendees can install tools directly on their host
machine following the Prerequisites section of the [hack README](../README.md).

For the optional VM deployment in Challenge 00, the Terraform scripts are in:
- `.NET:` `Student/Resources/dotnet/infra/`
- `Java:` `Student/Resources/java/infra/`

---

## Cleanup

Remind all squads to delete resources at the end of the event to avoid ongoing charges:

```bash
# List resource groups created during the hack
az group list --query "[?contains(name, 'rg-')].name" -o table

# Delete the main resource group (replace with actual group name)
az group delete --name <YOUR_RESOURCE_GROUP> --no-wait --yes
```

For Azure OpenAI deployments (Challenge 06), also delete the Cognitive Services account:

```bash
az cognitiveservices account delete \
  --name <YOUR_OPENAI_ACCOUNT> \
  --resource-group <YOUR_RESOURCE_GROUP>
```
