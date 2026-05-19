# Workflow State Machine

Use this as the canonical flow for the global orchestrator.

## 1. Intake

Identify request type, repository context, risk level, and whether the user is
asking for action, advice, or status.

Read local guidance before edits:

- `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`
- README and relevant docs
- package scripts, test config, CI config
- nearby project-specific conventions

## 2. Prompt Quality Check

Do not turn a weak prompt into implementation. Check goal, target surface,
success criteria, constraints, risk, and verification.

If weak, ask one question at a time or route to brainstorming.

## 3. Clarify Or Brainstorm

Default to brainstorming for:

- new behavior
- UI/product decisions
- architecture or data changes
- ambiguous scope
- multi-step work
- anything with user-visible impact

Tiny tasks may use fast path only after user approval.

## 4. Plan

When the design is approved, create or follow an implementation plan. The plan
must include:

- files/modules likely touched
- validation commands
- review path
- risk gates
- documentation or learning updates

## 5. Recommend Plan Review

Before implementation, recommend the GStack plan review that best matches the
work. Ask for approval before running it.

Recommendation wording:

```text
추천하는 계획 리뷰는 `<skill>`입니다. 이유는 <reason>입니다.
이 리뷰를 먼저 진행할까요?
```

Use:

- `gstack-plan-eng-review` for implementation, architecture, backend, tests,
  reliability, refactors, data flow.
- `gstack-plan-design-review` for UI/UX, visual design, user flow, interaction.
- `gstack-plan-devex-review` for setup, install, CLI, local development, CI,
  release, test ergonomics.
- `gstack-plan-ceo-review` for product scope, business priority, sequencing,
  user value.
- `gstack-autoplan` for broad, high-risk, ambiguous, cross-cutting work that
  needs multiple lenses.

If the user declines, continue only after noting that the plan review was
skipped by user choice.

## 6. Execute

Implement narrowly. Preserve unrelated user changes. Prefer existing project
patterns over new abstractions.

## 7. Verify

Run fresh checks that prove the claim being made. Partial checks prove only the
part they cover. If verification cannot run, state why.

## 8. Independent Review

Use a reviewer agent when allowed by the active platform and user instructions.
If unavailable, run a separate review pass in the main thread and disclose the
limitation.

## 9. Compound Or Learning

Capture durable lessons only when they would change a future run. Do not record
generic advice or clean no-finding reviews.

## 10. Final Report

Lead with outcome, then evidence. Include skipped checks and remaining risks.
