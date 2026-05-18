# AI Office

This project is designed as an AI dev office: a coordinated team of specialist
agents that can take an idea from rough product intent to production Flutter
code on `main`.

The core trick is to make every non-code contribution concrete. Product agents
write scoped briefs. Designer agents write versioned UX and design contracts.
Architecture agents write decisions and boundaries. Developer agents implement
small slices. Review and QA agents protect `main`.

The office structure itself is meant to live on `org/main`, a durable
organization branch that future products can inherit.

## The Best-Default Workflow

1. Intake the idea.
2. Create `docs/features/<feature-slug>/brief.md`.
3. Create `integrate/<feature-slug>` from `main`.
4. Product, design, and architecture agents open their own branches and PRs into
   the integration branch.
5. Flutter developer agents implement scoped slices from the approved docs.
6. QA and review agents file fixes against the integration branch.
7. Release Engineer opens one final PR from `integrate/<feature-slug>` to
   `main`.

This gives every agent freedom to work in parallel while keeping `main` clean.

## Why Not Let Every Agent Merge To Main?

`main` should not be the office whiteboard. It is the production branch. The
integration branch is where the team assembles the feature, handles conflicts,
and proves the result.

## Where Designer Agents Fit

Designer agents should use branches too, but their outputs are different from
coder outputs. They own:

- User journeys and screen states.
- Interaction rules and empty/error/loading states.
- Visual hierarchy and component behavior.
- Design tokens and theme requirements.
- Golden-test expectations for important UI.
- Copy guidelines for user-facing text.

For Flutter, the designer's best repo-native artifacts are Markdown contracts,
theme/token changes, reusable widget specs, and golden references. That keeps
design close to implementation without pretending design is only code.

## Office Structure

- CEO: owns the office vision, team structure, decision history, and
  `CEO_OVERVIEW.md`.
- Office Assistant: triages incoming tasks and routes work to the right role
  sequence.
- Product Lead: decides what problem is worth solving.
- UI/UX Designer: defines how the experience should feel and behave.
- Product Engineer: bridges product/design intent into buildable architecture.
- Senior Flutter Engineer: owns hard implementation and patterns.
- Junior Flutter Developer: implements narrow slices with tests.
- QA/Test Engineer: proves the feature works across states and devices.
- Code Reviewer: protects maintainability, correctness, and clarity.
- Release Engineer: protects `main` and manages production readiness.

See `roles.md`, `workflow.md`, and `quality-gates.md` for the operating details.

The CEO-level map lives at the repository root in `CEO_OVERVIEW.md`.

For stable company-structure branching, use:

- `org-branch-model.md`

For task triage, use:

- `task-triage.md`

For Flutter-specific behavior, start with:

- `flutter-specialization.md`
- `mcp-and-skills.md`
- `package-decisions.md`

For parallel or multi-session role execution, use:

- `async-agent-runtime.md`
