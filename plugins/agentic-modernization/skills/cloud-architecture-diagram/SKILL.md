---
name: cloud-architecture-diagram
description: Create, edit, or troubleshoot Azure-first architecture diagrams as editable draw.io files, with AWS and multicloud topology support and identity, API, and CI/CD flow diagrams. Use for architecture visualization, network boundaries, interaction flows, or missing diagram icons. Not for deploying infrastructure, live cloud discovery, security certification, or unrelated charts.
metadata:
  version: "1.0.1"
  contributors:
    - Paolo Montagna (adapter)
    - Marco Olivo (adapter)
    - Thomas Thornton (original work)
  source-name: drawio-mcp-diagramming
  source-last-updated: "2026-05-19"
compatibility: Python 3.10+ for local XML generation; optional draw.io desktop for rendering and Pillow for PNG trimming. Hosted draw.io MCP and public GitHub access are separate opt-in integrations, not required dependencies.
---

# Cloud Architecture Diagram

Adapted by Paolo Montagna from original work by Thomas Thornton.
Further adaptation by Marco Olivo. See
[source and asset terms](references/REFERENCE.md#source-and-asset-terms) for
provenance and the separate artwork restrictions.

Create accurate, readable diagrams from facts the user supplies. Azure is the
default cloud when specified by the brief, not permission to assume an unknown
provider. AWS, multicloud, auth/API flows, and CI/CD workflows are also supported.
The name describes the outcome; **draw.io remains the editable file format and
optional editor/renderer**, not a technology-independent runtime.

## Inputs and outputs

Establish the provider(s), components and relationships, verified network/service
deployment model, audience/detail level, desired format, and writable output
directory. For edits, identify the existing `.drawio` and any generator, requested
changes, and which file is authoritative. Read only user-authorized inputs.

If architecture facts or permissions are missing, report the specific gaps.
Ask for them when interactive; otherwise provide a clearly labelled incomplete
draft only if enough facts exist, with unknowns explicit. Never invent resources,
CIDRs, ports, redundancy, private access, or credentials. A synthetic example is
not a discovered customer architecture.

Outputs are an editable `.drawio`, optionally a user-owned Python generator, and
requested PNG/SVG/PDF exports when an approved renderer is available. Report file
paths, assumptions, source facts, missing components/icons, and the exact review
status. XML validation is not evidence of visual correctness or cloud security.

Do not use this skill to provision infrastructure, enumerate live subscriptions,
deploy services, certify security/compliance, or create unrelated statistical
charts. Explain that distinction without accessing cloud accounts.

## Tools, permissions, and privacy

| Capability | Prerequisites and access |
|---|---|
| Local `.drawio` generation (default) | Python 3.10+ standard library; read access to this skill and approved inputs, write access to the requested output directory. No network, credentials, MCP, or Python package required. |
| Local rendering | Separately installed, organization-approved draw.io desktop CLI; local executable/display support appropriate to the platform (Linux Electron may require an existing display or approved virtual display). No automatic installs, servers, sandbox disabling, or deployment. |
| Independent review | A read-only `explore` subagent that can inspect the generated `.drawio` and any local PNG/SVG exports. The reviewer receives only user-approved local artifact paths and architecture facts; it does not edit files or access cloud accounts. |
| Optional PNG trim | Pillow from [requirements.txt](requirements.txt), installed explicitly in an approved isolated environment. Modifies the selected PNG in place; preserve a copy when needed. |
| Optional hosted MCP | Organization-approved `https://mcp.draw.io/mcp` and discovered `drawio/create_diagram` capability; network access and any authentication required by that approved service/client. Inspect its current tool schema rather than assuming arguments. |
| Optional catalog refresh | Explicit `--allow-network`; HTTPS to public GitHub API/raw endpoints. No token is required by these scripts; rate limits or access failures are reported. This is a separate human-reviewed refresh, not a normal diagram step. |

Do not add MCP configuration to Baseline, change shared runtime configuration,
or silently install dependencies. Before any hosted MCP call or browser upload,
obtain organization approval **and explicit user consent to transmit the exact
diagram content**, including embedded images and labels. Never automatically send
customer architecture, secrets, tokens, internal identifiers, or source files.
Redact sensitive details and confirm the approved payload; never include real
tokens in auth-flow examples. Approval to diagram locally is not upload consent.

If MCP is unavailable or not approved, use local XML generation and explicitly
say hosted editing is unavailable/not used. If rendering/export is unavailable,
deliver only the local `.drawio` with **not visually reviewed; export not produced**.
Do not claim the missing live capability succeeded or silently substitute a hosted
renderer.

## Locate installed resources

Resolve `SKILL_DIR` to the **absolute directory of this loaded SKILL.md**, not the
repository cwd or a guessed installation path. All references, scripts, and assets
below are relative to that directory. Treat the installed skill as read-only.
Write generators, exports, and refresh candidates only to the user's output area.

## Workflow

1. Confirm inputs, scope, privacy, and architecture facts. For existing diagrams,
   preserve unrelated pages, IDs, layout, and edits; work on a copy unless overwrite
   is authorized. The builder creates new files, with one or more pages; it is not
   an existing-file editor or synchronizer. Do not regenerate an existing diagram
   from an incomplete description.
2. Choose topology or temporal flow. Read
   [topology-patterns.md](references/topology-patterns.md) for deployment boundaries,
   Azure/AWS examples, and auth/API/pipeline patterns.
3. Look up icons **locally**. Search filenames under
   `assets/az/i` for Azure, or
   `references/aws4-complete-catalog.txt` for AWS stencil names.
   Resolve Fabric, Power Platform, and Entra icons by exact family-qualified ID
   from `references/microsoft-icon-catalog.json`; examples include
   `fabric:lakehouse`, `power-platform:copilot-studio`, and `entra:workload-id`.
   Read [REFERENCE.md](references/REFERENCE.md) for catalog caveats and refresh.
   Missing icons are explicit errors; propose labelled generic shapes rather than
   silently using the wrong service icon. Do not fetch a replacement per invocation.
4. Build with [scripts/drawio_builder.py](scripts/drawio_builder.py), using arithmetic
   spacing and embedded local SVGs. Generic shapes require no image lookup.
   Keep facts separate from layout choices. Frames use absolute coordinates and
   `parent="1"`: visual nesting is not semantic mxGraph grouping.
5. Save and run the builder's `validate_file` on the XML. Check unique page IDs,
   page-local cell IDs and parent/edge references, `as="geometry"`, correct page
   dimensions, labels, and standalone images.
   See [standalone-file-requirements.md](references/standalone-file-requirements.md).
   On any helper exception, report the failing input/path and cause; correct it
   before continuing. Do not hide malformed input, missing files, or write failures.
6. If requested and available, render locally and inspect the export. Use
   [layout-antipatterns.md](references/layout-antipatterns.md) for overlap repair.
   Iterate only on user-owned artifacts. If the renderer is missing, stop the
   export step and report the limitation without uploading anywhere.
7. Run the bounded independent critique in
   [review-contract.md](references/review-contract.md) after local validation and
   the rendering attempt. Use one read-only reviewer for semantic, cross-page, and
   visual defects. Repair blocking and material findings, then send one targeted
   recheck to that same reviewer when multi-turn review is available. Stop when no
   blocking or material finding remains, or after two repair passes. Before
   stopping, account for every critique category as passed, finding,
   non-applicable, or blocked. Record residual findings instead of starting a
   fresh critique cycle.
8. Deliver paths and review status. Retain the generator with its generated file
   if requested; warn that regeneration replaces hand edits. Do not commit files
   automatically.

### Minimal local generator

Save the following as a user-owned Python script. Pass the actual loaded skill
directory and an approved output path as arguments. These are **synthetic**
components; replace them with the user's confirmed architecture facts.

```python
from pathlib import Path
import sys

skill_dir = Path(sys.argv[1]).resolve(strict=True)
sys.path.insert(0, str(skill_dir / "scripts"))
from drawio_builder import Diagram, find_icon, resolve_icon, svg_data_uri

icons = skill_dir / "assets" / "az" / "i"
d = Diagram("Synthetic architecture", 1000, 600)
api = d.icon(120, 180, "Azure API Management",
             svg_data_uri(find_icon(icons, "API-Management-Services")))
ai = d.icon(500, 180, "Azure OpenAI",
            svg_data_uri(find_icon(icons, "Azure-OpenAI")))
fabric = d.icon(760, 180, "Microsoft Fabric Lakehouse",
                svg_data_uri(resolve_icon(skill_dir, "fabric:lakehouse")))
d.edge(api, ai, "HTTPS 443 (example)", sx=1, sy=0.5, tx=0, ty=0.5)
d.edge(ai, fabric, "Grounded data request (example)", sx=1, sy=0.5, tx=0, ty=0.5)
d.save(sys.argv[2])
```

Available helpers: `banner`, `container`, `sub`, `note`, `icon`, `card`, `stage`,
`decision`, `terminator`, `edge`, and `box`/`raw` for custom styles.
Labels are plain text (including `<`, `&`, and line breaks), not HTML.
Build vertices before their edges. Both coordinates of each anchor are required,
in 0..1; waypoints and geometry must be finite. Nonpositive sizes are rejected.
`find_icon` returns the first lexically sorted matching filename; inspect the
returned filename and use a more specific fragment when multiple services match.
Use `resolve_icon` for the exact Microsoft product catalog; it rejects unknown IDs,
unsafe paths, and changed icon bytes rather than falling back to a similar service.

### Multiple pages and saved-file validation

Create a `Diagram` for each view, then import and call
`save_diagrams([context, components, data_flow, deployment], output_path)` to write
one `.drawio` in that order. Page names become page IDs and must be unique.
Cell IDs may repeat across pages; references must resolve within their own page.
`Diagram.save` uses the same writer for a single page.

Import and call `validate_file(output_path)` after saving or making targeted edits.
It returns the parsed XML root after checking the uncompressed builder format,
page dimensions, base cells, references, geometry, and embedded images.
Check expected page names/order and architecture meaning separately. Compressed
editor files require an explicit conversion on a copy before this validator can
read them. The writer replaces its destination; it does not merge existing pages
or preserve hand edits.

### Local export and optional trimming

Run the installed executable using absolute paths, for example:

```bash
drawio -x -f png -s 2 --border 10 -o "$OUTPUT_DIR/architecture.png" "$OUTPUT_DIR/architecture.drawio"
python3 "$SKILL_DIR/scripts/trim_png.py" --pad 14 "$OUTPUT_DIR/architecture.png"
```

Set both variables to actual approved absolute directories. `-f svg` or `-f pdf`
selects other formats. Do not pass `--no-sandbox`. If Electron/display support
is unavailable, report that prerequisite; do not launch background display
servers or relax protections automatically. Check process exit status and a new,
nonempty, decodable export; a stale existing file is not success.

Trim only when desired for a uniform-border PNG, not where deliberate page
layout must be preserved. Trimming composites transparency onto `--bg R,G,B`
(white by default), crops only the exported page border, and reapplies `--pad`.
It does not edit the source service icons. Blank images, bad PNGs, missing
Pillow, and invalid parameters fail explicitly.

### Visual and semantic review

- Preserve each page's declared purpose. Repeated entities are useful only when
  the page shows a different concern; repeated meaning is duplication.
- Trace important flows end to end. The direction, caller, authorization owner,
  and state transition must agree with the confirmed facts and with every other
  page where the flow appears.
- Keep actors behind an interaction boundary. A person reaches a store, queue,
  model, or managed service through the confirmed channel or application path.
- Distinguish proposal from execution. A model or agent can propose a tool
  operation; trusted application code authorizes and executes it.
- Prefer 3-4 zones, a left-to-right main path, 50-70 px service icons with nearby
  full service names, and labels at least 13 px. Do not distort, crop, flip, or
  rotate Microsoft icons or use them to represent your own service.
- Use thick VNet/VPC frames and dashed subnet frames only where confirmed.
  PaaS services and their private endpoints are distinct; a private endpoint
  does not move the managed service into the subnet.
- Label flows with known protocols/ports or explicit unknowns. Reserve red for
  failure/denial, use blue for primary traffic and dashed lines for secondary
  flows, and explain conventions in a legend.
- Pin anchors and route parallel edges through separate corridors. A simplified
  trunk must be labelled as an aggregate flow, not imply that a subnet is an
  application endpoint. Never remove meaningful flows merely to reduce clutter.
- Number temporal steps and show known failure paths. Use static connectors by
  default. Apply `flowAnimation=1` only when requested; actual animation support
  varies by viewer/exporter and must be checked, not promised. PNG/PDF are static.
- Inspect for overlapping labels, crossed icons, clipping, and wrong/missing
  images in the requested renderer. If inspection was impossible, state it.
- Record the independent critique, targeted recheck, repairs, stop reason, and
  residual limitations. Local self-review alone is not the independent gate.

## Offline checks

Resolve `SKILL_DIR` as above, then run from any directory (no network or customer data):

```bash
python3 -B -m unittest discover -s "$SKILL_DIR/tests" -v
```

The tests include a copied installed-like skill imported from an unrelated cwd.
Pillow tests require the optional requirement; missing Pillow is reported as
skipped, not passed. [evals/evals.json](evals/evals.json) contains synthetic
instruction scenarios; these are not a live benchmark. The pinned creator's
`claude -p` description evaluator is not Copilot-compatible and is not run here.
