from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
import re
import sys
from pathlib import Path

import numpy as np


DEFAULT_MODEL = "BAAI/bge-small-en-v1.5"
DEFAULT_OUTPUT = ".agent-memory"
VECTOR_FILE = "office-memory.vectors.npy"
RECORD_FILE = "office-memory.records.json"
MODEL_READY_FILE = "model-ready.json"
CHUNK_CHARS = 1800
CHUNK_OVERLAP = 250
DEFAULT_MAX_FILE_KB = 512
DEFAULT_MAX_CHUNKS = 5000
PREVIEW_CHARS = 240

INCLUDE_GLOBS = [
    "AGENTS.md",
    "CEO_OVERVIEW.md",
    "README.md",
    "CLAUDE.md",
    "GEMINI.md",
    "docs/**/*.md",
    ".codex/agents/*.toml",
    ".claude/agents/*.md",
    ".github/**/*.md",
]

SKIP_PARTS = {
    ".git",
    ".agent-memory",
    ".dart_tool",
    ".fvm",
    "build",
    ".worktrees",
    "android",
    "ios",
    "linux",
    "macos",
    "windows",
}


def load_text_embedding():
    try:
        from fastembed import TextEmbedding
    except ImportError as exc:
        raise SystemExit(
            "fastembed is not installed. Ask the user before installing it, then run: "
            "python -m pip install -r tools/office-memory/requirements.txt"
        ) from exc
    return TextEmbedding


def consent_message(command: str) -> str:
    return (
        "FastEmbed model initialization may download an ONNX embedding model.\n"
        "Ask the user before continuing. Advantages: semantic recall over office "
        "decisions, faster status/history lookup, and fewer broad doc crawls.\n"
        f"After approval, run: {command}"
    )


def ensure_model_consent(out_dir: Path, allow_download: bool, command: str) -> None:
    if allow_download or (out_dir / MODEL_READY_FILE).exists():
        return
    raise SystemExit(consent_message(command))


def write_model_ready(out_dir: Path, model: str) -> None:
    (out_dir / MODEL_READY_FILE).write_text(
        json.dumps(
            {
                "model": model,
                "ready_at": datetime.now(timezone.utc).isoformat(),
                "note": "Created after explicit --allow-download consent.",
            },
            indent=2,
        ),
        encoding="utf-8",
    )


def iter_candidate_files(root: Path) -> list[Path]:
    files: dict[Path, None] = {}
    for pattern in INCLUDE_GLOBS:
        for path in root.glob(pattern):
            if path.is_file() and not any(part in SKIP_PARTS for part in path.parts):
                files[path] = None
    return sorted(files)


def line_for_offset(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def chunk_text(text: str) -> list[tuple[int, str]]:
    normalized = re.sub(r"\n{3,}", "\n\n", text).strip()
    if not normalized:
        return []

    chunks: list[tuple[int, str]] = []
    start = 0
    while start < len(normalized):
        end = min(start + CHUNK_CHARS, len(normalized))
        if end < len(normalized):
            boundary = normalized.rfind("\n\n", start, end)
            if boundary > start + 400:
                end = boundary
        chunk = normalized[start:end].strip()
        if chunk:
            chunks.append((line_for_offset(normalized, start), chunk))
        if end >= len(normalized):
            break
        start = max(0, end - CHUNK_OVERLAP)
    return chunks


def excerpt(text: str, max_chars: int = PREVIEW_CHARS) -> str:
    compact = " ".join(text.split())
    if len(compact) <= max_chars:
        return compact
    return compact[: max_chars - 1].rstrip() + "..."


def normalize(vectors: np.ndarray) -> np.ndarray:
    norms = np.linalg.norm(vectors, axis=1, keepdims=True)
    norms[norms == 0] = 1.0
    return vectors / norms


def main() -> int:
    parser = argparse.ArgumentParser(description="Build the AI office memory index.")
    parser.add_argument("--root", default=".", help="Repository root.")
    parser.add_argument("--out", default=DEFAULT_OUTPUT, help="Output directory.")
    parser.add_argument("--model", default=DEFAULT_MODEL, help="FastEmbed model name.")
    parser.add_argument(
        "--allow-download",
        action="store_true",
        help="Allow FastEmbed to initialize and download the embedding model if needed.",
    )
    parser.add_argument(
        "--max-file-kb",
        type=int,
        default=DEFAULT_MAX_FILE_KB,
        help="Skip source files larger than this many KiB.",
    )
    parser.add_argument(
        "--max-chunks",
        type=int,
        default=DEFAULT_MAX_CHUNKS,
        help="Stop indexing after this many chunks.",
    )
    args = parser.parse_args()

    root = Path(args.root).resolve()
    out_dir = (root / args.out).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)
    ensure_model_consent(
        out_dir,
        args.allow_download,
        "python tools/office-memory/index.py --allow-download",
    )

    records: list[dict[str, object]] = []
    passages: list[str] = []
    skipped: list[dict[str, object]] = []

    for path in iter_candidate_files(root):
        rel = path.relative_to(root).as_posix()
        size = path.stat().st_size
        if size > args.max_file_kb * 1024:
            skipped.append({"path": rel, "reason": "max-file-kb", "bytes": size})
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        digest = hashlib.sha256(text.encode("utf-8")).hexdigest()
        lines = text.splitlines()
        for index, (line, chunk) in enumerate(chunk_text(text)):
            if len(records) >= args.max_chunks:
                skipped.append({"path": rel, "reason": "max-chunks"})
                break
            end_line = min(len(lines), line + chunk.count("\n"))
            records.append(
                {
                    "path": rel,
                    "start_line": line,
                    "end_line": end_line,
                    "chunk": index,
                    "sha256": digest,
                    "preview": excerpt(chunk),
                }
            )
            passages.append(f"passage: {chunk}")
        if len(records) >= args.max_chunks:
            break

    if not passages:
        raise SystemExit("No office documents found to index.")

    TextEmbedding = load_text_embedding()
    model = TextEmbedding(args.model)
    vectors = normalize(np.array(list(model.embed(passages)), dtype=np.float32))

    np.save(out_dir / VECTOR_FILE, vectors)
    (out_dir / RECORD_FILE).write_text(
        json.dumps(
            {
                "model": args.model,
                "root": root.as_posix(),
                "vector_file": VECTOR_FILE,
                "record_format": "pointer-v1",
                "chunk_chars": CHUNK_CHARS,
                "chunk_overlap": CHUNK_OVERLAP,
                "max_file_kb": args.max_file_kb,
                "max_chunks": args.max_chunks,
                "skipped": skipped,
                "records": records,
            },
            indent=2,
        ),
        encoding="utf-8",
    )
    write_model_ready(out_dir, args.model)

    print(f"Indexed {len(records)} chunks from {len(iter_candidate_files(root))} files.")
    if skipped:
        print(f"Skipped {len(skipped)} file(s) or chunk range(s).")
    print(f"Wrote {out_dir / RECORD_FILE}")
    print(f"Wrote {out_dir / VECTOR_FILE}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
