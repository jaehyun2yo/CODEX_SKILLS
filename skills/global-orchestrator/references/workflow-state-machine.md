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

## 5. Execute

Implement narrowly. Preserve unrelated user changes. Prefer existing project
patterns over new abstractions.

## 6. Verify

Run fresh checks that prove the claim being made. Partial checks prove only the
part they cover. If verification cannot run, state why.

## 7. Independent Review

Use a reviewer agent when allowed by the active platform and user instructions.
If unavailable, run a separate review pass in the main thread and disclose the
limitation.

## 8. Compound Or Learning

Capture durable lessons only when they would change a future run. Do not record
generic advice or clean no-finding reviews.

## 9. Final Report

Lead with outcome, then evidence. Include skipped checks and remaining risks.
