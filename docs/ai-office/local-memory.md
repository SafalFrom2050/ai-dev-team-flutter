# Local Semantic Memory

The office already has durable memory: Markdown docs, branch diffs, commits,
handoffs, outboxes, and status files. Local semantic memory is an accelerator on
top of that truth, not a replacement for it.

## Purpose

Use local semantic memory when an agent needs to answer questions such as:

- What did we decide about Android background timers?
- Which feature handoffs mention browser smoke evidence?
- Which role owns design tokens for a feature?
- What prior risk notes are relevant to this new task?

The answer must still cite the source Markdown file. The vector index only helps
find likely source passages.

## Technology Choice

Use FastEmbed for local embeddings:

- FastEmbed provides lightweight embedding generation.
- It uses quantized model weights and ONNX Runtime for inference.
- It supports small default text models and larger multilingual models.

Default model:

```text
BAAI/bge-small-en-v1.5
```

This is enough for English office docs and keeps the first local index small. If
the office starts storing mixed Japanese, Nepali, or multilingual product notes,
switch to a multilingual FastEmbed model and rebuild the index.

References:

- FastEmbed: https://qdrant.github.io/fastembed/
- FastEmbed getting started: https://qdrant.github.io/fastembed/Getting%20Started/
- ONNX Runtime: https://onnxruntime.ai/docs/

## Generated Files

Generated memory files live under:

```text
.agent-memory/
```

This directory is ignored by git. It is machine-local state, similar to a search
cache.

Expected generated files:

```text
.agent-memory/
  office-memory.records.json
  office-memory.vectors.npy
```

The index is pointer-first. Records store path, line range, source hash, chunk
number, and a short preview. Full chunk text is not duplicated in
`records.json`; search reads the source file live when it prints an excerpt.

Tracked history entries live under:

```text
docs/ai-office/memory-history/
```

These files are real repo memory. The vector index reads them on the next
rebuild.

## Install

From the repo root:

```powershell
python -m pip install -r tools/office-memory/requirements.txt
```

On Windows, `py` is also fine when the Python launcher is installed. If neither
`python` nor `py` is on PATH, use the Python executable bundled with the active
agent/runtime environment.

## Build The Index

Ask the user before the first run or any run that may initialize/download a
FastEmbed model. After approval:

```powershell
python tools/office-memory/index.py --allow-download
```

Useful bounds:

```powershell
python tools/office-memory/index.py --allow-download --max-file-kb 256 --max-chunks 2000
```

The indexer reads:

- `AGENTS.md`
- `CEO_OVERVIEW.md`
- `README.md`
- `CLAUDE.md`
- `GEMINI.md`
- `docs/**/*.md`
- `.codex/agents/*.toml`
- `.claude/agents/*.md`
- `.github/**/*.md`

It skips generated Flutter platform/build folders and `.agent-memory/`.

By default, files larger than 512 KiB are skipped and indexing stops after 5000
chunks. This keeps local memory from growing without bound. Rebuilding the index
overwrites the previous `.agent-memory/` files instead of appending to them.

## Search

Use `docs/ai-office/token-budgeting.md` for the default memory cap.

```powershell
python tools/office-memory/search.py "Android background timer verification" --top 5
```

The search output includes score, path, line number, and a short excerpt. Use the
path and line number as the evidence trail for the final answer or role packet.
Start with top 3-5 hits; only widen the search when the cited source files do
not answer the question.

If the model has not been approved/initialized yet, search will stop and ask for
user approval before running with `--allow-download`.

## Remember A Decision

When an agent judges that a decision or project learning should become durable
office history, write a memory entry:

```powershell
python tools/office-memory/remember.py `
  --title "Background timer verification remains pending" `
  --role "QA/Test Engineer" `
  --summary "Android background timer code is present, but release evidence is incomplete." `
  --decision "Treat Android background timer as verification-pending until emulator or device QA is recorded." `
  --why "Future agents should not describe the feature as release-ready without background behavior evidence." `
  --feature "android-background-timer" `
  --tags status qa android `
  --evidence "docs/features/android-background-timer/handoff.md"
```

To also rebuild the vector index after user approval:

```powershell
python tools/office-memory/remember.py ... --rebuild-index --allow-download
```

Without `--allow-download`, the memory entry is still written, but the script
will not initialize FastEmbed or rebuild vectors.

## Rules

- Do not commit `.agent-memory/`.
- Do not run FastEmbed indexing in CI by default. It downloads embedding models
  and creates machine-local cache files. CI should only run
  `tools/office-readiness/check.py`.
- Agents may write tracked memory-history entries without model download. They
  must ask before using `--allow-download`.
- Do not store secrets or private customer data in office docs or memory files.
- Do not treat semantic search output as confirmed truth until the source file is
  read.
- Do not dump full memory or history into packets. Pass source paths and line
  references whenever possible.
- Rebuild the index after major changes to `docs/`, `.codex/`, `.claude/`, or
  feature handoffs.
- For release/status answers, prefer `docs/features/status-index.md` first, then
  use semantic memory for supporting context.
