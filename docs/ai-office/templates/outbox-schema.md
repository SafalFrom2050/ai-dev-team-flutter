# Structured Handoff (JSON Outbox) Schema

This template defines the structured JSON outbox format. While Markdown outboxes (`outbox/<role-slug>.md`) remain the human-readable default, JSON outboxes (`outbox/<role-slug>.json`) are optional files that enable programmatic parsing by orchestration agents to automate feature-loop handoffs.

## Filename Convention

Place the JSON outbox file in the feature's outbox directory:
- Human Outbox: `docs/features/<feature-slug>/async/outbox/<role-slug>.md`
- JSON Outbox: `docs/features/<feature-slug>/async/outbox/<role-slug>.json`

## JSON Schema Definition

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "AgentOutbox",
  "type": "object",
  "properties": {
    "role": {
      "type": "string",
      "description": "The office role that produced this handoff (e.g., senior-flutter-engineer, qa-test-engineer)."
    },
    "branch": {
      "type": "string",
      "description": "The git branch where the work was executed."
    },
    "status": {
      "type": "string",
      "enum": ["in-progress", "complete", "blocked"],
      "description": "Execution status of the role's task."
    },
    "files_changed": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "description": "List of files created or modified by the agent."
    },
    "decisions_made": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "description": "Key technical or design choices recorded in the repo."
    },
    "tests_passed": {
      "type": "boolean",
      "description": "Whether all automated tests run by the agent passed successfully."
    },
    "test_evidence": {
      "type": "string",
      "description": "Details of manual verification or command logs (e.g., screenshot URLs, test output summaries)."
    },
    "blockers": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "description": "Issues preventing completion of the task."
    },
    "open_questions": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "description": "Unresolved questions requiring user or CEO input."
    },
    "recommended_next_agents": {
      "type": "array",
      "items": {
        "type": "string"
      },
      "description": "Roles that should be activated next in the feature loop."
    }
  },
  "required": ["role", "branch", "status", "files_changed", "decisions_made", "tests_passed"]
}
```

## Example JSON Outbox

Below is an example of `junior-flutter-developer.json`:

```json
{
  "role": "junior-flutter-developer",
  "branch": "feat/sleep-tracker/widgets",
  "status": "complete",
  "files_changed": [
    "work/sleep-tracker-app/lib/features/dashboard/widgets/sleep_progress_bar.dart",
    "work/sleep-tracker-app/test/widgets/sleep_progress_bar_test.dart"
  ],
  "decisions_made": [
    "Used custom painter for smooth arc rendering to match UI designs.",
    "Isolated animations inside the widget so parent does not rebuild repeatedly."
  ],
  "tests_passed": true,
  "test_evidence": "All widget tests in sleep_progress_bar_test.dart passed. Screenshots saved to docs/features/sleep-tracker/assets/progress_bar_states.png",
  "blockers": [],
  "open_questions": [],
  "recommended_next_agents": [
    "qa-test-engineer",
    "code-reviewer"
  ]
}
```

## Parsing Behavior

The Orchestrator agent checks for the existence of `*.json` outboxes inside the feature's outbox directory to:
1. Update the status dashboard automatically.
2. Route branches to QA if `tests_passed` is true and `status` is complete.
3. Halt execution and alert the user if any item exists in `blockers`.
