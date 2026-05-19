# Risk Gates

Stop for explicit user approval before actions that can affect real users,
money, data, infrastructure, or external systems.

## High-Risk Actions

- production deploy
- database migration or destructive data change
- deleting, moving, or overwriting user data
- real email, SMS, fax, push, or billing action
- external API calls with side effects
- secrets or credential handling
- auth/permission changes
- payment, invoice, or customer data flows
- public endpoint or security-sensitive middleware changes

## Required Handling

For high-risk work:

1. Name the risk.
2. Prefer dry-run, staging, mock, or design-only mode first.
3. Ask for explicit approval before real side effects.
4. Add security/data/API review where relevant.
5. Verify rollback or recovery path when applicable.

## Approval Wording

```text
This can affect <system/data/users>. I can first do <safe option>.
Do you approve running the real side-effecting step <exact command/action>?
```
