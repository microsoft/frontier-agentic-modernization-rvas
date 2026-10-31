#!/usr/bin/env python3
import argparse
import json
import sys
import urllib.error
import urllib.request
from urllib.parse import quote
from typing import List, Optional, Tuple

TREE_API = "https://api.github.com/repos/jgraph/drawio/git/trees/dev?recursive=1"
PATH_PREFIX = "src/main/webapp/img/lib/azure2/"
RAW_BASE = "https://raw.githubusercontent.com/jgraph/drawio/dev/src/main/webapp/img/lib/azure2/"


def fetch_json(url: str) -> dict:
    req = urllib.request.Request(url, method="GET", headers={"Accept": "application/vnd.github+json"})
    with urllib.request.urlopen(req, timeout=60) as response:
        return json.loads(response.read().decode("utf-8"))


def check_url(url: str) -> Tuple[bool, Optional[int], Optional[str]]:
    try:
        req = urllib.request.Request(url, method="HEAD")
        with urllib.request.urlopen(req, timeout=20) as response:
            return True, response.status, None
    except (urllib.error.URLError, OSError) as exc:
        try:
            req = urllib.request.Request(url, method="GET")
            with urllib.request.urlopen(req, timeout=20) as response:
                return True, response.status, None
        except (urllib.error.URLError, OSError) as exc2:
            return False, None, str(exc2 or exc)


def extract_azure2_paths(tree_payload: dict) -> List[str]:
    if not isinstance(tree_payload, dict) or tree_payload.get("truncated"):
        raise ValueError("GitHub tree is invalid or truncated")
    items = tree_payload.get("tree")
    if not isinstance(items, list):
        raise ValueError("GitHub response has no tree array")
    results = []
    for item in items:
        if not isinstance(item, dict) or not isinstance(item.get("path"), str):
            raise ValueError("GitHub tree entry has no valid path")
        path = item.get("path", "")
        if not path.startswith(PATH_PREFIX):
            continue
        if not path.endswith(".svg"):
            continue
        rel = path[len(PATH_PREFIX):]
        results.append(rel)
    return sorted(set(results))


def filter_paths(paths: List[str], terms: List[str]) -> List[str]:
    if not terms:
        return paths
    lowered = [term.lower() for term in terms]
    filtered = []
    for path in paths:
        path_l = path.lower()
        if any(term in path_l for term in lowered):
            filtered.append(path)
    return filtered


def main() -> int:
    parser = argparse.ArgumentParser(description="Fallback search for Azure2 icons directly in jgraph/drawio GitHub repo")
    parser.add_argument("--search", nargs="*", default=[], help="Keywords to match in icon path")
    parser.add_argument("--max-results", type=int, default=50, help="Maximum results to print")
    parser.add_argument("--validate", action="store_true", help="Validate each matched icon URL")
    parser.add_argument("--raw-base", default=RAW_BASE, help="Raw base URL for validation")
    parser.add_argument("--allow-network", action="store_true", help="Explicitly authorize public GitHub requests")
    args = parser.parse_args()
    if not args.allow_network:
        parser.error("network access requires --allow-network; use bundled catalogs offline")
    if args.max_results < 1:
        parser.error("--max-results must be positive")
    if args.raw_base != RAW_BASE:
        parser.error("--raw-base must be the reviewed public GitHub URL")

    try:
        payload = fetch_json(TREE_API)
        all_paths = extract_azure2_paths(payload)
    except (OSError, ValueError, urllib.error.URLError) as exc:
        print("ERROR: unable to fetch GitHub tree: {0}".format(exc), file=sys.stderr)
        return 1

    if not all_paths:
        print("ERROR: no Azure2 icon paths found in GitHub tree", file=sys.stderr)
        return 1

    matches = filter_paths(all_paths, args.search)
    if not matches:
        joined = ", ".join(args.search) if args.search else "(none)"
        print("No matches found for search terms: {0}".format(joined))
        return 1

    limited = matches[: args.max_results]
    print("Matched {0} icons (showing {1})".format(len(matches), len(limited)))

    failed = False
    for path in limited:
        if not args.validate:
            print(path)
            continue

        url = "{0}{1}".format(args.raw_base, quote(path, safe="/"))
        ok, status, err = check_url(url)
        if ok:
            print("OK   {0}  {1}".format(status, path))
        else:
            failed = True
            print("FAIL      {0} :: {1}".format(path, err))

    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
