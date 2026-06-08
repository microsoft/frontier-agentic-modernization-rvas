**[Home](../../README.md)**

# Coach Guide — Challenge 00: Modernize a Customer Application

## Purpose

This challenge moves squads from the pre-packaged sample apps to a **real codebase**. The goal is straightforward: pick something real and representative, make sure the team can actually build it, and apply the same modernization workflow from the .NET / Java tracks.

The only selection constraint worth enforcing is that squads **do not pick the most complex or most critical application** in the portfolio. Mission-critical, highly complex apps introduce risk and scope that will consume the entire session without producing a meaningful result. A medium-complexity app that the team can build, assess, and containerize in a day is the right target.

---

## Mini-Lecture (5 min before challenge)

Keep this brief. Two points:

1. **Real apps are messier than samples.** Build failures, hard-coded secrets, missing Dockerfiles, and undocumented dependencies are normal. The workflow is the same; the friction is higher.
2. **Pick tractable, not impressive.** The application the team is afraid to touch is not the right starting point. The application that is a good example of the legacy estate — legacy runtime, external database, one or two cloud-incompatible dependencies — is the right starting point.

---

## Facilitation Notes

### Step 1 — Application Selection

This challenge requires a **real customer-owned codebase**. Sample applications and public GitHub repositories are not acceptable substitutes. If the squad does not have a customer application ready, **stop and work with the customer to identify and prepare one before proceeding** — repo access, build instructions, and Docker tooling should all be confirmed before the session starts.

**Push back if the squad selects:**
- A greenfield or already-modern app (no meaningful migration work)
- A microservices platform with 15+ services (too complex for a single session)
- An app that nobody on the team can explain (no domain context = blocked on every decision)

### Step 2 — Readiness Checks

**This is the most important gate.** A squad that selects an application they cannot build locally will be blocked for the rest of the session. Walk through the checklist with them before they start the assessment:

- **Repo accessible** — everyone can clone it without needing someone else's credentials
- **Builds locally** — warnings are fine; a complete build failure is not
- **Docker/container tooling** — `docker info` returns without error

If a check fails, help the squad triage: 10-minute fix (install missing SDK, set an env var) or multi-hour blocker (database behind an inaccessible VPN, broken monorepo). For a multi-hour blocker, redirect to a different application.

### Assessment and Migration

From here, the workflow mirrors the .NET and Java track challenges exactly. Refer to the corresponding Solution guides for detailed facilitation notes on each step:

- Assessment: see [Solution-01 (.NET)](../dotnet/Solution-01.md) or the Java equivalent
- Migration plan and execution: see [Solution-02 (.NET)](../dotnet/Solution-02.md) or the Java equivalent
- Containerization and deployment: see the relevant later solution guides

The key difference from the sample tracks: customer repos frequently have build issues, secrets in config files, missing migration scripts, and undocumented startup dependencies. Coach the squad to treat each blocker as a learning moment rather than a reason to switch apps.

---

## Success Criteria Notes

| Criterion | What to look for |
|---|---|
| Application justification | Written, explains why it is a good candidate and explicitly states it is not the most complex or most critical app |
| Assessment report | `modernize assess` output exists; squad can summarize the top findings |
| Modern runtime build | `dotnet build` or `mvn package` succeeds on the target runtime |
| Deployed to Azure | Container running on ACA or AKS; squad can show the running app |
| Coach discussion | Squad can name the hardest issue the tools could not resolve automatically and explain how they handled it |

---

## Common Issues

| Issue | Coach response |
|---|---|
| Build fails before assessment | Help triage the build error. If it is a missing dependency or config value, unblock them. If it is a multi-hour structural issue, redirect to a different app. |
| Assessment produces no findings | Likely a build failure or a near-modern app. Check the assessment logs; if the app is already modern, have the squad pick a more representative target. |
| Squad picks an app nobody understands | Redirect. Domain ignorance blocks every architectural decision. Someone on the team needs to know what the app does. |
| Secrets hard-coded in config | Good teaching moment — this is a real and common blocker. Walk through replacing with environment variables or Azure Key Vault references before containerizing. |
