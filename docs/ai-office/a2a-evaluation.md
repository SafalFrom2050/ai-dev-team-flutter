# Agent-to-Agent (A2A) Protocol Evaluation

This document evaluates the emerging Agent-to-Agent (A2A) Protocol standard and determines its suitability for adoption within the AI Flutter Office.

## What is the A2A Protocol?

The **A2A Protocol** (v1.0) is a Linux Foundation-governed open standard initiated by Google and other industry partners to establish a unified protocol for agent interoperability.
- While the Model Context Protocol (MCP) defines how an agent talks to tools (`Agent <-> Tool`), A2A defines how agents discover, negotiate, and communicate with each other (`Agent <-> Agent`).
- A2A aims to make agent messaging, streaming, task delegation, and capabilities negotiation vendor-neutral.

## A2A vs. Our Current Handoff Protocol

| Feature | Current Handoff Protocol (Our Repo) | A2A Protocol Standard |
|---|---|---|
| **Underlying Mechanism** | File-based (Outboxes, status files, branch diffs) | API-based (HTTP/gRPC, JSON/Protobuf envelopes) |
| **Discovery** | Explicit directory paths (`docs/ai-office/roles.md`) | Dynamic discovery endpoints & Capability Negotiation |
| **Communication** | Async, durable writes in Git | Direct RPC, Pub/Sub, and Event Streaming |
| **Task Delegation** | Manual/Orchestrator packets & subagent spawning | Standardized task state machine (Created, Active, Done, Failed) |
| **Vendor Portability** | Runs anywhere Git runs | Requires runtime/platform support for the A2A spec |

## Current Assessment

The A2A standard offers a clean mental model and structure for agent-to-agent operations. However:
1. **Lack of Native Runtime Support**: Major developer agent runtimes (Claude Code, Cursor, Codex CLI) do not yet support A2A sockets or protocols natively.
2. **Repo as Truth is More Debuggable**: Our file-based repository-centric loop provides a permanent, auditable log of agent decisions directly in version control. A pure API-driven A2A protocol could hide critical decisions inside transient socket connections.

## Recommendation & Decision

### Decision: Monitor and Defer Adoption
We will **NOT** adopt A2A APIs at this time. The repository remains the single, durable store for shared memory and agent coordination.

### Trigger for Re-evaluation
Re-evaluate A2A when:
1. Codex CLI, Claude Code, or Antigravity CLI implement native A2A-compliant endpoints or messaging layers.
2. The user requests deployment of the office as a set of long-running API services rather than a CLI tool run over a local git repository.

When A2A matures, we can upgrade our handoff protocol to wrap our existing outbox files in A2A-compliant messaging packages, preserving the Git repository as the durable underlying data store.

## Reference URLs

- **Official Standard Website**: [a2a-protocol.org](https://a2a-protocol.org) (placeholder/upcoming)
- **Google Developer Documentation**: [google.dev/agent-development-kit](https://google.dev/agent-development-kit)
