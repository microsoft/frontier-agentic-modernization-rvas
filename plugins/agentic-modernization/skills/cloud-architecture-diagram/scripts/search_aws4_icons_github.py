#!/usr/bin/env python3
"""
Search for AWS4 stencil shape names in the jgraph/drawio GitHub repository.

AWS4 icons in draw.io are stencil-based (not individual SVG files).
They are packed in a single XML file and referenced in diagrams as:
    shape=mxgraph.aws4.<name_with_underscores>

Usage:
  # Write a refresh candidate outside the installed skill, for separate review:
  python3 search_aws4_icons_github.py --allow-network --max-results 9999 > /approved/output/aws4-candidate.txt

  # Search by keyword (prints matching shape= style strings):
  python3 search_aws4_icons_github.py --allow-network --search lambda ec2

  # Preview category breakdowns:
  python3 search_aws4_icons_github.py --allow-network --search lambda --verbose
"""

import argparse
import sys
import urllib.error
import urllib.request
import xml.etree.ElementTree as ET
from typing import List

STENCIL_URL = (
    "https://raw.githubusercontent.com/jgraph/drawio/dev/"
    "src/main/webapp/stencils/aws4.xml"
)
SHAPE_PREFIX = "mxgraph.aws4"


def fetch_stencil(url: str) -> str:
    req = urllib.request.Request(url, method="GET")
    with urllib.request.urlopen(req, timeout=120) as response:
        return response.read().decode("utf-8")


def extract_shape_names(xml_content: str) -> List[str]:
    """Extract all shape names from the AWS4 stencil XML."""
    root = ET.fromstring(xml_content)
    if root.tag != "shapes" or root.get("name") != SHAPE_PREFIX:
        raise ValueError("unexpected AWS4 stencil root")
    names = []
    for shape in root.findall("shape"):
        name = shape.get("name")
        if not name or any(char in name for char in ";=\r\n"):
            raise ValueError("missing or invalid AWS4 shape name")
        names.append(name)
    return sorted(set(names))


def name_to_style(name: str) -> str:
    """Convert a raw shape name to a draw.io style string."""
    # Shape names can contain spaces; draw.io accepts them as-is in the style.
    # Conventionally most tools replace spaces with underscores.
    safe = name.replace(" ", "_")
    return "shape={prefix}.{safe}".format(prefix=SHAPE_PREFIX, safe=safe)


def filter_names(names: List[str], terms: List[str]) -> List[str]:
    if not terms:
        return names
    lowered = [t.lower() for t in terms]
    return [n for n in names if any(t in n.lower() for t in lowered)]


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Search AWS4 stencil shape names from jgraph/drawio. "
            "AWS4 icons are stencil-based (shape=mxgraph.aws4.*), not SVG files."
        )
    )
    parser.add_argument(
        "--search", nargs="*", default=[], help="Keywords to match in shape name"
    )
    parser.add_argument(
        "--max-results", type=int, default=50, help="Maximum results to print"
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Also print the raw shape name alongside the style string",
    )
    parser.add_argument("--allow-network", action="store_true", help="Explicitly authorize public GitHub requests")
    args = parser.parse_args()
    if not args.allow_network:
        parser.error("network access requires --allow-network; use bundled catalogs offline")
    if args.max_results < 1:
        parser.error("--max-results must be positive")

    try:
        xml = fetch_stencil(STENCIL_URL)
        all_names = extract_shape_names(xml)
    except (OSError, ValueError, urllib.error.URLError, ET.ParseError) as exc:
        print(
            "ERROR: unable to fetch AWS4 stencil XML: {0}".format(exc),
            file=sys.stderr,
        )
        return 1

    if not all_names:
        print("ERROR: no shape names found in AWS4 stencil XML", file=sys.stderr)
        return 1

    matches = filter_names(all_names, args.search)
    if not matches:
        joined = ", ".join(args.search) if args.search else "(none)"
        print("No matches found for search terms: {0}".format(joined))
        return 1

    limited = matches[: args.max_results]
    print("Matched {0} shapes (showing {1})".format(len(matches), len(limited)))

    for name in limited:
        style = name_to_style(name)
        if args.verbose:
            print("{style:<80}  # {name}".format(style=style, name=name))
        else:
            print(style)

    return 0


if __name__ == "__main__":
    sys.exit(main())
