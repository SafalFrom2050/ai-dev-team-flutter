# Opus Review

External review of the AI Flutter office operating system by Claude Opus,
conducted on 2026-05-19. This documents the issues found, solutions applied, and
improvements made.

## Review Scope

Reviewed all files on `org/main`: 30+ Markdown documents, 8 templates, MCP and
skill configs, git history, and branch structure.

---

## Issue 1: Office Assistant Required Explicit Invocation

### Issue

Users had to type `Office Assistant: <task>` to activate triage. This forced
users to remember the role name and the invocation prefix before they could
interact with the office. It added friction to the most common entry point.

### Solution

Made the Office Assistant the **default mode**. Any unstructured prompt that does
not begin with a specific role name automatically activates the Office Assistant.

Direct role invocation (for example, `Senior Flutter Engineer: implement X`)
bypasses the Office Assistant and activates that role directly.

### What Improved

- Zero-friction entry: users just describe their task naturally.
- The `Office Assistant:` prefix is no longer required.
- Direct role invocation is still available as an escape hatch.
- The routing rule is simple: no role prefix -> Office Assistant; role prefix -> that role.

### Files Changed

- `AGENTS.md` (Collaboration Rules)
- `docs/ai-office/roles.md` (Office Assistant role definition)
- `docs/ai-office/task-triage.md` (activation rules)
- `docs/ai-office/user-activation.md` (minimal prompt section)
- `docs/ai-office/role-activation.md` (activation rules)
- `README.md` (How To Fire Up The Office)

---

## Issue 2: Office Assistant Produced Routing Metadata Instead Of Actionable Output

### Issue

The Office Assistant's default output was structured metadata about what to do
next:

```text
Recommended owner:
Supporting roles:
Branch:
Feature folder:
Packets to create:
```

This told the user which packets to create, but the user still had to write them
manually. The Office Assistant described the work instead of producing the work
product.

### Solution

Changed the Office Assistant's primary output to **ready-to-paste agent
packets**. Each packet is a complete prompt that the user can copy-paste directly
into a separate agent session.

### What Improved

- The Office Assistant's output is immediately actionable.
- Users no longer need to manually write agent prompts.
- The workflow becomes: describe task -> get packets -> paste into sessions.
- Packet generation is defined with a concrete output format in `task-triage.md`.

### Files Changed

- `docs/ai-office/task-triage.md` (complete rewrite of output format)
- `docs/ai-office/user-activation.md` (updated response examples)
- `README.md` (added packet example in activation section)

---

## Issue 3: Office Assistant Could Accidentally Execute Tasks

### Issue

During testing, the Office Assistant started writing code and modifying files
when it should have only been planning. The existing status-is-read-only rule
partially addressed this, but the general-case behavior was unclear: should the
Office Assistant ever implement tasks?

### Solution

Added an explicit rule: **the Office Assistant produces packets but never
executes them**. It never writes feature code, creates branches, or modifies
project files. It analyzes, plans, and outputs.

This generalizes the status-is-read-only rule to cover all Office Assistant
behavior, not just status requests.

### What Improved

- Clear separation: Office Assistant is the brain (analysis + packets),
  specialist roles are the hands (implementation).
- The human is the orchestrator who decides which packets to run and when.
- Eliminates the risk of the Office Assistant bypassing the role system.

### Files Changed

- `AGENTS.md` (Collaboration Rules: "produces packets, never executes")
- `docs/ai-office/roles.md` (Office Assistant "Should not" list)
- `docs/ai-office/task-triage.md` (ownership boundaries)

---

## Issue 4: Agent Session Packet Template Was Over-Specified

### Issue

The agent session packet template had 12 fields:

```text
Role, Activation banner, Mission, Branch, Inputs, Files owned, Files to avoid,
Commands to run, Required outputs, Definition of done, Stop conditions
```

Several fields were redundant (Definition of done repeats Mission) or
inferrable by the agent (Commands to run). The template was heavier than needed,
which discouraged use and inflated context windows.

### Solution

Slimmed the template to the essential fields that prevent collisions and enable
handoffs. After CEO review, every packet answers five core questions:

1. Who are you? (activation banner)
2. What is your job? (Role + Mission)
3. What branch? (prevents commit collisions)
4. What files are yours / off-limits? (prevents edit collisions)
5. Who else is working and what do you leave behind? (enables handoffs)

Added: Files To Avoid, Other Agents Working Now (critical for parallel work).
Restored after CEO review: Activation banner as the first visible line in every
copy-pasted packet.
Removed: Commands to run, Definition of done (redundant).
Kept as optional: Context references, stop conditions.

### What Improved

- Packets are shorter (under 200 words target) and fit better in AI context
  windows.
- The essential collision-prevention fields are explicit and required.
- The template matches the format the Office Assistant generates.

### Files Changed

- `docs/ai-office/templates/agent-session-packet.md` (complete rewrite)
- `docs/ai-office/async-agent-runtime.md` (updated packet section with example)

---

## Issue 5: README Activation Section Was Procedure-Heavy

### Issue

The README's "How To Fire Up The Office" section required users to understand
CEO kickoff prompts, integration branch creation, feature folder structure, and
async packet directory layout before they could start.

### Solution

Replaced the section with the new activation model: just describe your task,
get packets, paste into sessions. Added a concrete packet example so visitors
can see what the output looks like.

### What Improved

- First-time visitors see a working example immediately.
- The activation section matches the actual user experience.
- Reduced from ~75 lines of procedure to ~50 lines of examples.

### Files Changed

- `README.md` (How To Fire Up The Office section)

---

## CEO Resolution

Accepted with amendments after review:

- Keep no-prefix Office Assistant as the default entry point.
- Keep Office Assistant packet-only: it analyzes and produces packets, but does
  not execute product/design/code/QA work itself.
- Keep activation banners inside generated packets so pasted role sessions still
  announce themselves before doing task work.
- Record this operating-model change in `CEO_OVERVIEW.md`.
- Use ASCII arrows in this review file to avoid encoding issues.

---

## Summary Of Changes

| File | Change Type |
|---|---|
| `AGENTS.md` | Default mode rule, packet-only output, collaboration rules |
| `README.md` | Simplified activation section with packet example |
| `docs/ai-office/roles.md` | Office Assistant role redefined as packet generator |
| `docs/ai-office/task-triage.md` | Complete rewrite: packet output format and routing |
| `docs/ai-office/user-activation.md` | Complete rewrite: no-prefix activation, packet output |
| `docs/ai-office/role-activation.md` | Updated banner text and default-mode rules |
| `docs/ai-office/async-agent-runtime.md` | Updated packet section with example format |
| `docs/ai-office/templates/agent-session-packet.md` | Slimmed to essential fields |
| `CEO_OVERVIEW.md` | Recorded the accepted hybrid operating decision |
| `OPUS_REVIEW.md` | Fixed encoding artifacts and documented CEO amendments |

## Design Principles Applied

1. **The default should require zero ceremony.** Any prompt is an Office
   Assistant prompt unless the user explicitly invokes a role.

2. **Output should be immediately actionable.** The Office Assistant produces
   ready-to-paste packets, not metadata about packets.

3. **Analysis and execution are separate concerns.** The Office Assistant
   analyzes. Specialist agents execute. The human orchestrates.

4. **Packets prevent collisions through core fields.** Activation banner,
   mission, branch, files owned, files to avoid, and handoff target are the
   required context.
