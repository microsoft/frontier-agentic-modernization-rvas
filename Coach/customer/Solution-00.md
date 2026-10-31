**[Home](../../README.md)** | [Troubleshooting](../TROUBLESHOOTING.md)

# Coach Guide — Challenge 00: Upgrade a Customer Application

This is the **Replatform & refactor** customer path. For substantial architecture,
business-workflow, or rebuild work, use the separate
[rebuild facilitation guide](../rebuild/facilitation-guide.md). Route by intended
change, not by programming language.

## Purpose

Help teams choose a representative customer application they can build, then apply the modernization workflow from the .NET / Java tracks.

Do not choose the portfolio's most complex or most critical application. Its risk and scope can consume the session. Choose a medium-complexity app the team can build, assess, and containerize in a day.

---

## Mini-Lecture (5 min before challenge)

Cover two points:

1. **Real apps are messier than samples.** Build failures, hard-coded secrets, missing Dockerfiles, and undocumented dependencies are normal. The workflow is the same; the friction is higher.
2. **Choose a manageable application.** Look for a legacy runtime, an external database, and one or two cloud-incompatible dependencies. Avoid the application the team is afraid to touch.

---

## Facilitation Notes

### Step 1 — Application Selection

Use a **real customer-owned codebase**, not a sample. A public customer repository
is valid with authorized access. If no application is ready, **stop and prepare
one with the customer**. Confirm repository access, build instructions, and
Docker tooling before the session.

**Push back if the team selects:**
- A greenfield or already-modern app (no meaningful migration work)
- A microservices platform with 15+ services (too complex for a single session)
- An app that nobody on the team can explain (business decisions will be blocked)

### Step 2 — Readiness Checks

Check readiness before assessment. If the team cannot build the application locally, they cannot proceed:

- **Repo accessible** — everyone can clone it without needing someone else's credentials
- **Builds locally** — warnings are fine; a complete build failure is not
- **Docker/container tooling** — `docker info` returns without error

If a check fails, help the team triage: 10-minute fix (install missing SDK, set an env var) or multi-hour blocker (database behind an inaccessible VPN, broken monorepo). For a multi-hour blocker, redirect to a different application.

### Assessment and Migration

Follow the .NET and Java workflow. Use the corresponding Solution guides:

- Assessment: see [Solution-01 (.NET)](../dotnet/Solution-01.md) or the Java equivalent
- Migration plan and execution: see [Solution-02 (.NET)](../dotnet/Solution-02.md) or the Java equivalent
- Containerization and deployment: see the relevant later solution guides

Help teams resolve manageable blockers rather than immediately switching applications.

---

## Success Criteria Notes

| Criterion | What to look for |
|---|---|
| Application justification | Written, explains why it is a good candidate and explicitly states it is not the most complex or most critical app |
| Assessment report | `modernize assess` output exists; team can summarize the top findings |
| Modern runtime build | `dotnet build` or `mvn package` succeeds on the target runtime |
| Deployed to Azure | Container running on ACA or AKS; team can show the running app |
| Coach discussion | Team can name the hardest issue the tools could not resolve automatically and explain how they handled it |

---

## Common Issues

| Issue | Coach response |
|---|---|
| Build fails before assessment | Help triage the build error. If it is a missing dependency or config value, unblock them. If it is a multi-hour structural issue, redirect to a different app. |
| Assessment produces no findings | Likely a build failure or a near-modern app. Check the assessment logs; if the app is already modern, have the team pick a more representative target. |
| Team picks an app nobody understands | Redirect to an app someone on the team understands well enough to make architectural decisions. |
| Secrets hard-coded in config | Walk through replacing them with environment variables or Azure Key Vault references before containerizing. |
