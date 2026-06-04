from __future__ import annotations

import argparse
from datetime import datetime, timezone
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_HISTORY_DIR = "docs/ai-office/memory-history"
MODEL_READY_FILE = ".agent-memory/model-ready.json"


def slugify(text: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    return slug[:72] or "memory-entry"


def render_entry(args: argparse.Namespace) -> str:
    now = datetime.now(timezone.utc).isoformat()
    evidence = "\n".join(f"- `{item}`" for item in args.evidence)
    tags = ", ".join(args.tags) if args.tags else "office-memory"
    feature = args.feature or "office"
    return f"""# Memory Entry: {args.title}

Created: {now}
Role: {args.role}
Feature: {feature}
Tags: {tags}

## Summary

{args.summary}

## Decision

{args.decision}

## Why It Matters

{args.why}

## Evidence

{evidence or "- No source paths supplied."}
"""


def rebuild_index(root: Path, allow_download: bool) -> int:
    marker = root / MODEL_READY_FILE
    if not allow_download and not marker.exists():
        print(
            "Memory entry written, but the vector index was not rebuilt.\n"
            "FastEmbed model initialization may download an ONNX embedding model.\n"
            "Ask the user before continuing. Advantages: semantic recall over "
            "office decisions, faster status/history lookup, and fewer broad doc crawls.\n"
            "After approval, run: python tools/office-memory/index.py --allow-download"
        )
        return 0

    command = [
        sys.executable,
        str(root / "tools" / "office-memory" / "index.py"),
    ]
    if allow_download:
        command.append("--allow-download")
    result = subprocess.run(command, cwd=root, check=False)
    return result.returncode


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Write a durable office memory entry and optionally rebuild the local vector index."
    )
    parser.add_argument("--title", required=True, help="Short memory title.")
    parser.add_argument("--role", required=True, help="Role writing this memory.")
    parser.add_argument("--summary", required=True, help="One-sentence summary.")
    parser.add_argument("--decision", required=True, help="Decision or durable learning.")
    parser.add_argument("--why", required=True, help="Why this should be remembered.")
    parser.add_argument("--feature", help="Feature slug, if applicable.")
    parser.add_argument("--tags", nargs="*", default=[], help="Optional tags.")
    parser.add_argument("--evidence", action="append", default=[], help="Source path or evidence pointer.")
    parser.add_argument("--history-dir", default=DEFAULT_HISTORY_DIR, help="Tracked memory history directory.")
    parser.add_argument("--rebuild-index", action="store_true", help="Rebuild vector index after writing.")
    parser.add_argument(
        "--allow-download",
        action="store_true",
        help="Allow FastEmbed to initialize and download the embedding model if needed.",
    )
    args = parser.parse_args()

    root = ROOT
    history_dir = root / args.history_dir
    history_dir.mkdir(parents=True, exist_ok=True)

    date = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    path = history_dir / f"{date}-{slugify(args.title)}.md"
    suffix = 2
    while path.exists():
        path = history_dir / f"{date}-{slugify(args.title)}-{suffix}.md"
        suffix += 1

    path.write_text(render_entry(args), encoding="utf-8")
    print(f"Wrote {path.relative_to(root)}")

    if args.rebuild_index:
        return rebuild_index(root, args.allow_download)

    print("Vector index not rebuilt. Rebuild after consent with:")
    print("  python tools/office-memory/index.py --allow-download")
    return 0


if __name__ == "__main__":
    sys.exit(main())
