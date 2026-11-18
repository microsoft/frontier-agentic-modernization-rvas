#!/usr/bin/env python3
"""Check Markdown links in tracked files.

Default: relative links and #anchors (offline).
--external: also HEAD/GET every http(s) URL.
"""
import re
import subprocess
import sys
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)|!\[[^\]]*\]\(([^)\s]+)\)")
FENCE = re.compile(r"^\s*(```|~~~)")


def tracked_markdown():
    out = subprocess.check_output(
        ["git", "ls-files", "*.md", ":!labs/*/resources", ":!solutions/**", ":!**/node_modules/**"],
        cwd=ROOT, text=True)
    return [ROOT / p for p in out.splitlines() if (ROOT / p).is_file()]


def slug(heading):
    h = re.sub(r"[`*_]", "", heading.strip().lower())
    h = re.sub(r"[^\w\- ]", "", h)
    return h.replace(" ", "-")


def anchors(path, cache={}):
    if path not in cache:
        found, inside = set(), False
        for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
            if FENCE.match(line):
                inside = not inside
            elif not inside and (m := re.match(r"#{1,6}\s+(.*)", line)):
                found.add(slug(m.group(1)))
        cache[path] = found
    return cache[path]


def links(path):
    inside = False
    for n, line in enumerate(path.read_text(encoding="utf-8", errors="ignore").splitlines(), 1):
        if FENCE.match(line):
            inside = not inside
            continue
        if inside:
            continue
        line = re.sub(r"`[^`]*`", "", line)
        for m in LINK.finditer(line):
            yield n, (m.group(1) or m.group(2))


def check_external(url):
    req = urllib.request.Request(url, headers={"User-Agent": "link-check"})
    try:
        with urllib.request.urlopen(req, timeout=15):
            return None
    except urllib.error.HTTPError as e:
        return None if e.code in (401, 403, 429) else f"HTTP {e.code}"
    except Exception as e:
        return str(e)


def main():
    external = "--external" in sys.argv
    errors, urls = [], {}
    for f in tracked_markdown():
        rel = f.relative_to(ROOT)
        for n, target in links(f):
            if re.match(r"https?://", target):
                urls.setdefault(target, []).append(f"{rel}:{n}")
                continue
            if re.match(r"[a-z]+:", target) or target.startswith("{{"):
                continue
            base, _, frag = target.partition("#")
            dest = (f.parent / base.split("?")[0]).resolve() if base else f
            if not dest.exists():
                errors.append(f"{rel}:{n}: missing {target}")
            elif frag and dest.suffix == ".md" and frag.lower() not in anchors(dest):
                errors.append(f"{rel}:{n}: missing anchor {target}")
    if external:
        with ThreadPoolExecutor(16) as pool:
            for url, err in zip(urls, pool.map(check_external, urls)):
                if err:
                    errors.append(f"{urls[url][0]}: {url} -> {err}")
    for e in errors:
        print(e)
    print(f"{'FAIL' if errors else 'OK'}: {len(errors)} broken link(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
