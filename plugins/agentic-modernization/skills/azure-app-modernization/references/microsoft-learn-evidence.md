# Azure capability evidence contract

Read before product-capability, lifecycle, compatibility, sizing, or service-selection claims. Keep discovery facts separate from public product evidence.

## Verify at the decision point

Use the Microsoft Learn MCP search/fetch tools when available; discover their schemas before calling deferred tools. Search with public product/feature terms and retrieve the supporting official pages.

Verify the claims that could change the target or migration path:

- Source/target runtime, OS, framework, SDK/driver support and lifecycle.
- Target compute/data/integration capabilities and compatibility limits.
- Identity, authorization, encryption, private/public networking, DNS, and residency.
- Region/SKU availability, scaling, HA/DR, backup/restore, and quotas.
- Migration-tool source/target coverage, offline/online modes, permissions, and limitations.
- Pricing/licensing when estimating alternatives.
- GitHub Actions identity claims, environment protections/plan availability, workflow/action behavior, and artifact provenance when designing delivery; use official GitHub documentation and relevant action/vendor sources alongside Microsoft Learn.

Use official Azure Architecture Center, Cloud Adoption Framework, Well-Architected Framework, lifecycle, and service documentation as evidence, not an assumed static truth. Recommendations in the strategy reference are candidate families; they do not establish current feature support.

## Privacy

Send only public capability terms. Keep source code, customer names, sensitive schema names, row data, connection strings, credentials, secrets, and confidential business details out of external queries. Describe a feature generically rather than pasting a private error dump.

## Evidence record

Record in `target-architecture.md`:

| Decision / claim | Official source and supporting section | Checked date | Version/region/SKU context | Consequence / remaining validation |
|---|---|---|---|---|

Include actual retrieved URLs and precise supporting sections, not invented links or tool names alone. Record assumptions, contradictory sources, preview status, and applicability limits.

A documentation check establishes a documented capability, not deployment viability, available subscription quota, measured performance, or completed migration validation.

## Failure path

If Learn MCP is unavailable, use another available official-document retrieval tool and disclose the fallback. If retrieval fails, mark the claim unverified and the affected option provisional. Continue independent discovery; block firm target selection only where the unverified claim determines feasibility.

State what could not be verified, the next owner/check, and the architectural consequence. Do not substitute memory for verified lifecycle or feature claims or fabricate a successful lookup.
