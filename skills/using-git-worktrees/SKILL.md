---
name: using-git-worktrees
description: Use when starting non-trivial feature work, parallel panel work, branch-isolated work, or implementation plans that may need a separate workspace
---

# Using Git Worktrees

## Overview

Ensure non-trivial work happens in an isolated workspace, while simple edits can stay on the current branch. Prefer your platform's native worktree tools. Fall back to manual git worktrees only when no native tool is available.

**Core principle:** Classify scope first. Keep simple edits in place. Isolate non-trivial work. Detect existing isolation before creating anything. Then use native tools. Then fall back to git. Never fight the harness.

**Branch base principle:** New isolated branches must start from `main` or `master`, not from the currently checked-out branch, unless the user explicitly asks to branch from current HEAD.

**Announce at start:** "I'm using the using-git-worktrees skill to decide whether this work needs an isolated workspace."

## Step 0: Classify Work Scope

**Before creating a worktree, decide whether the work deserves isolation.**

Stay on the current branch for simple edits:
- User explicitly asks for a small change on the current branch
- Single-file or narrow documentation/config/text changes
- Typo, copy, comments, imports, formatting, or obvious one-line fixes
- Inspection, status checks, or read-only analysis

Use an isolated worktree for non-trivial work:
- Multiple files, multiple modules, or unclear blast radius
- Feature work, bug fixes, refactors, UI redesign, algorithm changes, migrations, or dependency changes
- Parallel panel work where two branches must stay checked out at the same time
- Any implementation plan, TDD cycle, or work expected to produce commits/PRs
- Any task where switching branches would disrupt uncommitted work

If scope is ambiguous, ask one concise question: "Is this a quick current-branch edit, or should I isolate it in a worktree?"

If it is a simple current-branch edit, report: "This is a simple edit; staying on the current branch." Then stop this skill and continue in place.

## Step 1: Detect Existing Isolation

**Before creating anything, check if you are already in an isolated workspace.**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Submodule guard:** `GIT_DIR != GIT_COMMON` is also true inside git submodules. Before concluding "already in a worktree," verify you are not in a submodule:

```bash
# If this returns a path, you're in a submodule, not a worktree — treat as normal repo
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**If `GIT_DIR != GIT_COMMON` (and not a submodule):** You are already in a linked worktree. Skip to Step 4 (Project Setup). Do NOT create another worktree.

Report with branch state:
- On a branch: "Already in isolated workspace at `<path>` on branch `<name>`."
- Detached HEAD: "Already in isolated workspace at `<path>` (detached HEAD, externally managed). Branch creation needed at finish time."

**If `GIT_DIR == GIT_COMMON` (or in a submodule):** You are in a normal repo checkout.

Has the user already indicated their worktree preference in your instructions or by asking for non-trivial/parallel work? If not, ask for consent before creating a worktree:

> "Would you like me to set up an isolated worktree? It protects your current branch from changes."

Honor any existing declared preference without asking. If the user declines consent, work in place and skip to Step 4.

## Step 2: Create Isolated Workspace

**You have two mechanisms. Try them in this order.**

### 2a. Native Worktree Tools (preferred)

The user has asked for an isolated workspace (Step 1 consent). Do you already have a way to create a worktree? It might be a tool with a name like `EnterWorktree`, `WorktreeCreate`, a `/worktree` command, or a `--worktree` flag. If you do, configure it to create the branch from the Base Branch Rule below, then skip to Step 4.

Native tools handle directory placement, branch creation, and cleanup automatically. Using `git worktree add` when you have a native tool creates phantom state your harness can't see or manage. If the native tool cannot choose a base/source ref and would branch from current HEAD, use the git fallback instead.

Only proceed to Step 2b if you have no native worktree tool available.

### 2b. Git Worktree Fallback

**Only use this if Step 2a does not apply** — you have no native worktree tool available. Create a worktree manually using git.

#### Directory Selection

Follow this priority order. Explicit user preference always beats observed filesystem state.

1. **Check your instructions for a declared worktree directory preference.** If the user has already specified one, use it without asking.

2. **Check for an existing project-local worktree directory:**
   ```bash
   ls -d .worktrees 2>/dev/null     # Preferred (hidden)
   ls -d worktrees 2>/dev/null      # Alternative
   ```
   If found, use it. If both exist, `.worktrees` wins.

3. **Check for an existing global directory:**
   ```bash
   project=$(basename "$(git rev-parse --show-toplevel)")
   ls -d ~/.config/superpowers/worktrees/$project 2>/dev/null
   ```
   If found, use it (backward compatibility with legacy global path).

4. **If there is no other guidance available**, default to `.worktrees/` at the project root.

#### Safety Verification (project-local directories only)

**MUST verify directory is ignored before creating worktree:**

```bash
git check-ignore -q .worktrees 2>/dev/null || git check-ignore -q worktrees 2>/dev/null
```

**If NOT ignored:** Add to .gitignore, commit the change, then proceed.

**Why critical:** Prevents accidentally committing worktree contents to repository.

Global directories (`~/.config/superpowers/worktrees/`) need no verification.

#### Base Branch Rule

For native tools and git fallback, create the new branch from a `main`/`master` base ref:

1. Prefer an updated remote base: `origin/main`, then `origin/master`.
2. Fall back to local branches: `main`, then `master`.
3. If none exists, stop and ask which base branch to use.
4. Do not switch the current checkout just to create the branch, especially if it has uncommitted changes.

#### Create the Worktree

```bash
project=$(basename "$(git rev-parse --show-toplevel)")

# Prefer a fresh remote base when origin exists; fall back to local base refs.
git remote get-url origin >/dev/null 2>&1 && git fetch --prune origin || true
if git show-ref --verify --quiet refs/remotes/origin/main; then
  BASE_REF=origin/main
elif git show-ref --verify --quiet refs/remotes/origin/master; then
  BASE_REF=origin/master
elif git show-ref --verify --quiet refs/heads/main; then
  BASE_REF=main
elif git show-ref --verify --quiet refs/heads/master; then
  BASE_REF=master
else
  echo "No main/master base ref found. Ask the user which base branch to use."
  exit 1
fi

# Determine path based on chosen location
# For project-local: path="$LOCATION/$BRANCH_NAME"
# For global: path="~/.config/superpowers/worktrees/$project/$BRANCH_NAME"

git worktree add "$path" -b "$BRANCH_NAME" "$BASE_REF"
cd "$path"
```

Never omit `"$BASE_REF"` from the `git worktree add` command; without it, Git branches from the current HEAD.

**Sandbox fallback:** If `git worktree add` fails with a permission error (sandbox denial), tell the user the sandbox blocked worktree creation and you're working in the current directory instead. Then run setup and baseline tests in place.

## Step 3: Enter the Isolated Workspace

After creating or selecting a worktree, run all further commands inside that worktree path. Do not continue implementation from the original checkout.

For parallel panel work, tell the user which panel should `cd` into which worktree path.

## Step 4: Project Setup

Auto-detect and run appropriate setup:

```bash
# Node.js
if [ -f package.json ]; then npm install; fi

# Rust
if [ -f Cargo.toml ]; then cargo build; fi

# Python
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

## Step 5: Verify Clean Baseline

Run tests to ensure workspace starts clean:

```bash
# Use project-appropriate command
npm test / cargo test / pytest / go test ./...
```

**If tests fail:** Report failures, ask whether to proceed or investigate.

**If tests pass:** Report ready.

### Report

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

## Quick Reference

| Situation | Action |
|-----------|--------|
| Simple current-branch edit | Stay in place; do not create a worktree |
| Ambiguous scope | Ask quick edit vs isolated worktree |
| Non-trivial work | Create or enter a worktree |
| Parallel panel work | Use separate worktrees and branches per panel |
| Already in linked worktree | Skip creation (Step 1) |
| In a submodule | Treat as normal repo (Step 1 guard) |
| Native worktree tool available | Use it (Step 2a) |
| No native tool | Git worktree fallback (Step 2b) |
| New isolated branch base | Prefer `origin/main`, then `origin/master`, then local `main`, then local `master` |
| `.worktrees/` exists | Use it (verify ignored) |
| `worktrees/` exists | Use it (verify ignored) |
| Both exist | Use `.worktrees/` |
| Neither exists | Check instruction file, then default `.worktrees/` |
| Global path exists | Use it (backward compat) |
| Directory not ignored | Add to .gitignore + commit |
| Permission error on create | Sandbox fallback, work in place |
| Tests fail during baseline | Report failures + ask |
| No package.json/Cargo.toml | Skip dependency install |

## Common Mistakes

### Fighting the harness

- **Problem:** Using `git worktree add` when the platform already provides isolation
- **Fix:** Step 1 detects existing isolation. Step 2a defers to native tools.

### Skipping detection

- **Problem:** Creating a nested worktree inside an existing one
- **Fix:** Always run Step 1 before creating anything

### Over-isolating tiny changes

- **Problem:** Creating branches and worktrees for simple edits adds cleanup overhead
- **Fix:** Step 0 keeps small current-branch edits in place

### Branching from the wrong base

- **Problem:** `git worktree add "$path" -b "$BRANCH_NAME"` creates the branch from the current HEAD
- **Fix:** Always resolve `BASE_REF` and run `git worktree add "$path" -b "$BRANCH_NAME" "$BASE_REF"`

### Skipping ignore verification

- **Problem:** Worktree contents get tracked, pollute git status
- **Fix:** Always use `git check-ignore` before creating project-local worktree

### Assuming directory location

- **Problem:** Creates inconsistency, violates project conventions
- **Fix:** Follow priority: existing > global legacy > instruction file > default

### Proceeding with failing tests

- **Problem:** Can't distinguish new bugs from pre-existing issues
- **Fix:** Report failures, get explicit permission to proceed

## Red Flags

**Never:**
- Create a worktree for a clearly simple current-branch edit
- Create a worktree when Step 1 detects existing isolation
- Use `git worktree add` when you have a native worktree tool (e.g., `EnterWorktree`). This is the #1 mistake — if you have it, use it.
- Skip Step 2a by jumping straight to Step 2b's git commands
- Create an isolated feature branch from the current branch unless the user explicitly asks for that base
- Run `git worktree add "$path" -b "$BRANCH_NAME"` without a `BASE_REF`
- Create worktree without verifying it's ignored (project-local)
- Skip baseline test verification
- Proceed with failing tests without asking

**Always:**
- Classify simple vs non-trivial scope first
- Run Step 1 detection before creating anything
- Resolve `BASE_REF` from `origin/main`, `origin/master`, `main`, or `master` before branch creation
- Prefer native tools over git fallback
- Follow directory priority: existing > global legacy > instruction file > default
- Verify directory is ignored for project-local
- Auto-detect and run project setup
- Verify clean test baseline
