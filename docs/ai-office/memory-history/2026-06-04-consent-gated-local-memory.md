# Memory Entry: Consent-Gated Local Memory

Created: 2026-06-04T00:00:00Z
Role: CEO
Feature: office-runtime
Tags: local-memory, fastembed, consent, vector-index

## Summary

Local semantic memory should be useful without silently downloading embedding
models or turning vectors into the durable source of truth.

## Decision

Agents may write durable decision/history entries under
`docs/ai-office/memory-history/` based on judgment. They must ask the user before
installing FastEmbed dependencies, initializing/downloading embedding models, or
running memory commands with `--allow-download`.

## Why It Matters

This gives the office searchable long-term history while keeping model downloads
explicit, the vector cache disposable, and Git-tracked Markdown as the real
memory.

## Evidence

- `docs/ai-office/local-memory.md`
- `tools/office-memory/remember.py`
- `tools/office-memory/index.py`
- `tools/office-memory/search.py`
