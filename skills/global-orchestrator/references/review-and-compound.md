# Review And Compound

## Independent Review

For non-trivial work, the implementer cannot be the only final reviewer.

Preferred order:

1. Use a separate reviewer agent when the platform and user permit subagents.
2. Use Compound/GStack review skills when they fit the change type.
3. If separate review is unavailable, run a fresh-context main-thread review
   and disclose that limitation.

Review must inspect:

- requirements and acceptance criteria
- diff and touched files
- tests and skipped checks
- edge cases and regressions
- maintainability
- security, data, API, or deployment risk when relevant

Critical or Important findings must be fixed and re-reviewed.

## Learning Capture

Capture a durable lesson when a review or verification found something that
would change future behavior.

Use one of:

- `superpowers-compound-review-loop`
- Compound `ce-compound`
- Compound `ce-compound-refresh`
- GStack learn/artifacts

Do not save a learning for:

- clean review with no reusable lesson
- one-off typo
- generic advice
- unverified speculation

Learning should include:

- bad pattern
- root cause
- future trigger
- prevention check
- evidence from this task
