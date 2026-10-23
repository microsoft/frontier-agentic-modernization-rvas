"""Synthetic offline checks; no renderer, network, or customer data."""

import base64
from contextlib import redirect_stderr, redirect_stdout
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch
from urllib.parse import unquote
import urllib.error
import xml.etree.ElementTree as ET


SKILL = Path(__file__).resolve().parents[1]
SCRIPTS = SKILL / "scripts"
ICONS = SKILL / "assets" / "az" / "i"
MICROSOFT_CATALOG = SKILL / "references" / "microsoft-icon-catalog.json"
SVG = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 10 10"><path d="M0 0h10v10z"/></svg>'
PNG = base64.b64decode(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/iZk9HQAAAABJRU5ErkJggg=="
)


def load_helper(name):
    spec = importlib.util.spec_from_file_location("cloud_diagram_" + name, SCRIPTS / (name + ".py"))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


builder = load_helper("drawio_builder")
trim_png = load_helper("trim_png")
azure = load_helper("search_azure2_icons_github")
aws = load_helper("search_aws4_icons_github")
HAS_PILLOW = importlib.util.find_spec("PIL") is not None


class OfflineCase(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.out = Path(self.temp.name)
        deny = patch("urllib.request.urlopen", side_effect=AssertionError("network forbidden in offline tests"))
        deny.start()
        self.addCleanup(deny.stop)

    def save(self, diagram, filename="example.drawio"):
        path = self.out / filename
        with redirect_stdout(io.StringIO()):
            diagram.save(path)
        return ET.parse(path).getroot()

    def assert_structure(self, root):
        self.assertEqual(root.tag, "mxfile")
        self.assertIsNotNone(root.find("./diagram/mxGraphModel/root"))
        cells = root.findall(".//mxCell")
        ids = {cell.get("id") for cell in cells}
        self.assertEqual(len(ids), len(cells))
        self.assertIn("0", ids)
        self.assertIn("1", ids)
        for cell in cells:
            for key in ("parent", "source", "target"):
                if key in cell.attrib:
                    self.assertIn(cell.get(key), ids)
            if cell.get("vertex") == "1" or cell.get("edge") == "1":
                self.assertEqual(cell.find("mxGeometry").get("as"), "geometry")


class BuilderTests(OfflineCase):
    def test_all_shape_helpers_and_edge_geometry(self):
        d = builder.Diagram("Synthetic", 1600, 1000)
        d.banner(0, 0, 1600, 60, "Title")
        d.container(20, 100, 700, 700, "Cloud", "#fff", "#333")
        d.sub(40, 180, 600, 300, "Logical group", "#fff", "#333")
        d.note(800, 100, 300, 90, "A note")
        icon = d.icon(70, 220, "Icon", builder.inline_svg_data_uri(SVG))
        card = d.card(300, 220, 200, 100, "Card", "Subtitle", badge_uri=builder.inline_svg_data_uri(SVG))
        d.stage(800, 300, 200, 120, "Build", number=1)
        d.decision(1100, 300, "Pass?")
        d.terminator(1100, 500, 150, 70, "Stop")
        d.box(50, 600, 200, 70, "Box", "rounded=1;")
        edge = d.edge(icon, card, "Request", dashed=True, animated=True,
                      sx=1, sy=0.5, tx=0, ty=0.5, points=[(200, 250)],
                      ldx=4, ldy=-8)
        root = self.save(d)
        self.assert_structure(root)
        model = root.find("./diagram/mxGraphModel")
        self.assertEqual((model.get("pageWidth"), model.get("pageHeight")), ("1600", "1000"))
        self.assertEqual(len(root.findall(".//mxCell")), 15)
        connector = root.find(f".//mxCell[@id='{edge}']")
        self.assertIn("flowAnimation=1", connector.get("style"))
        self.assertIn("exitY=0.5", connector.get("style"))
        geometry = connector.find("mxGeometry")
        self.assertEqual(geometry.get("relative"), "1")
        self.assertEqual(geometry.find("Array/mxPoint").attrib, {"x": "200", "y": "250"})
        self.assertEqual(geometry.find("mxPoint").attrib, {"x": "4", "y": "-8", "as": "offset"})

    def test_escaping_plain_labels_styles_ids_and_references(self):
        text = 'A & B <literal> "quoted"\nnext'
        d = builder.Diagram(text, 500, 300)
        a = d.raw('a"&', text, 'html=1;custom="&<>";', 10, 10, 100, 60)
        b = d.card(200, 10, 100, 60, text)
        d.edge(a, b, text, color='"&')
        root = self.save(d)
        self.assert_structure(root)
        self.assertEqual(root.find("diagram").get("name"), text)
        vertices = root.findall(".//mxCell[@vertex='1']")
        self.assertEqual(vertices[0].get("id"), 'a"&')
        for vertex in vertices:
            self.assertEqual(vertex.get("value"), text)
            self.assertIn("html=0", vertex.get("style"))
        self.assertIn('custom="&<>";', vertices[0].get("style"))
        edge = root.find(".//mxCell[@edge='1']")
        self.assertEqual(edge.get("source"), a)
        self.assertEqual(edge.get("value"), text)

    def test_generation_is_deterministic(self):
        d = builder.Diagram("Stable", 500, 300)
        d.card(10, 10, 100, 70, "Synthetic")
        self.save(d, "first.drawio")
        self.save(d, "second.drawio")
        self.assertEqual((self.out / "first.drawio").read_bytes(), (self.out / "second.drawio").read_bytes())

    def test_four_page_document_with_page_local_ids_and_embedded_icons(self):
        names = ["Context", "Components", "AI and data flow", "Deployment"]
        pages = []
        for name in names:
            d = builder.Diagram(name, 1000, 600)
            client = d.card(100, 200, 120, 60, "Synthetic client")
            api = d.icon(400, 200, "Azure API Management",
                         builder.svg_data_uri(builder.find_icon(ICONS, "API-Management-Services")))
            d.edge(client, api, "Synthetic request")
            pages.append(d)
        output = self.out / "solution.drawio"
        with redirect_stdout(io.StringIO()):
            builder.save_diagrams(pages, output)
        root = builder.validate_file(output)
        self.assertEqual([page.get("name") for page in root.findall("diagram")], names)
        for page in root.findall("diagram"):
            single = ET.Element("mxfile")
            single.append(page)
            self.assert_structure(single)
            self.assertEqual(page.find(".//mxCell[@vertex='1']").get("id"), "n11")
            image = page.find(".//mxCell[@id='n12']").get("style").split("image=", 1)[1].split(";", 1)[0]
            self.assertTrue(image.startswith("data:image/svg+xml,"))
        first = output.read_bytes()
        with redirect_stdout(io.StringIO()):
            builder.save_diagrams(pages, output)
        self.assertEqual(first, output.read_bytes())

    def test_invalid_page_sets_preserve_existing_output(self):
        output = self.out / "existing.drawio"
        output.write_text("existing hand edits")
        for pages in ([], [None], [builder.Diagram("Same", 500, 300),
                                  builder.Diagram("Same", 500, 300)]):
            with self.subTest(pages=pages), self.assertRaises(ValueError):
                builder.save_diagrams(pages, output)
            self.assertEqual(output.read_text(), "existing hand edits")

    def test_saved_file_validation_rejects_invalid_structure_and_images(self):
        d = builder.Diagram("Validation", 500, 300)
        a = d.card(0, 0, 100, 60, "A")
        b = d.card(200, 0, 100, 60, "B")
        d.edge(a, b)
        original = ET.tostring(self.save(d))
        mutations = [
            lambda root: root.find("diagram").set("id", ""),
            lambda root: root.find(".//mxGraphModel").set("pageWidth", "nan"),
            lambda root: root.find(".//mxCell[@id='0']").set("id", "missing-base"),
            lambda root: root.find(".//mxCell[@id='1']").set("parent", "1"),
            lambda root: root.find(".//mxCell[@vertex='1']").set("id", "1"),
            lambda root: root.find(".//mxCell[@vertex='1']").set("parent", "absent"),
            lambda root: root.find(".//mxCell[@vertex='1']/mxGeometry").set("as", "wrong"),
            lambda root: root.find(".//mxCell[@vertex='1']/mxGeometry").set("width", "0"),
            lambda root: root.find(".//mxCell[@edge='1']").set("source", "0"),
            lambda root: root.find(".//mxCell[@edge='1']").set("target", "another-page-node"),
            lambda root: root.find(".//mxCell[@edge='1']/mxGeometry").set("relative", "0"),
            lambda root: root.find(".//mxCell[@vertex='1']").set("style", "image=https://example.invalid/icon.svg;"),
        ]
        for index, mutate in enumerate(mutations):
            root = ET.fromstring(original)
            mutate(root)
            output = self.out / f"invalid-{index}.drawio"
            ET.ElementTree(root).write(output)
            with self.subTest(index=index), self.assertRaises(ValueError):
                builder.validate_file(output)
        for xml in ("<root/>", "<mxfile/>", '<mxfile><diagram id="compressed">encoded</diagram></mxfile>'):
            output = self.out / "invalid.drawio"
            output.write_text(xml)
            with self.subTest(xml=xml), self.assertRaises(ValueError):
                builder.validate_file(output)

    def test_edge_cannot_reference_a_vertex_on_another_page(self):
        first = builder.Diagram("First", 500, 300)
        first.raw("first-node", "A", "", 0, 0, 100, 60)
        second = builder.Diagram("Second", 500, 300)
        second.raw("second-node", "B", "", 0, 0, 100, 60)
        first.cells.append(
            '<mxCell id="cross-page" edge="1" parent="1" source="first-node" target="second-node">'
            '<mxGeometry relative="1" as="geometry"/></mxCell>'
        )
        output = self.out / "cross-page.drawio"
        with self.assertRaisesRegex(ValueError, "unknown target reference"):
            builder.save_diagrams([first, second], output)
        self.assertFalse(output.exists())

    def test_invalid_diagram_inputs(self):
        for args in (("", 1, 1), ("x", 0, 1), ("x", 1, -1), ("x", float("nan"), 1),
                     ("x", "500", 100), ("x", True, 100)):
            with self.subTest(args=args), self.assertRaises(ValueError):
                builder.Diagram(*args)

    def test_invalid_geometry_and_duplicate_ids(self):
        d = builder.Diagram("Invalid", 500, 300)
        for dims in ((0, 0, 0, 1), (0, 0, 1, -1), (float("inf"), 0, 1, 1)):
            with self.subTest(dims=dims), self.assertRaises(ValueError):
                d.box(*dims, "x", "")
        d.raw("custom", "x", "", 0, 0, 10, 10)
        for cid in ("custom", "0", "1", ""):
            with self.subTest(cid=cid), self.assertRaises(ValueError):
                d.raw(cid, "x", "", 0, 0, 10, 10)

    def test_edge_references_and_anchors_fail_explicitly(self):
        d = builder.Diagram("Invalid edge", 500, 300)
        a = d.card(0, 0, 100, 60, "A")
        b = d.card(200, 0, 100, 60, "B")
        with self.assertRaisesRegex(ValueError, "existing vertices"):
            d.edge(a, "missing")
        for params in ({"sx": 0.5}, {"ty": 0}, {"sx": 2, "sy": 0},
                       {"tx": -1, "ty": 0}, {"points": [(1, float("nan"))]},
                       {"width": 0}, {"ldx": float("inf")}):
            with self.subTest(params=params), self.assertRaises(ValueError):
                d.edge(a, b, **params)

    def test_bad_xml_fails_before_creating_output(self):
        d = builder.Diagram("Invalid", 500, 300)
        d.card(0, 0, 100, 60, "illegal control \x00")
        target = self.out / "absent" / "bad.drawio"
        with self.assertRaises(ET.ParseError):
            d.save(target)
        self.assertFalse(target.exists())

    def test_output_errors_are_not_swallowed(self):
        d = builder.Diagram("IO", 500, 300)
        with self.assertRaises(OSError):
            d.save(self.out)

    def test_missing_or_empty_icon_search(self):
        with self.assertRaises(FileNotFoundError):
            builder.find_icon(self.out / "missing", "x")
        with self.assertRaises(FileNotFoundError):
            builder.find_icon(ICONS, "not-a-real-service-synthetic")
        with self.assertRaises(ValueError):
            builder.find_icon(ICONS, "")

    def test_icon_search_sorted_case_insensitive(self):
        (self.out / "b-Example.SVG").write_text(SVG)
        (self.out / "a-example.svg").write_text(SVG)
        found = builder.find_icon(self.out, "EXAMPLE")
        self.assertEqual(Path(found).name, "a-example.svg")

    def test_exact_microsoft_icon_catalog_resolution(self):
        catalog = json.loads(MICROSOFT_CATALOG.read_text())
        self.assertEqual(catalog["schema_version"], 1)
        icons = catalog["icons"]
        self.assertEqual(len(icons), 32)
        self.assertEqual(
            {family: sum(icon_id.startswith(family + ":") for icon_id in icons)
             for family in ("fabric", "power-platform", "entra")},
            {"fabric": 20, "power-platform": 8, "entra": 4},
        )
        self.assertEqual(list(icons), sorted(icons))
        for icon_id, entry in icons.items():
            with self.subTest(icon_id=icon_id):
                family = icon_id.split(":", 1)[0]
                self.assertEqual(entry["source_family"], family)
                self.assertTrue(entry["path"].startswith(f"assets/{family}/i/"))
                path = Path(builder.resolve_icon(SKILL, icon_id))
                self.assertEqual(path, SKILL / entry["path"])
                self.assertEqual(hashlib.sha256(path.read_bytes()).hexdigest(), entry["sha256"])
                uri = builder.svg_data_uri(path)
                self.assertEqual(unquote(uri.split(",", 1)[1]).encode(), path.read_bytes())

    def test_exact_icon_resolution_fails_explicitly(self):
        for icon_id in ("", "lakehouse", "Fabric:lakehouse", "fabric:", ":lakehouse", None):
            with self.subTest(icon_id=icon_id), self.assertRaises(ValueError):
                builder.resolve_icon(SKILL, icon_id)
        with self.assertRaises(FileNotFoundError):
            builder.resolve_icon(SKILL, "fabric:not-a-real-icon")
        with self.assertRaises(FileNotFoundError):
            builder.resolve_icon(self.out, "fabric:lakehouse")

        references = self.out / "references"
        asset = self.out / "assets" / "fabric" / "i" / "lakehouse.svg"
        references.mkdir()
        asset.parent.mkdir(parents=True)
        asset.write_text(SVG)
        bad = {
            "schema_version": 1,
            "icons": {
                "fabric:lakehouse": {
                    "path": "assets/fabric/i/lakehouse.svg",
                    "sha256": "0" * 64,
                }
            },
        }
        (references / "microsoft-icon-catalog.json").write_text(json.dumps(bad))
        with self.assertRaisesRegex(ValueError, "hash mismatch"):
            builder.resolve_icon(self.out, "fabric:lakehouse")

    def test_svg_and_png_embed_standalone(self):
        svg_path = self.out / "synthetic.svg"
        png_path = self.out / "synthetic.png"
        svg_path.write_text(SVG)
        png_path.write_bytes(PNG)
        d = builder.Diagram("Images", 500, 300)
        d.icon(20, 20, "SVG", builder.svg_data_uri(svg_path))
        d.icon(200, 20, "PNG", builder.png_data_uri(png_path))
        root = self.save(d)
        self.assert_structure(root)
        images = [cell.get("style").split("image=", 1)[1].split(";", 1)[0]
                  for cell in root.findall(".//mxCell[@vertex='1']")]
        self.assertEqual(unquote(images[0].split(",", 1)[1]), SVG)
        self.assertEqual(base64.b64decode(images[1].split(",", 1)[1]), PNG)
        svg_path.unlink()
        png_path.unlink()
        self.assertNotIn(str(self.out), (self.out / "example.drawio").read_text())
        ET.fromstring(unquote(images[0].split(",", 1)[1]))

    def test_missing_and_invalid_images_fail(self):
        with self.assertRaises(FileNotFoundError):
            builder.svg_data_uri(self.out / "missing.svg")
        with self.assertRaises(FileNotFoundError):
            builder.png_data_uri(self.out / "missing.png")
        path = self.out / "not.png"
        path.write_text("not a png")
        with self.assertRaises(ValueError):
            builder.png_data_uri(path)
        for svg in ("not xml", "<html/>", '<svg><script>alert(1)</script></svg>',
                    '<svg onload="bad"/>', '<svg><image href="https://example.invalid/a"/></svg>',
                    '<svg><style>@import "https://example.invalid";</style></svg>',
                    '<svg><path fill="url(https://example.invalid/a)"/></svg>',
                    '<!DOCTYPE svg [<!ENTITY secret "x">]><svg/>'):
            with self.subTest(svg=svg), self.assertRaises((ValueError, ET.ParseError)):
                builder.inline_svg_data_uri(svg)
        d = builder.Diagram("URI errors", 500, 300)
        for uri in ("file:///tmp/x.svg", "https://example.invalid/a.svg",
                    "data:image/svg+xml;base64,YQ==", "img/lib/azure2/a.svg",
                    "data:image/png,", "data:image/svg+xml,", "data:image/png,@@@"):
            with self.subTest(uri=uri), self.assertRaises((ValueError, ET.ParseError)):
                d.icon(0, 0, "Invalid", uri)

    def test_truncated_and_corrupt_png_rejected(self):
        for data in (PNG[:16], PNG[:-12], PNG[:40] + b"bad" + PNG[43:]):
            path = self.out / "bad.png"
            path.write_bytes(data)
            with self.subTest(data=data), self.assertRaises(ValueError):
                builder.png_data_uri(path)

    def test_every_bundled_svg_embeds_unchanged(self):
        paths = list(ICONS.rglob("*.svg"))
        self.assertEqual(len(paths), 714)
        for path in paths:
            with self.subTest(icon=path.name):
                uri = builder.svg_data_uri(path)
                self.assertNotIn(";", uri)
                self.assertEqual(unquote(uri.split(",", 1)[1]).encode(), path.read_bytes())

    def test_topology_reference_snippets_generate_valid_artifacts(self):
        text = (SKILL / "references" / "topology-patterns.md").read_text()
        snippets = re.findall(r"```python\n(.*?)```", text, re.S)
        self.assertEqual(len(snippets), 2)
        for index, snippet in enumerate(snippets):
            scope = {"Diagram": builder.Diagram}
            exec(compile(snippet, "synthetic-reference-example", "exec"), scope)
            root = self.save(scope["d"], f"topology-{index}.drawio")
            self.assert_structure(root)
            self.assertNotIn("image=", ET.tostring(root, encoding="unicode"))

    def test_standalone_xml_reference(self):
        text = (SKILL / "references" / "standalone-file-requirements.md").read_text()
        snippet = re.search(r"```xml\n(.*?)```", text, re.S).group(1)
        self.assert_structure(ET.fromstring(snippet))

    def test_copied_skill_runs_from_unrelated_cwd(self):
        installed = self.out / "installed plugin" / "skills" / "cloud-architecture-diagram"
        shutil.copytree(SKILL, installed, ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
        cwd = self.out / "unrelated project"
        cwd.mkdir()
        snippet = re.search(r"```python\n(.*?)```", (installed / "SKILL.md").read_text(), re.S).group(1)
        generator = cwd / "synthetic_generator.py"
        generator.write_text(snippet)
        output = cwd / "artifacts" / "architecture.drawio"
        result = subprocess.run(
            [sys.executable, "-B", "-S", str(generator), str(installed), str(output)],
            cwd=cwd, capture_output=True, text=True, timeout=30,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        root = ET.parse(output).getroot()
        self.assert_structure(root)
        self.assertEqual(len(root.findall(".//mxCell[@vertex='1']")), 3)
        self.assertEqual(len(root.findall(".//mxCell[@edge='1']")), 2)
        for cell in root.findall(".//mxCell[@vertex='1']"):
            uri = cell.get("style").split("image=", 1)[1].split(";", 1)[0]
            self.assertTrue(uri.startswith("data:image/svg+xml,"))
            ET.fromstring(unquote(uri.split(",", 1)[1]))
        self.assertNotIn(str(installed), output.read_text())
        self.assertFalse(list(installed.rglob("*.drawio")))
        self.assertFalse(list(installed.rglob("__pycache__")))


class RefreshTests(OfflineCase):
    def invoke(self, module, args):
        with patch.object(sys, "argv", [module.__name__, *args]), \
                redirect_stdout(io.StringIO()) as stdout, redirect_stderr(io.StringIO()) as stderr:
            status = module.main()
        return status, stdout.getvalue(), stderr.getvalue()

    def test_refresh_requires_explicit_network_opt_in(self):
        for module in (azure, aws):
            with self.subTest(module=module.__name__), redirect_stderr(io.StringIO()), \
                    self.assertRaises(SystemExit) as result:
                self.invoke(module, [])
            self.assertEqual(result.exception.code, 2)

    def test_invalid_limits_rejected_before_network(self):
        for module in (azure, aws):
            for limit in ("0", "-1"):
                with self.subTest(module=module.__name__, limit=limit), \
                        self.assertRaises(SystemExit) as result:
                    self.invoke(module, ["--allow-network", "--max-results", limit])
                self.assertEqual(result.exception.code, 2)

    def test_azure_extract_filter_and_sort(self):
        payload = {"tree": [{"path": azure.PATH_PREFIX + "Compute/VM.svg"},
                            {"path": "unrelated.svg"},
                            {"path": azure.PATH_PREFIX + "Compute/VM.svg"},
                            {"path": azure.PATH_PREFIX + "Network/Gateway.svg"}]}
        paths = azure.extract_azure2_paths(payload)
        self.assertEqual(paths, ["Compute/VM.svg", "Network/Gateway.svg"])
        self.assertEqual(azure.filter_paths(paths, ["gateway"]), ["Network/Gateway.svg"])
        self.assertEqual(azure.filter_paths(paths, []), paths)

    def test_azure_invalid_and_truncated_tree_rejected(self):
        for payload in ([], {}, {"tree": [], "truncated": True}, {"tree": [None]}, {"tree": [{"path": 3}]}):
            with self.subTest(payload=payload), self.assertRaises(ValueError):
                azure.extract_azure2_paths(payload)

    def test_azure_missing_results_and_fetch_failures_nonzero(self):
        for payload in ({"tree": []}, {"tree": [{"path": azure.PATH_PREFIX + "Compute/VM.svg"}]},
                        {"tree": [], "truncated": True}):
            with patch.object(azure, "fetch_json", return_value=payload):
                result = self.invoke(azure, ["--allow-network", "--search", "absent"])
            self.assertEqual(result[0], 1)
        with patch.object(azure, "fetch_json", side_effect=urllib.error.URLError("offline fixture")):
            status, _, error = self.invoke(azure, ["--allow-network"])
        self.assertEqual(status, 1)
        self.assertIn("ERROR", error)

    def test_azure_validation_failure_returns_nonzero_and_encodes_url(self):
        payload = {"tree": [{"path": azure.PATH_PREFIX + "AI + ML/Icon Name.svg"}]}
        with patch.object(azure, "fetch_json", return_value=payload), \
                patch.object(azure, "check_url", return_value=(False, None, "not found")) as check:
            status, output, _ = self.invoke(azure, ["--allow-network", "--validate"])
        self.assertEqual(status, 1)
        self.assertIn("FAIL", output)
        self.assertEqual(check.call_args.args[0], azure.RAW_BASE + "AI%20%2B%20ML/Icon%20Name.svg")

    def test_azure_nonvalidation_search(self):
        payload = {"tree": [{"path": azure.PATH_PREFIX + "Compute/VM.svg"}]}
        with patch.object(azure, "fetch_json", return_value=payload):
            status, output, _ = self.invoke(azure, ["--allow-network", "--search", "vm"])
        self.assertEqual(status, 0)
        self.assertIn("Compute/VM.svg", output)

    def test_azure_rejects_arbitrary_validation_host(self):
        with self.assertRaises(SystemExit) as result:
            self.invoke(azure, ["--allow-network", "--raw-base", "https://example.invalid/"])
        self.assertEqual(result.exception.code, 2)

    def test_azure_head_falls_back_to_get_with_reported_failure(self):
        with patch("urllib.request.urlopen", side_effect=urllib.error.URLError("synthetic failure")) as request:
            ok, status, error = azure.check_url(azure.RAW_BASE + "missing.svg")
        self.assertFalse(ok)
        self.assertIsNone(status)
        self.assertIn("synthetic failure", error)
        self.assertEqual([call.args[0].method for call in request.call_args_list], ["HEAD", "GET"])

    def test_aws_xml_parsing_filtering_and_styles(self):
        xml = """<shapes name="mxgraph.aws4"><shape name='lambda'/>
                 <shape name="API Gateway"/><shape name="lambda"/></shapes>"""
        names = aws.extract_shape_names(xml)
        self.assertEqual(names, ["API Gateway", "lambda"])
        self.assertEqual(aws.filter_names(names, ["LAMBDA"]), ["lambda"])
        self.assertEqual(aws.name_to_style(names[0]), "shape=mxgraph.aws4.API_Gateway")
        with patch.object(aws, "fetch_stencil", return_value=xml):
            status, output, _ = self.invoke(aws, ["--allow-network", "--search", "lambda", "--verbose"])
        self.assertEqual(status, 0)
        self.assertIn("shape=mxgraph.aws4.lambda", output)

    def test_aws_invalid_xml_or_empty_results_fail(self):
        for xml in ("broken", "<shapes/>", '<shapes name="mxgraph.aws4"><shape/></shapes>',
                    '<shapes name="mxgraph.aws4"><shape name="a;bad"/></shapes>',
                    '<shapes name="mxgraph.aws4"/>'):
            with self.subTest(xml=xml), patch.object(aws, "fetch_stencil", return_value=xml):
                status, _, error = self.invoke(aws, ["--allow-network"])
                self.assertEqual(status, 1)
                self.assertIn("ERROR", error)

    def test_aws_fetch_failure_or_no_matches_fail(self):
        with patch.object(aws, "fetch_stencil", side_effect=urllib.error.URLError("synthetic failure")):
            status, _, error = self.invoke(aws, ["--allow-network"])
        self.assertEqual(status, 1)
        self.assertIn("synthetic failure", error)
        with patch.object(aws, "fetch_stencil", return_value='<shapes name="mxgraph.aws4"><shape name="lambda"/></shapes>'):
            status, output, _ = self.invoke(aws, ["--allow-network", "--search", "missing"])
        self.assertEqual(status, 1)
        self.assertIn("No matches", output)


class TrimCliTests(OfflineCase):
    def invoke(self, *args, no_site=False):
        return subprocess.run(
            [sys.executable, "-B", *(["-S"] if no_site else []), str(SCRIPTS / "trim_png.py"), *args],
            cwd=self.out, capture_output=True, text=True, timeout=30,
        )

    def test_missing_pillow_reports_prerequisite(self):
        image = self.out / "synthetic.png"
        image.write_bytes(PNG)
        result = self.invoke(str(image), no_site=True)
        self.assertEqual(result.returncode, 1)
        self.assertIn("Pillow is required", result.stderr)
        self.assertEqual(image.read_bytes(), PNG)

    def test_invalid_cli_options(self):
        for args in (("--pad", "-1"), ("--bg", "x,y,z"), ("--bg", "1,2"),
                     ("--bg", "256,0,0")):
            with self.subTest(args=args):
                result = self.invoke("missing.png", *args)
                self.assertEqual(result.returncode, 2)
                self.assertIn("error:", result.stderr)

    @unittest.skipUnless(HAS_PILLOW, "optional Pillow is not installed")
    def test_missing_file_reported_nonzero(self):
        result = self.invoke("missing.png")
        self.assertEqual(result.returncode, 1)
        self.assertIn("ERROR:", result.stderr)


@unittest.skipUnless(HAS_PILLOW, "optional Pillow is not installed")
class TrimImageTests(OfflineCase):
    def test_embedded_png_payload_decodes(self):
        from PIL import Image
        path = self.out / "fixture.png"
        path.write_bytes(PNG)
        uri = builder.png_data_uri(path)
        with Image.open(io.BytesIO(base64.b64decode(uri.split(",", 1)[1]))) as image:
            image.load()
            self.assertEqual(image.size, (1, 1))

    def test_trim_exact_size_margin_and_idempotence(self):
        from PIL import Image
        image = Image.new("RGB", (100, 80), "white")
        image.paste((255, 0, 0), (20, 30, 40, 50))
        path = self.out / "synthetic.png"
        image.save(path)
        with redirect_stdout(io.StringIO()):
            self.assertTrue(trim_png.trim(path, pad=5))
        with Image.open(path) as output:
            self.assertEqual(output.size, (30, 30))
            self.assertEqual(output.getpixel((4, 4)), (255, 255, 255))
            self.assertEqual(output.getpixel((5, 5)), (255, 0, 0))
        first = path.read_bytes()
        with redirect_stdout(io.StringIO()):
            trim_png.trim(path, pad=5)
        self.assertEqual(first, path.read_bytes())

    def test_transparent_pixels_composited_on_background(self):
        from PIL import Image
        image = Image.new("RGBA", (40, 40), (0, 0, 0, 0))
        image.paste((255, 0, 0, 255), (10, 10, 20, 20))
        path = self.out / "transparent.png"
        image.save(path)
        with redirect_stdout(io.StringIO()):
            trim_png.trim(path, pad=2, bg=(240, 240, 240))
        with Image.open(path) as output:
            self.assertEqual(output.size, (14, 14))
            self.assertEqual(output.getpixel((0, 0)), (240, 240, 240))
            self.assertEqual(output.getpixel((2, 2)), (255, 0, 0))

    def test_blank_invalid_or_non_png_input_fails_without_rewrite(self):
        from PIL import Image
        blank = self.out / "blank.png"
        Image.new("RGB", (10, 10), "white").save(blank)
        original = blank.read_bytes()
        with self.assertRaisesRegex(ValueError, "entirely background"):
            trim_png.trim(blank)
        self.assertEqual(blank.read_bytes(), original)
        invalid = self.out / "invalid.png"
        invalid.write_text("bad")
        with self.assertRaises(OSError):
            trim_png.trim(invalid)
        jpeg = self.out / "jpeg.png"
        Image.new("RGB", (10, 10), "red").save(jpeg, format="JPEG")
        with self.assertRaisesRegex(ValueError, "not a PNG"):
            trim_png.trim(jpeg)

    def test_invalid_function_options(self):
        for kwargs in ({"pad": -1}, {"pad": 1.5}, {"bg": (1, 2)},
                       {"bg": (0, 0, 256)}, {"bg": (True, 0, 0)}):
            with self.subTest(kwargs=kwargs), self.assertRaises(ValueError):
                trim_png.trim("unused.png", **kwargs)


class PackageTests(OfflineCase):
    def test_source_fingerprint_and_preserved_assets(self):
        record = json.loads((SKILL / "source-snapshot.json").read_text())
        files = record["files"]
        self.assertEqual(len(files), 725)
        self.assertEqual([entry["path"] for entry in files], sorted(entry["path"] for entry in files))
        manifest = "".join(entry["sha256"] + "  " + entry["path"] + "\n" for entry in files)
        self.assertEqual(hashlib.sha256(manifest.encode()).hexdigest(), record["snapshot_sha256"])
        for entry in files:
            if entry["path"].startswith("assets/") or entry["path"].endswith("-catalog.txt"):
                actual = hashlib.sha256((SKILL / entry["path"]).read_bytes()).hexdigest()
                self.assertEqual(actual, entry["sha256"], entry["path"])

    def test_catalog_counts_and_local_azure_paths(self):
        azure_lines = (SKILL / "references" / "azure2-complete-catalog.txt").read_text().splitlines()[1:]
        aws_lines = (SKILL / "references" / "aws4-complete-catalog.txt").read_text().splitlines()[1:]
        self.assertEqual(len(azure_lines), 714)
        self.assertTrue(all((ICONS / line).is_file() for line in azure_lines))
        self.assertLessEqual(max(len(line) for line in azure_lines), 70)
        self.assertTrue(all("icon-service-" not in line for line in azure_lines))
        self.assertEqual(len(aws_lines), 1037)
        self.assertTrue(all(line.startswith("shape=mxgraph.aws4.") for line in aws_lines))

    def test_microsoft_catalog_sources_and_notices(self):
        catalog = json.loads(MICROSOFT_CATALOG.read_text())
        self.assertEqual(catalog["retrieved"], "2026-10-07")
        self.assertEqual(set(catalog["sources"]), {"fabric", "power-platform", "entra"})
        for family, source in catalog["sources"].items():
            with self.subTest(family=family):
                self.assertRegex(source["archive_sha256"], r"^[0-9a-f]{64}$")
                self.assertTrue(source["source"].startswith("https://"))
                self.assertTrue(source["terms_source"].startswith("https://learn.microsoft.com/"))
        reference = (SKILL / "references" / "REFERENCE.md").read_text()
        self.assertIn("#### Fabric MIT license", reference)
        self.assertIn(
            "The above copyright notice and this permission notice shall be included",
            reference,
        )
        for path in (
            SKILL / "assets" / "az" / "faq.pdf",
            SKILL / "assets" / "az" / "terms.pdf",
            SKILL / "assets" / "fabric" / "LICENSE.txt",
            SKILL / "assets" / "power-platform" / "faq.pdf",
            SKILL / "assets" / "power-platform" / "terms.pdf",
            SKILL / "assets" / "entra" / "terms.docx",
            SKILL / "assets" / "entra" / "branding-playbook.pptx",
        ):
            self.assertFalse(path.exists(), path)

    def test_evaluations_have_required_shape(self):
        data = json.loads((SKILL / "evals" / "evals.json").read_text())
        self.assertEqual(data["skill_name"], SKILL.name)
        cases = data["evals"]
        self.assertGreaterEqual(len(cases), 6)
        self.assertEqual(len({case["id"] for case in cases}), len(cases))
        for case in cases:
            self.assertTrue({"id", "prompt", "expected_output", "files", "expectations"} <= case.keys())
            self.assertTrue(case["prompt"] and case["expected_output"])
            self.assertEqual(case["files"], [])
            self.assertTrue(all(isinstance(item, str) and item for item in case["expectations"]))

    def test_skill_contract_and_no_machine_paths(self):
        text = (SKILL / "SKILL.md").read_text()
        self.assertLess(len(text.splitlines()), 500)
        self.assertIn("name: cloud-architecture-diagram", text)
        credit = "Adapted by Paolo Montagna from original work by Thomas Thornton."
        self.assertIn(credit, text)
        self.assertIn(credit, (SKILL / "references" / "REFERENCE.md").read_text())
        for path in list(SKILL.rglob("*.md")) + list(SCRIPTS.glob("*.py")):
            content = path.read_text()
            self.assertNotIn(".github/skills/", content, path)
            self.assertNotIn("/home/marco/", content, path)
        self.assertFalse((SKILL / "mcp.json").exists())


if __name__ == "__main__":
    unittest.main()
