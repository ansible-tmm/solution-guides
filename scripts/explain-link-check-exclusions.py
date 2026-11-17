#!/usr/bin/env python3
"""Categorize links that lychee counts as Excluded for the weekly report.

Lychee only checks http/https (see .lychee.toml scheme). Everything else, plus
configured exclude patterns, is tallied as Excluded. This script scans the same
markdown inputs and prints a markdown section explaining those buckets.
"""

from __future__ import annotations

import re
import sys
from collections import Counter
from pathlib import Path

INPUTS = [
    *sorted(Path(".").glob("README-*.md")),
    Path("index.md"),
    Path("README.md"),
    Path("guide-types.md"),
    Path("best-practices.md"),
    Path("reviews.md"),
    Path("updates.md"),
    Path("aiops-use-cases.md"),
    Path("content-type-definition.md"),
]

# href/src attributes and markdown links/images
LINK_RE = re.compile(
    r"""(?x)
    (?:href|src)\s*=\s*["']([^"']+)["']
  | !?\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)
"""
)

TWEMOJI_RE = re.compile(r"^https://cdn\.jsdelivr\.net/gh/twitter/twemoji")
LOCALHOST_RE = re.compile(r"^https?://(localhost|127\.0\.0\.1|0\.0\.0\.0)\b")
SERVICENOW_RE = re.compile(r"^https://www\.servicenow\.com/")
HTTP_RE = re.compile(r"^https?://", re.I)
SCHEME_RE = re.compile(r"^[a-zA-Z][a-zA-Z0-9+.-]*:")
IMAGE_RE = re.compile(r"\.(png|jpe?g|gif|svg|webp|ico)(\?.*)?$", re.I)


def categorize(url: str) -> str:
    u = url.strip()
    if not u or u.startswith("{{"):
        return "ignored_template"

    if TWEMOJI_RE.match(u):
        return "twemoji"
    if LOCALHOST_RE.match(u):
        return "localhost"
    if SERVICENOW_RE.match(u):
        return "servicenow"
    if HTTP_RE.match(u):
        return "http_checked"

    if u.startswith("data:"):
        return "data_uri"
    if SCHEME_RE.match(u) and not u.lower().startswith("mailto:"):
        return "other_scheme"
    if u.lower().startswith("mailto:"):
        return "mailto"

    # Relative / local: anchors, images, markdown paths
    if u.startswith("#") or ".md#" in u or re.search(r"\.html#", u):
        return "anchor"
    if IMAGE_RE.search(u.split("#", 1)[0]):
        return "local_image"
    return "relative_path"


def main() -> int:
    counts: Counter[str] = Counter()
    for path in INPUTS:
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8", errors="ignore")
        for match in LINK_RE.finditer(text):
            url = next(g for g in match.groups() if g is not None)
            counts[categorize(url)] += 1

    # Authoritative Excluded total from lychee summary, if present on stdin/arg
    lychee_excluded = None
    if len(sys.argv) > 1 and sys.argv[1].isdigit():
        lychee_excluded = int(sys.argv[1])

    excluded_keys = [
        "anchor",
        "relative_path",
        "local_image",
        "twemoji",
        "localhost",
        "servicenow",
        "data_uri",
        "mailto",
        "other_scheme",
    ]
    rows = [
        (
            "In-page anchors",
            "anchor",
            "`#section` and `file.md#section` -- local navigation, not outbound URLs",
        ),
        (
            "Relative files",
            "relative_path",
            "Cross-guide `.md` / hub paths resolved as local `file://` links",
        ),
        (
            "Local images",
            "local_image",
            "`assets/images/...` and other repo-relative image paths",
        ),
        (
            "Twemoji icons",
            "twemoji",
            "Decorative CDN emoji images; excluded in `.lychee.toml`",
        ),
        (
            "localhost / lab",
            "localhost",
            "Lab placeholders (`localhost`, `127.0.0.1`); excluded in config",
        ),
        (
            "servicenow.com",
            "servicenow",
            "Flaky vendor front door; excluded in `.lychee.toml`",
        ),
        (
            "data: URIs",
            "data_uri",
            "Inline base64 images embedded in markdown/HTML",
        ),
        (
            "mailto:",
            "mailto",
            "Email links (`include_mail = false` in `.lychee.toml`)",
        ),
        (
            "Other schemes",
            "other_scheme",
            "Non-http(s) URLs such as `s3://` placeholders",
        ),
    ]

    explained = sum(counts[k] for _, k, _ in rows)

    print("## How to read this report")
    print()
    print("| Status | Meaning | What to do |")
    print("|--------|---------|------------|")
    print(
        "| **Errors** | Outbound http(s) URL failed "
        "(usually 404) | Fix the link in the guide source |"
    )
    print(
        "| **Redirected** | URL works but hops to a new location | "
        "Update the source to the final URL |"
    )
    print(
        "| **Excluded** | Intentionally not checked "
        "(see breakdown) | No action required |"
    )
    print(
        "| **Successful** | Outbound http(s) URL returned an "
        "accepted status | None |"
    )
    print()
    print(
        "This job only **checks** `http`/`https` links "
        "(`scheme` in `.lychee.toml`). Relative paths, in-page anchors, "
        "local images, and configured noise patterns are counted as "
        "**Excluded** -- they are not failures."
    )
    print()
    print("## Excluded breakdown")
    print()
    if lychee_excluded is not None:
        print(
            f"Lychee reported **{lychee_excluded}** excluded discoveries. "
            "Approximate composition from the same markdown inputs:"
        )
    else:
        print(
            "Approximate composition of excluded discoveries "
            "from the same markdown inputs:"
        )
    print()
    print("| Category | Count | Why it is excluded |")
    print("|----------|------:|--------------------|")
    for label, key, why in rows:
        n = counts[key]
        if n == 0:
            continue
        print(f"| {label} | {n} | {why} |")
    print(f"| **Total (explained)** | **{explained}** | |")
    print()
    print(
        "_Counts are from a source scan of the same inputs lychee uses. "
        "They should be close to the Excluded total in Summary; "
        "small differences are normal (parser edge cases)._"
    )
    print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
