"""Generic, reusable draw.io (.drawio / mxGraphModel) builder.

Generating XML from a script makes repeated layouts arithmetic (columns, rows,
gutters) and regeneration deterministic. It does not replace visual review.

Usage
-----
    from drawio_builder import Diagram, svg_data_uri, png_data_uri, find_icon, resolve_icon

    d = Diagram("My architecture", 2000, 1200)
    api = d.icon(100, 100, "API Management", svg_data_uri(find_icon(ICONS, "API-Management")))
    db  = d.icon(400, 100, "SQL Database",   svg_data_uri(find_icon(ICONS, "SQL-Database")))
    d.edge(api, db, "TDS 1433")
    d.save("out/architecture.drawio")

Optional export + trim (see SKILL.md "Local export and optional trimming"):
    drawio -x -f png -s 2 --border 10 -o out/architecture.png out/architecture.drawio
    python trim_png.py out/architecture.png

No third-party dependency is required by this module (Pillow is only needed by
trim_png.py).
"""

from __future__ import annotations

import base64
import hashlib
import html
import json
import math
import os
from pathlib import Path
import re
import struct
import xml.etree.ElementTree as ET
from urllib.parse import quote, unquote
import zlib

# --------------------------------------------------------------------------
# Icon / image embedding
# --------------------------------------------------------------------------
# Icons are embedded as data URIs so the .drawio file is self-contained and the
# PNG export never depends on network access or on a draw.io shape library.


def find_icon(root_dir: str, fragment: str, ext: str = ".svg") -> str:
    """Return the first file under root_dir whose name contains `fragment`.

    Raises FileNotFoundError so a typo fails the build instead of silently
    producing a diagram with a missing icon.
    """
    if not fragment.strip():
        raise ValueError("icon search fragment must not be empty")
    if not Path(root_dir).is_dir():
        raise FileNotFoundError(f"icon directory does not exist: {root_dir}")
    matches = []
    for root, _dirs, files in os.walk(root_dir):
        for f in files:
            if f.lower().endswith(ext.lower()) and fragment.lower() in f.lower():
                matches.append(os.path.join(root, f))
    if not matches:
        raise FileNotFoundError(f"no {ext} under {root_dir} matching {fragment!r}")
    return sorted(matches)[0]


def resolve_icon(skill_dir: str, icon_id: str) -> str:
    """Resolve an exact family-qualified icon ID from the bundled catalog."""
    if not isinstance(icon_id, str) or not re.fullmatch(
        r"[a-z0-9]+(?:-[a-z0-9]+)*:[a-z0-9]+(?:-[a-z0-9]+)*", icon_id
    ):
        raise ValueError("icon ID must be family-qualified, for example 'fabric:lakehouse'")

    root = Path(skill_dir).resolve()
    catalog_path = root / "references" / "microsoft-icon-catalog.json"
    if not catalog_path.is_file():
        raise FileNotFoundError(f"icon catalog does not exist: {catalog_path}")
    try:
        catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"invalid icon catalog: {catalog_path}") from exc
    if catalog.get("schema_version") != 1 or not isinstance(catalog.get("icons"), dict):
        raise ValueError(f"unsupported icon catalog schema: {catalog_path}")

    entry = catalog["icons"].get(icon_id)
    if not isinstance(entry, dict):
        raise FileNotFoundError(f"icon catalog has no entry for {icon_id!r}")
    relative = entry.get("path")
    expected_hash = entry.get("sha256")
    if not isinstance(relative, str) or not isinstance(expected_hash, str):
        raise ValueError(f"invalid catalog entry for {icon_id!r}")

    path = (root / relative).resolve()
    if not path.is_relative_to(root) or path.suffix.lower() != ".svg":
        raise ValueError(f"unsafe icon path for {icon_id!r}: {relative!r}")
    if not path.is_file():
        raise FileNotFoundError(f"catalog icon does not exist: {path}")
    actual_hash = hashlib.sha256(path.read_bytes()).hexdigest()
    if actual_hash != expected_hash:
        raise ValueError(f"catalog icon hash mismatch for {icon_id!r}: {path}")
    return str(path)


def svg_data_uri(path: str) -> str:
    """URL-encoded SVG data URI (the form draw.io parses most reliably)."""
    with open(path, "r", encoding="utf-8", newline="") as fh:
        return inline_svg_data_uri(fh.read())


def png_data_uri(path: str) -> str:
    """PNG data URI in *comma form* — `data:image/png,<base64>`.

    Do NOT use the canonical `data:image/png;base64,...`: the semicolon is a
    style-attribute separator in draw.io and truncates the image, so the shape
    renders empty.
    """
    with open(path, "rb") as fh:
        data = fh.read()
    _validate_png(data)
    return "data:image/png," + base64.b64encode(data).decode("ascii")


def _validate_png(data: bytes) -> None:
    """Check PNG framing/checksums; pixel decoding still belongs to the renderer."""
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        raise ValueError("not a PNG image")
    offset = 8
    kinds = []
    while offset + 12 <= len(data):
        length = struct.unpack_from(">I", data, offset)[0]
        end = offset + 12 + length
        if end > len(data):
            raise ValueError("truncated PNG chunk")
        kind = data[offset + 4:offset + 8]
        payload = data[offset + 8:end - 4]
        crc = struct.unpack_from(">I", data, end - 4)[0]
        if zlib.crc32(kind + payload) != crc:
            raise ValueError("invalid PNG chunk checksum")
        if not kinds:
            if kind != b"IHDR" or length != 13:
                raise ValueError("PNG must start with an IHDR chunk")
            if 0 in struct.unpack_from(">II", payload):
                raise ValueError("PNG dimensions must be positive")
        kinds.append(kind)
        offset = end
        if kind == b"IEND":
            if length != 0 or offset != len(data) or b"IDAT" not in kinds:
                raise ValueError("invalid PNG end or missing image data")
            return
    raise ValueError("PNG is missing its end chunk")


def inline_svg_data_uri(svg: str) -> str:
    """Data URI from an inline SVG string (handy for small custom marks)."""
    if "<!DOCTYPE" in svg.upper() or "<!ENTITY" in svg.upper():
        raise ValueError("SVG declarations/entities are not supported")
    root = ET.fromstring(svg)
    if root.tag.rsplit("}", 1)[-1] != "svg":
        raise ValueError("image root must be svg")
    for element in root.iter():
        if element.tag.rsplit("}", 1)[-1] in ("script", "foreignObject"):
            raise ValueError("active SVG content is not supported")
        for key, value in element.attrib.items():
            name = key.rsplit("}", 1)[-1].lower()
            if name.startswith("on") or (name == "href" and not value.startswith("#")):
                raise ValueError("SVG must not contain active or external references")
        # Local gradient/filter references are safe; remote CSS can leak content.
        content = " ".join(element.attrib.values()) + (element.text or "")
        if "@import" in content.lower() or any(
            not ref.strip(" '\"").startswith("#")
            for ref in re.findall(r"url\((.*?)\)", content, re.IGNORECASE)
        ):
            raise ValueError("SVG must use local fragment references only")
    return "data:image/svg+xml," + quote(svg, safe="")


def _number(value, name, minimum=None):
    if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value):
        raise ValueError(f"{name} must be a finite number")
    if minimum is not None and value < minimum:
        raise ValueError(f"{name} must be >= {minimum}")


def _image_uri(uri):
    if not isinstance(uri, str) or ";" in uri or not uri.startswith(
        ("data:image/svg+xml,", "data:image/png,")
    ):
        raise ValueError("use a bundled image helper: only draw.io-safe embedded SVG/PNG is supported")
    kind, payload = uri.split(",", 1)
    if kind == "data:image/svg+xml":
        inline_svg_data_uri(unquote(payload, errors="strict"))
    else:
        _validate_png(base64.b64decode(payload, validate=True))


# --------------------------------------------------------------------------
# Diagram
# --------------------------------------------------------------------------


class Diagram:
    """Accumulates mxCells and writes a complete .drawio file.

    All coordinates are absolute page coordinates; every helper returns the cell
    id so it can be passed to `edge()`.
    """

    def __init__(self, name: str, width: int, height: int):
        if not isinstance(name, str) or not name.strip():
            raise ValueError("diagram name is required")
        _number(width, "page width", 1)
        _number(height, "page height", 1)
        self.name = name
        self.W = width
        self.H = height
        self.cells: list[str] = []
        self._i = 10
        self._vertices: set[str] = set()

    # -- internals ---------------------------------------------------------
    def nid(self) -> str:
        self._i += 1
        return f"n{self._i}"

    @staticmethod
    def esc(text: str) -> str:
        """XML-escape a label; `\n` becomes a draw.io line break."""
        return html.escape(text, quote=True).replace("\n", "&#10;")

    def raw(self, cid, value, style, x, y, w, h) -> str:
        if not isinstance(cid, str) or not cid or cid in {"0", "1"} | self._vertices:
            raise ValueError(f"invalid or duplicate vertex id: {cid!r}")
        for key, val in (("x", x), ("y", y), ("width", w), ("height", h)):
            _number(val, key, 1 if key in ("width", "height") else None)
        style = style.replace("html=1", "html=0")
        self.cells.append(
            f'<mxCell id="{self.esc(cid)}" value="{self.esc(value)}" style="{self.esc(style)}" vertex="1" parent="1">'
            f'<mxGeometry x="{x}" y="{y}" width="{w}" height="{h}" as="geometry"/></mxCell>'
        )
        self._vertices.add(cid)
        return cid

    # -- shapes ------------------------------------------------------------
    def box(self, x, y, w, h, label, style) -> str:
        """Escape hatch: any shape, any raw draw.io style string."""
        return self.raw(self.nid(), label, style, x, y, w, h)

    def banner(self, x, y, w, h, label, fill="#1F3864", fs=20) -> str:
        """Full-width title bar."""
        return self.box(
            x, y, w, h, label,
            f"rounded=0;whiteSpace=wrap;html=1;fillColor={fill};strokeColor=none;fontColor=#ffffff;"
            f"fontSize={fs};fontStyle=1;align=center;verticalAlign=middle;",
        )

    def container(self, x, y, w, h, title, fill, stroke, font="#1a1a1a", fs=17) -> str:
        """Solid grouping frame (platform / account / region boundary)."""
        return self.box(
            x, y, w, h, title,
            f"rounded=1;arcSize=3;whiteSpace=wrap;html=1;fillColor={fill};strokeColor={stroke};"
            f"strokeWidth=2;fontColor={font};fontSize={fs};fontStyle=1;verticalAlign=top;align=left;"
            "spacingLeft=14;spacingTop=8;dashed=0;",
        )

    def sub(self, x, y, w, h, title, fill, stroke, font="#1a1a1a", fs=14) -> str:
        """Dashed sub-grouping frame (subnet / logical zone)."""
        return self.box(
            x, y, w, h, title,
            f"rounded=1;arcSize=6;whiteSpace=wrap;html=1;fillColor={fill};strokeColor={stroke};"
            f"strokeWidth=1;dashed=1;dashPattern=6 6;fontColor={font};fontSize={fs};fontStyle=1;"
            "verticalAlign=top;align=center;spacingTop=6;",
        )

    def note(self, x, y, w, h, text, fill="#FFFDE7", stroke="#F9A825", fs=11, font="#333333") -> str:
        """Callout / annotation."""
        return self.box(
            x, y, w, h, text,
            f"text;html=1;align=center;verticalAlign=middle;fontSize={fs};fontColor={font};"
            f"fillColor={fill};strokeColor={stroke};rounded=1;whiteSpace=wrap;",
        )

    def icon(self, x, y, label, uri, w=64, h=64, fs=13, font="#1a1a1a") -> str:
        """Vendor icon with the label placed *below* the glyph."""
        _image_uri(uri)
        style = (
            "sketch=0;html=1;pointerEvents=1;shadow=0;dashed=0;fillColor=none;strokeColor=none;"
            "labelPosition=center;verticalLabelPosition=bottom;verticalAlign=top;align=center;"
            f"fontSize={fs};fontColor={font};aspect=fixed;image;image={uri};"
        )
        return self.raw(self.nid(), label, style, x, y, w, h)

    def card(self, x, y, w, h, title, subtitle="", fill="#1f2328", stroke="#57606a",
             font="#ffffff", fs=13, badge_uri=None) -> str:
        """Titled rounded card, optionally with a small mark in the top-left corner."""
        if badge_uri is not None:
            _image_uri(badge_uri)
        value = f"{title}\n{subtitle}" if subtitle else title
        cid = self.raw(
            self.nid(), value,
            f"rounded=1;arcSize=10;whiteSpace=wrap;html=1;fillColor={fill};strokeColor={stroke};"
            f"fontColor={font};fontSize={fs};fontStyle=1;verticalAlign=top;spacingTop=8;"
            "spacingLeft=6;spacingRight=6;align=center;",
            x, y, w, h,
        )
        if badge_uri:
            self.raw(self.nid(), "", f"html=1;image;image={badge_uri};imageAspect=1;",
                     x + 8, y + 8, 22, 22)
        return cid

    def stage(self, x, y, w, h, title, subtitle="", fill="#0078D4", fs=15, number=None) -> str:
        """Pipeline stage tile; pass `number` to add a circled step number."""
        value = f"{title}\n{subtitle}" if subtitle else title
        spacing = 26 if number is not None else 10
        cid = self.raw(
            self.nid(), value,
            f"rounded=1;arcSize=12;whiteSpace=wrap;html=1;fillColor={fill};strokeColor=none;"
            f"fontColor=#ffffff;fontSize={fs};fontStyle=1;verticalAlign=top;spacingTop={spacing};"
            "align=center;",
            x, y, w, h,
        )
        if number is not None:
            self.raw(
                self.nid(), str(number),
                f"ellipse;whiteSpace=wrap;html=1;fillColor=#ffffff;strokeColor=none;fontColor={fill};"
                "fontSize=15;fontStyle=1;",
                x + w / 2 - 15, y + 6, 30, 30,
            )
        return cid

    def decision(self, x, y, label="GATE", size=58, fill="#795548") -> str:
        """Diamond decision / quality gate."""
        return self.box(
            x, y, size, size, label,
            f"rhombus;whiteSpace=wrap;html=1;fillColor={fill};strokeColor=none;fontColor=#ffffff;"
            "fontSize=11;fontStyle=1;",
        )

    def terminator(self, x, y, w, h, label, fill="#C62828") -> str:
        """Hexagonal stop / terminal state."""
        return self.box(
            x, y, w, h, label,
            "shape=hexagon;perimeter=hexagonPerimeter2;whiteSpace=wrap;html=1;"
            f"fillColor={fill};strokeColor=none;fontColor=#ffffff;fontSize=11;fontStyle=1;",
        )

    # -- edges -------------------------------------------------------------
    def edge(self, source, target, label="", color="#0078D4", dashed=False,
             sx=None, sy=None, tx=None, ty=None, width=2, points=None,
             ldx=0, ldy=0, animated=False) -> str:
        """Orthogonal edge.

        sx/sy and tx/ty are draw.io exit/entry anchors in 0..1 (e.g. sx=1, sy=0.5
        leaves the right-hand mid-point). Pin them whenever an auto-routed edge
        crosses an icon. `points` is a list of (x, y) waypoints for manual routing.
        `ldx`/`ldy` nudge the label off the line.
        """
        if source not in self._vertices or target not in self._vertices:
            raise ValueError("edge source and target must reference existing vertices")
        for prefix, ax, ay in (("exit", sx, sy), ("entry", tx, ty)):
            if (ax is None) != (ay is None):
                raise ValueError(f"{prefix} anchors require both x and y")
            if ax is not None:
                for value in (ax, ay):
                    _number(value, f"{prefix} anchor", 0)
                    if value > 1:
                        raise ValueError(f"{prefix} anchor must be <= 1")
        _number(width, "edge width", 0.1)
        _number(ldx, "label offset x")
        _number(ldy, "label offset y")
        if points is not None:
            points = list(points)
            for px, py in points:
                _number(px, "waypoint x")
                _number(py, "waypoint y")
        style = (
            f"edgeStyle=orthogonalEdgeStyle;rounded=1;html=0;strokeColor={color};"
            f"strokeWidth={width};fontSize=13;fontColor={color};endArrow=block;endFill=1;"
        )
        if dashed:
            style += "dashed=1;dashPattern=6 6;"
        if animated:
            style += "flowAnimation=1;"
        if sx is not None:
            style += f"exitX={sx};exitY={sy};exitDx=0;exitDy=0;"
        if tx is not None:
            style += f"entryX={tx};entryY={ty};entryDx=0;entryDy=0;"

        cid = self.nid()
        geo = '<mxGeometry relative="1" as="geometry">'
        if points:
            geo += '<Array as="points">' + "".join(
                f'<mxPoint x="{px}" y="{py}"/>' for px, py in points
            ) + "</Array>"
        if ldx or ldy:
            geo += f'<mxPoint x="{ldx}" y="{ldy}" as="offset"/>'
        geo += "</mxGeometry>"

        self.cells.append(
            f'<mxCell id="{cid}" value="{self.esc(label)}" style="{self.esc(style)}" edge="1" parent="1" '
            f'source="{self.esc(source)}" target="{self.esc(target)}">{geo}</mxCell>'
        )
        return cid

    # -- output ------------------------------------------------------------
    def _page_xml(self) -> str:
        inner = "\n".join(self.cells)
        return (
            f'  <diagram name="{self.esc(self.name)}" id="{self.esc(self.name)}">\n'
            '    <mxGraphModel dx="1400" dy="900" grid="0" gridSize="10" guides="1" tooltips="1" '
            'connect="1" arrows="1" fold="1" page="1" pageScale="1" '
            f'pageWidth="{self.W}" pageHeight="{self.H}" math="0" shadow="0">\n'
            "      <root>\n"
            '        <mxCell id="0"/>\n'
            '        <mxCell id="1" parent="0"/>\n'
            f"{inner}\n"
            "      </root>\n    </mxGraphModel>\n  </diagram>\n"
        )

    def save(self, path: str) -> str:
        return save_diagrams([self], path)


def _validate_document(root: ET.Element) -> None:
    if root.tag != "mxfile":
        raise ValueError("document root must be mxfile")
    pages = root.findall("diagram")
    if not pages:
        raise ValueError("document must contain at least one page")
    page_ids = [page.get("id") for page in pages]
    if not all(page_ids) or len(set(page_ids)) != len(page_ids):
        raise ValueError("missing or duplicate page ids")
    for page in pages:
        model = page.find("mxGraphModel")
        if model is None or model.find("root") is None:
            raise ValueError(f"page {page.get('id')!r} requires an uncompressed mxGraphModel/root")
        for key in ("pageWidth", "pageHeight"):
            _number(float(model.get(key, "nan")), key, 1)
        cells = model.findall("root/mxCell")
        ids = [cell.get("id") for cell in cells]
        if not all(ids) or len(set(ids)) != len(ids):
            raise ValueError("missing or duplicate cell ids")
        if not {"0", "1"} <= set(ids):
            raise ValueError("page requires base cells 0 and 1")
        if model.find("root/mxCell[@id='1']").get("parent") != "0":
            raise ValueError("base cell 1 must reference parent 0")
        vertices = {cell.get("id") for cell in cells if cell.get("vertex") == "1"}
        for cell in cells:
            for key in ("parent", "source", "target"):
                if key in cell.attrib and cell.get(key) not in ids:
                    raise ValueError(f"unknown {key} reference")
            if cell.get("vertex") == "1" or cell.get("edge") == "1":
                geometry = cell.find("mxGeometry")
                if geometry is None or geometry.get("as") != "geometry":
                    raise ValueError("vertex and edge geometry requires as='geometry'")
                if cell.get("vertex") == "1":
                    for key in ("x", "y", "width", "height"):
                        minimum = 1 if key in ("width", "height") else None
                        _number(float(geometry.get(key, "nan")), key, minimum)
                if cell.get("edge") == "1":
                    if geometry.get("relative") != "1":
                        raise ValueError("edge geometry must be relative")
                    if any(cell.get(key) not in vertices for key in ("source", "target")):
                        raise ValueError("edge endpoints must reference page-local vertices")
                for element in geometry.iter():
                    for key in ("x", "y"):
                        if key in element.attrib:
                            _number(float(element.get(key)), key)
            for item in cell.get("style", "").split(";"):
                if item.startswith("image="):
                    _image_uri(item.removeprefix("image="))


def validate_file(path: str) -> ET.Element:
    """Validate an uncompressed builder-format file; this is not visual review."""
    root = ET.parse(path).getroot()
    _validate_document(root)
    return root


def save_diagrams(diagrams: list[Diagram], path: str) -> str:
    """Write new pages in order; cell IDs are scoped independently to each page."""
    diagrams = list(diagrams)
    if not diagrams or any(not isinstance(diagram, Diagram) for diagram in diagrams):
        raise ValueError("provide at least one Diagram")
    xml = '<mxfile host="app.diagrams.net">\n' + "".join(
        diagram._page_xml() for diagram in diagrams
    ) + "</mxfile>\n"
    _validate_document(ET.fromstring(xml))
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(xml)
    print(f"wrote {path} ({sum(len(diagram.cells) for diagram in diagrams)} cells)")
    return path
