---
name: superpowers-compound-review-loop
description: Run after a Superpowers execution/review cycle finishes, especially after requesting-code-review, receiving-code-review, subagent-driven-development, or verification-before-completion. Captures mistakes, review findings, fixes, and lessons through Compound Engineering so future execution-review cycles do not repeat the same failures.
---

# Superpowers Compound Review Loop

## Overview

Use this skill as the final learning step after a Superpowers review cycle has completed and all accepted feedback has been handled. It does not replace Superpowers review; it records the reusable lessons from that review by invoking or following Compound Engineering's `ce-compound` process.

## Trigger Point

Run this immediately after the review is complete and before moving to the next task, claiming completion, merging, or wrapping up.

Use it when any of these occurred:

- Superpowers `requesting-code-review` found a real issue.
- Superpowers `receiving-code-review` caused code, tests, plan, or docs to change.
- `subagent-driven-development` review caught spec drift, quality issues, missing tests, or incomplete work.
- `verification-before-completion` exposed a false completion claim or missing evidence.
- A review discussion produced a durable rule, checklist item, project convention, or testing lesson.

Skip it only when the review was clean and there is no new lesson beyond "no findings".

## Workflow

1. Summarize the execution-review cycle in 3-6 bullets:
   - task or plan step reviewed
   - review source
   - concrete mistake or missed consideration
   - fix applied or decision made
   - evidence that the fix now holds

2. Convert each useful lesson into a reusable rule:
   - bad pattern: what happened
   - root cause: why it was missed
   - future trigger: when another agent should remember it
   - prevention: exact check, test, prompt, or project convention to apply next time

3. Run Compound Engineering's learning step:
   - Prefer the installed `ce-compound` skill if available.
   - If `ce-compound-refresh` is more appropriate for updating an existing note, use it instead.
   - If Compound skills are not currently loaded, read the installed CE skill from `~/.codex/skills/ce-compound/SKILL.md` or the plugin cache and follow its process manually.

4. Keep the compound note factual and small. Do not record generic advice. Record only lessons that would have changed this review outcome.

5. After compounding, report the saved location or state clearly that no durable note was created because there was no reusable lesson.

## Output Shape

When reporting back, use:

```text
Compound review loop:
- Source review: <Superpowers skill or review phase>
- Lessons captured: <count>
- Saved to: <path or "not saved">
- Next-cycle guardrail: <one concise rule>
```

## Guardrails

- Do not edit vendored Superpowers or Compound Engineering skill files to add this behavior.
- Do not compound unverified guesses. Lessons must be grounded in a real finding, fix, or review discussion.
- Do not create process noise for trivial clean reviews.
- Prefer project-local learning artifacts when CE chooses a path; only write global notes when the lesson is cross-project.
