---
name: work-session-routing
description: Use when starting, resuming, wrapping up, or finishing coding work; Korean triggers include 작업 시작, 개발 시작, 코딩 시작, 시작하자, 이어서 개발, 어디까지 했지, 마무리, 작업 마무리, 세션 정리, wrap up, done, and when deciding current-branch quick edits vs main/master-based isolated branch work.
---

# Work Session Routing

## Overview

Route coding sessions without copying Superpowers workflows. This skill decides whether to stay on the current branch or invoke the relevant Superpowers skill, so Superpowers updates keep applying automatically.

**Branch base principle:** For isolated work, create the new branch/worktree from `main` or `master`, not from the currently checked-out branch, unless the user explicitly asks to branch from the current HEAD.

## Start Routing

Use this flow for "작업 시작", "개발 시작", "코딩 시작", "시작하자", "이어서 개발", "어디까지 했지", "start coding", "start dev", and similar requests.

1. First inspect the current git state and workspace:
   - `git branch --show-current`
   - `git status --short`
   - `git rev-parse --git-dir`
   - `git rev-parse --git-common-dir`
   - `git worktree list --porcelain`
   - `git remote -v`
2. Classify the requested work.
3. If the user only asks for status, branch, logs, read-only inspection, or a tiny current-branch edit, stay in the current workspace.
4. If the task is non-trivial, parallel, branch-isolated, or likely to touch multiple modules, select a `main`/`master` base ref using the Base Branch Rule below, then use **REQUIRED SUB-SKILL:** `superpowers:using-git-worktrees`.
5. If implementation begins, use **REQUIRED SUB-SKILL:** `superpowers:test-driven-development`.

## Base Branch Rule

When creating a branch or worktree for isolated work:

1. Prefer an updated remote base if available: run `git fetch --prune origin` when an `origin` remote exists and the command is available.
2. Choose `BASE_REF` in this order: `origin/main`, `origin/master`, `main`, `master`.
3. If none of those refs exists, stop and ask which base branch to use.
4. Pass the base explicitly to branch/worktree creation. Manual fallback must use:

```bash
git worktree add "$path" -b "$BRANCH_NAME" "$BASE_REF"
```

Never omit `"$BASE_REF"` from `git worktree add ... -b`; Git otherwise branches from the current HEAD. Do not switch the current checkout to `main`/`master` just to create the branch, especially when it has uncommitted changes.

Simple current-branch work:
- Single-file text/doc/config changes
- Typos, copy, comments, imports, formatting, obvious one-line fixes
- Read-only status checks, explanations, branch checks, or diff review
- User explicitly says to use the current branch

Worktree-isolated work:
- Feature work, bug fixes, refactors, UI redesign, algorithm changes, migrations, dependency changes
- Multiple files, multiple modules, unclear blast radius, or expected commit/PR
- Parallel panel work where design and algorithm work must keep separate branches checked out
- Any work where branch switching would disturb uncommitted changes

If the classification is ambiguous, ask exactly one short question: "현재 브랜치에서 빠르게 수정할까요, 아니면 worktree로 분리할까요?"

## Finish Routing

Use this flow for "마무리", "작업 마무리", "세션 정리", "커밋하고 끝", "wrap up", "done", and similar requests.

1. Use **REQUIRED SUB-SKILL:** `superpowers:verification-before-completion` before claiming work is complete.
2. Inspect whether the workspace is a normal checkout or a linked worktree:
   - `git rev-parse --git-dir`
   - `git rev-parse --git-common-dir`
   - `git branch --show-current`
   - `git status --short`
3. For simple current-branch work in a normal checkout, present only these options:

```text
현재 브랜치 작업 검증이 끝났습니다. 어떻게 마무리할까요?

1. 현재 브랜치에 커밋
2. 미커밋 상태로 유지
3. 내가 한 변경만 되돌리기
```

4. For linked worktrees, feature branches, PR work, merge requests, cleanup requests, or discard requests, use **REQUIRED SUB-SKILL:** `superpowers:finishing-a-development-branch`.

Never remove a worktree during current-branch finish mode. Never stage or revert unrelated user changes.

## Common Mistakes

| Mistake | Correct action |
|--------|----------------|
| Creating a worktree for a branch/status question | Answer in place |
| Keeping non-trivial parallel work in one checkout | Use `superpowers:using-git-worktrees` |
| Creating an isolated branch from the current feature branch | Use explicit `BASE_REF`: `origin/main`, `origin/master`, `main`, or `master` |
| Copying Superpowers instructions into this skill | Reference Superpowers by name so updates apply |
| Claiming completion before verification | Use `superpowers:verification-before-completion` |
| Cleaning up a worktree from a simple current-branch wrap-up | Do not offer worktree cleanup |

## Quick Reference

| User intent | Route |
|------------|-------|
| "현재 브랜치 뭐야" | Stay in place |
| "작업 시작" with no implementation yet | Inspect state, classify scope |
| Simple edit | Current branch |
| Feature/refactor/bug/UI/algorithm work | Branch from `main`/`master`, use `superpowers:using-git-worktrees`, then TDD |
| Parallel panels/branches | Branch each worktree from `main`/`master`, then use `superpowers:using-git-worktrees` |
| "마무리" after simple current-branch work | Verify, then current-branch 3-option finish |
| "마무리" after worktree/feature branch work | Verify, then `superpowers:finishing-a-development-branch` |
