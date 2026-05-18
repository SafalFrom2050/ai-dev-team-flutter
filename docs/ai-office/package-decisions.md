# Package Decisions

Flutter agents should not casually add packages. Every new dependency should
earn its place.

Use one short decision record per dependency:

```text
docs/package-decisions/<package-name>.md
```

## Decision Template

```markdown
# Package Decision: <package>

## Use Case

Why do we need this package?

## Options Compared

| Package | Pros | Cons |
| --- | --- | --- |
|  |  |  |

## Decision

Chosen package:

Reason:

## Risk

- Maintenance:
- License:
- Platform support:
- Bundle size:
- API stability:

## Exit Strategy

How hard would this be to replace later?
```

## Default Rule

Prefer Flutter/Dart standard libraries and existing project dependencies first.
Use packages when they reduce real complexity or provide mature platform
behavior that would be risky to hand-roll.

