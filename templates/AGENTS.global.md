# Global AGENTS.md

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
