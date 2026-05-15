<!-- BEGIN COMPOUND CODEX TOOL MAP -->
## Compound Codex Tool Mapping (Claude Compatibility)

This section maps Claude Code plugin tool references to Codex behavior.
Only this block is managed automatically.

Tool mapping:
- Read: use shell reads (cat/sed) or rg
- Write: create files via shell redirection or apply_patch
- Edit/MultiEdit: use apply_patch
- Bash: use shell_command
- Grep: use rg (fallback: grep)
- Glob: use rg --files or find
- LS: use ls via shell_command
- WebFetch/WebSearch: use curl or Context7 for library docs
- AskUserQuestion/Question: present choices as a numbered list in chat and wait for a reply number. For multi-select (multiSelect: true), accept comma-separated numbers. Never skip or auto-configure — always wait for the user's response before proceeding.
- Task (subagent dispatch) / Subagent / Parallel: run sequentially in main thread; use multi_tool_use.parallel for tool calls
- TaskCreate/TaskUpdate/TaskList/TaskGet/TaskStop/TaskOutput (Claude Code task-tracking, current): use update_plan (Codex's task-tracking primitive)
- TodoWrite/TodoRead (Claude Code task-tracking, legacy — deprecated, replaced by Task* tools): use update_plan
- Skill: open the referenced SKILL.md and follow it
- ExitPlanMode: ignore
<!-- END COMPOUND CODEX TOOL MAP -->

## Mandatory Workflow Role Separation

Development and review must be separate for non-trivial work.

- The same agent that plans or implements a change must not be the only final
  reviewer of that change.
- When Codex subagents are available and permitted, dispatch a separate reviewer
  agent for review instead of relying only on self-review.
- The reviewer must inspect the work product independently: requirements, diff,
  tests, regressions, edge cases, and maintainability.
- Review findings rated Critical or Important must be fixed by the implementer
  and re-reviewed before completion is claimed.
- If an active tool-compatibility rule prevents true subagent dispatch, keep the
  roles explicitly separated in the main thread, state the limitation, and run a
  fresh-context review pass before finalizing.

This workflow rule is separate from the Claude compatibility tool map above.
The tool map describes how unavailable Claude tools are translated; it does not
waive the requirement that development and review be separated.
