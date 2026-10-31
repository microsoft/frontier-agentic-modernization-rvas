# Draw.io Layout Anti-Patterns Reference

Imported layout guidance, adapted for local artifacts. Examples are schematic
fragments, not complete executable XML or evidence about a customer's deployment.
Covers both Azure and AWS diagrams. Resolve paths from the loaded skill directory.

---

## Common Root Causes of Cluttered Diagrams

Eight issues frequently compound to make lines and labels unreadable:

| # | Problem | Symptom |
|---|---------|---------|
| 1 | Repeated identical label on 3+ edges from the same hub node | Labels stacked on top of each other at the source exit |
| 2 | 3+ dashed lines leaving the same node face within 20px | Lines rendered as one thick bar |
| 3 | Azure Monitor placed inside a VNet/subnet container | Architecturally incorrect and visually clutters private network |
| 4 | CloudWatch placed inside a VPC/subnet container | Architecturally incorrect — CloudWatch is a regional managed service |
| 5 | Decorative resource icon free-floating inside a container, overlapping service icons | Icon covers service icon |
| 6 | Two services sharing one subnet with exits on the same face | Shared corridor, all edges stacked |
| 7 | All `mxCell` elements on one line | Any patch edit fails context match |
| 8 | Using `image=img/lib/aws4/...` style for AWS4 shapes | AWS4 icons are stencils — must use `shape=mxgraph.aws4.*` |

---

## Fix Patterns

### Repeated edge labels

```xml
<!-- BEFORE (all three labels identical) -->
<mxCell id="33" value="Route" ... source="hub" target="A">
<mxCell id="34" value="Route" ... source="hub" target="B">
<mxCell id="35" value="Route" ... source="hub" target="C">

<!-- AFTER (each label names the specific target) -->
<mxCell id="33" value="Service A" ... source="hub" target="A">
<mxCell id="34" value="Service B" ... source="hub" target="B">
<mxCell id="35" value="Service C" ... source="hub" target="C">
```

### Exit anchor fanning (3+ edges from one node face)

Spread `exitX` values at least 0.15 apart. Use `<Array as="points">` waypoints to route each edge into its own horizontal corridor before they reach targets.

The `x`/`y` attributes on `mxGeometry relative="1"` shift the **label** along the edge path — use this to avoid label stacking when edges share a path segment:

```xml
<!-- Three edges leaving the bottom of a hub node, fanned across 0.35 / 0.5 / 0.65 -->
<mxCell id="33" value="Service A"
  style="...;exitX=0.35;exitY=1;...;entryX=0.5;entryY=0;..."
  edge="1" source="hub" target="A" parent="1">
  <mxGeometry relative="1" x="-0.55" y="-16" as="geometry">
    <Array as="points"><mxPoint x="WAY_X" y="WAY_Y"/></Array>
  </mxGeometry>
</mxCell>

<mxCell id="34" value="Service B"
  style="...;exitX=0.5;exitY=1;...;entryX=0.5;entryY=0;..."
  edge="1" source="hub" target="B" parent="1">
  <mxGeometry relative="1" x="-0.2" y="-4" as="geometry">
    <Array as="points"><mxPoint x="WAY_X" y="WAY_Y"/></Array>
  </mxGeometry>
</mxCell>

<mxCell id="35" value="Service C"
  style="...;exitX=0.65;exitY=1;...;entryX=0.5;entryY=0;..."
  edge="1" source="hub" target="C" parent="1">
  <mxGeometry relative="1" x="0.2" y="10" as="geometry">
    <Array as="points"><mxPoint x="WAY_X" y="WAY_Y"/></Array>
  </mxGeometry>
</mxCell>
```

Same pattern for right-side dashed management/observability edges from a hub node:

```xml
<!-- Three dashed lines leaving the right face of a hub node -->
exitX=1, exitY=0.35   → first target   (label offset: x=-0.45, y=-18)
exitX=1, exitY=0.52   → second target  (label offset: x=-0.15, y=-2)
exitX=1, exitY=0.68   → third target   (label offset: x=0.25,  y=14)
```

### Observability zone placement

```
WRONG layout:
  ┌─────────────────────────────────────────────┐
  │ VNet                                        │
  │  ┌──────────────────┐  ┌─────────────────┐  │
  │  │ snet-ingress     │  │ snet-mgmt       │  │
  │  │  [GW]  [Hub Svc] │  │  [PE] [DNS]     │  │
  │  └──────────────────┘  └─────────────────┘  │
  │  [Monitor]  ← WRONG: Monitor inside VNet     │
  └─────────────────────────────────────────────┘

CORRECT layout:
  ┌─────────────────────────────────────────────┐   [Monitor] ──→ [Log Analytics] ──→ [Sentinel]
  │ VNet                                        │       ↑
  │  ┌──────────────────┐  ┌─────────────────┐  │   dashed telemetry edge exits VNet boundary
  │  │ snet-ingress     │  │ snet-mgmt       │  │
  │  │  [GW]  [Hub Svc] │  │  [PE] [DNS]     │  │
  │  └──────────────────┘  └─────────────────┘  │
  └─────────────────────────────────────────────┘
```

Azure Monitor, Log Analytics Workspace, and Microsoft Sentinel are **not VNet resources**. They must be positioned in a zone outside/right of the VNet boundary. The telemetry edge (dashed) crosses the VNet boundary — that's correct and communicates the service model.

`PE` denotes a private endpoint, not Key Vault itself. Show the managed Key Vault
service outside the VNet. DNS placement depends on the actual deployment:
distinguish a resolver endpoint from an Azure Private DNS zone.

### AWS: CloudWatch placed inside a VPC/subnet

CloudWatch, AWS Config, CloudTrail, and similar managed observability services are **regional services**, not VPC-resident resources. Place them outside the VPC boundary in an "AWS Managed Services" or "Observability" zone.

```
WRONG layout:
  ┌─────────────────────────────────────────────┐
  │ VPC                                         │
  │  ┌──────────────────┐                       │
  │  │ Private Subnet   │                       │
  │  │  [EC2]  [RDS]    │                       │
  │  └──────────────────┘                       │
  │  [CloudWatch]  ← WRONG: CloudWatch inside VPC│
  └─────────────────────────────────────────────┘

CORRECT layout:
  ┌─────────────────────────────────────────────┐   [CloudWatch] ──→ [S3 Logs] ──→ [Athena]
  │ VPC                                         │       ↑
  │  ┌──────────────────┐                       │   dashed telemetry edge exits VPC boundary
  │  │ Private Subnet   │                       │
  │  │  [EC2]  [RDS]    │                       │
  │  └──────────────────┘                       │
  └─────────────────────────────────────────────┘
```

### AWS: Wrong icon style for AWS4 shapes

AWS4 icons are stencil-based and must **not** be referenced as SVG image paths.

```xml
<!-- BAD: AWS4 has no SVG files at img/lib/aws4/ -->
<mxCell style="image;aspect=fixed;html=1;image=img/lib/aws4/compute/Lambda.svg;"/>

<!-- GOOD: Use stencil shape notation -->
<mxCell style="shape=mxgraph.aws4.lambda;fillColor=#ED7100;fontColor=#ffffff;strokeColor=none;html=1;" vertex="1">
  <mxGeometry x="300" y="400" width="64" height="64" as="geometry"/>
</mxCell>
```

Always grep `references/aws4-complete-catalog.txt` for the exact shape name before adding an AWS icon.

### Decorative icon positioning

Icons such as the Virtual Network icon (`networking/Virtual_Networks.svg`) used as a visual label companion should be anchored to a fixed corner of their parent container — typically top-right. Without anchoring, draw.io renders them at the computed top-left of the container where they land on top of subnet boxes or service icons.

```xml
<!-- Anchor to top-right of region/VNet container -->
<mxCell id="8" value="Virtual Network"
  style="image;aspect=fixed;...;image=img/lib/azure2/networking/Virtual_Networks.svg;"
  vertex="1" parent="1">
  <!-- x = container_x + container_width - icon_width - 20px margin -->
  <mxGeometry x="1360" y="180" width="64" height="64" as="geometry"/>
</mxCell>
```

### Single-line XML — how to avoid

When generating `mxGraphModel` XML, always emit one `mxCell` per line with child elements indented:

```xml
<!-- BAD: impossible to patch, xmllint errors point to char 0 -->
<mxCell id="0"/><mxCell id="1" parent="0"/><mxCell id="2" value="..." style="..." vertex="1" parent="1"><mxGeometry x="30" y="20" width="1940" height="70" as="geometry"/></mxCell>...

<!-- GOOD: each element independently patchable -->
<mxCell id="0"/>
<mxCell id="1" parent="0"/>
<mxCell id="2" value="Title" style="..." vertex="1" parent="1">
  <mxGeometry x="30" y="20" width="1940" height="70" as="geometry"/>
</mxCell>
```

---

## Quick Checklist Before Finalising Any Diagram

**General:**
- [ ] All sibling edges (same source → different targets) have **unique** labels
- [ ] 3+ edges from same node face have spread `exitX` values (≥0.15 gap) + waypoints
- [ ] Edge labels are offset using `mxGeometry x`/`y` when edges share a path segment
- [ ] Reduce unnecessary cross-zone clutter without dropping confirmed relationships
- [ ] XML is indented (one `mxCell` per line) — not minified
- [ ] XML parses with Python ElementTree (or `xmllint` if already installed); all references resolve

**Azure-specific:**
- [ ] Monitor / Log Analytics / Sentinel are **outside** any VNet or subnet container
- [ ] Decorative network/resource icons are corner-anchored, not free-floating
- [ ] Standalone Azure icons use embedded data URIs from the bundled builder, not remote/library paths

**AWS-specific:**
- [ ] CloudWatch / CloudTrail / Config are **outside** any VPC or subnet container
- [ ] AWS icons use `shape=mxgraph.aws4.<name>` style (not `image=img/lib/aws4/...`)
- [ ] Shape names verified against `references/aws4-complete-catalog.txt` before use
- [ ] fillColor matches AWS service category colour conventions

The historical `img/lib/azure2/...` snippets illustrate layout only. For portable
artifacts use the bundled Microsoft icons as encoded images. AWS stencils still
require the editor's AWS4 library; generic labelled shapes are the offline option
when that library is unavailable. Neither XML parsing nor this checklist replaces
visual inspection in an approved renderer.
