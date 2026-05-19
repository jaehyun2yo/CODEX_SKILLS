# Fast Path Policy

Fast path keeps tiny work efficient without bypassing the harness silently.

## Allowed Only With User Approval

The agent may propose fast path, but the user must approve it each time.

Required wording:

```text
This looks small enough for fast path because <specific reason>.
I would skip full brainstorming/planning, make the narrow change, run <check>,
and do a short review pass. Proceed with fast path?
```

## Good Fast Path Candidates

- typo or wording change
- single command output
- simple file read/report
- one-line config change with obvious effect
- mechanical rename with clear scope
- small bug with existing failing test and obvious fix

## Not Fast Path

- new feature
- UI/UX design change
- architecture change
- data model or migration
- auth, permission, security, payment, billing, messaging
- production data or deploy
- external API side effects
- ambiguous user intent
- no obvious verification command

## Fast Path Still Requires

- scoped edit
- relevant verification
- short review pass
- final report with skipped steps named
