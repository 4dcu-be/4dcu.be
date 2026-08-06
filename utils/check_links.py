#!/usr/bin/env python3
"""Check external links in the blog's markdown posts for dead URLs.

Extracts all external http(s) URLs from ``_posts/*.md`` (and ``.markdown``),
deduplicates them, and checks each one is still reachable. Only *hard* failures
are reported as dead (404/410, DNS/connection errors, timeouts). Ambiguous
responses such as 403/429/5xx are treated as "likely alive" to avoid false
positives from bot-blocking.

Requests are grouped per domain and throttled so we never hammer a single host
(e.g. the ~155 github.com links) while still checking many domains in parallel.

Usage:
    python utils/check_links.py                # check all posts
    python utils/check_links.py --posts _posts # custom posts dir
    python utils/check_links.py --report out.json

Requires: httpx  (see utils/requirements.txt)
"""

from __future__ import annotations

import argparse
import asyncio
import json
import re
import sys
from collections import defaultdict
from pathlib import Path
from urllib.parse import urlparse

import httpx

# --- Tuning -----------------------------------------------------------------

# Overall cap on simultaneous in-flight requests across all domains.
GLOBAL_CONCURRENCY = 30
# Max simultaneous requests to a single domain (politeness).
PER_DOMAIN_CONCURRENCY = 1
# Minimum delay (seconds) between consecutive requests to the same domain.
PER_DOMAIN_DELAY = 0.5
# Per-request timeout in seconds.
TIMEOUT = 20.0
# Number of retries on transient network errors before giving up.
RETRIES = 2

# Statuses that mean "definitely dead".
DEAD_STATUSES = {404, 410}
# Statuses where the server clearly answered but blocked our automated request
# (bot protection / auth walls). The host is up and the path resolved, so for a
# liveness check these count as alive rather than dead or uncertain.
BLOCKED_STATUSES = {401, 403, 429}

# A realistic browser User-Agent + headers to reduce bot-blocking. The extra
# Sec-Fetch-* / Upgrade-Insecure-Requests headers mimic what Chrome sends and
# get past some WAFs (Cloudflare, Akamai) that fingerprint bare clients.
HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
    ),
    "Accept": (
        "text/html,application/xhtml+xml,application/xml;q=0.9,"
        "image/avif,image/webp,*/*;q=0.8"
    ),
    "Accept-Language": "en-US,en;q=0.9",
    "Accept-Encoding": "gzip, deflate, br",
    "Upgrade-Insecure-Requests": "1",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-User": "?1",
    "Sec-Ch-Ua": '"Chromium";v="124", "Google Chrome";v="124", "Not-A.Brand";v="99"',
    "Sec-Ch-Ua-Mobile": "?0",
    "Sec-Ch-Ua-Platform": '"Windows"',
}

# --- URL extraction ---------------------------------------------------------

# Markdown links [text](url), bare <url>, and HTML href="url" / src="url".
_MD_LINK = re.compile(r"\]\(\s*<?(https?://[^)\s>]+)>?\s*[^)]*\)")
_ANGLE_LINK = re.compile(r"<(https?://[^>\s]+)>")
_HTML_ATTR = re.compile(r"""(?:href|src)\s*=\s*["'](https?://[^"']+)["']""")
# Fallback: any bare URL in text.
_BARE_LINK = re.compile(r"(?<![\"'(<])(https?://[^\s)\]<>\"']+)")

# Trailing punctuation to strip from URLs captured loosely.
_TRAILING = ".,;:!?'\""


def _clean(url: str) -> str:
    url = url.strip().rstrip(_TRAILING)
    # Drop a trailing ) if it isn't matched by a ( inside the url.
    while url.endswith(")") and url.count("(") < url.count(")"):
        url = url[:-1]
    return url


# Hostnames that are only meaningful when running a project locally; they can
# never be checked, so we skip them.
_LOOPBACK_HOSTS = {"localhost", "127.0.0.1", "0.0.0.0", "::1", "[::1]"}


def _is_checkable(url: str) -> bool:
    # Drop unrendered Liquid/template artifacts like {{ site.x }} or {% ... %}.
    if "{{" in url or "}}" in url or "{%" in url:
        return False
    parsed = urlparse(url)
    if parsed.scheme not in ("http", "https"):
        return False
    host = parsed.hostname or ""
    if host in _LOOPBACK_HOSTS or host.startswith("127."):
        return False
    return True


def extract_urls(text: str) -> set[str]:
    urls: set[str] = set()
    for pattern in (_MD_LINK, _ANGLE_LINK, _HTML_ATTR, _BARE_LINK):
        for match in pattern.findall(text):
            urls.add(_clean(match))
    return {u for u in urls if _is_checkable(u)}


def collect_links(posts_dir: Path) -> dict[str, set[str]]:
    """Return {post_filename: {url, ...}} for every post with external links."""
    files = sorted(posts_dir.rglob("*.md")) + sorted(posts_dir.rglob("*.markdown"))
    result: dict[str, set[str]] = {}
    for path in files:
        text = path.read_text(encoding="utf-8", errors="replace")
        urls = extract_urls(text)
        if urls:
            result[str(path.name)] = urls
    return result


# --- Checking ---------------------------------------------------------------


async def _check_one(client: httpx.AsyncClient, url: str) -> tuple[str, str, str | None]:
    """Return (url, verdict, detail). verdict in {alive, dead, uncertain}."""
    last_detail: str | None = None
    for attempt in range(RETRIES + 1):
        try:
            # Try HEAD first (cheap); fall back to GET when disallowed. Some
            # servers 403/405 HEAD specifically but serve GET fine.
            resp = await client.head(url, follow_redirects=True)
            if resp.status_code in (403, 405, 501) or resp.status_code >= 500:
                resp = await client.get(url, follow_redirects=True)

            code = resp.status_code
            if code in DEAD_STATUSES:
                return url, "dead", f"HTTP {code}"
            if code < 400 or code in BLOCKED_STATUSES:
                # 2xx/3xx, or a server-answered block (401/403/429): the host is
                # up and the path resolved, so it's alive for our purposes.
                note = " (blocked)" if code in BLOCKED_STATUSES else ""
                return url, "alive", f"HTTP {code}{note}"
            # Anything else (e.g. lingering 5xx after retries) — ambiguous.
            return url, "uncertain", f"HTTP {code}"
        except (httpx.ConnectError, httpx.ConnectTimeout) as exc:
            # DNS failure / no route == dead. Timeouts get retried.
            if isinstance(exc, httpx.ConnectError):
                return url, "dead", f"connect error: {exc}"
            last_detail = f"timeout: {exc}"
        except (httpx.ReadTimeout, httpx.PoolTimeout, httpx.WriteTimeout) as exc:
            last_detail = f"timeout: {exc}"
        except httpx.HTTPError as exc:
            last_detail = f"error: {exc}"
        if attempt < RETRIES:
            await asyncio.sleep(1.0 * (attempt + 1))
    # Exhausted retries on transient errors — treat as dead (unreachable).
    return url, "dead", last_detail or "unreachable"


async def _domain_worker(
    client: httpx.AsyncClient,
    urls: list[str],
    global_sem: asyncio.Semaphore,
    results: dict[str, tuple[str, str | None]],
) -> None:
    """Process all URLs for a single domain, serialised and throttled."""
    for i, url in enumerate(urls):
        if i:
            await asyncio.sleep(PER_DOMAIN_DELAY)
        async with global_sem:
            _, verdict, detail = await _check_one(client, url)
        results[url] = (verdict, detail)


async def check_urls(urls: set[str]) -> dict[str, tuple[str, str | None]]:
    by_domain: dict[str, list[str]] = defaultdict(list)
    for url in urls:
        by_domain[urlparse(url).netloc.lower()].append(url)

    results: dict[str, tuple[str, str | None]] = {}
    global_sem = asyncio.Semaphore(GLOBAL_CONCURRENCY)
    limits = httpx.Limits(max_connections=GLOBAL_CONCURRENCY)
    timeout = httpx.Timeout(TIMEOUT)

    async with httpx.AsyncClient(
        headers=HEADERS, timeout=timeout, limits=limits, http2=True
    ) as client:
        await asyncio.gather(
            *(
                _domain_worker(client, domain_urls, global_sem, results)
                for domain_urls in by_domain.values()
            )
        )
    return results


# --- Reporting --------------------------------------------------------------


def build_report(
    links_by_post: dict[str, set[str]],
    results: dict[str, tuple[str, str | None]],
) -> dict:
    """Build a report grouping problem links by verdict, then by domain.

    Structure::

        {
          "dead": {
            "example.com": [
              {"url": "...", "detail": "HTTP 404", "posts": ["a.md", "b.md"]},
              ...
            ],
            ...
          },
          "uncertain": { ... }
        }

    Dead links come first; within each verdict links are grouped per domain.
    Each entry records the actual URL, the failure detail, and every post the
    URL appears in.
    """
    # Reverse the mapping: url -> sorted list of posts it appears in.
    posts_by_url: dict[str, list[str]] = defaultdict(list)
    for post, urls in links_by_post.items():
        for url in urls:
            posts_by_url[url].append(post)

    # verdict -> domain -> list of entries.
    grouped: dict[str, dict[str, list[dict]]] = {"dead": {}, "uncertain": {}}
    for url, (verdict, detail) in results.items():
        if verdict == "alive":
            continue
        domain = urlparse(url).netloc.lower()
        entry = {"url": url, "detail": detail, "posts": sorted(posts_by_url[url])}
        grouped[verdict].setdefault(domain, []).append(entry)

    # Sort domains alphabetically and URLs within each domain; keep "dead" first.
    report: dict[str, dict[str, list[dict]]] = {}
    for verdict in ("dead", "uncertain"):
        domains = grouped[verdict]
        if not domains:
            continue
        report[verdict] = {
            domain: sorted(domains[domain], key=lambda e: e["url"])
            for domain in sorted(domains)
        }
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--posts",
        type=Path,
        default=Path(__file__).resolve().parent.parent / "_posts",
        help="Directory containing markdown posts (default: ../_posts).",
    )
    parser.add_argument(
        "--report",
        type=Path,
        default=Path(__file__).resolve().parent / "link_report.json",
        help="Path to write the JSON report (default: utils/link_report.json).",
    )
    args = parser.parse_args()

    if not args.posts.is_dir():
        print(f"error: posts directory not found: {args.posts}", file=sys.stderr)
        return 2

    links_by_post = collect_links(args.posts)
    all_urls = set().union(*links_by_post.values()) if links_by_post else set()
    print(
        f"Found {len(all_urls)} unique external URLs "
        f"across {len(links_by_post)} posts. Checking…\n"
    )

    results = asyncio.run(check_urls(all_urls))

    dead = [u for u, (v, _) in results.items() if v == "dead"]
    uncertain = [u for u, (v, _) in results.items() if v == "uncertain"]

    report = build_report(links_by_post, results)
    args.report.write_text(json.dumps(report, indent=2, ensure_ascii=False))

    # Console summary — dead first, grouped by domain, showing source posts.
    markers = {"dead": "DEAD", "uncertain": "????"}
    for verdict in ("dead", "uncertain"):
        domains = report.get(verdict)
        if not domains:
            continue
        print(f"{verdict.upper()} links (by domain):\n")
        for domain, entries in domains.items():
            print(f"  {domain}")
            for e in entries:
                posts = ", ".join(e["posts"])
                print(f"    [{markers[verdict]}] {e['url']}  ({e['detail']})")
                print(f"           in: {posts}")
            print()

    print(
        f"Summary: {len(all_urls)} checked — "
        f"{len(dead)} dead, {len(uncertain)} uncertain, "
        f"{len(all_urls) - len(dead) - len(uncertain)} alive."
    )
    print(f"Report written to {args.report}")

    # Non-zero exit only for hard failures, so this can gate CI if desired.
    return 1 if dead else 0


if __name__ == "__main__":
    raise SystemExit(main())
