# Icon and diagram references

These resources were supplied with `drawio-mcp-diagramming` 1.0.0 and adapted for
`cloud-architecture-diagram`; see [source and asset terms](#source-and-asset-terms).
Adapted by Paolo Montagna from original work by Thomas Thornton.

## Local first

- `../assets/az/i`: 714 bundled Microsoft Azure SVGs. Paths use compact category
  codes and omit the redundant `icon-service-` filename prefix to keep Windows
  checkouts portable; each filename retains its original numeric identifier and
  searchable service name.
- `microsoft-icon-catalog.json`: 32 curated Microsoft Fabric, Power Platform, and
  Entra SVGs resolved by exact family-qualified IDs. The catalog records labels,
  upstream filenames, source versions, archive fingerprints, and per-icon hashes.
  Family namespaces prevent semantic collisions such as Microsoft Fabric versus
  Azure Service Fabric and Power BI versus Power BI Embedded.
- `azure2-complete-catalog.txt`: supplied inventory of 714 paths matching that
  local icon set. Despite its inherited filename, these numbered/hyphenated
  paths are **not verified jgraph Azure2 web library paths**. Do not prepend
  `img/lib/azure2/` to them. Resolve against the bundled Icons directory.
- `aws4-complete-catalog.txt`: 1,037 supplied AWS4 stencil style names. The first
  line is a generation summary, not a shape. Match `shape=mxgraph.aws4.*` lines.
  These are names, not bundled AWS artwork or stencil definitions.

Use `find`/filename globbing against the absolute loaded skill directory for
Azure; use `grep -i "lambda" "$SKILL_DIR/references/aws4-complete-catalog.txt"`
for AWS. Use `resolve_icon(SKILL_DIR, "fabric:lakehouse")` for the exact Microsoft
catalog. Catalogs are snapshots, not proof that the installed renderer supports
every entry.

## Embedding and rendering

Use `svg_data_uri(find_icon(...))` from the builder to embed an Azure icon with
`image=data:image/svg+xml,<percent-encoded-svg>;`. Do not put a bare local path,
URL, or `img/lib/...` in an otherwise standalone artifact.

Use `svg_data_uri(resolve_icon(...))` for Fabric, Power Platform, and Entra.
`resolve_icon` verifies the catalog schema, exact ID, safe local path, file
existence, and recorded SHA-256 before returning an SVG.

draw.io styles use semicolons as separators. Canonical `;base64` data URIs break
that grammar; the builder uses percent-encoded SVG and draw.io's PNG comma form
`data:image/png,<base64>`. These are draw.io image values, not a general browser
data-URI API. Verify the requested renderer.

AWS4 uses **stencils**, not `image=img/lib/aws4/...`. Look up the exact case-sensitive
shape name. Example: `shape=mxgraph.aws4.lambda;fillColor=#ED7100;`.
The target editor must have the AWS4 library. For strict standalone rendering
without that library, use clearly labelled generic shapes with user agreement
or separately approved embedded artwork. Do not invent a stencil or claim the
catalog contains the SVGs.

Use category colors consistently (compute orange, networking purple, storage
green, security red) but prefer readability and accurate labels over decoration.
Plain flow diagrams can skip cloud icons entirely.

## Optional public GitHub search / refresh

These helpers perform outbound HTTPS only with explicit `--allow-network`.
They request public jgraph resources; they do not receive architecture files
or need credentials. Review organization network policy first.

```bash
python3 "$SKILL_DIR/scripts/search_azure2_icons_github.py" --allow-network --search gateway
python3 "$SKILL_DIR/scripts/search_aws4_icons_github.py" --allow-network --search lambda
```

Azure searches the jgraph `dev` tree and emits relative web-library SVG paths,
not the bundled Microsoft filename inventory. `--validate` checks public image
URLs and returns failure if any URL check fails. AWS parses `aws4.xml` and emits
stencil names. No matches, malformed/truncated data, HTTP failures, and invalid
parameters return a nonzero status; never fabricate output when GitHub fails.

For a separate reviewed catalog update, use `--max-results 9999` and capture
stdout to a **new candidate file outside the installed skill**. Check the exit
code before using it; shell redirection can create an empty/partial file on
failure. Record the actual upstream revision and retrieval date before a
maintainer replaces any catalog. Neither script rewrites installed files.
Never replace the bundled Azure inventory with web-library paths without
updating its documented meaning and tests.

## Additional guidance

- [Topology and flow patterns](topology-patterns.md): cloud placement and synthetic
  examples; apply only facts confirmed in the user's system.
- [Standalone file requirements](standalone-file-requirements.md): complete XML,
  geometry, IDs, image portability, and validation limits.
- [Layout anti-patterns](layout-antipatterns.md): useful routing/label repair
  fragments, not executable complete diagrams or real customer topology.

Example requests: "Diagram the Azure components in my approved input with private
endpoints distinguished from managed services"; "Show the AWS VPC tiers and
confirmed egress paths"; "Show our confirmed Azure-AWS connection and identity
flow". Do not assume VPN/ExpressRoute/Direct Connect are interchangeable or present.

## Source and asset terms

The supplied snapshot and adaptation retain their original attribution. The
repository owner's authorization covers redistribution of this skill in Agentic
Co-build. The artwork below has separate permitted-use terms; the repository's
MIT license does not replace them.

### Microsoft Azure artwork

The 714 SVG icons remain byte-for-byte as supplied. Their current official terms
are published at `https://learn.microsoft.com/azure/architecture/icons/`. They
are not MIT-licensed by this import.

The supplied terms permit architectural diagrams, training materials, or
documentation, and copying, distribution, and display only for that permitted
use unless Microsoft grants explicit permission; other rights are reserved.
Do not crop, flip, rotate, distort, or change icon shapes, or use a Microsoft
product icon to represent another product or service. Keep the full service
name nearby without overlap. Proportionate SVG resizing is supported.
Redistribution is for architectural diagramming, not a general artwork or
trademark license; retain the supplied terms and permitted-use restrictions.

### Microsoft Fabric artwork

The curated Fabric subset comes from `@fabric-msft/svg-icons` 8.2.0, retrieved
2026-10-07. The package declares the MIT license reproduced below. Product and
service names remain Microsoft trademarks; use the artwork to identify the
represented Fabric product or item, retain nearby labels, and preserve its
proportions. Current icon guidance is published at
`https://learn.microsoft.com/fabric/fundamentals/icons`.

#### Fabric MIT license

MIT License

Copyright (c) 2025 Microsoft Corporation

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

### Microsoft Power Platform artwork

The eight Power Platform SVGs remain byte-for-byte from the official scalable
icon package. Current terms are published at
`https://learn.microsoft.com/power-platform/guidance/icons`. The permitted use
is architectural diagrams, training materials, or documentation. Do not crop,
rotate, distort, recolor, or use a product icon to represent another service.
Power BI is intentionally sourced from the Fabric catalog; Power BI Embedded
remains a distinct Azure icon.

### Microsoft Entra artwork

The four product-level Entra SVGs remain byte-for-byte from the official October
2023 package. Current terms and branding guidance are published at
`https://learn.microsoft.com/entra/architecture/architecture-icons`. Use these
for Entra product boundaries; continue to use Azure resource icons for specific
deployed capabilities such as managed identities or private access.

Microsoft 365 product logos are not bundled. The official architecture package
contains generic content symbols rather than a licensed product-logo subset;
use labelled generic shapes until an approved redistributable source is recorded.

The supplied AWS catalog contains stencil names, not artwork or libraries.
The Azure catalog is the local Microsoft inventory despite its inherited
`azure2` filename. Names and refresh scripts grant no rights to third-party
logos or fetched jgraph assets. The repository/plugin MIT license does not
supersede these asset terms.

### Import adaptations

- Renamed the skill to describe its architecture deliverable; retained Azure,
  AWS/multicloud, auth/API, and pipeline guidance and repaired service/subnet
  distinctions, XML examples, and icon advice.
- Replaced mandatory hosted MCP use with local standard-library generation and
  explicit consent for hosted content transmission. No hosted service or
  dependencies are installed automatically.
- Made paths portable and retained/adapted four helpers for XML handling,
  embedding, PNG trimming, and opt-in refresh, with explicit failures and no
  routine writes to installed files.
- Shortened the local Azure asset tree for Windows-compatible checkouts while
  preserving icon bytes, numeric identifiers, searchable service names, terms,
  and the catalog inventory.
- Added offline tests, instruction scenarios, optional Pillow requirements, and
  the source fingerprint manifest.
- Excluded two compiled `scripts/__pycache__/*.pyc` files, archives, generated
  evaluation workspaces, customer data, and generator outputs.
