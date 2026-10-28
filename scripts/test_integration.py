import importlib.util
import json
import re
import unittest
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
PLUGIN = ROOT / "plugins/agentic-modernization"
spec = importlib.util.spec_from_file_location("supporting", ROOT / "scripts/supporting-skills.py")
supporting = importlib.util.module_from_spec(spec)
spec.loader.exec_module(supporting)


class Links(HTMLParser):
    def __init__(self, text):
        super().__init__()
        self.hrefs = []
        self.ids = []
        self.feed(text)

    def handle_starttag(self, tag, attrs):
        values = dict(attrs)
        if "id" in values:
            self.ids.append(values["id"])
        if tag == "a" and "href" in values:
            self.hrefs.append(values["href"])


class IntegrationTests(unittest.TestCase):
    def test_marketplace_resolves_complete_plugin(self):
        marketplace = json.loads((ROOT / ".github/plugin/marketplace.json").read_text())
        self.assertEqual(len(marketplace["plugins"]), 1)
        entry = marketplace["plugins"][0]
        folder = ROOT / entry["source"]
        manifest = json.loads((folder / "plugin.json").read_text())
        self.assertEqual(entry["name"], manifest["name"])
        self.assertEqual(entry["version"], manifest["version"])
        self.assertEqual(
            {path.parent.name for path in (folder / "skills").glob("*/SKILL.md")},
            {"azure-app-modernization", "azure-app-rebuild", "cloud-architecture-diagram"},
        )
        self.assertTrue((folder / "skills/cloud-architecture-diagram/scripts/drawio_builder.py").is_file())
        self.assertTrue((folder / "skills/cloud-architecture-diagram/references/REFERENCE.md").is_file())
        servers = json.loads((folder / "mcp.json").read_text())["mcpServers"]
        self.assertEqual(set(servers), {"microsoft-learn"})

    def test_generated_install_commands_match_inventory(self):
        inventory = json.loads(supporting.INVENTORY.read_text())
        self.assertEqual(supporting.OUTPUT.read_text(), supporting.render(inventory))
        names = []
        for profile in inventory["profiles"]:
            for source in profile["sources"]:
                self.assertRegex(source["revision"], r"^[a-f0-9]{40}$")
                names.extend(source["skills"])
        self.assertNotIn("cloud-architecture-diagram", names)
        self.assertNotIn("implement", names)
        self.assertEqual(len(names), len(set(names)))

    def test_imported_eval_fixtures_resolve(self):
        for eval_file in PLUGIN.glob("skills/*/evals/evals.json"):
            data = json.loads(eval_file.read_text())
            for case in data["evals"]:
                for fixture in case.get("files", []):
                    with self.subTest(evaluation=case["id"], fixture=fixture):
                        self.assertTrue((ROOT / fixture).is_file())

    def test_both_delivery_paths_and_customer_track_are_reachable_from_navigation(self):
        html = (ROOT / "web/index.html").read_text()
        primary = re.search(r'<nav\b[^>]*id="navLinks"[^>]*>(.*?)</nav>', html, re.S)[1]
        navigation = Links(primary)
        destinations = Links(html).ids
        for target in ["challenges", "rebuild-challenges", "customer-challenges"]:
            with self.subTest(destination=target):
                self.assertIn(f"#{target}", navigation.hrefs)
                self.assertIn(target, destinations)

    def test_rebuild_milestones_and_navigation(self):
        files = sorted((ROOT / "Student/rebuild").glob("Challenge-*.md"))
        self.assertEqual([path.stem for path in files], [f"Challenge-{i:02}" for i in range(9)])
        html = (ROOT / "web/index.html").read_text()
        total_minutes = 0
        for path in files:
            text = path.read_text()
            with self.subTest(file=path.name):
                for heading in [
                    "Introduction", "Prerequisites", "Description",
                    "Success Criteria", "Learning Resources",
                ]:
                    self.assertIn(f"## {heading}", text)
                self.assertGreaterEqual(text.count("- [ ]"), 4)
                self.assertNotRegex(text, r"\b(TODO|TBD|FIXME|PLACEHOLDER)\b")
                self.assertIn("```text\n", text)
                self.assertIn(f'href="{path.relative_to(ROOT)}"', html)
                self.assertIn(f"file: '{path.relative_to(ROOT)}'", html)
                minutes = int(re.search(r"\*\*Estimated Time:\*\* (\d+) minutes", text)[1])
                total_minutes += minutes
                card = re.search(
                    rf'<a\b[^>]*class="[^"]*\bchallenge-card\b[^"]*"[^>]*href="{re.escape(str(path.relative_to(ROOT)))}"[^>]*>(.*?)</a>',
                    html, re.S,
                )[1]
                self.assertIn(f"{minutes} min &middot;", card)
                index = int(path.stem.split("-")[1])
                if index:
                    self.assertIn(f"[Previous](Challenge-{index - 1:02}.md)", text)
                if index < len(files) - 1:
                    self.assertIn(f"[Next](Challenge-{index + 1:02}.md)", text)
        coach = (ROOT / "Coach/rebuild/facilitation-guide.md").read_text()
        self.assertIn(f"{total_minutes} minutes", coach)
        links = Links(html)
        self.assertEqual(len(links.ids), len(set(links.ids)))
        for href in links.hrefs:
            if href.startswith("#"):
                self.assertIn(href[1:], links.ids)
            elif href == "Student/sample-architecture.md" or href.startswith(("Student/rebuild/", "Coach/rebuild/")):
                self.assertTrue((ROOT / href).is_file())

    def test_new_guide_and_skill_relative_links_resolve(self):
        docs = [
            ROOT / "README.md", ROOT / "CONTRIBUTING.md",
            ROOT / "Student/sample-architecture.md",
            ROOT / "Student/customer/Challenge-00.md",
            ROOT / "Coach/customer/Solution-00.md",
            *(ROOT / "Student/rebuild").glob("*.md"),
            *(ROOT / "Coach/rebuild").glob("*.md"),
            *PLUGIN.glob("**/*.md"),
        ]
        for path in docs:
            text = re.sub(r"```.*?```", "", path.read_text(), flags=re.S)
            for target in re.findall(r"\[[^\]]*\]\(([^)\s]+)\)", text):
                url = urlsplit(target)
                if url.scheme or url.netloc or not url.path:
                    continue
                with self.subTest(file=str(path.relative_to(ROOT)), target=target):
                    self.assertTrue((path.parent / unquote(url.path)).resolve().exists())


if __name__ == "__main__":
    unittest.main()
