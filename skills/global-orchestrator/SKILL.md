---
name: global-orchestrator
description: Shared AI workflow orchestrator for every user task. Use at the start of work to inspect prompt quality, choose between full orchestration and user-approved fast path, trigger brainstorming/planning/debugging/review skills, enforce verification before completion, run independent review when required, and decide whether to capture lessons with Compound/GStack.
---

# Global Orchestrator

## Purpose

Use this skill as the first workflow layer for user work. It does not replace
Superpowers, GStack, or Compound Engineering. It routes to them in a predictable
order and prevents weak prompts from turning directly into implementation.

Default to full orchestration. Use fast path only after explaining why it is
safe and receiving user approval.

## State Machine

Follow this flow unless the user explicitly asks for a status-only answer or a
read-only explanation.

```text
intake
  -> prompt-quality-check
  -> clarify-or-brainstorm
  -> plan
  -> recommend-plan-review
  -> user-approved-plan-review
  -> execute
  -> verify
  -> independent-review
  -> compound-or-learning
  -> final-report
```

For details, read `references/workflow-state-machine.md` when starting a
non-trivial task.

## Intake

Classify the request before acting:

- **Answer-only**: explain, summarize, or report. No code changes expected.
- **Tiny operation**: command output, typo, one-line config, simple file read.
- **Implementation**: code, docs, behavior, UI, data, deployment, automation.
- **Risky operation**: production data, secrets, deploy, migration, deletion,
  real external API calls, billing, messages, or customer data.
- **Ambiguous operation**: missing goal, scope, success criteria, target files,
  constraints, or user impact.

If the task touches a repository, read applicable project guidance before
designing or editing: AGENTS/CLAUDE/GEMINI files, README, docs, package scripts,
and nearby conventions.

## Prompt Quality Gate

Before planning or implementing, check whether the request has enough context:

- goal
- target surface
- expected behavior or output
- constraints and non-goals
- success criteria
- risk level
- verification expectation

If any key item is missing, ask one focused question or invoke the relevant
brainstorming process. Read `references/prompt-quality-check.md` for the full
rubric.

## Fast Path Policy

Fast path is an exception, not the default.

You may propose fast path only when all are true:

- scope is small and localized
- existing pattern is obvious
- no production, data, auth, billing, messaging, deploy, migration, or deletion
  risk exists
- no meaningful product/design/architecture choice is hidden
- verification is simple and available

Always ask the user before fast path:

```text
This looks small enough for fast path because <reason>.
I would skip full brainstorming/planning, make the narrow change, run <check>,
and do a short review pass. Proceed with fast path?
```

If the user does not approve, use full orchestration. Read
`references/fast-path-policy.md` for examples.

## Skill Routing

Use existing skills rather than duplicating them:

- New feature, behavior change, unclear request: Superpowers brainstorming.
- Approved design moving to implementation: Superpowers writing-plans.
- Before implementing a non-trivial plan: recommend a GStack plan review and
  ask for approval.
- Bug or failing test: Superpowers systematic-debugging or GStack investigate.
- Test-first feature or bug fix: Superpowers test-driven-development.
- UI/web QA: GStack qa/qa-only or Compound frontend/design review skills.
- Code review: GStack review, Compound code review, or a dedicated reviewer
  agent when the platform permits it.
- Completion claims: Superpowers verification-before-completion.
- Durable lesson after review: superpowers-compound-review-loop, ce-compound,
  ce-compound-refresh, or GStack learn.

Project-specific adapters may refine this routing with exact commands and
risk lists.

## Plan Review Recommendation Gate

After a plan is drafted and before implementation, recommend the most relevant
GStack plan review skill. Do not run it automatically. Ask the user first.

Use this wording:

```text
추천하는 계획 리뷰는 `<skill>`입니다. 이유는 <reason>입니다.
이 리뷰를 먼저 진행할까요?
```

Choose:

- `gstack-plan-eng-review`: implementation, architecture, backend, data flow,
  tests, reliability, or refactoring risk.
- `gstack-plan-design-review`: UI/UX, layout, visual hierarchy, interaction,
  design system, or user flow risk.
- `gstack-plan-devex-review`: setup, install, CLI, local development, test
  ergonomics, CI, release, or contributor workflow risk.
- `gstack-plan-ceo-review`: product scope, business priority, user value,
  sequencing, or opportunity-cost risk.
- `gstack-autoplan`: broad, ambiguous, high-risk, cross-cutting, or multi-review
  work where several lenses are needed.

If the work is fast-path approved, simple documentation, typo-only, or a small
read-only task, state that plan review is not recommended and why.

## Execution Rules

- Do not implement while requirements are materially unclear.
- Do not skip brainstorming for non-trivial feature or behavior changes.
- Do not run a non-trivial plan review without user approval.
- Do not claim completion without fresh verification evidence.
- Do not be the sole final reviewer of non-trivial work.
- Preserve user changes in the working tree.
- For risky operations, stop and get explicit approval.

## Review And Learning

After implementation:

1. Run relevant deterministic checks.
2. Run independent review. Use a separate reviewer agent when allowed. If not,
   state the limitation and run a fresh-context review pass.
3. Fix Critical or Important findings and re-review.
4. Decide whether a durable lesson was learned. If yes, capture it through
   Compound/GStack. Read `references/review-and-compound.md`.

## Final Report

Report concisely:

- what changed
- files touched
- verification run and result
- review method and findings
- risks or skipped checks
- learning/artifact saved, if any

Never hide skipped verification or reviewer limitations.
