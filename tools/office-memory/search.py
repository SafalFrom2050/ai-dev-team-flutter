from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

import numpy as np


DEFAULT_INDEX = ".agent-memory"
VECTOR_FILE = "office-memory.vectors.npy"
RECORD_FILE = "office-memory.records.json"
MODEL_READY_FILE = "model-ready.json"


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


def normalize(vector: np.ndarray) -> np.ndarray:
    norm = np.linalg.norm(vector)
    if norm == 0:
        return vector
    return vector / norm


def excerpt(text: str, max_chars: int = 260) -> str:
    compact = " ".join(text.split())
    if len(compact) <= max_chars:
        return compact
    return compact[: max_chars - 1].rstrip() + "..."


def source_excerpt(root: Path, record: dict[str, object]) -> str:
    path = root / str(record["path"])
    if not path.exists():
        return str(record.get("preview", "[source file missing]"))

    text = path.read_text(encoding="utf-8", errors="replace")
    digest = hashlib.sha256(text.encode("utf-8")).hexdigest()
    if digest != record.get("sha256"):
        return f"[source changed since index] {record.get('preview', '')}"

    lines = text.splitlines()
    start = max(1, int(record.get("start_line", record.get("line", 1))))
    end = max(start, int(record.get("end_line", start)))
    snippet = "\n".join(lines[start - 1 : end])
    return excerpt(snippet)


def main() -> int:
    parser = argparse.ArgumentParser(description="Search the AI office memory index.")
    parser.add_argument("query", help="Search query.")
    parser.add_argument("--index", default=DEFAULT_INDEX, help="Index directory.")
    parser.add_argument("--top", type=int, default=8, help="Number of results.")
    parser.add_argument(
        "--allow-download",
        action="store_true",
        help="Allow FastEmbed to initialize and download the embedding model if needed.",
    )
    args = parser.parse_args()

    index_dir = Path(args.index).resolve()
    record_path = index_dir / RECORD_FILE
    vector_path = index_dir / VECTOR_FILE

    if not record_path.exists() or not vector_path.exists():
        raise SystemExit(
            "Memory index not found. Build it after user approval with: "
            "python tools/office-memory/index.py --allow-download"
        )
    if not args.allow_download and not (index_dir / MODEL_READY_FILE).exists():
        raise SystemExit(
            consent_message(
                f"python tools/office-memory/search.py --allow-download \"{args.query}\""
            )
        )

    payload = json.loads(record_path.read_text(encoding="utf-8"))
    records = payload["records"]
    vectors = np.load(vector_path)
    root = Path(payload.get("root", ".")).resolve()

    TextEmbedding = load_text_embedding()
    model = TextEmbedding(payload["model"])
    query_vector = normalize(
        np.array(list(model.embed([f"query: {args.query}"]))[0], dtype=np.float32)
    )
    scores = vectors @ query_vector
    top_indexes = np.argsort(scores)[::-1][: args.top]

    for rank, idx in enumerate(top_indexes, start=1):
        record = records[int(idx)]
        print(
            f"{rank}. {scores[int(idx)]:.3f} "
            f"{record['path']}:{record.get('start_line', record.get('line', 1))} "
            f"[chunk {record['chunk']}]"
        )
        print(f"   {source_excerpt(root, record)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
