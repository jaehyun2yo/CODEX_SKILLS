# Prompt Quality Check

Use this rubric before planning or implementation.

## Required Context

The prompt is strong enough when these are clear:

- **Goal**: what outcome the user wants.
- **Target**: app, file, workflow, feature, or command.
- **Success criteria**: how the user will know it worked.
- **Constraints**: tech, UX, compatibility, timing, style, safety.
- **Non-goals**: what should not change.
- **Risk**: data, auth, external systems, deploy, money, messages.
- **Verification**: tests, build, visual QA, manual check, or command output.

## Weak Prompt Signals

Route to clarification or brainstorming when you see:

- vague verbs: "fix", "improve", "make better", "clean up"
- missing target surface
- multiple possible interpretations
- UI or product taste decisions
- hidden data model or migration impact
- external API or production side effects
- no acceptance criteria

Ask one focused question at a time. Prefer choices when they speed decision
making.

## Minimal Question Templates

Use these when helpful:

```text
What should count as success for this change?
```

```text
Which surface should this apply to: <A>, <B>, or <C>?
```

```text
This could be solved as <A> or <B>. Which direction do you want?
```

```text
This touches <risk>. Should I treat it as a dry-run/design task first?
```
