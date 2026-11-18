#!/usr/bin/env python3
"""Validate labs/ and generate labs.json for the web page.

  labs.py validate            check structure, frontmatter and links
  labs.py index [-o FILE]     write labs.json (default: stdout)
"""
import argparse, json, re, sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
FILE = re.compile(r"^(\d{2})-[a-z0-9]+(?:-[a-z0-9]+)*\.md$")
LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)\s]+)\)")
LAB_REQUIRED = ["id", "title", "summary", "accent", "order"]
MODULE_REQUIRED = ["title", "summary", "phase", "group"]
MODULE_SECTIONS = ["## Objective", "## Checkpoint"]
DURATION = re.compile(r"^> \*\*Duration:\*\* ~(\d+) minutes \| \*\*Phase:\*\* .+$", re.M)


def frontmatter(path):
    text = path.read_text()
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not m:
        return None, text
    return yaml.safe_load(m.group(1)) or {}, text[m.end():]


def labs():
    return sorted(p for p in ROOT.iterdir() if p.is_dir() and not p.name.startswith(("_", ".")) and (p / "lab.yaml").exists())


def check_links(md, errors):
    for m in LINK.finditer(md.read_text()):
        target = m.group(1).split("#")[0]
        if not target or re.match(r"^(https?:|mailto:)", target):
            continue
        if not (md.parent / target).resolve().exists():
            errors.append(f"{md.relative_to(ROOT.parent)}: broken link {m.group(1)}")


def load():
    errors, out = [], []
    for lab in labs():
        meta = yaml.safe_load((lab / "lab.yaml").read_text()) or {}
        for k in LAB_REQUIRED:
            if k not in meta:
                errors.append(f"{lab.name}/lab.yaml: missing '{k}'")
        if meta.get("id") != lab.name:
            errors.append(f"{lab.name}/lab.yaml: id must equal the folder name")
        if not (lab / "README.md").exists():
            errors.append(f"{lab.name}: missing README.md")
        else:
            check_links(lab / "README.md", errors)
        chs = []
        cdir = lab / "challenges"
        folders = sorted(p for p in cdir.iterdir() if p.is_file()) if cdir.is_dir() else []
        if not folders:
            errors.append(f"{lab.name}: no module files in challenges/")
        seen = set()
        for f in folders:
            m = FILE.match(f.name)
            if not m:
                errors.append(f"{lab.name}/challenges/{f.name}: file must be NN-kebab-case.md")
                continue
            n = int(m.group(1))
            if n in seen:
                errors.append(f"{lab.name}/challenges/{f.name}: duplicate number {n:02d}")
            seen.add(n)
            readme = f
            fm, body = frontmatter(readme)
            if fm is None:
                errors.append(f"{readme.relative_to(ROOT.parent)}: missing frontmatter")
                continue
            for k in MODULE_REQUIRED:
                if not fm.get(k):
                    errors.append(f"{readme.relative_to(ROOT.parent)}: frontmatter missing '{k}'")
            rel = readme.relative_to(ROOT.parent)
            for section in MODULE_SECTIONS:
                if not re.search(rf"^{section}\s*$", body, re.M):
                    errors.append(f"{rel}: missing '{section}'")
            h1 = re.search(r"^# Module (\d+): (.+)$", body, re.M)
            if not h1 or int(h1.group(1)) != n:
                errors.append(f"{rel}: first heading must be '# Module {n:02d}: <title>'")
            duration = DURATION.search(body)
            if not duration:
                errors.append(f"{rel}: missing '> **Duration:** ~N minutes | **Phase:** <phase>' line")
            if re.search(r"(?<![/\w])challenges?(?![/\w])", body, re.I):
                errors.append(f"{rel}: use 'module' or 'lab', not 'challenge'")
            check_links(readme, errors)
            chs.append({"n": n, "minutes": int(duration[1]) if duration else 0, "id": f.stem, "title": fm.get("title", ""), "summary": fm.get("summary", ""),
                        "phase": fm.get("phase", ""), "group": fm.get("group", ""),
                        "tags": fm.get("tags", []), "highlight": bool(fm.get("highlight")),
                        "file": f"labs/{lab.name}/challenges/{f.name}"})
        if folders and sorted(seen) != list(range(len(seen))):
            errors.append(f"{lab.name}: module numbers must run 00..{len(seen)-1:02d} without gaps")
        out.append({"id": meta.get("id"), "title": meta.get("title"), "summary": meta.get("summary"),
                    "accent": meta.get("accent"), "order": meta.get("order", 99), "prefix": meta.get("prefix", "MOD"),
                    "highlights": meta.get("highlights", []), "readme": f"labs/{lab.name}/README.md",
                    "modules": sorted(chs, key=lambda c: c["n"])})
    out.sort(key=lambda l: l["order"])
    return {"labs": out}, errors


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["validate", "index"])
    ap.add_argument("-o", "--output")
    a = ap.parse_args()
    data, errors = load()
    if errors:
        print("\n".join(errors), file=sys.stderr)
        sys.exit(1)
    if a.cmd == "validate":
        print(f"OK: {len(data['labs'])} labs, {sum(len(l['modules']) for l in data['labs'])} modules")
    else:
        s = json.dumps(data, indent=2, ensure_ascii=False)
        Path(a.output).write_text(s + "\n") if a.output else print(s)


if __name__ == "__main__":
    main()
