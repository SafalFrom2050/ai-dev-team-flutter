# Gemini CLI Compatibility

Gemini CLI uses `GEMINI.md` as its project instruction file. This repository
therefore keeps a root `GEMINI.md` alongside `AGENTS.md`.

`AGENTS.md` is the full office operating system. `GEMINI.md` is the small
Gemini-specific guardrail that Gemini should see before it uses tools.

## Expected Behavior

For an unstructured prompt such as:

```text
how is our app doing?
```

Gemini's first visible response line should be exactly:

```text
Office Assistant Activated: I am your Office Assistant and responsible for analyzing tasks and producing ready-to-paste agent packets.
```

It should not start with "Researching", "Assessing", or a tool call.

For a status-only prompt, Gemini should read lightweight repo evidence first:

- `docs/features/status-index.md`
- relevant feature handoff, brief, and tech-plan docs
- git branch/log/status when useful

It should not read app source, tests, `pubspec.yaml`, platform folders, generated
files, or manifests unless the user explicitly asks for code inspection.

## Startup Checklist

Run Gemini from the repository root:

```powershell
gemini
```

If PowerShell blocks the npm shim, use:

```powershell
cmd /c gemini
```

After pulling changes to `GEMINI.md`, restart Gemini or run:

```text
/memory reload
```

To confirm the file is loaded:

```text
/memory list
/memory show
```

`/memory list` should include the root `GEMINI.md`.

## Why This Exists

Codex reads `AGENTS.md` as project instructions. Gemini CLI does not use that
file as its default context contract; it uses `GEMINI.md`. Without the shim,
Gemini may use the Dart MCP server and read app code before it has loaded the
office activation and status rules.

The `.gemini/settings.json` file configures tools. It does not replace
`GEMINI.md` as the behavioral instruction layer.
