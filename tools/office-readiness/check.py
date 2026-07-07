from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]

ROLE_NAMES = {
    "ceo": "CEO",
    "office-assistant": "Office Assistant",
    "product-lead": "Product Lead",
    "ui-ux-designer": "UI/UX Designer",
    "product-engineer": "Product Engineer",
    "senior-flutter-engineer": "Senior Flutter Engineer",
    "junior-flutter-developer": "Junior Flutter Developer",
    "qa-test-engineer": "QA/Test Engineer",
    "code-reviewer": "Code Reviewer",
    "release-engineer": "Release Engineer",
}

CODEX_AGENT_ROUTES = {
    "ceo": ("gpt-5.5", "high"),
    "office-assistant": ("gpt-5.4-mini", "medium"),
    "product-lead": ("gpt-5.4-mini", "medium"),
    "ui-ux-designer": ("gpt-5.5", "medium"),
    "product-engineer": ("gpt-5.5", "high"),
    "senior-flutter-engineer": ("gpt-5.5", "high"),
    "junior-flutter-developer": ("gpt-5.4-mini", "medium"),
    "qa-test-engineer": ("gpt-5.4-mini", "medium"),
    "code-reviewer": ("gpt-5.5", "high"),
    "release-engineer": ("gpt-5.5", "high"),
}

MOJIBAKE_MARKERS = ("隨・", "﨟・", "遯ｶ", "郢・", "・ｽ")


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def fail(message: str, failures: list[str]) -> None:
    failures.append(message)
    print(f"FAIL: {message}")


def ok(message: str) -> None:
    print(f"OK: {message}")


def role_banners() -> dict[str, str]:
    text = read("docs/ai-office/role-activation.md")
    banners_by_name = {
        name.strip(): banner.strip()
        for name, banner in re.findall(r"\| ([^|]+) \| `([^`]+)` \|", text)
    }
    return {
        role: banners_by_name.get(display_name, "")
        for role, display_name in ROLE_NAMES.items()
    }


def check_role_activation(failures: list[str]) -> None:
    text = read("docs/ai-office/role-activation.md")
    for role, banner in role_banners().items():
        if not banner or banner not in text:
            fail(f"role banner missing for {role}", failures)
    if any(marker in text for marker in MOJIBAKE_MARKERS):
        fail("role-activation.md contains mojibake markers", failures)
    else:
        ok("role activation banners are UTF-8 clean")


def check_codex_agents(failures: list[str]) -> None:
    for role, banner in role_banners().items():
        path = ROOT / ".codex" / "agents" / f"{role}.toml"
        if not path.exists():
            fail(f"missing Codex agent {path.relative_to(ROOT)}", failures)
            continue
        text = path.read_text(encoding="utf-8")
        if "developer_instructions" not in text:
            fail(f"{path.relative_to(ROOT)} lacks developer_instructions", failures)
        if "[instructions]" in text:
            fail(f"{path.relative_to(ROOT)} uses stale [instructions] table", failures)
        if banner not in text:
            fail(f"{path.relative_to(ROOT)} lacks canonical banner", failures)
        if "nickname_candidates" not in text:
            fail(f"{path.relative_to(ROOT)} lacks display nickname candidates", failures)
        model, effort = CODEX_AGENT_ROUTES[role]
        if f'model = "{model}"' not in text:
            fail(f"{path.relative_to(ROOT)} should route to {model}", failures)
        if f'model_reasoning_effort = "{effort}"' not in text:
            fail(f"{path.relative_to(ROOT)} should use {effort} reasoning", failures)
    ok("Codex role agent files checked")


def check_claude_agents(failures: list[str]) -> None:
    for role, banner in role_banners().items():
        path = ROOT / ".claude" / "agents" / f"{role}.md"
        if not path.exists():
            fail(f"missing Claude agent {path.relative_to(ROOT)}", failures)
            continue
        text = path.read_text(encoding="utf-8")
        if not text.startswith("---"):
            fail(f"{path.relative_to(ROOT)} lacks YAML frontmatter", failures)
        if f"name: {role}" not in text:
            fail(f"{path.relative_to(ROOT)} has wrong name frontmatter", failures)
        if banner not in text:
            fail(f"{path.relative_to(ROOT)} lacks canonical banner", failures)
    ok("Claude role agent files checked")


def check_mcp_configs(failures: list[str]) -> None:
    for path in [".mcp.json", ".claude/settings.json"]:
        full = ROOT / path
        if not full.exists():
            fail(f"missing MCP config {path}", failures)
            continue
        data = json.loads(full.read_text(encoding="utf-8"))
        dart = data.get("mcpServers", {}).get("dart")
        if not dart or dart.get("command") != "fvm":
            fail(f"{path} does not configure the FVM Dart MCP server", failures)
    codex_config = read(".codex/config.toml")
    if "[mcp_servers.dart]" not in codex_config:
        fail(".codex/config.toml does not configure the Dart MCP server", failures)
    if "max_depth = 1" not in codex_config:
        fail(".codex/config.toml should keep agent max_depth at 1", failures)
    ok("MCP configs checked")


def check_context_summary_wiring(failures: list[str]) -> None:
    required = [
        "docs/features/README.md",
        "docs/ai-office/async-agent-runtime.md",
        "docs/ai-office/context-compression.md",
        "docs/ai-office/token-budgeting.md",
        "docs/ai-office/templates/agent-session-packet.md",
        "docs/ai-office/templates/context-summary.md",
    ]
    for path in required:
        if "context-summary.md" not in read(path):
            fail(f"{path} does not reference context-summary.md", failures)
    ok("context summary wiring checked")


def check_token_budgeting_wiring(failures: list[str]) -> None:
    if not (ROOT / "docs/ai-office/token-budgeting.md").exists():
        fail("missing docs/ai-office/token-budgeting.md", failures)
        return

    referenced_by = [
        "AGENTS.md",
        "docs/ai-office/README.md",
        "docs/ai-office/task-triage.md",
        "docs/ai-office/runtime-adapters.md",
        "docs/ai-office/async-agent-runtime.md",
        "docs/ai-office/context-compression.md",
        "docs/ai-office/templates/agent-session-packet.md",
        "docs/ai-office/templates/agent-outbox.md",
        "docs/ai-office/templates/context-summary.md",
        "docs/ai-office/local-memory.md",
        "docs/ai-office/quality-gates.md",
    ]
    for path in referenced_by:
        if "token-budgeting.md" not in read(path):
            fail(f"{path} does not reference token-budgeting.md", failures)

    tier_doc = read("docs/ai-office/token-budgeting.md")
    triage_doc = read("docs/ai-office/task-triage.md")
    for tier in ["T0", "T1", "T2", "T3", "T4"]:
        if tier not in tier_doc:
            fail(f"token-budgeting.md does not define {tier}", failures)
        if tier not in triage_doc:
            fail(f"task-triage.md does not route {tier}", failures)

    packet = read("docs/ai-office/templates/agent-session-packet.md")
    outbox = read("docs/ai-office/templates/agent-outbox.md")
    if "Model route" not in packet or "Task tier" not in packet:
        fail("agent-session-packet.md lacks task tier/model route fields", failures)
    if "Token telemetry" not in outbox:
        fail("agent-outbox.md lacks token telemetry field", failures)
    ok("token budgeting wiring checked")


def check_local_memory_wiring(failures: list[str]) -> None:
    required = [
        "tools/office-memory/index.py",
        "tools/office-memory/search.py",
        "tools/office-memory/remember.py",
        "docs/ai-office/local-memory.md",
        "docs/ai-office/memory-history/.gitkeep",
    ]
    for path in required:
        if not (ROOT / path).exists():
            fail(f"missing local memory artifact {path}", failures)
    local_memory_doc = read("docs/ai-office/local-memory.md")
    if "--allow-download" not in local_memory_doc:
        fail("local-memory.md does not document consent-gated downloads", failures)
    if "memory-history" not in local_memory_doc:
        fail("local-memory.md does not document tracked memory history", failures)
    ok("local memory wiring checked")


def git_branches() -> set[str]:
    try:
        result = subprocess.run(
            ["git", "branch", "--list", "--all"],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
    except OSError:
        return set()
    names: set[str] = set()
    for line in result.stdout.splitlines():
        cleaned = line.strip().lstrip("* ").strip()
        if not cleaned or " -> " in cleaned:
            continue
        names.add(cleaned)
        if cleaned.startswith("remotes/origin/"):
            names.add(cleaned.removeprefix("remotes/origin/"))
    return names


def check_status_index(failures: list[str]) -> None:
    text = read("docs/features/status-index.md")
    if "Handoff: `missing`" in text:
        fail("status-index still has a missing handoff marker", failures)
    branches = git_branches()
    for branch in re.findall(r"Source of truth: `([^`]+)`", text):
        if branch.startswith("<") and branch.endswith(">"):
            continue
        if branch not in branches and branch not in {"main", "org/main"}:
            fail(f"status-index references unavailable source branch {branch}", failures)
    ok("feature status index checked")


def check_mojibake(failures: list[str]) -> None:
    paths = [
        "AGENTS.md",
        "CEO_OVERVIEW.md",
        "README.md",
        "CLAUDE.md",
        "GEMINI.md",
        "docs/ai-office",
        ".codex/agents",
        ".claude/agents",
    ]
    for entry in paths:
        full = ROOT / entry
        files = [full] if full.is_file() else list(full.rglob("*"))
        for path in files:
            if path.is_file() and path.suffix in {".md", ".toml"}:
                text = path.read_text(encoding="utf-8", errors="replace")
                if any(marker in text for marker in MOJIBAKE_MARKERS):
                    fail(f"mojibake marker found in {path.relative_to(ROOT)}", failures)
    ok("mojibake scan checked")


def main() -> int:
    failures: list[str] = []
    check_role_activation(failures)
    check_codex_agents(failures)
    check_claude_agents(failures)
    check_mcp_configs(failures)
    check_context_summary_wiring(failures)
    check_token_budgeting_wiring(failures)
    check_local_memory_wiring(failures)
    check_status_index(failures)
    check_mojibake(failures)

    if failures:
        print(f"\nOffice readiness failed with {len(failures)} issue(s).")
        return 1
    print("\nOffice readiness checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
