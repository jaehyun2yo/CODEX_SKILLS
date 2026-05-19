# Global AGENTS.md

## Global Workflow Orchestrator

At the start of every user task, apply the `global-orchestrator` skill before
planning, editing, running tests, or asking broad follow-up questions.

The orchestrator is the common workflow harness for all projects:

- inspect prompt quality and missing context first;
- default to full orchestration for non-trivial work;
- use brainstorming for unclear, product, design, architecture, behavior, or
  multi-step work;
- move approved designs into planning before implementation;
- after drafting a non-trivial plan, recommend the most relevant GStack plan
  review skill and ask the user before running it;
- run implementation, verification, independent review, learning capture, and
  final reporting in that order;
- treat fast path as an exception that always requires user approval;
- block fast path for risky work such as production data, secrets, deploys,
  migrations, destructive changes, real external API side effects, billing, or
  user/customer communications.

If another skill also applies, use `global-orchestrator` first to choose the
route, then invoke the more specific skill.

Plan review recommendation wording:

> 추천하는 계획 리뷰는 `<skill>`입니다. 이유는 <reason>입니다.
> 이 리뷰를 먼저 진행할까요?

## Mandatory Developer / Reviewer Separation

For non-trivial planning or implementation work, development and review must be
performed by separate agents or, when the active platform cannot dispatch a
separate agent, by clearly separated roles with fresh review context.

Required separation:

- The agent that plans or implements a change must not be the sole final
  reviewer of that same change.
- Use a distinct reviewer agent for inspection whenever subagent dispatch is
  available and permitted by the active environment.
- Review must happen after implementation and before claiming completion,
  merging, shipping, or moving to the next major task.
- Reviewer context should focus on the work product, requirements, diff, tests,
  and risks. Do not rely on the implementer's internal reasoning as evidence.
- The reviewer must check both requirement/spec compliance and code quality.
- If the reviewer finds Critical or Important issues, the implementer fixes
  them and the reviewer re-checks before the task is considered complete.
- If a separate reviewer agent cannot be used, explicitly state that limitation
  and run an independent review pass before finalizing.

Default role split:

- Planning agent: clarifies requirements, constraints, risks, and acceptance
  criteria.
- Development agent: implements the approved work and runs relevant tests.
- Review agent: independently verifies correctness, completeness, regressions,
  test coverage, maintainability, and alignment with the plan.

Completion rule: do not present work as complete until the independent review
step is complete, or until the user explicitly waives review for that task.

## Superpowers Compound Review Hook

When a Superpowers execution/review cycle finishes, run the custom
`superpowers-compound-review-loop` skill before moving to the next task,
claiming completion, merging, or wrapping up.

This applies after:

- `superpowers:requesting-code-review`
- `superpowers:receiving-code-review`
- `superpowers:subagent-driven-development` review phases
- `superpowers:verification-before-completion`

The custom skill must use Compound Engineering's `ce-compound` or
`ce-compound-refresh` process to capture concrete mistakes, review findings,
fixes, and reusable lessons from the execution-review cycle.

Do not edit vendored Superpowers, gstack, or Compound Engineering skill files
for this integration. Keep local workflow customizations in
`~/.codex/skills/superpowers-compound-review-loop` or another custom skill so
upstream package updates do not overwrite them.
