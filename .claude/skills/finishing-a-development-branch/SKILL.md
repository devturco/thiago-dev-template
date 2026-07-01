---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to ship via merge or PR. Default outcome: push + create PR (Option 2).
---

# Finishing a Development Branch

Verify tests → Detect environment → **Push and create PR by default** → Clean up.

**Default outcome (NOT a menu choice):** at the end of any implementation, work must be **pushed to origin and visible on GitHub as a Pull Request**. Presenting merge/PR as one of four options is no longer acceptable — the user cannot review code that only exists locally.

## The Process

### Step 1: Verify Tests

Before shipping, verify tests pass:
```bash
bun typecheck
bun check
bun test
```

If any fail, **stop**. Don't proceed.

### Step 2: Detect Environment

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir 2>/dev/null)" && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir 2>/dev/null)" && pwd -P)
```

This determines cleanup approach:

| State | Cleanup |
|---|---|
| `GIT_DIR == GIT_COMMON` (normal repo) | No worktree to clean up |
| `GIT_DIR != GIT_COMMON`, named branch | Provenance-based cleanup |

### Step 3: Determine Base Branch

```bash
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

### Step 4: Ship (Default = Push + PR)

**Mandatory default — DO NOT SKIP. Run this:**

```bash
git push -u origin HEAD
gh pr create --fill --base main
```

Report the PR URL to the user.

**Only present the menu when:**
- User explicitly asked "show me my options"
- Worktree state is genuinely ambiguous (detached HEAD, uncommitted work from unknown source)
- This is a one-off task (not part of a multi-task plan)

In all other cases, push + PR yourself.

### Step 5: Cleanup (Only for merge/discard)

For worktrees under `.worktrees/`:
```bash
MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
cd "$MAIN_ROOT"
git worktree remove "$WORKTREE_PATH"
git worktree prune
```

For Options 2 (push + PR) and 3 (keep), **don't cleanup** — user needs the worktree to iterate on PR feedback.

## Common Mistakes

- **Telling the user "I'll create the PR when you ask"** — agent ends a 22-commit feature with no push, no PR, no GitHub visibility. User reaction: "por que tudo isso não veio pra PULL REQUEST? torne padrão isso."
- **Cleaning up worktree for push+PR** — remove worktree user needs to iterate
- **Deleting branch before removing worktree** — `git branch -d` fails because worktree still references the branch
- **Running `git worktree remove` from inside the worktree** — fails silently; `cd` to main repo root first

## Red Flags

**Never:**
- Proceed with failing tests
- Merge without verifying tests on result
- Force-push without explicit request
- Remove a worktree before confirming merge success