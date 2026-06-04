# Antigravity CLI Migration Plan

> [!WARNING]
> The Gemini CLI standard tier reaches End-of-Life (EOL) on **June 18, 2026**. All agent configurations, shims, and skills must migrate to the Antigravity CLI (`agy`) before this date.

## Overview

The successor to Gemini CLI is the Antigravity CLI (`agy`), built in Go for significantly faster startup times, improved sandboxing, and native support for dynamic agent team orchestrations. This document outlines the migration path for this repository to ensure zero-downtime development.

## Timeline

- **Phase 1: Dual Support (Current)**: Both `gemini` and `agy` runtimes work. Configs are backward compatible.
- **Phase 2: Transition (May 2026)**: Prefer the `agy` command for interactive loops. Import existing plugins.
- **Phase 3: Deprecation (June 18, 2026)**: Standard tier Gemini CLI is disabled. Antigravity CLI is the default.

## Migration Steps

1. **Install Antigravity CLI**:
   Ensure you have the latest executable on your system path.
   ```powershell
   npm install -g @antigravity/cli
   ```
   Verify installation:
   ```powershell
   agy --version
   ```

2. **Import Gemini Plugins**:
   Import your existing local Gemini settings and tools directly into the Antigravity configuration space:
   ```powershell
   agy plugin import gemini
   ```

3. **Verify Backward Compatibility**:
   Ensure that the existing configuration file at `.gemini/settings.json` is detected. Antigravity CLI automatically loads `.gemini/` folders to avoid breaking existing setups.

4. **Verify Instruction Shims**:
   The `GEMINI.md` shim file remains valid and is loaded automatically by the Antigravity engine. However, developers should transition to checking `CLAUDE.md` or general role packets under `.agents/` as part of the unified team configuration.

5. **Test MCP Connections**:
   Ensure the Dart MCP server registers properly:
   ```powershell
   agy mcp list
   ```

## What Stays the Same vs. What Changes

| Aspect | Gemini CLI (`gemini`) | Antigravity CLI (`agy`) |
|---|---|---|
| **CLI Binary** | `gemini` | `agy` |
| **Performance** | Python-based, slower initialization | Go-based compiled binary, instant start |
| **Instruction Shim** | `GEMINI.md` (root) | Backward compatible with `GEMINI.md`; recommends `.agents/` |
| **User Settings** | `.gemini/settings.json` | Backward compatible; migrates to `.agents/settings.json` |
| **Skills Directory** | `.gemini/config/plugins/` | Configurable; prefers `.agents/skills/` |
| **Harness Support** | Sequential model loops | Parallel subagent execution with shared workspaces |

## Recommended Next Steps

1. Run the import command `agy plugin import gemini` to port your local tokens and plugin registrations.
2. Update references in documentation from `gemini` commands to `agy` commands.
3. Keep `GEMINI.md` at the project root for backward compatibility with developers who haven't fully updated their systems.
